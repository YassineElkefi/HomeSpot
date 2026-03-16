# HomeSpot — Mobile App

Flutter mobile client for the HomeSpot real estate platform.

---

## Tech Stack

| Package | Purpose |
|---|---|
| Flutter | Cross-platform mobile (iOS & Android) |
| Provider | State management |
| http + http_parser | HTTP client + multipart MIME types |
| flutter_secure_storage | JWT persistence (Keychain / Keystore) |
| cached_network_image | Network image caching |
| image_picker | Device gallery access |

---

## Setup

```bash
flutter pub get

# Run on a device or emulator — use your machine's LAN IP, not localhost
flutter run --dart-define=API_URL=http://192.168.1.x:3000
```

The API base URL is read at compile time in `lib/services/api.dart`:

```dart
const _baseUrl = String.fromEnvironment(
  'API_URL',
  defaultValue: 'http://192.168.1.x:3000',
);
```

---

## Project Structure

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
│   ├── crud_screen.dart          ← Admin — manage all listings
│   └── advert_form_screen.dart   ← Admin — create / edit a listing
├── widgets/
│   ├── advert_card.dart
│   ├── filter_bar.dart
│   ├── gradient_button.dart
│   ├── styled_input.dart
│   └── styled_picker.dart
└── theme/
    └── app_theme.dart            ← Colors · gradients · spacing · shadows
```

---

## Screens

| Screen | Route | Access | Description |
|---|---|---|---|
| Main | `/main` | Logged in | Listings, search, filter chips, infinite scroll |
| Detail | `/detail` | Logged in | Full property view, stats, contact CTA |
| Login | `/login` | Public | Email + password → JWT |
| Register | `/register` | Public | Name + email + password → auto-login |
| CRUD | `/crud` | Admin only | Create, edit, delete all listings |
| Advert Form | `/advert-form` | Admin only | Listing form with image picker |

---

## Auth & Navigation

### Startup

```
AuthProvider._initialize()
  → read token from flutter_secure_storage
  → GET /auth/me
  ├── valid   → _user set → AuthGate pushes /main
  └── invalid → token cleared → AuthGate pushes /login
```

### Login / Register

```
POST /auth/login  (or /auth/register)
  → token saved to flutter_secure_storage
  → _user set in AuthProvider
  → Navigator.pushNamedAndRemoveUntil('/main')
```

### Sign Out

```
AuthProvider.signOut()
  → token cleared · _user = null · notifyListeners()
  → AuthListener catches the change
  → Navigator.pushNamedAndRemoveUntil('/login')
```

### AuthGate + AuthListener

`MaterialApp(home:)` only respects its value on the first render and cannot drive
navigation reactively. Two lightweight widgets solve this:

- **`AuthGate`** — the stable `home:` widget. Uses `addPostFrameCallback` to
  imperatively push to `/main` or `/login` on startup.
- **`AuthListener`** — wraps every protected screen. Listens to `AuthProvider`
  and redirects to `/login` the moment `isLoggedIn` becomes `false`.

---

## Image Uploads

Images are sent as `multipart/form-data`. The `contentType` **must** be set
explicitly via `http_parser` — without it the backend rejects the upload:

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

## Build for Release

```bash
# Android
flutter build apk --dart-define=API_URL=https://api.homespot.tn

# iOS
flutter build ipa --dart-define=API_URL=https://api.homespot.tn
```