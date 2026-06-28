# Setup Guide - Financial App

## ⚠️ IMPORTANT: Firebase Configuration

Sebelum menjalankan aplikasi, Anda **HARUS** mengkonfigurasi Firebase terlebih dahulu.

### Langkah 1: Setup Firebase Project

1. **Buka Firebase Console**
   - Kunjungi https://console.firebase.google.com
   - Pilih project `keuangan-a80e6` (atau buat baru jika belum ada)

2. **Enable Firebase Services**
   - **Authentication**: 
     - Klik Authentication > Get Started
     - Enable "Email/Password" provider
   - **Firestore Database**:
     - Klik Firestore Database > Create Database
     - Pilih "Start in production mode"
     - Pilih lokasi server (asia-southeast2 recommended)
   - **Analytics** (optional): Enable jika ingin tracking

### Langkah 2: Add Apps to Firebase Project

#### Android App

1. Di Firebase Console, klik "Add app" > Android
2. **Android package name**: `com.keuangan.financial_app`
3. Download `google-services.json`
4. Copy ke `android/app/google-services.json`
5. Salin **API Key** dan **App ID** untuk langkah selanjutnya

#### iOS App (Optional)

1. Di Firebase Console, klik "Add app" > iOS
2. **iOS bundle ID**: `com.keuangan.financialApp`
3. Download `GoogleService-Info.plist`
4. Copy ke `ios/Runner/GoogleService-Info.plist`
5. Salin **API Key** dan **App ID**

#### Web App (Optional)

1. Di Firebase Console, klik "Add app" > Web
2. Daftarkan app dengan nama "Financial App Web"
3. Salin **API Key**, **App ID**, **Project ID**, dll

### Langkah 3: Update `firebase_options.dart`

Buka file `lib/firebase_options.dart` dan ganti placeholder dengan kredensial asli:

```dart
// ANDROID
static const FirebaseOptions android = FirebaseOptions(
  apiKey: 'AIzaSyXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX', // Ganti dengan API Key Android
  appId: '1:123456789:android:abcdef1234567890',    // Ganti dengan App ID Android
  messagingSenderId: '123456789',                   // Ganti dengan Messaging Sender ID
  projectId: 'keuangan-a80e6',
  storageBucket: 'keuangan-a80e6.firebasestorage.app',
);

// IOS
static const FirebaseOptions ios = FirebaseOptions(
  apiKey: 'AIzaSyXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX', // Ganti dengan API Key iOS
  appId: '1:123456789:ios:abcdef1234567890',        // Ganti dengan App ID iOS
  messagingSenderId: '123456789',
  projectId: 'keuangan-a80e6',
  storageBucket: 'keuangan-a80e6.firebasestorage.app',
  iosBundleId: 'com.keuangan.financialApp',
);

// WEB
static const FirebaseOptions web = FirebaseOptions(
  apiKey: 'AIzaSyXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX', // Ganti dengan API Key Web
  appId: '1:123456789:web:abcdef1234567890',        // Ganti dengan App ID Web
  messagingSenderId: '123456789',
  projectId: 'keuangan-a80e6',
  authDomain: 'keuangan-a80e6.firebaseapp.com',
  storageBucket: 'keuangan-a80e6.firebasestorage.app',
);
```

### Langkah 4: Deploy Firestore Security Rules

1. **Buat file `firestore.rules` di root project:**

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // User data
    match /users/{userId} {
      allow read, write: if request.auth.uid == userId;
    }
    
    // Transactions
    match /transactions/{userId}/{transactionId} {
      allow read, write: if request.auth.uid == userId;
    }
    
    // Payment Methods
    match /paymentMethods/{userId}/{methodId} {
      allow read, write: if request.auth.uid == userId;
    }
    
    // Bills
    match /bills/{userId}/{billId} {
      allow read, write: if request.auth.uid == userId;
    }
    
    // Custody
    match /custody/{userId}/{custodyId} {
      allow read, write: if request.auth.uid == userId;
    }
    
    // Monthly Snapshots
    match /monthlySnapshots/{userId}/{yearMonth} {
      allow read, write: if request.auth.uid == userId;
    }
  }
}
```

2. **Deploy via Firebase Console:**
   - Buka Firestore Database > Rules
   - Paste rules di atas
   - Klik "Publish"

**ATAU deploy via Firebase CLI:**
```bash
firebase deploy --only firestore:rules
```

### Langkah 5: Jalankan Aplikasi

```bash
# Install dependencies
flutter pub get

# Run code generation (jika ada model Freezed/JSON)
flutter pub run build_runner build --delete-conflicting-outputs

# Run app
flutter run
```

---

## Alternative: Automatic Setup dengan Firebase CLI

Jika Anda sudah install Firebase CLI & FlutterFire CLI:

```bash
# 1. Login Firebase
firebase login

# 2. Install FlutterFire CLI
dart pub global activate flutterfire_cli

# 3. Configure Firebase (auto-generate firebase_options.dart)
flutterfire configure --project=keuangan-a80e6

# 4. Pilih platform (Android, iOS, Web, dll)
# 5. File firebase_options.dart akan di-generate otomatis
```

---

## Troubleshooting

### Error: "No Firebase App '[DEFAULT]' has been created"

**Solusi:**
- Pastikan `firebase_options.dart` sudah diisi dengan kredensial yang benar
- Pastikan `Firebase.initializeApp()` dipanggil di `main.dart` sebelum `runApp()`

### Error: "API key not valid"

**Solusi:**
- Periksa kembali API Key di Firebase Console
- Pastikan API Key untuk platform yang benar (Android/iOS/Web)
- Enable required APIs di Google Cloud Console

### Error: "Client is unauthorized to retrieve access tokens"

**Solusi:**
- Pastikan SHA-1/SHA-256 fingerprint sudah didaftarkan di Firebase Console (untuk Android)
- Regenerate `google-services.json` jika perlu

### Firestore Permission Denied

**Solusi:**
- Periksa Firestore Security Rules sudah di-deploy
- Pastikan user sudah login (`request.auth.uid` harus ada)
- Test rules di Firebase Console > Firestore > Rules Playground

---

## Next Steps

Setelah Firebase dikonfigurasi:

1. ✅ Test login dengan email/password
2. ✅ Test create transaction ke Firestore
3. ✅ Implement SQLite offline storage
4. ✅ Build sync engine
5. ✅ Develop remaining features

---

## Kontak

Jika ada masalah setup, buka issue di repository atau hubungi developer.
