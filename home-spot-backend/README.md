# HomeSpot — Backend API

NestJS REST API for the HomeSpot real estate platform.

---

## Tech Stack

| Package | Purpose |
|---|---|
| NestJS | Framework |
| TypeORM | ORM |
| MySQL | Database |
| JWT + Passport | Authentication |
| bcrypt | Password hashing |
| multer | Image uploads to local disk |

---

## Setup

```bash
npm install
cp .env.example .env    # fill in your credentials
npm run start:dev
```

---

## Environment Variables

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

---

## Database

Tables are **auto-created** by TypeORM on first run (`synchronize: true` in dev).

| Table | Key Columns |
|---|---|
| `users` | id, email, password *(hashed)*, displayName, role `user\|admin`, disabled |
| `adverts` | id, description, adType, estateType, surfaceArea, nbRooms, location, price, imageURL, createdById |

> ⚠️ Set `synchronize: false` before going to production and use TypeORM migrations instead.

### First-time setup

1. Open phpMyAdmin → **New** → name: `HomeSpot` · collation: `utf8mb4_unicode_ci` → **Create**
2. Start the server — tables appear automatically
3. Seed the first admin user:

```bash
ADMIN_EMAIL=admin@homespot.tn \
ADMIN_PASSWORD=Admin1234! \
npx ts-node scripts/seed-admin.ts
```

---

## API Reference

### Auth

All endpoints are public except `/auth/me` and `/auth/set-role`.

| Method | Path | Auth | Body | Returns |
|---|---|---|---|---|
| `POST` | `/auth/register` | Public | `{ name, email, password }` | `{ access_token, user }` |
| `POST` | `/auth/login` | Public | `{ email, password }` | `{ access_token, user }` |
| `GET` | `/auth/me` | JWT | — | Current user |
| `POST` | `/auth/set-role` | Admin | `{ email, role }` | Confirmation |

### Adverts

| Method | Path | Auth | Description |
|---|---|---|---|
| `GET` | `/adverts` | Public | Paginated list with filters |
| `GET` | `/adverts/:id` | Public | Single advert |
| `POST` | `/adverts` | Admin | Create — `multipart/form-data` |
| `PUT` | `/adverts/:id` | Admin | Update — `multipart/form-data` |
| `DELETE` | `/adverts/:id` | Admin | Delete + removes image from disk |

#### `GET /adverts` — Query Parameters

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

Response shape:

```json
{
  "data": [ ...adverts ],
  "meta": { "total": 142, "page": 1, "limit": 20, "totalPages": 8 }
}
```

#### `POST` / `PUT` `/adverts` — Form Fields

```
description   string    required
adType        string    "Sale" | "Rent"
estateType    string    "Apartment" | "House" | "Office" | "Field"
surfaceArea   number
nbRooms       number    omit for Field listings
location      string    one of the 10 supported Tunisian cities
price         number
image         file      JPEG · PNG · WebP · max 5 MB (optional)
```

### Users *(admin only)*

| Method | Path | Description |
|---|---|---|
| `GET` | `/users` | List all users |
| `GET` | `/users/:id` | User + their adverts |
| `PATCH` | `/users/:id` | Update `displayName` / `disabled` |
| `DELETE` | `/users/:id` | Delete user |

---

## Image Uploads

Images are saved to `./uploads/` and served as static files:

```
POST /adverts  { image: <file> }
  → disk:  ./uploads/550e8400-e29b-41d4-a716-446655440000.jpg
  → DB:    imageURL = "/uploads/550e8400-…jpg"
  → URL:   http://192.168.1.x:3000/uploads/550e8400-…jpg
```

- `PUT` with a new image **automatically deletes** the old file.
- `DELETE` on an advert **automatically deletes** its image file.

> **Decimal columns:** `surfaceArea` and `price` use a TypeORM column transformer
> to return MySQL `DECIMAL` values as `number` instead of strings.

---

## Auth Flow

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

## Production Checklist

- [ ] Set `NODE_ENV=production` and `synchronize: false` in TypeORM config
- [ ] Run `npm run build` and deploy `dist/` + `uploads/` to your server
- [ ] Use `pm2` to keep the process alive
- [ ] Put Nginx in front to serve `/uploads/` as static files directly
- [ ] Store `JWT_SECRET` in a secrets manager — never commit it
- [ ] Set up regular MySQL backups (`mysqldump` or phpMyAdmin export)
- [ ] Tighten CORS `origin` to your production domain