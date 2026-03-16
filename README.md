# HomeSpot

> Tunisia's premier real estate platform — browse, search, and manage property listings from a Flutter mobile app backed by a NestJS REST API.

**Stack:** Flutter · NestJS · TypeORM · MySQL

---

## Table of Contents

- [Project Structure](#project-structure)
- [Backend — NestJS](#backend--nestjs)
  - [Tech Stack](#tech-stack)
  - [Setup](#setup)
  - [Environment Variables](#environment-variables)
  - [Database](#database)
  - [API Reference](#api-reference)
  - [Image Uploads](#image-uploads)
  - [Auth Flow](#auth-flow)
- [Mobile App — Flutter](#mobile-app--flutter)
  - [Tech Stack](#tech-stack-1)
  - [Setup](#setup-1)
  - [Project Structure](#project-structure-1)
  - [Screens](#screens)
  - [Auth & Navigation](#auth--navigation)
  - [Image Upload Notes](#image-upload-notes)
- [Database Quick Setup](#database-quick-setup)
- [Production Checklist](#production-checklist)

---

## Project Structure

```
homespot/
├── home-spot-backend/   ← NestJS REST API
└── homespot/            ← Flutter mobile app
```

---

## Backend — NestJS

### Tech Stack

| Package | Purpose |
|---|---|
| NestJS | Framework |
| TypeORM | ORM |
| MySQL | Database |
| JWT + Passport | Authentication |
| bcrypt | Password hashing |
| multer | Image uploads to local disk |

### Setup

```bash
cd home-spot-backend
npm install
cp .env.example .env        # then fill in your credentials
npm run start:dev
```

### Environment Variables

Create a `.env` file at the root of `home-spot-backend/`:

```env
DB_HOST=localhost
DB_PORT=3306
DB_USERNAME=root
DB_PASSWORD=yourpassword
DB_NAME=HomeSpot

JWT_SECRET=<64+ random hex chars>
JWT_EXPIRES_IN=7d

UPLOAD_DIR=./uploads
PORT=3000
NODE_ENV=development
```

Generate a secure `JWT_SECRET`:

```bash
node -e "console.log(require('crypto').randomBytes(64).toString('hex'))"
```

### Database

Tables are **auto-created** by TypeORM on first run (`synchronize: true` in dev).

| Table | Key Columns |
|---|---|
| `users` | id, email, password *(hashed)*, displayName, role `user\|admin`, disabled |
| `adverts` | id, description, adType, estateType, surfaceArea, nbRooms, location, price, imageURL, createdById |

> ⚠️ Set `synchronize: false` before going to production and switch to TypeORM migrations.

#### Seed the first admin user

```bash
ADMIN_EMAIL=admin@homespot.tn \
ADMIN_PASSWORD=Admin1234! \
npx ts-node scripts/seed-admin.ts
```

### API Reference

#### Auth

All endpoints are public except `/auth/me` and `/auth/set-role`.

| Method | Path | Auth | Body | Returns |
|---|---|---|---|---|
| `POST` | `/auth/register` | Public | `{ name, email, password }` | `{ access_token, user }` |
| `POST` | `/auth/login` | Public | `{ email, password }` | `{ access_token, user }` |
| `GET` | `/auth/me` | JWT | — | Current user |
| `POST` | `/auth/set-role` | Admin | `{ email, role }` | Confirmation |

#### Adverts

| Method | Path | Auth | Description |
|---|---|---|---|
| `GET` | `/adverts` | Public | Paginated list with filters |
| `GET` | `/adverts/:id` | Public | Single advert |
| `POST` | `/adverts` | Admin | Create — `multipart/form-data` |
| `PUT` | `/adverts/:id` | Admin | Update — `multipart/form-data` |
| `DELETE` | `/adverts/:id` | Admin | Delete + removes image from disk |

**`GET /adverts` — query parameters**

```
q             string   Full-text search (description, location, type)
adType        string   Sale | Rent
estateType    string   Apartment | House | Office | Field
location      string   Exact city name
minPrice      number
maxPrice      number
minSurface    number   m²
maxSurface    number   m²
page          number   default: 1
limit         number   default: 20
```

**Response envelope**

```json
{
  "data": [ ...adverts ],
  "meta": { "total": 142, "page": 1, "limit": 20, "totalPages": 8 }
}
```

**`POST` / `PUT` `/adverts` — form fields**

```
description   string    required
adType        string    "Sale" | "Rent"
estateType    string    "Apartment" | "House" | "Office" | "Field"
surfaceArea   number
nbRooms       number    omit for Field listings
location      string    one of the 10 supported Tunisian cities
price         number
image         file      JPEG · PNG · WebP — max 5 MB (optional)
```

#### Users *(admin only)*

| Method | Path | Description |
|---|---|---|
| `GET` | `/users` | List all users |
| `GET` | `/users/:id` | User + their adverts |
| `PATCH` | `/users/:id` | Update `displayName` / `disabled` |
| `DELETE` | `/users/:id` | Delete user |

### Image Uploads

Images are stored on disk and served as static files:

```
POST /adverts  { image: <file> }
  → disk:  ./uploads/550e8400-e29b-41d4-a716-446655440000.jpg
  → DB:    imageURL = "/uploads/550e8400-…jpg"
  → URL:   http://192.168.1.x:3000/uploads/550e8400-…jpg
```

- Replacing an image on `PUT` **automatically deletes** the old file from disk.
- Deleting an advert **automatically deletes** its image file.

> **Decimal columns:** `surfaceArea` and `price` use a TypeORM column transformer to
> serialize MySQL `DECIMAL` values as JavaScript `number` instead of strings.

### Auth Flow

```
Client                            NestJS
  │                                 │
  ├── POST /auth/login ────────────>│
  │   { email, password }           │  bcrypt.compare → jwt.sign
  │<── { access_token, user } ──────┤
  │                                 │
  ├── GET /adverts ────────────────>│  No token required
  │<── { data[], meta } ────────────┤
  │                                 │
  ├── POST /adverts ───────────────>│  Authorization: Bearer <token>
  │   multipart/form-data           │  JwtAuthGuard → AdminGuard
  │<── Created advert ──────────────┤
```

---

## Mobile App — Flutter

### Tech Stack

| Package | Purpose |
|---|---|
| Flutter | Cross-platform mobile (iOS & Android) |
| Provider | State management (`AuthProvider`, `AdvertsProvider`) |
| http + http_parser | HTTP client + multipart MIME types |
| flutter_secure_storage | JWT persistence (Keychain / Keystore) |
| cached_network_image | Network image caching |
| image_picker | Device gallery access |

> No Firebase — authentication is handled entirely by the NestJS JWT backend.

### Setup

```bash
cd homespot
flutter pub get

# Run with your machine's LAN IP (not localhost)
flutter run --dart-define=API_URL=http://192.168.1.x:3000
```

The constant is read in `lib/services/api.dart`:

```dart
const _baseUrl = String.fromEnvironment(
  'API_URL',
  defaultValue: 'http://192.168.1.x:3000',
);
```

### Project Structure

```
lib/
├── main.dart                     ← Entry point, MultiProvider setup
├── navigation/
│   └── app_router.dart           ← Routes, AuthGate, AuthListener
├── models/
│   ├── advert.dart               ← Advert · AdvertMeta · AdvertFilters
│   └── user.dart
├── providers/
│   ├── auth_provider.dart        ← Login · register · logout state
│   └── adverts_provider.dart     ← Fetch · create · update · delete state
├── services/
│   └── api.dart                  ← All HTTP calls to the backend
├── screens/
│   ├── login_screen.dart
│   ├── register_screen.dart
│   ├── main_screen.dart          ← Listings, search bar, filter chips
│   ├── detail_screen.dart        ← Property detail + contact CTA
│   ├── crud_screen.dart          ← Admin — manage listings
│   └── advert_form_screen.dart   ← Admin — create / edit listing
├── widgets/
│   ├── advert_card.dart
│   ├── filter_bar.dart
│   ├── gradient_button.dart
│   ├── styled_input.dart
│   └── styled_picker.dart
└── theme/
    └── app_theme.dart            ← Colors · gradients · spacing · shadows
```

### Screens

| Screen | Route | Access | Description |
|---|---|---|---|
| Main | `/main` | Logged in | Listings, search, filter chips, infinite scroll |
| Detail | `/detail` | Logged in | Full property view, stats, contact CTA |
| Login | `/login` | Public | Email + password → JWT |
| Register | `/register` | Public | Name + email + password → auto-login |
| CRUD | `/crud` | Admin | Create, edit, delete all listings |
| Advert Form | `/advert-form` | Admin | Listing form with image picker |

### Auth & Navigation

#### Startup flow

```
AuthProvider._initialize()
  → read token from flutter_secure_storage
  → GET /auth/me
  ├── valid   → _user set → AuthGate pushes /main
  └── invalid → token cleared → AuthGate pushes /login
```

#### Login / Register

```
POST /auth/login  (or /auth/register)
  → token saved to flutter_secure_storage
  → _user set in AuthProvider
  → Navigator.pushNamedAndRemoveUntil('/main')
```

#### Sign out

```
AuthProvider.signOut()
  → token cleared, _user = null, notifyListeners()
  → AuthListener (wrapping protected screens) catches change
  → Navigator.pushNamedAndRemoveUntil('/login')
```

#### Why AuthGate + AuthListener?

`MaterialApp(home:)` only respects its value on the **first render** — it cannot drive
navigation reactively after that. HomeSpot solves this with two small widgets:

- **`AuthGate`** — used as the stable `home:`. Fires once via `addPostFrameCallback`
  and imperatively pushes to `/main` or `/login`.
- **`AuthListener`** — wraps protected screens. Listens to `AuthProvider` and
  redirects to `/login` the instant `isLoggedIn` becomes `false`.

### Image Upload Notes

Images are picked from the gallery via `image_picker` and sent as `multipart/form-data`.
The `contentType` **must** be set explicitly — without it, multer rejects the file with
`"Only image files are allowed"`:

```yaml
# pubspec.yaml
dependencies:
  http_parser: ^4.0.2
```

```dart
import 'package:http_parser/http_parser.dart';

final ext = imageFile.path.split('.').last.toLowerCase();
final mimeType = switch (ext) {
  'png'  => 'png',
  'gif'  => 'gif',
  'webp' => 'webp',
  _      => 'jpeg',
};

request.files.add(await http.MultipartFile.fromPath(
  'image',
  imageFile.path,
  contentType: MediaType('image', mimeType),
));
```

---

## Database Quick Setup

1. Open **phpMyAdmin** — usually `http://localhost/phpmyadmin`
2. Click **New** in the left sidebar
3. Set database name to `HomeSpot`, collation `utf8mb4_unicode_ci`
4. Click **Create**
5. Start the NestJS server — all tables appear automatically

To browse data: `HomeSpot` → `adverts` or `users` → **Browse**

---

## Production Checklist

**Backend**
- [ ] Set `NODE_ENV=production` and `synchronize: false` in TypeORM config
- [ ] Run `npm run build` and deploy `dist/` + `uploads/` to your server
- [ ] Use `pm2` (or equivalent) to keep the process alive
- [ ] Put Nginx in front to serve `/uploads/` as static files directly
- [ ] Store `JWT_SECRET` in a secrets manager — never commit it
- [ ] Set up regular MySQL backups (`mysqldump` or phpMyAdmin export)
- [ ] Tighten CORS `origin` to your production domain

**Flutter**
- [ ] Set `API_URL` to your production server address
- [ ] Build release APK: `flutter build apk --dart-define=API_URL=https://api.homespot.tn`
- [ ] Build release IPA: `flutter build ipa --dart-define=API_URL=https://api.homespot.tn`
- [ ] Test image upload on a real device before shipping

---

# Author
**Yassine ELKEFFI**