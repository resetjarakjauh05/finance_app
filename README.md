# Financial App - Aplikasi Keuangan Personal

Aplikasi mobile/web untuk tracking keuangan personal dengan Flutter & Firebase.

## Features

- ✅ **Authentication** - Firebase Auth (email/password)
- ✅ **Transaction Management** - CRUD transaksi dengan offline support
- ✅ **Payment Methods** - Kelola berbagai metode pembayaran
- ✅ **Bills Tracking** - Track tagihan/hutang dengan reminder
- ✅ **Custody Tracking** - Track penitipan uang
- ✅ **Offline Support** - SQLite local database dengan auto-sync
- ✅ **Reports & Analytics** - Laporan bulanan dengan grafik
- ✅ **Multi-device Sync** - Real-time sync via Firestore
- ✅ **Bahasa Indonesia** - Default UI dalam Bahasa Indonesia

## Tech Stack

**Frontend:**
- Flutter 3.x
- Riverpod (State Management)
- SQLite (Offline storage)
- Material 3 UI

**Backend:**
- Firebase Auth
- Cloud Firestore
- Firebase Analytics
- Firebase Crashlytics

## Project Structure

```
lib/
├── data/
│   ├── models/         # Data models
│   ├── repositories/   # Repository implementations
│   └── services/       # Firebase & SQLite services
├── domain/
│   ├── models/         # Domain models
│   └── use_cases/      # Business logic
├── ui/
│   ├── core/           # Shared widgets, themes
│   └── features/       # Feature screens
│       ├── auth/
│       ├── dashboard/
│       ├── transactions/
│       ├── bills/
│       ├── custody/
│       ├── reports/
│       └── settings/
├── l10n/               # Localization files
├── firebase_options.dart
└── main.dart
```

## Setup Instructions

### Prerequisites

- Flutter SDK 3.5.0+
- Dart 3.5.0+
- Firebase CLI (optional, for full setup)
- Android Studio / VS Code

### Installation

1. **Clone repository**
```bash
git clone <repository-url>
cd financial
```

2. **Install dependencies**
```bash
flutter pub get
```

3. **Configure Firebase**

**Option A: Manual (Current)**
- Update `lib/firebase_options.dart` with your Firebase project credentials
- Get credentials from Firebase Console:
  - Go to Project Settings > General
  - Add apps (Android/iOS/Web)
  - Copy API keys and App IDs

**Option B: Automatic (Requires Firebase CLI)**
```bash
# Install Firebase CLI first
npm install -g firebase-tools

# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Configure Firebase
flutterfire configure --project=keuangan-a80e6
```

4. **Run code generation**
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

5. **Run the app**
```bash
flutter run
```

## Firebase Configuration

### Required Firebase Services

1. **Authentication**
   - Enable Email/Password provider in Firebase Console

2. **Firestore Database**
   - Create database in production mode
   - Deploy security rules (see `firestore.rules`)

3. **Firebase Storage** (optional, for future features)
   - Enable Cloud Storage

### Firestore Security Rules

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId}/{document=**} {
      allow read, write: if request.auth.uid == userId;
    }
    match /transactions/{userId}/{document=**} {
      allow read, write: if request.auth.uid == userId;
    }
    match /paymentMethods/{userId}/{document=**} {
      allow read, write: if request.auth.uid == userId;
    }
    match /bills/{userId}/{document=**} {
      allow read, write: if request.auth.uid == userId;
    }
    match /custody/{userId}/{document=**} {
      allow read, write: if request.auth.uid == userId;
    }
  }
}
```

## Development Phases

- [x] Phase 0: Project setup, Firebase config
- [ ] Phase 1: Authentication (F1)
- [ ] Phase 2: Payment Methods (F4)
- [ ] Phase 3: SQLite Setup (F8)
- [ ] Phase 4: Transaction CRUD (F3)
- [ ] Phase 5: Sync Engine (F8)
- [ ] Phase 6: Dashboard (F2)
- [ ] Phase 7: Bills Tracking (F5)
- [ ] Phase 8: Custody Tracking (F6)
- [ ] Phase 9: Reports & Analytics (F7)
- [ ] Phase 10: Search & Filter (F9)
- [ ] Phase 11: Settings (F10)
- [ ] Phase 12: Testing
- [ ] Phase 13: Data Migration
- [ ] Phase 14: UI/UX Polish
- [ ] Phase 15: Alpha/Beta Testing
- [ ] Phase 16: Production Deployment

## Testing

```bash
# Run unit tests
flutter test

# Run integration tests
flutter test integration_test/

# Run with coverage
flutter test --coverage
```

## Build

```bash
# Android APK
flutter build apk --release

# Android App Bundle
flutter build appbundle --release

# iOS
flutter build ios --release

# Web
flutter build web --release
```

## Contributing

This is a personal project. Contributions are welcome via pull requests.

## License

Private - All rights reserved

## Support

For issues and questions, please open an issue in the repository.
