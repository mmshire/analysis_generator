# Dalbo — Food Delivery App Setup Guide

> Built for Hargeisa, Somaliland. Works on iOS and Android.

---

## What you need before starting

| Tool | What it is | Download |
|------|-----------|---------|
| Flutter | Builds the mobile app | https://flutter.dev/docs/get-started/install |
| Node.js (v18+) | Runs the backend server | https://nodejs.org → LTS version |
| PostgreSQL (v14+) | The database | https://www.postgresql.org/download |
| Android Studio | For Android emulator | https://developer.android.com/studio |

---

## Step 1 — Install Flutter

### Windows
1. Download Flutter SDK from https://flutter.dev/docs/get-started/install/windows
2. Extract the zip to `C:\flutter`
3. Add `C:\flutter\bin` to your PATH environment variable
4. Open a new Command Prompt and run:
   ```
   flutter doctor
   ```
   Fix anything it warns about (usually Android licenses — run `flutter doctor --android-licenses`)

### Mac
```bash
brew install --cask flutter
flutter doctor
```

---

## Step 2 — Set up PostgreSQL database

```bash
# Log in to PostgreSQL
psql -U postgres

# Create the database (inside psql prompt)
CREATE DATABASE dalbo_db;
\q

# Run the schema (creates all tables)
psql -U postgres -d dalbo_db -f dalbo_backend/src/db/schema.sql

# Load the 5 sample restaurants
psql -U postgres -d dalbo_db -f dalbo_backend/src/db/seed.sql
```

---

## Step 3 — Start the backend

```bash
cd dalbo_backend

# Install packages (one-time)
npm install

# Create your environment file
cp .env.example .env
```

Open `.env` and set your database password:
```
DATABASE_URL=postgresql://postgres:YOUR_POSTGRES_PASSWORD@localhost:5432/dalbo_db
JWT_SECRET=type-any-long-random-string-here-like-abc123xyz
ADMIN_SECRET=admin-secret-for-adding-restaurants
OTP_DEV_MODE=true
```

Then start the server:
```bash
npm run dev
```

You should see:
```
🚀 Dalbo API running → http://localhost:3000
```

Test it works — open http://localhost:3000/health in your browser. You should see `{"status":"ok"}`.

---

## Step 4 — Create the Flutter project

```bash
# Go to the project folder
cd ..   (back to the dalbo_app parent folder)

# Create the Flutter project (this sets up Android/iOS files)
flutter create dalbo_app --org com.dalbo.food

# The lib/ folder and pubspec.yaml are already written for you.
# Flutter create makes the Android/iOS wrapper files.
```

---

## Step 5 — Run the Flutter app

```bash
cd dalbo_app

# Download Flutter packages
flutter pub get

# Generate localization files (for multi-language support)
flutter gen-l10n

# Start an Android emulator in Android Studio first, then:
flutter run
```

### Testing on a real phone

1. Enable Developer Mode on your phone:
   - Android: Settings → About Phone → tap "Build number" 7 times
   - Then go to Settings → Developer Options → enable USB Debugging
2. Connect via USB cable
3. Run `flutter run` — it will list your device and install the app

---

## Step 6 — Test the app end-to-end

1. Open the app — you should see the Dalbo splash screen
2. Go through onboarding (3 swipeable screens)
3. Enter any phone number (e.g. `+252 63 000 0000`)
4. When asked for OTP code, enter **123456** (dev mode — always works)
5. You're logged in! You should see 5 Hargeisa restaurants
6. Tap a restaurant → add items to cart → go to cart
7. Enter delivery address → Place Order
8. You'll land on the Order Tracking screen

---

## API reference (for testing manually)

Use the free app **Postman** or **Insomnia** to test the API:

### Send OTP
```
POST http://localhost:3000/api/auth/send-otp
Body: { "phone": "+252630000000" }
```

### Verify OTP (dev: use 123456)
```
POST http://localhost:3000/api/auth/verify-otp
Body: { "phone": "+252630000000", "code": "123456" }
Response: { "token": "...", "user": { "id": 1, "phone": "..." } }
```

### Get restaurants
```
GET http://localhost:3000/api/restaurants
```

### Get restaurant + menu
```
GET http://localhost:3000/api/restaurants/1
```

### Place order (needs the token from login)
```
POST http://localhost:3000/api/orders
Header: Authorization: Bearer <your_token>
Body: {
  "restaurant_id": 1,
  "items": [{ "menu_item_id": 1, "quantity": 2 }],
  "delivery_address": "26 June Road, Hargeisa",
  "payment_method": "cash_on_delivery"
}
```

### Add a restaurant (admin)
```
POST http://localhost:3000/api/admin/restaurants
Header: x-admin-secret: admin-secret-for-adding-restaurants
Body: {
  "name": "My New Restaurant",
  "cuisine_type": "Somali",
  "delivery_time_min": 25,
  "address": "Airport Road, Hargeisa",
  "is_open": true
}
```

### Update order status (admin/rider)
```
PATCH http://localhost:3000/api/orders/1/status
Header: Authorization: Bearer <token>
Body: { "status": "preparing" }
```

Valid statuses in order: `placed` → `accepted` → `preparing` → `rider_on_the_way` → `delivered`

---

## Project structure explained (for beginners)

```
dalbo_backend/         ← The server (runs on your computer / cloud)
├── src/
│   ├── app.js         ← Express app, all routes registered here
│   ├── server.js      ← Starts the server on port 3000
│   ├── db/
│   │   ├── index.js   ← Database connection
│   │   ├── schema.sql ← Table definitions (run once)
│   │   └── seed.sql   ← Sample restaurant data (run once)
│   ├── middleware/
│   │   └── auth.js    ← Checks JWT tokens on protected routes
│   └── routes/
│       ├── auth.js         ← /api/auth/* (login, OTP)
│       ├── restaurants.js  ← /api/restaurants/*
│       ├── orders.js       ← /api/orders/*
│       └── admin.js        ← /api/admin/* (add restaurants, etc.)

dalbo_app/lib/         ← The Flutter mobile app
├── main.dart          ← App entry point, all screens registered
├── core/
│   ├── theme.dart     ← Orange colour theme, fonts, button styles
│   ├── constants.dart ← API URL, exchange rate (USD → SLS)
│   └── routes.dart    ← Screen route names
├── models/            ← Data structures (Restaurant, MenuItem, Order, CartItem)
├── providers/         ← State management:
│   ├── auth_provider.dart   ← Login state, token storage
│   ├── cart_provider.dart   ← Cart items, totals
│   └── order_provider.dart  ← Order history, active order
├── services/
│   ├── api_service.dart     ← All HTTP calls to the backend
│   └── storage_service.dart ← Saves token to phone storage
├── screens/           ← All 7 screens
└── widgets/           ← Reusable UI components
```

---

## Phase 2 checklist (next steps)

- [ ] Plug in WaafiPay for Zaad / eDahab payments (`src/routes/orders.js` has the payment_method field ready)
- [ ] Add SMS provider for real OTPs (replace the `sendSms()` stub in `src/routes/auth.js`)
- [ ] Add Firebase push notifications (FCM tokens table already created in DB)
- [ ] Add a Rider app (separate Flutter project, uses the same backend)
- [ ] Add a web admin dashboard
- [ ] Add Google Maps for live delivery tracking
- [ ] Add Somali translation (strings already in `lib/l10n/app_so.arb`)

---

## Common issues

| Problem | Fix |
|---------|-----|
| `flutter doctor` shows Android issues | Run `flutter doctor --android-licenses` and accept all |
| `Connection refused` in app | Make sure the backend is running (`npm run dev`) |
| App can't reach backend on real phone | Change `apiBaseUrl` in `lib/core/constants.dart` to your computer's WiFi IP (e.g. `http://192.168.1.100:3000`) |
| OTP not working | Set `OTP_DEV_MODE=true` in `.env` and use code `123456` |
| Database error | Check your `DATABASE_URL` in `.env` has the right password |
