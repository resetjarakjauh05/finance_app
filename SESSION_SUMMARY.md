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
8b488c1 feat: Material Icons, validasi saldo, fix tagihan & dashboard performa
130a970 fix: hapus sisa kode lama di reports_screen kategori tab
a580c6f fix: custom range laporan + tambah pemasukan per kategori
5e7eefa fix: kategori hutang/piutang/tagihan ter-tracking di transaksi
42a3055 fix: tambah updatedAt ke _toQueueData agar waktu bayar offline akurat saat sync
8c428f3 ux: hapus biaya transfer hutang create, tambah kategori tagihan, indikator sudah bayar bulan ini
3f5d2c9 fix: payment_methods_screen bracket mismatch, filter aktif/non-aktif
6266673 ux: filter aktif/non-aktif metode pembayaran, edit transaksi tampil semua rekening
6820262 ux: tagihan hapus field jatuh tempo, auto-set dari billingDay
2bf78bc fix: _tabController not initialized in initState → LateInitializationError
2062525 ux: filter chip Semua/Belum Lunas/Lunas per tab tagihan
c27c937 feat: tambah riwayat transaksi per hutang/piutang/tagihan
9ae667b feat: 3 tipe tagihan (hutang/piutang/tagihan), recurring cicilan, opsional rekening, fix sync offline
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
4. Shell `flutter analyze` kadang return git output → pakai `dart analyze <path>` atau git stash trick
5. `dart run` tidak bisa import `package:flutter` — gunakan `flutter test` untuk script yang butuh Flutter SDK

## Sesi Terbaru (commit 8b488c1)

### Material Icons Migration
- **`lib/ui/core/icon_helper.dart`** ← NEW
  - `iconFromHex(String hex)` → `Icon(IconData(int.parse(hex, radix:16), fontFamily:'MaterialIcons'))`
  - `kCategoryMaterialIcons` — 40 hex codepoint untuk kategori
  - `kSavingsMaterialIcons` — 20 hex codepoint untuk tabungan
  - `kIconLabels` — label deskriptif untuk accessibility
- Semua emoji icon diganti ke hex codepoint Material Icons
- `PaymentMethodType.iconData` getter (Icons.payments_outlined, account_balance_outlined, dll)
- Migrasi data lama: `CategoryService.migrateIconsIfNeeded(userId)` jalan sekali via SharedPreferences flag `icon_migrated_v2_{userId}`
- File diupdate: `category_model.dart`, `category_form_screen.dart`, `category_list_screen.dart`, `savings_plan_screen.dart`, `savings_history_screen.dart`, `dashboard_screen.dart`, `add_edit_bill_screen.dart`, `bills_screen.dart`, `monthly_budget_screen.dart`, `add_edit_transaction_screen.dart`, `spending_limit_form_screen.dart`, `payment_methods_screen.dart`, `add_edit_payment_method_screen.dart`

### Preset Kategori Baru
- `preset_gaji` → "Gaji & Pendapatan" 💼 (account_balance_wallet, biru)
- `preset_hutang` → "Bayar Hutang" 💸 (payments, merah)
- `preset_piutang` → "Terima Piutang" 💰 (savings, hijau)
- Fallback `payBill`: hutang→`preset_hutang`, tagihan→`preset_tagihan`, piutang→`preset_piutang`
- Biaya transfer → `preset_lainnya` (bukan `uncategorized`)

### Validasi Saldo Rekening
Coverage lengkap di semua titik uang keluar:
| Titik | File | Status |
|---|---|---|
| Transaksi expense | add_edit_transaction_screen | sudah ada sebelumnya |
| Transfer antar rekening | transfer_screen | sudah ada sebelumnya |
| Bayar hutang/tagihan | bills_screen._handlePay | ✅ baru |
| Buat piutang + rekening | add_edit_bill_screen._handleSave | ✅ baru |
| Custody KELUAR | custody_detail_screen | ✅ baru |

### Fix Tagihan
- `createBill`: tagihan kirim `categoryId`/`categoryName` (sebelumnya hanya hutang)
- `_fromFirestore`: parse `updatedAt` → indikator "sudah bayar bulan ini" muncul saat online
- `_toFirestore`: include `updatedAt` → tersimpan ke Firestore
- `_cacheBillsToSqlite`: skip overwrite jika `paidAmount`/`installmentsPaid` lokal lebih tinggi → progress tidak reset saat update APK
- Tombol bayar: disabled + label "Bayar Bulan Depan" saat sudah bayar bulan ini

### Form Tagihan Cicilan (Redesign)
- Hapus field "Nominal per Cicilan" (redundan)
- `_nominalController` = nominal per bulan
- `_hasMaxInstallments = true` → `nominal = perBulan × maxCicilan`, `installmentAmount = perBulan`
- Preview kalkulasi realtime: `Rp X × N bulan = Rp Total`

### Fix Anggaran Bulanan Icon
- Dashboard L643: `Text(b.categoryIcon)` → `Icon(iconFromHex(b.categoryIcon))`
- Budget dialog hapus: hapus hex prefix, pakai `categoryName` saja

### Performa Dashboard (Anti-Loop)
- `AuthViewModel._clearError`: skip `notifyListeners` jika `_errorMessage == null`
  → kurangi trigger rebuild berulang
- Dashboard `_loadedUserId` guard: `_onAuthStateChanged` hanya panggil `_loadDashboardData` saat userId berubah (bukan tiap `notifyListeners`)
  → eliminasi multiple load saat sign-in/token refresh
- Batch loading flags: 4 `setState(_isLoading=true)` → 1 `setState` di `_loadDashboardData`
  → kurangi 4 rebuild jadi 1

## Arsitektur Icon Storage
```
Model field 'icon': String  ← hex codepoint e.g. 'e532'
Render:  Icon(iconFromHex(icon), ...)
Storage: SQLite TEXT, Firestore String  ← tidak perlu schema migration
Notifikasi (categoryIcon monthly_budget/spending_limit): TETAP emoji String ← tidak diubah
Migrasi: CategoryService.migrateIconsIfNeeded() ← jalan sekali per user via SharedPrefs
```

## Sesi Sebelumnya

### Tabungan (Savings)
- UX: validasi rekening sumber ≠ rekening tujuan di form alokasi
- Getter `_fromOptions` + `_toOptions` di `SavingsAllocationFormScreen`

### Tagihan & Pinjaman (Bills) — Major Refactor
**3 Tipe:**
- `hutang` — kita berutang, opsional rekening masuk saat create (income), expense saat bayar
- `piutang` — kita memberi pinjaman, opsional rekening keluar saat create (expense), income saat terima
- `tagihan` — tagihan rutin bulanan, recurring dengan/tanpa batas cicilan

**Model `BillModel` fields:**
- `transferFee`, `paymentMethodId`, `paymentMethodName`
- `billingDay`, `maxInstallments`, `installmentAmount`, `installmentsPaid`
- `updatedAt` — dipakai untuk deteksi bayar bulan ini

**Sync offline→online:**
- `_cacheBillsToSqlite` skip overwrite jika `isSynced=0` atau progress lokal lebih tinggi
- `updatedAt` di `_toQueueData` → waktu bayar offline akurat saat sync

### Metode Pembayaran
- FilterChip Semua/Aktif/Non-aktif di `PaymentMethodsScreen`
- Edit transaksi: tampilkan semua rekening (aktif + non-aktif)

### Laporan
- Bug fix: custom range support `startDate/endDate`
- Tambah: Pemasukan per Kategori (pie chart + list)

## File Utama
```
lib/ui/core/icon_helper.dart                               ← NEW: Material Icons utility
lib/domain/models/category_model.dart                     ← preset hex codepoint + 3 preset baru
lib/domain/models/payment_method_model.dart               ← IconData getter
lib/data/services/category_service.dart                   ← migrateIconsIfNeeded()
lib/data/services/bill_service.dart                       ← updatedAt parse/save, cache fix
lib/data/repositories/bill_repository.dart                ← preset categories, saldo check
lib/ui/features/bills/views/bills_screen.dart             ← saldo check, tombol bayar bulan depan
lib/ui/features/bills/views/add_edit_bill_screen.dart     ← form cicilan redesign, saldo piutang
lib/ui/features/custody/views/custody_detail_screen.dart  ← saldo check KELUAR
lib/ui/features/dashboard/views/dashboard_screen.dart     ← anti-loop guard, icon fix
lib/ui/features/auth/view_models/auth_view_model.dart     ← _clearError guard
lib/ui/features/budget/views/monthly_budget_screen.dart   ← icon fix
```

## Known Issues / Belum Selesai
- Warning: `json_annotation ^4.9.0` allows pre-4.12.0 → pertimbangkan upgrade
- Warning: KGP (Kotlin Gradle Plugin) di `firebase_analytics` → future breaking change
- `sdk: ^3.5.0` di pubspec — pertimbangkan bump ke `^3.8.0`
- Shell `flutter analyze` di environment ini return git output → workaround: `dart analyze <path>`
- `PRD_Financial_App_Flutter_Firebase.md` dan `SETUP.md` terhapus (unstaged, tidak di-commit)
- `categoryIcon` di `monthly_budget_model` & `spending_limit_model` masih emoji string (by design untuk notifikasi push)
