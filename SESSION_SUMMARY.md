# Session Summary — 1 Juli 2026

## Stack
- Flutter 3.44.4 + Dart 3.8+ (stable)
- Firebase (Auth, Firestore, Analytics, Crashlytics, Messaging)
- SQLite (sqflite) — offline-first, sync via SyncEngine
- freezed ^3.2.6-dev.1 + freezed_annotation ^3.1.0
- riverpod ^3.3.2 + riverpod_generator ^4.0.4
- Architecture: Data/Domain/UI layers, ViewModel (ChangeNotifier)

## Git Log (terbaru)
```
59e7b55 fix: sync Firestore → SQLite saat reinstall/device baru
876fd9d docs: update SESSION_SUMMARY sesi 1 Juli 2026
8b488c1 feat: Material Icons, validasi saldo, fix tagihan & dashboard performa
130a970 fix: hapus sisa kode lama di reports_screen kategori tab
a580c6f fix: custom range laporan + tambah pemasukan per kategori
5e7eefa fix: kategori hutang/piutang/tagihan ter-tracking di transaksi
42a3055 fix: tambah updatedAt ke _toQueueData agar waktu bayar offline akurat saat sync
8c428f3 ux: hapus biaya transfer hutang create, tambah kategori tagihan, indikator sudah bayar bulan ini
```

## Critical: freezed v3 Breaking Change
- Semua class `@freezed` WAJIB pakai `abstract class X with _$X`
- Setelah edit model `@freezed`: wajib run `dart run build_runner build`
- JANGAN `flutter clean` — gunakan `dart run build_runner clean && dart run build_runner build`
- SDK `^3.8.0` di pubspec.yaml

## Rule Penting
1. **Jangan `flutter clean`** — breaks `.dart_tool/flutter_build` di Windows
2. Setelah edit `@freezed` model → `dart run build_runner build`
3. Semua `@freezed` class harus `abstract class X with _$X`
4. Shell `flutter analyze` kadang return git output → pakai `flutter analyze <path>` langsung
5. `dart run` tidak bisa import `package:flutter` — gunakan `flutter test` untuk script yang butuh Flutter SDK
6. **Build APK** selalu pakai `--no-tree-shake-icons` → `iconFromHex()` pakai non-const `IconData`

## Sesi Terbaru (commit 59e7b55)

### Bug Fix: Firestore → SQLite tidak sync saat reinstall / device baru

**Root Causes yang ditemukan & diperbaiki:**

#### 1. Filter `isDeleted`/`isActive` di Firestore query → skip doc lama
Doc lama di Firestore tidak punya field `isDeleted` atau `isActive` → Firestore skip → 0 docs → SQLite kosong setelah reinstall.

**Fix (semua service):** hapus filter Firestore, filter **client-side** setelah fetch semua docs:
- `spending_limit_service.dart` — hapus `.where('isActive', isEqualTo: true)` & `.where('isDeleted', isEqualTo: false)`, filter client-side
- `monthly_budget_service.dart` — hapus `.where('isDeleted', isEqualTo: false)`, filter client-side
- `savings_plan_service.dart` — hapus `.where('isDeleted', isEqualTo: false)` & `.where('isActive', ...)`, filter client-side
- `custody_service.dart` — filter isDeleted client-side di loop doc

#### 2. `createdAt` di doc lama = String ISO, bukan Timestamp
`_toFirestore()` lama pakai `.toIso8601String()` → cast `as Timestamp` → `TypeError` → exception silent di try/catch → semua doc skip → 0 results.

**Fix:** tambah helper `_parseDateTime(dynamic)` di semua 4 service:
```dart
static DateTime _parseDateTime(dynamic value) {
  if (value == null) return DateTime.now();
  if (value is Timestamp) return value.toDate();
  if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
  return DateTime.now();
}
```
Service yang difix: `spending_limit_service`, `monthly_budget_service`, `savings_plan_service`, `custody_service`

#### 3. `savings_allocations` tidak di-fetch Firestore saat reinstall
`getAllocations()` sebelumnya hanya baca SQLite lokal → reinstall = allocations kosong → `savedAmount` recalculate = 0.

**Fix:** `getAllocations(planId, userId)` Firestore-first + cache ke SQLite + merge offline unsynced. Signature berubah → update chain:
- `savings_plan_service.dart` — tambah `_allocFromFirestore()`, fetch `savings_allocations` subcollection
- `savings_plan_repository.dart` — `getAllocations(planId, userId)`
- `savings_plan_view_model.dart` — pass `userId` ke `getAllocations`
- `savings_history_screen.dart` — pass `widget.userId`

#### 4. `bill_service` — `getBills` tidak filter `isDeleted`
Doc soft-deleted ikut di-cache → ghost records. Fix: filter client-side + tambah `isDeleted` ke `_toFirestore` + handle nullable di `_fromFirestore`.

### Files diubah (commit 59e7b55)
```
lib/data/services/bill_service.dart               ← isDeleted client-filter, _toFirestore, _fromFirestore fix
lib/data/services/custody_service.dart            ← isDeleted client-filter, _parseDateTime, parse isDeleted
lib/data/services/monthly_budget_service.dart     ← isDeleted client-filter, _parseDateTime, _fromFirestore fix
lib/data/services/savings_plan_service.dart       ← isDeleted+isActive client-filter, _parseDateTime, getAllocations Firestore-first
lib/data/services/spending_limit_service.dart     ← isActive+isDeleted client-filter, _parseDateTime
lib/data/repositories/savings_plan_repository.dart ← getAllocations(planId, userId)
lib/ui/features/savings/view_models/savings_plan_view_model.dart ← pass userId
lib/ui/features/savings/views/savings_history_screen.dart        ← pass widget.userId, fix unnecessary __
```

## Sesi Sebelumnya (commit 8b488c1)

### Material Icons Migration
- **`lib/ui/core/icon_helper.dart`** ← NEW
  - `iconFromHex(String hex)` → `Icon(IconData(int.parse(hex, radix:16), fontFamily:'MaterialIcons'))`
  - `kCategoryMaterialIcons` — 40 hex codepoint untuk kategori
  - `kSavingsMaterialIcons` — 20 hex codepoint untuk tabungan
  - `kIconLabels` — label deskriptif untuk accessibility
- Semua emoji icon diganti ke hex codepoint Material Icons
- `PaymentMethodType.iconData` getter
- Migrasi data lama: `CategoryService.migrateIconsIfNeeded(userId)` via SharedPreferences flag

### Preset Kategori Baru
- `preset_gaji` → "Gaji & Pendapatan" (account_balance_wallet, biru)
- `preset_hutang` → "Bayar Hutang" (payments, merah)
- `preset_piutang` → "Terima Piutang" (savings, hijau)

### Validasi Saldo Rekening
Coverage lengkap di semua titik uang keluar: transaksi expense, transfer, bayar hutang/tagihan, buat piutang, custody KELUAR.

### Fix Tagihan
- `_cacheBillsToSqlite`: skip overwrite jika `paidAmount`/`installmentsPaid` lokal lebih tinggi
- Tombol bayar: disabled + label "Bayar Bulan Depan" saat sudah bayar bulan ini

### Performa Dashboard (Anti-Loop)
- `AuthViewModel._clearError`: skip `notifyListeners` jika `_errorMessage == null`
- Dashboard `_loadedUserId` guard: hanya load saat userId berubah

## Arsitektur Icon Storage
```
Model field 'icon': String  ← hex codepoint e.g. 'e532'
Render:  Icon(iconFromHex(icon), ...)
Storage: SQLite TEXT, Firestore String
Notifikasi (categoryIcon monthly_budget/spending_limit): TETAP emoji String ← by design
Migrasi: CategoryService.migrateIconsIfNeeded() ← jalan sekali per user via SharedPrefs
```

## Pola Firestore Query — WAJIB DIIKUTI
> **JANGAN** filter `isDeleted`/`isActive` di Firestore query jika field tsb mungkin tidak ada di doc lama.
> **SELALU** fetch semua doc, filter client-side setelah parse.

```dart
// ✅ BENAR
final snap = await _col(userId).get();
final items = snap.docs
    .map((d) => _fromFirestore(d.id, d.data()))
    .where((item) => !item.isDeleted && item.isActive)
    .toList();

// ❌ SALAH — skip doc lama yang tidak punya field
final snap = await _col(userId)
    .where('isDeleted', isEqualTo: false)
    .where('isActive', isEqualTo: true)
    .get();
```

## Pola `_parseDateTime` — WAJIB di semua `_fromFirestore`
```dart
static DateTime _parseDateTime(dynamic value) {
  if (value == null) return DateTime.now();
  if (value is Timestamp) return value.toDate();   // Firestore baru
  if (value is String) return DateTime.tryParse(value) ?? DateTime.now(); // doc lama
  return DateTime.now();
}
```

## Known Issues / Belum Selesai
- Warning: `json_annotation ^4.9.0` allows pre-4.12.0 → pertimbangkan upgrade
- Warning: KGP (Kotlin Gradle Plugin) di `firebase_analytics` → future breaking change (tidak bisa fix dari kode kita)
- `sdk: ^3.5.0` di pubspec — pertimbangkan bump ke `^3.8.0`
- Shell `flutter analyze` di environment ini kadang return git output → workaround: jalankan dengan path spesifik
- `PRD_Financial_App_Flutter_Firebase.md` dan `SETUP.md` terhapus (unstaged, tidak di-commit)
- `categoryIcon` di `monthly_budget_model` & `spending_limit_model` masih emoji string (by design untuk notifikasi push)
- Build APK wajib `--no-tree-shake-icons` karena `iconFromHex()` non-const IconData
