# Product Requirements Document (PRD)
## Personal Financial Tracker App

**Project:** Financial Recording & Tracking App  
**Platform:** Flutter (iOS, Android, Web)  
**Backend:** Firebase (Firestore, Authentication)  
**Created:** June 2026  
**Status:** In Planning

---

## 📌 Executive Summary

Aplikasi mobile/web untuk tracking keuangan personal yang memungkinkan pencatatan transaksi, monitoring saldo per metode pembayaran, tracking tagihan/hutang, dan penitipan uang. Dapat diakses multi-device dengan sync real-time menggunakan Firebase sebagai backend.

---

## 🎯 Business Objectives

1. **Digitalisasi pencatatan** - Replace Excel manual dengan aplikasi terstruktur
2. **Real-time sync** - Akses data yang sama di berbagai device (phone, tablet, web)
3. **Automated calculation** - Saldo otomatis tanpa input manual
4. **Better insights** - Dashboard & laporan untuk analisis spending pattern
5. **Accessibility** - Offline support & easy-to-use UI

---

## 👤 User Profile & Use Cases

### Target User
- Seorang individu dengan multiple payment methods (Cash, 5 bank accounts)
- Active daily transaction recording
- Need monthly financial summary
- Personal use (tidak untuk multi-user/bisnis)

### Primary Use Cases

1. **Daily Transaction Recording**
   - User input transaksi: Keterangan, Kategori, Metode Bayar, Nominal, Tanggal
   - Apps auto-calculate saldo per metode pembayaran
   - History tersimpan otomatis ke cloud

2. **Balance Monitoring**
   - View current balance per payment method (Cash, Bank Mandiri, Bank Jatim, Bank Jago, Bank Jago, Dana, SEA BANK)
   - Total saldo keseluruhan
   - Balance breakdown by payment method

3. **Bill Tracking**
   - Input tagihan/hutang: Nama, Nominal, Due date, Status
   - Track pembayaran partial
   - Reminder untuk tagihan yang belum dibayar

4. **Custody Money Tracking**
   - Input uang yang dititipkan ke user atau user titip ke orang lain
   - Track pemasukan/pengeluaran dari penitipan
   - Total penitipan yang outstanding

5. **Monthly Report**
   - Summary per bulan: Total masuk, Total keluar, Net
   - Breakdown transaksi per kategori
   - Export/share laporan

6. **Multi-Device Sync**
   - Semua perubahan di satu device langsung terlihat di device lain
   - Offline support: Input transaksi offline, auto-sync saat online

---

## 📊 Data Model & Schema

### Firebase Firestore Collections

```
collections/
├─ users/
│  └─ {userId}
│     ├─ profile: {name, email, createdAt}
│     └─ preferences: {currency, theme, notifications}
│
├─ transactions/
│  └─ {userId}
│     └─ {transactionId}
│        ├─ description: string
│        ├─ category: enum [Uang Masuk, Uang Keluar]
│        ├─ paymentMethodId: string (reference to paymentMethods/{methodId})
│        ├─ paymentMethodName: string (denormalized, for display & offline)
│        ├─ nominal: number
│        ├─ date: timestamp
│        ├─ notes: string (optional)
│        ├─ createdAt: timestamp
│        ├─ updatedAt: timestamp
│        └─ isDeleted: boolean (soft delete)
│
├─ paymentMethods/
│  └─ {userId}
│     └─ {methodId}
│        ├─ name: string
│        ├─ type: enum [CASH, BANK, WALLET, DIGITAL]
│        ├─ bankName: string (optional)
│        ├─ accountNumber: string (encrypted, optional)
│        ├─ isActive: boolean
│        ├─ order: number (untuk sorting)
│        └─ createdAt: timestamp
│
├─ bills/
│  └─ {userId}
│     └─ {billId}
│        ├─ name: string
│        ├─ nominal: number
│        ├─ dueDate: timestamp
│        ├─ paidAmount: number (default 0)
│        ├─ status: enum [UNPAID, PARTIAL, PAID]
│        ├─ category: string (optional, untuk bill grouping)
│        ├─ notes: string (optional)
│        ├─ createdAt: timestamp
│        └─ updatedAt: timestamp
│
├─ custody/
│  └─ {userId}
│     └─ {custodyId}
│        ├─ depositorName: string
│        ├─ description: string
│        ├─ totalNominal: number
│        ├─ type: enum [DITERIMA, DIBERIKAN] (uang diterima/diberikan)
│        ├─ movements: array [
│           ├─ id: string
│           ├─ type: enum [MASUK, KELUAR]
│           ├─ nominal: number
│           ├─ date: timestamp
│           ├─ description: string
│        ]
│        ├─ currentBalance: number (calculated)
│        ├─ createdAt: timestamp
│        └─ updatedAt: timestamp
│
└─ monthlySnapshots/
   └─ {userId}
      └─ {yearMonth} (e.g., "2026-06")
         ├─ totalIncome: number
         ├─ totalExpense: number
         ├─ netBalance: number
         ├─ categoryBreakdown: object
         ├─ paymentMethodBreakdown: object
         ├─ balancePerMethod: object
         └─ generatedAt: timestamp
```

### Data Relationships & Calculations

**Real-time Calculations:**
- `transaction.category = "Uang Masuk"` → add to `paymentMethodId` balance
- `transaction.category = "Uang Keluar"` → subtract from `paymentMethodId` balance
- Balance grouping uses `paymentMethodId` (bukan `paymentMethodName`) untuk konsistensi meskipun nama method diubah
- `bill.paidAmount < bill.nominal` → status = "PARTIAL"
- `bill.paidAmount >= bill.nominal` → status = "PAID"
- `custody.movements` sum masuk - sum keluar = currentBalance

---

## 🎨 Feature Specifications

### F1: Authentication & User Management
**Scope:** User login/signup, session management

**Requirements:**
- [x] Sign up dengan email/password
- [x] Sign in dengan email/password
- [x] Logout
- [x] Password reset via email
- [x] Session persist (auto-login jika belum logout)
- [x] Auth state management (Redux/Provider)

**Priority:** P0 (Critical - blocking)  
**Effort:** M (Medium)  
**Owner:** Firebase Auth

---

### F2: Dashboard/Home Screen
**Scope:** Overview keuangan utama

**Requirements:**
- [x] Display total saldo keseluruhan (real-time)
- [x] Card list saldo per payment method:
  - Method name
  - Current balance
  - Last transaction
  - Indicator: naik/turun vs kemarin
- [x] Quick stats:
  - Total transaksi hari ini
  - Total pemasukan bulan ini
  - Total pengeluaran bulan ini
- [x] Quick action buttons:
  - + Add Transaction
  - + Add Bill
  - + Add Custody
- [x] Recent transactions (last 5-10)
- [x] Notification badge (tagihan belum dibayar)

**UI/UX Notes:**
- Minimize scrolling, maximize information density
- Color code: Positive (green) Masuk, Negative (red) Keluar
- Swipe refresh untuk manual sync

**Priority:** P0 (Critical)  
**Effort:** M (Medium)  
**Owner:** Flutter UI + Firestore real-time listener

---

### F3: Transaction Management
**Scope:** CRUD transaksi

**Requirements - Create Transaction:**
- [x] Input form:
  - Description (dropdown dari history + text input)
  - Category (Uang Masuk / Uang Keluar) - radio/dropdown
  - Payment Method (dropdown di-fetch dari `paymentMethods/{userId}` collection, filter `isActive == true`, sort by `order`)
  - Nominal (number input dengan formatting)
  - Date (date picker, default today)
  - Notes (optional textarea)
- [x] Input validation (nominal > 0, required fields)
- [x] Save to Firestore dengan offline support
- [x] Success toast notification
- [x] Quick category suggestions based on history

**Requirements - List/View Transactions:**
- [x] List semua transaksi (paginated, 20 per page)
- [x] Filter options:
  - By date range (week, month, custom)
  - By category (Masuk/Keluar)
  - By payment method (dropdown dari `paymentMethods/{userId}` collection)
  - By search description
- [x] Sorting options (date newest/oldest, nominal high/low)
- [x] Pull to refresh
- [x] Lazy load / infinite scroll
- [x] Each transaction card shows:
  - Description, category icon, nominal, payment method, date
  - Swipe to edit/delete (with confirmation)

**Requirements - Edit Transaction:**
- [x] Pre-fill existing data
- [x] Same validation as create
- [x] Update timestamp
- [x] Soft delete (mark isDeleted = true, not physical delete)

**Requirements - Analytics per Transaction:**
- [x] Category breakdown (pie chart)
- [x] Payment method breakdown (bar chart)
- [x] Trend line (daily spending over month)
- [x] Comparison (vs previous month)

**Priority:** P0 (Critical)  
**Effort:** L (Large - complex filtering & UI)  
**Owner:** Flutter UI + Firestore queries

---

### F4: Balance & Account Management
**Scope:** Manage payment methods & view balances

**Requirements:**
- [x] Payment method list view:
  - Show all configured methods (Cash, Bank Mandiri, etc.)
  - Display current balance per method
  - Last updated timestamp
  - Total count of transactions per method
- [x] Payment method detail view:
  - Method name, type, balance
  - Transaction history for this method only
  - Add/Edit/Delete method (soft delete)
- [x] Add custom payment method:
  - Name (e.g., "Bank OVO", "Crypto Wallet")
  - Type (Cash, Bank, Digital Wallet, Crypto)
  - Optional: bank name, account number
- [x] **Payment method dropdown di semua form (transaksi, bill payment) harus di-fetch dinamis dari collection `paymentMethods/{userId}` (filter `isActive == true`, sort by `order`) — bukan dari enum hardcoded**
- [x] Balance recalculation:
  - Background job to recalc all method balances monthly
  - Manual recalculate button for debugging
- [x] Export balance history (CSV)

**UI Notes:**
- Card-based layout
- Color code per method (cash=orange, bank=blue, wallet=green)

**Priority:** P1 (High)  
**Effort:** M (Medium)  
**Owner:** Flutter UI + Firestore aggregation

---

### F5: Bill/Receivables Tracking
**Scope:** Manage hutang & piutang

**Requirements - Add Bill:**
- [x] Form input:
  - Creditor/Debtor name (text)
  - Total nominal (number)
  - Due date (date picker)
  - Category (tag: Hutang, Piutang, Tagihan Rutin)
  - Notes (optional)
- [x] Save ke bills collection
- [x] Auto notification 3 hari sebelum due date (opt-in)

**Requirements - Bill List:**
- [x] Tab view: Unpaid / Partial / Paid
- [x] Sort by due date (most urgent first)
- [x] Show: Name, total nominal, paid amount, remaining, status
- [x] Progress bar showing paid %
- [x] Color code: Red (overdue), Yellow (due soon), Green (on track)
- [x] Tap to view detail / edit / pay

**Requirements - Bill Payment:**
- [x] Quick pay form:
  - Nominal to pay (pre-filled remaining amount)
  - Payment date
  - Payment method
  - Notes
- [x] Record payment as transaction (optional: auto-create transaction entry)
- [x] Update paidAmount & status
- [x] Payment history log per bill

**Requirements - Monthly Summary:**
- [x] Total bills due this month
- [x] Paid vs unpaid count
- [x] Amount due vs already paid

**Priority:** P1 (High)  
**Effort:** M (Medium)  
**Owner:** Flutter UI + Firestore queries + Push notifications

---

### F6: Custody Money Tracking
**Scope:** Track uang titipan (received/given)

**Requirements:**
- [x] Add custody record:
  - Depositor name
  - Description (reason of custody)
  - Type: Money received / Money given
  - Initial nominal
  - Date received
- [x] Track movements (inflows/outflows):
  - Add movement form: type (masuk/keluar), nominal, date, description
  - Each movement recorded with timestamp
  - Current balance = sum(masuk) - sum(keluar)
- [x] Custody list view:
  - Show all custody records
  - Current balance per custody
  - Total outstanding
  - Last transaction date
- [x] Custody detail view:
  - Timeline of all movements
  - Current balance
  - Add new movement button
  - Settlement option (mark as settled/closed)

**UI Notes:**
- Timeline/history view (newest first)
- Clear visual: + untuk masuk (green), - untuk keluar (red)

**Priority:** P1 (High)  
**Effort:** M (Medium)  
**Owner:** Flutter UI + Firestore

---

### F7: Monthly Reports & Analytics
**Scope:** Insights & reporting

**Requirements:**
- [x] Monthly summary view:
  - Month picker (select which month to view)
  - Total income, total expense, net
  - Income vs expense comparison graph
  - Category breakdown (pie chart)
  - Payment method breakdown (bar chart)
  - Top 5 expenses
  - Comparison with previous month (% change)
- [x] Category analytics:
  - Select specific category
  - Show all transactions in category
  - Trend over last 3/6/12 months
  - Average per transaction
- [x] Payment method analytics:
  - Balance history per method
  - Usage frequency
- [x] Custom date range report:
  - Date from/to picker
  - Generate report for custom range
  - Download as PDF/CSV
- [x] Year-to-date summary:
  - Monthly breakdown (12-month view)
  - Running total
  - Year comparison

**Priority:** P2 (Medium)  
**Effort:** L (Large - complex charting)  
**Owner:** Flutter UI + Charts library + Firestore queries

---

### F8: Offline Support & Sync with SQLite
**Scope:** Complete offline functionality with SQLite, auto-sync when online

**Requirements - Offline Mode:**
- [x] SQLite database initialized on app install (automatic)
- [x] All data synced to SQLite on app open (if online)
- [x] User can perform ALL operations offline:
  - Add/edit/delete transactions
  - Add/edit/delete bills
  - Add/edit/delete custody records
  - View dashboard (with cached data)
  - Search & filter transactions
  - View balance history
- [x] Clear visual indicator when offline:
  - Banner merah di atas layar dengan ikon WiFi
  - **"Mode Offline — Perubahan akan disinkronkan saat online"**
  - Badge status sinkronisasi menampilkan jumlah operasi yang tertunda

**Requirements - Data Persistence (SQLite):**
- [x] SQLite tables structure (as detailed in architecture):
  - transactions, bills, custody, custody_movements, payment_methods
  - Each record has: id, isSynced flag, firebaseDocId, syncedAt, localCreatedAt
- [x] Efficient queries (indexed on frequently filtered columns):
  - date, paymentMethod, category, isSynced
- [x] Data size management:
  - Keep last 12 months of transactions locally
  - Archive older data (optional export)
  - Cleanup synced records (optional, default keep for reference)

**Requirements - Auto-Sync When Online:**
- [x] Connectivity listener (using connectivity_plus package):
  - Monitor network state continuously (background)
  - Detect when connection changes: offline → online
  - Trigger sync engine automatically
- [x] Sync engine logic:
  ```
  1. Query pending_operations table (records with isSynced=false)
  2. For each pending record:
     a. Check if record already exists in Firestore (conflict check)
     b. If not exists → Create new in Firestore
     c. If exists + local is newer → Update in Firestore
     d. If exists + cloud is newer → Skip (preserve cloud version)
  3. Batch operations (max 50 per batch to avoid timeout)
  4. On success:
     - Update isSynced=1, recordFirebaseDocId, syncedAt
     - Remove from pending_operations
     - Log in sync_log as "SUCCESS"
  5. On failure:
     - Increment retryCount
     - If retryCount < 3 → Schedule retry with exponential backoff
     - If retryCount >= 3 → Mark as "FAILED", notify user
     - Log error in sync_log for debugging
  ```
- [x] Sync status UI:
  - Toast notifikasi: **"Menyinkron..."** → **"Tersinkron ✓"** atau **"Gagal Sinkron ✗"**
  - Indikator progress sinkronisasi (jika banyak record)
  - Tombol **Coba Lagi** (jika gagal)

**Requirements - Conflict Resolution:**
- [x] Last-Write-Wins (LWW) strategy:
  - Compare localCreatedAt vs Firestore updatedAt timestamp
  - Newer timestamp wins
  - Log conflict in sync_log for audit
- [x] Optional: User prompt for close conflicts:
  - If timestamps within 1 minute → Ask user which version to keep
  - Show side-by-side comparison
  - User selects preferred version
- [x] Bidirectional sync (pull from cloud):
  - When online, also pull latest from Firestore
  - Update SQLite with cloud data (if cloud is newer)
  - User can manually trigger "Pull Latest" refresh

**Requirements - Retry & Error Handling:**
- [x] Exponential backoff retry logic:
  - 1st attempt: immediate
  - 1st fail: retry after 5 seconds
  - 2nd fail: retry after 30 seconds
  - 3rd fail: retry after 2 minutes
  - 4th fail: retry after 10 minutes
  - After 4 failures: Mark as "Manual Review Needed"
  - Keep trying silently in background (max once per hour)
- [x] Error types & handling:
  - Network timeout → Retry
  - Invalid data → Log error, don't retry (show user)
  - Firebase quota exceeded → Retry with longer backoff
  - Auth error → Prompt user to re-login
  - Unknown error → Log, retry later
- [x] User notifications:
  - Sukses: **"Data berhasil disinkronkan"**
  - Sebagian gagal: **"X data menunggu sinkronisasi"**
  - Gagal kritis: **"Gagal menyinkronkan [data], periksa koneksi dan coba lagi"**
  - Tombol sinkronisasi manual (**Sinkronkan Sekarang**)

**Requirements - Offline-First Data Architecture:**
- [x] Data flow:
  - User action → Write to SQLite immediately (fast)
  - If online → Also write to Firestore in background
  - If offline → Queue to pending_operations, wait for sync
- [x] Eventual consistency:
  - User sees data immediately (optimistic update)
  - Backend catches up asynchronously
  - No blocking on network operations
- [x] Data validation:
  - Validate on local create (before SQLite insert)
  - Validate again before Firestore push (consistency check)
  - If validation fails → Log error, keep in pending for manual review

**Requirements - Performance Optimization:**
- [x] SQLite queries optimized:
  - Indexed queries (date, paymentMethod, category, isSynced)
  - Pagination (load 20 records per page, not all at once)
  - Lazy loading for large lists
- [x] Sync performance:
  - Batch operations (50 records per batch)
  - Only sync changed records (isSynced=0)
  - Skip unchanged records
  - Compress data if size > 1MB
- [x] Background sync:
  - Sync runs on background thread (not UI thread)
  - Doesn't freeze app UI during sync
  - Can be paused if user explicitly goes offline

**Requirements - Data Integrity Checks:**
- [x] Sync log auditing:
  - Every operation logged with timestamp
  - Track what, when, success/fail
  - Available in Settings → "Sync History"
- [x] Periodic validation:
  - On app open: Compare SQLite balance vs Firebase balance
  - If mismatch > threshold → Alert user
  - Option to "Restore from Cloud" or "Keep Local"
- [x] Rollback capability (if sync fails critically):
  - Keep old SQLite backup (automatic)
  - User can restore previous version
  - Ask confirmation before rollback

**Priority:** P0 (Critical - core feature)  
**Effort:** XL (Extra Large - complex state management & sync logic)  
**Owner:** SQLite + Firestore sync engine + Connectivity monitoring

---

### F9: Search & Filtering
**Scope:** Quick access to past transactions/bills

**Requirements:**
- [x] Global search:
  - Search by description (full-text search)
  - Search by nominal (range)
  - Search by date
  - Search by payment method
  - Combine multiple filters
- [x] Search UI:
  - Search bar on top of list screens
  - Filter icon → filter modal
  - Save favorite filters
  - Quick filters (Today, This Week, This Month, Custom)
- [x] Search performance:
  - Index Firestore queries for speed
  - Debounce search input
  - Limit results (paginate)

**Priority:** P2 (Medium)  
**Effort:** M (Medium)  
**Owner:** Flutter UI + Firestore indexing

---

### F10: Settings & Preferences
**Scope:** User preferences & app configuration

**Requirements:**
- [x] Profile settings:
  - User name
  - Email
  - Change password
- [x] App preferences:
  - Theme (light/dark)
  - Currency (default IDR)
  - Date format (DD/MM/YYYY)
  - Decimal precision (2 places)
  - Language (default: **Bahasa Indonesia**; opsi tambahan: English)
- [x] Notification settings:
  - Bill reminders (enable/disable, days before)
  - Sync status notifications
  - Daily summary notification (optional)
- [x] Data management:
  - Export data (JSON/CSV)
  - Import data (JSON/CSV)
  - Backup to cloud (automatic daily)
  - Clear cache
  - Delete account (irreversible)
- [x] About:
  - App version
  - Privacy policy link
  - Terms of service link
  - Contact/support
  - Changelog

**Priority:** P2 (Medium)  
**Effort:** M (Medium)  
**Owner:** Flutter UI + Firestore

---

### F10a: Bahasa UI & Lokalisasi
**Scope:** Seluruh teks antarmuka pengguna dalam Bahasa Indonesia

**Ketentuan Bahasa UI:**
- [x] **Default bahasa: Bahasa Indonesia** — semua label, tombol, pesan, dan placeholder wajib dalam Bahasa Indonesia
- [x] Teks navigasi bawah: **Beranda, Transaksi, Tagihan, Lainnya**
- [x] Label form transaksi: **Keterangan, Kategori, Metode Pembayaran, Nominal, Tanggal, Catatan**
- [x] Tombol aksi: **Simpan, Batal, Hapus, Edit, Tambah**
- [x] Konfirmasi hapus: **"Yakin ingin menghapus data ini?"** → **Ya, Hapus / Batal**
- [x] Label kategori: **Uang Masuk / Uang Keluar**
- [x] Status tagihan: **Belum Bayar / Sebagian / Lunas**
- [x] Status sinkronisasi: **Menyinkron... / Tersinkron ✓ / Gagal Sinkron ✗ / Offline**
- [x] Pesan offline: **"Mode Offline — Perubahan akan disinkronkan saat online"**
- [x] Toast sukses: **"Transaksi berhasil disimpan"**, **"Data berhasil dihapus"**
- [x] Pesan error validasi: **"Nominal harus lebih dari 0"**, **"Keterangan wajib diisi"**
- [x] Label laporan: **Pemasukan, Pengeluaran, Selisih, Bulan Ini, Tahun Ini**
- [x] Label titipan: **Uang Diterima / Uang Diberikan, Saldo Saat Ini, Tambah Pergerakan**
- [x] Placeholder search: **"Cari transaksi..."**
- [x] Empty state: **"Belum ada transaksi"**, **"Belum ada tagihan"**, **"Belum ada titipan"**
- [x] Opsi bahasa di Settings tetap tersedia (Bahasa Indonesia / English) untuk fleksibilitas masa depan

**Catatan:** Kode internal (variable, field name, enum value di Firestore/SQLite) tetap dalam Bahasa Inggris untuk konsistensi teknis. Hanya teks yang tampil ke user yang wajib Bahasa Indonesia.

**Priority:** P1 (High — tampilan utama)
**Effort:** S (Small — localization strings)
**Owner:** Flutter UI (l10n / intl package)
**Scope:** One-time import of historical data

**Requirements:**
- [x] Excel template/format specification
- [x] Parse Excel (transactions, bills, custody)
- [x] Validation before import (check for errors)
- [x] Batch import to Firestore
- [x] Migration report (success count, errors, warnings)
- [x] Rollback option if issues

**Priority:** P1 (High - one-time at launch)  
**Effort:** M (Medium)  
**Owner:** Backend script + Admin panel

---

## 🛠️ Technical Architecture

### Technology Stack

**Frontend:**
- **Framework:** Flutter 3.x (Dart)
- **State Management:** Riverpod or Provider (for simplicity)
- **Local Storage:** 
  - **SQLite** (Primary - complex queries, large datasets)
  - **Hive** (Secondary - cache layer, fast access)
  - **Shared Preferences** (App config & user preferences)
- **ORM/Database Adapter:** sqflite or drift (type-safe)
- **UI Components:** Material 3 + custom widgets
- **Charts:** fl_chart or charts_flutter
- **Date/Time:** intl, timezone
- **Networking:** http, dio (with retry logic)
- **Connectivity:** connectivity_plus (monitor internet status)

**Backend:**
- **Database:** Firebase Firestore (NoSQL)
- **Authentication:** Firebase Auth
- **Storage:** Firebase Cloud Storage (for file exports)
- **Functions:** Cloud Functions (optional, for complex calculations)
- **Hosting:** Firebase Hosting (if web version)
- **Monitoring:** Firebase Analytics

**Platforms:**
- iOS 12+
- Android 8+
- Web (optional Phase 2)

### Architecture Pattern

**MVVM/Clean Architecture:**
```
lib/
├─ data/
│  ├─ models/          # Data models (transaction, bill, etc)
│  ├─ datasources/     # Firebase operations
│  └─ repositories/    # Abstract & concrete repositories
├─ domain/
│  ├─ entities/        # Business entities
│  ├─ repositories/    # Abstract repository interfaces
│  └─ usecases/        # Business logic
├─ presentation/
│  ├─ screens/         # UI screens
│  ├─ widgets/         # Reusable widgets
│  ├─ providers/       # Riverpod/Provider definitions
│  └─ styles/          # Theme, colors, typography
├─ core/
│  ├─ error/
│  ├─ constants/
│  ├─ extensions/
│  └─ utils/
└─ main.dart
```

### Authentication Flow

```
1. User opens app
   ↓
2. Check FirebaseAuth.instance.currentUser
   ├─ if null → Show auth screen
   ├─ if not null → Load user data → Show dashboard
   ↓
3. Auth screen:
   ├─ Sign Up:
      - Email validation
      - Password strength check
      - Create user via FirebaseAuth
      - Create user doc in Firestore
   ├─ Sign In:
      - Email/password validation
      - FirebaseAuth.signInWithEmailAndPassword()
   ├─ Password Reset:
      - Send reset email
   ↓
4. Session management:
   - AuthStateNotifier (Riverpod) listens to auth changes
   - Auto-redirect to auth screen if signed out
```

### Offline-First Architecture with SQLite + Firestore Sync

**Local Database Layer (SQLite):**
```
SQLite Database Structure:
├─ transactions (id, description, category, paymentMethodId, paymentMethodName, nominal, date, notes, isSynced, syncedAt, localCreatedAt)
├─ bills (id, name, nominal, paidAmount, dueDate, status, isSynced, syncedAt, localCreatedAt)
├─ custody (id, depositorName, description, totalNominal, type, currentBalance, isSynced, syncedAt, localCreatedAt)
├─ custody_movements (id, custodyId, movementType, nominal, date, description, isSynced, syncedAt)
├─ payment_methods (id, name, type, isActive, currentBalance, isSynced, syncedAt, localCreatedAt)
├─ sync_log (id, operation, entityType, entityId, status, firebaseDocId, localCreatedAt, syncedAt, error)
└─ pending_operations (id, operation, tableName, recordId, data, timestamp, retryCount, status)
```

**Sync Flow Architecture:**

```
┌─────────────────────────────────────────────────────────────────────┐
│                        USER INTERACTION                              │
│                    (Add Transaction, Edit Bill)                       │
└────────────────────────────┬────────────────────────────────────────┘
                             ↓
                    ┌────────────────────┐
                    │ Check Connectivity │
                    └────────┬───────────┘
                             ↓
        ┌────────────────────┴────────────────────┐
        ↓ OFFLINE                                  ↓ ONLINE
    ┌──────────────┐                         ┌──────────────┐
    │ Save to      │                         │ Save to Both │
    │ SQLite Only  │                         │ SQLite +     │
    │              │                         │ Firestore    │
    │ Mark:        │                         │              │
    │ isSynced=0   │                         │ Mark:        │
    │ Add to       │                         │ isSynced=1   │
    │ pending_ops  │                         │              │
    └───────┬──────┘                         └───────┬──────┘
            ↓                                        ↓
    ┌──────────────┐                         ┌──────────────┐
    │ Show Toast:  │                         │ Show Toast:  │
    │ "Saved       │                         │ "Synced to   │
    │ Offline"     │                         │ Cloud"       │
    └──────────────┘                         └──────────────┘

        CONNECTIVITY LISTENER RUNNING (background)
                         ↓
        ┌───────────────────────────────┐
        │ Internet Detected             │
        │ (was offline, now online)     │
        └────────────┬──────────────────┘
                     ↓
        ┌─────────────────────────────────────┐
        │ SYNC ENGINE ACTIVATED               │
        │ 1. Query pending_operations table   │
        │ 2. Get unsynced records from SQLite │
        │ 3. Batch upload to Firestore        │
        └────────────┬────────────────────────┘
                     ↓
        ┌─────────────────────────────────────┐
        │ CONFLICT RESOLUTION                 │
        │ (if same doc edited in cloud)       │
        │ Strategy: Last-Write-Wins (LWW)     │
        │ or User Prompt (if timestamp close) │
        └────────────┬────────────────────────┘
                     ↓
        ┌─────────────────────────────────────┐
        │ UPDATE SYNC STATUS                  │
        │ - Mark as isSynced=1                │
        │ - Record firebaseDocId              │
        │ - Remove from pending_operations    │
        │ - Log in sync_log table             │
        └────────────┬────────────────────────┘
                     ↓
        ┌─────────────────────────────────────┐
        │ ERROR HANDLING                      │
        │ - Failed? Mark for retry            │
        │ - Retry logic:                      │
        │   1st fail: retry after 5s          │
        │   2nd fail: retry after 30s         │
        │   3rd fail: retry after 2min        │
        │   4th+ fail: notify user, manual    │
        │   Keep record in pending_ops        │
        └────────────┬────────────────────────┘
                     ↓
        ┌─────────────────────────────────────┐
        │ SYNC COMPLETE                       │
        │ - Notify user "All data synced"     │
        │ - Update UI if visible              │
        └─────────────────────────────────────┘
```

**SQLite Data Persistence Strategy:**

```dart
// Example table schema (using drift ORM)
@DataClassName("Transaction")
class Transactions extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get description => text()();
  TextColumn get category => text()(); // Uang Masuk / Uang Keluar
  TextColumn get paymentMethodId => text()(); // reference to paymentMethods/{methodId}
  TextColumn get paymentMethodName => text()(); // denormalized, for display & offline
  IntColumn get nominal => integer()();
  DateTimeColumn get date => dateTime()();
  TextColumn get notes => text().nullable()();
  
  // Sync tracking
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
  TextColumn get firebaseDocId => text().nullable()();
  DateTimeColumn get syncedAt => dateTime().nullable()();
  DateTimeColumn get localCreatedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().nullable()();
  
  @override
  Set<Column> get primaryKey => {id};
}
```

**Sync Log untuk Troubleshooting:**

```
sync_log table:
├─ id: primary key
├─ operation: "CREATE", "UPDATE", "DELETE"
├─ entityType: "TRANSACTION", "BILL", "CUSTODY"
├─ entityId: local SQLite id
├─ firebaseDocId: remote Firestore id
├─ status: "PENDING", "SYNCING", "SUCCESS", "FAILED"
├─ error: error message (if failed)
├─ localCreatedAt: when operation was created locally
├─ syncedAt: when successfully synced to Firestore
├─ retryCount: number of retry attempts

Useful for:
- Debugging sync issues
- Audit trail
- Finding failed syncs needing manual attention
```

### Real-time Sync (Multi-device)

```
Device A: Add transaction "Beli Kopi 5000"
   ↓
Firestore: Create transaction doc
   ↓
Device B, C (listening to transactions stream)
   ↓
StreamBuilder/StreamProvider triggers rebuild
   ↓
UI updates with new transaction (real-time)
```

---

## 📱 User Interface Wireframes

### Screen Hierarchy

```
AuthStack
├─ Layar Masuk (Login)
├─ Layar Daftar (Register)
└─ Layar Reset Kata Sandi

MainStack
├─ Navigasi Bawah (4 tab)
│  ├─ Tab 1: Beranda
│  ├─ Tab 2: Transaksi
│  ├─ Tab 3: Tagihan
│  └─ Tab 4: Lainnya (Titipan, Laporan, Pengaturan)
│
├─ Layar Beranda (Dashboard)
│  ├─ Kartu total saldo keseluruhan
│  ├─ Kartu saldo per metode pembayaran
│  ├─ Statistik cepat (hari ini, bulan ini)
│  ├─ Transaksi terbaru
│  └─ Tombol aksi cepat (+ Tambah Transaksi, + Tagihan, + Titipan)
│
├─ Layar Transaksi
│  ├─ Toolbar filter & urutkan
│  ├─ Daftar transaksi
│  ├─ Tombol Tambah (FAB)
│  └─ Detail transaksi (modal saat diklik)
│
├─ Layar Tambah/Edit Transaksi
│  ├─ Form (keterangan, kategori, metode bayar, nominal, tanggal, catatan)
│  ├─ Pesan validasi
│  └─ Tombol Simpan
│
├─ Layar Tagihan
│  ├─ Tab (Belum Bayar / Sebagian / Lunas)
│  ├─ Daftar tagihan dengan progress bar
│  └─ Tombol Tambah (FAB)
│
├─ Layar Tambah/Edit Tagihan
│
├─ Layar Titipan
│  ├─ Daftar titipan
│  └─ Tombol Tambah (FAB)
│
├─ Layar Tambah/Edit Titipan
│
├─ Layar Detail Titipan
│  ├─ Saldo saat ini
│  ├─ Riwayat pergerakan (timeline)
│  └─ Tombol Tambah Pergerakan
│
├─ Layar Laporan
│  ├─ Pilih bulan
│  ├─ Kartu ringkasan (Pemasukan, Pengeluaran, Selisih)
│  ├─ Grafik (pemasukan vs pengeluaran, breakdown kategori)
│  ├─ Analitik kategori & metode pembayaran
│  └─ Tombol Unduh Laporan
│
├─ Layar Pengaturan
│  ├─ Profil
│  ├─ Preferensi aplikasi
│  ├─ Notifikasi
│  ├─ Manajemen data
│  └─ Tentang Aplikasi
│
└─ Layar Metode Pembayaran
   ├─ Daftar metode
   ├─ Tambah/Edit metode
   └─ Detail metode
```

### Komponen UI Utama

1. **Kartu Saldo** - Tampilkan saldo per metode dengan waktu pembaruan terakhir
2. **Item Transaksi** - Tampilkan keterangan, ikon kategori, nominal, metode
3. **Kartu Tagihan** - Tampilkan progress bar, jumlah terbayar & sisa
4. **Widget Grafik** - Grafik pie/bar/line dengan keterangan (legend)
5. **Modal Filter** - Multi-select filter untuk tanggal, kategori, metode pembayaran
6. **Indikator Sinkron** - Badge status (Menyinkron..., Tersinkron ✓, Gagal ✗, Offline)

---

## 🧪 Testing Strategy

### Unit Tests
- Model validation (transaction, bill, custody)
- Calculation logic (balance calc, bill status)
- Date/time utilities

### Widget Tests
- Form validation UI
- List rendering with filters
- Chart display

### Integration Tests
- Auth flow (signup, login, logout)
- Transaction CRUD
- Offline/online sync simulation
- Bill management

### Firebase Emulator
- Use Firebase Emulator Suite for testing Firestore & Auth without hitting production
- Test security rules
- Test cloud functions (if used)

---

## 📊 Analytics & Monitoring

### Events to Track
- User signup/login
- Transaction created/edited/deleted
- Bill added/paid
- Custody created
- Report generated/exported
- Settings changed
- Sync events (success/fail)
- Error events

### Metrics to Monitor
- Daily active users (DAU)
- Monthly active users (MAU)
- Average transactions per user per day
- Sync success rate
- App crash rate
- Feature usage (which screens most used)

### Tools
- Firebase Analytics (built-in)
- Firebase Crashlytics (for error tracking)
- Firebase Performance Monitoring

---

## 🚀 Release & Deployment Plan

### Phase 0: Development & Testing (Weeks 1-6)
- Week 1-2: Setup project, Firebase config, auth flow
- Week 2-3: Dashboard & transaction management
- Week 3-4: Bills & custody features
- Week 4-5: Reports & analytics
- Week 5-6: Offline sync, testing, bug fixes
- Week 6: Data migration from Excel, final testing

### Phase 1: Alpha Release (Week 7)
- Internal testing (team members)
- Edge case testing
- Performance optimization
- Firebase security rules finalization

### Phase 2: Beta Release (Week 8)
- Limited external testing (close friends)
- Gather feedback
- Bug fixes & improvements
- Prepare for production launch

### Phase 3: Production Launch (Week 9)
- Deploy to iOS App Store
- Deploy to Google Play Store
- Deploy web version (if included)
- Monitor crash rates & user feedback
- Post-launch support & bug fixes

### Phase 4: Post-Launch (Week 10+)
- Feature iterations based on feedback
- Performance optimization
- New feature development (Phase 2)
- Maintenance & updates

---

## 📈 Success Metrics

**Functional Success:**
- ✅ All transactions sync real-time across devices
- ✅ Offline mode works seamlessly
- ✅ Zero data loss during sync
- ✅ Search & filter work fast (<500ms)
- ✅ Reports generate within 2 seconds

**User Experience Success:**
- ✅ App load time < 2 seconds
- ✅ Transaction creation < 30 seconds
- ✅ Crash rate < 0.1%
- ✅ User retention (still using after 30 days) > 80%

**Performance Success:**
- ✅ Firebase Firestore costs within budget ($10/month)
- ✅ App size < 100MB
- ✅ Battery usage acceptable (< 5% per hour active use)

---

## 🔒 Security & Privacy

### Data Security
- [x] All data at rest encrypted (Firebase default + custom encryption for sensitive fields like account number)
- [x] All data in transit encrypted (HTTPS/TLS)
- [x] Firebase Security Rules:
  ```
  match /databases/{database}/documents {
    match /users/{userId}/{document=**} {
      allow read, write: if request.auth.uid == userId;
    }
    match /transactions/{userId}/{document=**} {
      allow read, write: if request.auth.uid == userId;
    }
    // Similar rules for bills, custody, etc.
  }
  ```

### Authentication
- [x] Email/password hashing (Firebase Auth)
- [x] No credentials stored locally in plain text
- [x] Session tokens auto-refresh

### Privacy
- [x] No data sharing with third parties
- [x] User can export/delete all data anytime
- [x] GDPR compliance (right to be forgotten)
- [x] Clear privacy policy & terms of service

### Backup & Recovery
- [x] Automatic daily backup (Firestore export)
- [x] User can download data anytime
- [x] Retention: 90 days backup history

---

## 🎯 Constraints & Assumptions

### Constraints
- Single-user app (no multi-user collaboration)
- Internet required for setup/account creation
- Offline support for specific features only
- Firebase free tier limitations (50k reads/writes per day, 1GB storage)
- Mobile-first design (web version Phase 2)

### Assumptions
- User has stable internet connection (sync eventually consistent)
- User will backup data regularly
- No concurrent edits from multiple devices at same time (unlikely for personal app)
- User maintains ~100 transactions per month (reasonable growth assumption)

---

## 💰 Resource Requirements

### Team
- 1 Flutter Developer (full-time)
- Optional: 1 UI/UX Designer (for design review)
- Optional: 1 QA Tester (for final phase)

### Infrastructure
- Firebase project (free tier initially)
- GitHub for version control
- Firebase Emulator (local development)

### Tools & Services
- VS Code / Android Studio IDE
- Figma (for design)
- GitHub Projects (for task tracking)
- Firebase Console (for monitoring)

---

## 📝 Acceptance Criteria

### Must Have (MVP)
- [x] User auth (signup/login)
- [x] Add/edit/delete transactions
- [x] View balance per payment method
- [x] Real-time sync across devices
- [x] Offline support (queue & sync)
- [x] Basic reports (monthly summary)
- [x] Data export (CSV/JSON)

### Should Have (Phase 1)
- [x] Bills tracking
- [x] Custody money tracking
- [x] Advanced filters & search
- [x] Analytics & charts
- [x] Notifications
- [x] Settings & preferences

### Nice to Have (Phase 2+)
- [ ] Web version
- [ ] Budget alerts
- [ ] Recurring transactions
- [ ] Receipt image attachment
- [ ] Multi-currency support
- [ ] Data import from other apps
- [ ] Collaborative features (if expand to family)
- [ ] AI-powered spending insights

---

## 📚 Detailed SQLite Implementation Guide

### Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  # Database
  sqflite: ^2.3.0
  path: ^1.8.0
  # Alternative: drift (type-safe ORM)
  drift: ^2.14.0
  sqlite3_flutter_libs: ^0.5.0
  
  # Sync & Connectivity
  connectivity_plus: ^5.0.0
  
  # State Management
  riverpod: ^2.4.0
  flutter_riverpod: ^2.4.0
  
  # Firestore
  cloud_firestore: ^4.9.0
  firebase_auth: ^4.10.0
  
  # Utilities
  uuid: ^4.0.0
  dio: ^5.3.0
```

### SQLite Database Helper Class

```dart
// lib/data/datasources/local/database_helper.dart

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'financial_app.db');

    return openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE transactions(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        firebaseDocId TEXT UNIQUE,
        description TEXT NOT NULL,
        category TEXT NOT NULL,
        paymentMethod TEXT NOT NULL,
        nominal INTEGER NOT NULL,
        date INTEGER NOT NULL,
        notes TEXT,
        isSynced INTEGER DEFAULT 0,
        syncedAt INTEGER,
        localCreatedAt INTEGER NOT NULL,
        updatedAt INTEGER,
        isDeleted INTEGER DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE bills(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        firebaseDocId TEXT UNIQUE,
        name TEXT NOT NULL,
        nominal INTEGER NOT NULL,
        paidAmount INTEGER DEFAULT 0,
        dueDate INTEGER NOT NULL,
        status TEXT NOT NULL,
        isSynced INTEGER DEFAULT 0,
        syncedAt INTEGER,
        localCreatedAt INTEGER NOT NULL,
        updatedAt INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE custody(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        firebaseDocId TEXT UNIQUE,
        depositorName TEXT NOT NULL,
        description TEXT,
        totalNominal INTEGER NOT NULL,
        type TEXT NOT NULL,
        currentBalance INTEGER DEFAULT 0,
        isSynced INTEGER DEFAULT 0,
        syncedAt INTEGER,
        localCreatedAt INTEGER NOT NULL,
        updatedAt INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE pending_operations(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        operation TEXT NOT NULL,
        tableName TEXT NOT NULL,
        recordId INTEGER NOT NULL,
        firebaseDocId TEXT,
        data TEXT NOT NULL,
        timestamp INTEGER NOT NULL,
        retryCount INTEGER DEFAULT 0,
        status TEXT DEFAULT 'PENDING',
        error TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE sync_log(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        operation TEXT NOT NULL,
        entityType TEXT NOT NULL,
        entityId INTEGER,
        firebaseDocId TEXT,
        status TEXT NOT NULL,
        error TEXT,
        localCreatedAt INTEGER NOT NULL,
        syncedAt INTEGER
      )
    ''');

    // Create indexes for performance
    await db.execute('CREATE INDEX idx_transactions_isSynced ON transactions(isSynced)');
    await db.execute('CREATE INDEX idx_transactions_date ON transactions(date)');
    await db.execute('CREATE INDEX idx_bills_isSynced ON bills(isSynced)');
    await db.execute('CREATE INDEX idx_pending_status ON pending_operations(status)');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle database migrations here
  }
}
```

### Sync Engine Implementation

```dart
// lib/data/datasources/sync/sync_engine.dart

class SyncEngine {
  final Firestore firestore = FirebaseFirestore.instance;
  final DatabaseHelper dbHelper = DatabaseHelper();
  final ConnectivityPlus connectivity = ConnectivityPlus();

  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  bool _isSyncing = false;

  void startSyncListener() {
    // Listen to connectivity changes
    _connectivitySubscription = 
        connectivity.onConnectivityChanged.listen((result) {
      if (result.contains(ConnectivityResult.none)) {
        // Offline
        print('🔴 Offline - queuing operations');
      } else {
        // Online - start sync
        print('🟢 Online - starting sync');
        syncPendingOperations();
      }
    });
  }

  Future<void> syncPendingOperations() async {
    if (_isSyncing) {
      print('⏳ Sync already in progress');
      return;
    }

    _isSyncing = true;
    try {
      final db = await dbHelper.database;
      
      // Get all pending operations
      final pendingOps = await db.query(
        'pending_operations',
        where: 'status = ? AND retryCount < ?',
        whereArgs: ['PENDING', 3],
      );

      for (var op in pendingOps) {
        await _processSingleOperation(op, db);
      }

      print('✅ Sync completed');
    } catch (e) {
      print('❌ Sync failed: $e');
    } finally {
      _isSyncing = false;
    }
  }

  Future<void> _processSingleOperation(
    Map<String, dynamic> operation,
    Database db,
  ) async {
    try {
      final opType = operation['operation'] as String;
      final tableName = operation['tableName'] as String;
      final recordId = operation['recordId'] as int;
      final data = jsonDecode(operation['data'] as String);

      String? firebaseDocId;

      switch (opType) {
        case 'CREATE':
          final docRef = await firestore
              .collection(tableName)
              .add({...data, 'createdAt': FieldValue.serverTimestamp()});
          firebaseDocId = docRef.id;
          break;

        case 'UPDATE':
          firebaseDocId = operation['firebaseDocId'];
          await firestore
              .collection(tableName)
              .doc(firebaseDocId)
              .update({...data, 'updatedAt': FieldValue.serverTimestamp()});
          break;

        case 'DELETE':
          firebaseDocId = operation['firebaseDocId'];
          await firestore.collection(tableName).doc(firebaseDocId).delete();
          break;
      }

      // Mark as synced in SQLite
      await db.update(
        'pending_operations',
        {
          'status': 'SUCCESS',
          'firebaseDocId': firebaseDocId,
        },
        where: 'id = ?',
        whereArgs: [operation['id']],
      );

      // Update main table isSynced flag
      await db.update(
        tableName,
        {
          'isSynced': 1,
          'firebaseDocId': firebaseDocId,
          'syncedAt': DateTime.now().millisecondsSinceEpoch,
        },
        where: 'id = ?',
        whereArgs: [recordId],
      );

      // Log success
      await db.insert('sync_log', {
        'operation': opType,
        'entityType': tableName,
        'entityId': recordId,
        'firebaseDocId': firebaseDocId,
        'status': 'SUCCESS',
        'localCreatedAt': DateTime.now().millisecondsSinceEpoch,
        'syncedAt': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e) {
      // Handle error and retry
      await _handleSyncError(operation, db, e);
    }
  }

  Future<void> _handleSyncError(
    Map<String, dynamic> operation,
    Database db,
    dynamic error,
  ) async {
    final retryCount = (operation['retryCount'] as int) + 1;
    final errorMsg = error.toString();

    // Calculate backoff delay
    final delaySeconds = _getBackoffDelay(retryCount);

    await db.update(
      'pending_operations',
      {
        'retryCount': retryCount,
        'status': retryCount >= 3 ? 'FAILED' : 'PENDING',
        'error': errorMsg,
      },
      where: 'id = ?',
      whereArgs: [operation['id']],
    );

    // Log failure
    await db.insert('sync_log', {
      'operation': operation['operation'],
      'entityType': operation['tableName'],
      'entityId': operation['recordId'],
      'firebaseDocId': operation['firebaseDocId'],
      'status': 'FAILED',
      'error': errorMsg,
      'localCreatedAt': DateTime.now().millisecondsSinceEpoch,
    });

    // Schedule retry if not exceeded max retries
    if (retryCount < 3) {
      Future.delayed(Duration(seconds: delaySeconds), () {
        syncPendingOperations();
      });
    }
  }

  int _getBackoffDelay(int retryCount) {
    switch (retryCount) {
      case 1:
        return 5;
      case 2:
        return 30;
      case 3:
        return 120;
      default:
        return 600; // 10 minutes
    }
  }

  void dispose() {
    _connectivitySubscription.cancel();
  }
}
```

### Local-First Write Pattern

```dart
// lib/data/repositories/transaction_repository.dart

class TransactionRepository {
  final DatabaseHelper dbHelper;
  final SyncEngine syncEngine;

  TransactionRepository({
    required this.dbHelper,
    required this.syncEngine,
  });

  Future<int> addTransaction(Transaction transaction) async {
    final db = await dbHelper.database;

    // 1. Write to SQLite immediately (offline-first)
    final localId = await db.insert('transactions', {
      'description': transaction.description,
      'category': transaction.category,
      'paymentMethod': transaction.paymentMethod,
      'nominal': transaction.nominal,
      'date': transaction.date.millisecondsSinceEpoch,
      'notes': transaction.notes,
      'isSynced': 0,
      'localCreatedAt': DateTime.now().millisecondsSinceEpoch,
    });

    // 2. Queue for sync
    await db.insert('pending_operations', {
      'operation': 'CREATE',
      'tableName': 'transactions',
      'recordId': localId,
      'data': jsonEncode(transaction.toJson()),
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'status': 'PENDING',
    });

    // 3. If online, sync immediately (fire and forget)
    final isOnline = await _checkConnectivity();
    if (isOnline) {
      syncEngine.syncPendingOperations();
    }

    return localId;
  }

  Future<bool> _checkConnectivity() async {
    final result = await ConnectivityPlus().checkConnectivity();
    return !result.contains(ConnectivityResult.none);
  }
}
```

### Real-time Data Provider with Local Cache

```dart
// lib/presentation/providers/transactions_provider.dart

final transactionsProvider = StreamProvider<List<Transaction>>((ref) {
  final dbHelper = ref.watch(databaseHelperProvider);
  
  return Stream.periodic(Duration(seconds: 1), (_) async {
    final db = await dbHelper.database;
    
    // Always fetch from local SQLite first (instant)
    final results = await db.query(
      'transactions',
      where: 'isDeleted = 0',
      orderBy: 'date DESC',
    );

    return results.map((e) => Transaction.fromJson(e)).toList();
  }).asyncMap((event) => event);
});

// When online, subscribe to Firestore for real-time updates
final firestoreTransactionsProvider = StreamProvider<List<Transaction>>((ref) {
  return FirebaseFirestore.instance
      .collection('transactions')
      .orderBy('date', descending: true)
      .snapshots()
      .map((snapshot) {
    return snapshot.docs
        .map((doc) => Transaction.fromJson(doc.data()))
        .toList();
  });
});
```

### UI State Indicator

```dart
// lib/presentation/widgets/sync_status_widget.dart

class SyncStatusWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncStatus = ref.watch(syncStatusProvider);
    
    return syncStatus.when(
      data: (status) {
        switch (status) {
          case SyncStatus.synced:
            return Row(
              children: [
                Icon(Icons.cloud_done, color: Colors.green, size: 16),
                SizedBox(width: 4),
                Text('Synced', style: TextStyle(fontSize: 12, color: Colors.green)),
              ],
            );
          case SyncStatus.syncing:
            return Row(
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                SizedBox(width: 4),
                Text('Syncing...', style: TextStyle(fontSize: 12)),
              ],
            );
          case SyncStatus.offline:
            return Row(
              children: [
                Icon(Icons.cloud_off, color: Colors.orange, size: 16),
                SizedBox(width: 4),
                Text('Offline', style: TextStyle(fontSize: 12, color: Colors.orange)),
              ],
            );
          case SyncStatus.error:
            return Row(
              children: [
                Icon(Icons.error, color: Colors.red, size: 16),
                SizedBox(width: 4),
                Text('Sync Failed', style: TextStyle(fontSize: 12, color: Colors.red)),
              ],
            );
        }
      },
      loading: () => SizedBox(
        width: 16,
        height: 16,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
      error: (_, __) => Icon(Icons.error, color: Colors.red, size: 16),
    );
  }
}
```

---

| Term | Definition |
|------|-----------|
| **Transaction** | Single money movement (in/out) with amount, date, method |
| **Payment Method** | Account where money is stored (cash, bank, digital wallet) |
| **Bill/Receivable** | Money owed (utang) or expected (piutang) with due date |
| **Custody** | Money held on behalf of someone / money someone holds for you |
| **Balance** | Current amount in specific payment method |
| **Sync** | Synchronize data between local device and Firebase cloud |
| **Offline** | App continues working without internet (limited features) |

---

## 💡 Tips & Best Practices: Flutter + Firebase

### 1. Real-Time Data Sync with StreamProvider

**Problem:** Tanpa state management yang tepat, real-time updates dapat menyebabkan rebuild yang tidak perlu.

**Solution: Gunakan Riverpod StreamProvider untuk auto-update**

```dart
// ✅ GOOD: Real-time auto-update di semua device
final transactionsStreamProvider = StreamProvider<List<Transaction>>((ref) {
  return FirebaseFirestore.instance
      .collection('transactions')
      .orderBy('date', descending: true)
      .snapshots()
      .map((snapshot) {
        return snapshot.docs
            .map((doc) => Transaction.fromJson(doc.data()))
            .toList();
      });
});

// Widget akan otomatis rebuild ketika data berubah
@override
Widget build(BuildContext context, WidgetRef ref) {
  final transactionsAsync = ref.watch(transactionsStreamProvider);
  
  return transactionsAsync.when(
    data: (transactions) => ListView.builder(
      itemCount: transactions.length,
      itemBuilder: (context, index) => TransactionTile(transactions[index]),
    ),
    loading: () => LoadingIndicator(),
    error: (err, stack) => ErrorWidget(error: err),
  );
}
```

**Hasil:**
- User A tambah transaksi di HP → Database Firestore update
- Listener di Device A mendeteksi perubahan
- Stream emit data baru
- Widget rebuild otomatis dalam milliseconds
- User B di laptop/tablet langsung melihat update tanpa refresh! ⚡

---

### 2. Hindari Query Terlalu Sering - Pagination & Caching

**Problem:** Fetch seluruh data transaksi (1000+) setiap kali membuka halaman = lambat, mahal, baterai cepat habis

**Solution: Pagination & Segmentasi per Bulan**

```dart
// ✅ GOOD: Hanya ambil 50 transaksi bulan berjalan
final transactionsProvider = StreamProvider.family<List<Transaction>, DateTime>(
  (ref, month) {
    final startOfMonth = DateTime(month.year, month.month, 1);
    final endOfMonth = DateTime(month.year, month.month + 1, 0);

    return FirebaseFirestore.instance
        .collection('transactions')
        .where('date', isGreaterThanOrEqualTo: startOfMonth)
        .where('date', isLessThan: endOfMonth)
        .orderBy('date', descending: true)
        .limit(50) // Pagination
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Transaction.fromJson(doc.data()))
            .toList());
  },
);

// Firebase otomatis cache query yang sama
// Query kedua ke bulan yang sama = read dari cache (instant!) ⚡
```

**vs Cara Salah:**

```dart
// ❌ BAD: Fetch semua data
final allTransactions = await firestore.collection('transactions').get();
// Load 10,000+ records = lambat banget!

// ❌ BAD: Fetch ulang dari awal setiap kali
// Tidak ada caching = network call setiap kali
```

---

### 3. Optimize Filtering - Query di Database Level

**Problem: N+1 Query**

```dart
// ❌ BAD: Query per payment method
for (var method in paymentMethods) {
  final transactions = await firestore
      .collection('transactions')
      .where('paymentMethod', isEqualTo: method)
      .get(); // Query berulang = slow!
}

// ❌ BAD: Load all then filter in app
final allTransactions = await db.query('transactions'); // 10,000 records!
final filtered = allTransactions
    .where((t) => t.category == 'UANG_KELUAR')
    .toList();
```

**Solution: Query dengan multiple filters di database**

```dart
// ✅ GOOD: Single query dengan filters
final expensesThisMonth = await FirebaseFirestore.instance
    .collection('transactions')
    .where('category', isEqualTo: 'UANG_KELUAR')
    .where('date', isGreaterThanOrEqualTo: startOfMonth)
    .where('date', isLessThan: endOfMonth)
    .orderBy('date', descending: true)
    .get();

// Firebase otomatis suggest composite index jika diperlukan
// Efficient queries = fast results! ⚡
```

---

### 4. Batch Operations untuk Performance

**Problem: Sync 50 transaksi = 50 API calls**

```dart
// ❌ BAD: Write satu-satu
for (var transaction in pendingTransactions) {
  await firestore.collection('transactions').add(transaction);
  // 50 network round trips! Super slow!
}
```

**Solution: Batch writes**

```dart
// ✅ GOOD: Batch operation
WriteBatch batch = firestore.batch();

for (var transaction in pendingTransactions) {
  final docRef = firestore.collection('transactions').doc();
  batch.set(docRef, transaction);
}

await batch.commit(); // Satu network call saja! ⚡
```

---

### 5. Leverage Firestore Built-in Cache

```dart
// First query: Network request
final data1 = await firestore.collection('transactions').get();

// Subsequent query (same): Read from cache (instant!) ⚡
final data2 = await firestore.collection('transactions').get();

// Force refresh dari server:
final data3 = await firestore.collection('transactions')
    .get(GetOptions(source: Source.server));
```

---

### 6. Security Rules Best Practice

```firestore
rules_version = '2';

service cloud.firestore {
  match /databases/{database}/documents {
    // User hanya bisa akses data mereka sendiri
    match /transactions/{userId}/{document=**} {
      allow read, write: if request.auth.uid == userId;
      
      // Validate structure
      allow create: if request.resource.data.keys().hasAll(['description', 'nominal']);
    }
  }
}
```

---

### 7. Testing dengan Firebase Emulator

```dart
// ✅ GOOD: Use emulator untuk testing (gratis, cepat, no quota)
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  if (kDebugMode) {
    await Firebase.initializeApp();
    FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
    FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
  }
  
  runApp(MyApp());
}

// Tests jalan super cepat, tanpa internet! ⚡
```

---

## 🎨 Color Palette & Design System

### Recommended Color Palette

**Primary Colors:**
```
🟢 Success/Income (Uang Masuk)
   Main: #22C55E (Emerald 500)
   Light: #DCFCE7 (Emerald 100)
   Dark: #15803D (Emerald 700)

🔴 Danger/Expense (Uang Keluar)
   Main: #EF4444 (Red 500)
   Light: #FEE2E2 (Red 100)
   Dark: #991B1B (Red 900)

🔵 Primary/Accent
   Main: #3B82F6 (Blue 500)
   Light: #DBEAFE (Blue 100)
   Dark: #1E40AF (Blue 800)

⚪ Neutral/Base
   Primary: #1F2937 (Gray 800)
   Secondary: #6B7280 (Gray 500)
   Light: #F9FAFB (Gray 50)
```

**Complete Color Tokens:**

```dart
// lib/presentation/styles/app_colors.dart

class AppColors {
  // Income (Uang Masuk)
  static const Color incomeMain = Color(0xFF22C55E);      // Emerald 500
  static const Color incomeLight = Color(0xFFDCFCE7);     // Emerald 100
  static const Color incomeDark = Color(0xFF15803D);      // Emerald 700
  static const Color incomeHover = Color(0xFF16A34A);     // Emerald 600

  // Expense (Uang Keluar)
  static const Color expenseMain = Color(0xFFEF4444);     // Red 500
  static const Color expenseLight = Color(0xFFFEE2E2);    // Red 100
  static const Color expenseDark = Color(0xFF991B1B);     // Red 900
  static const Color expenseHover = Color(0xFFDC2626);    // Red 600

  // Primary/Brand
  static const Color primary = Color(0xFF3B82F6);         // Blue 500
  static const Color primaryLight = Color(0xFFDBEAFE);    // Blue 100
  static const Color primaryDark = Color(0xFF1E40AF);     // Blue 800
  static const Color primaryHover = Color(0xFF2563EB);    // Blue 600

  // Neutral
  static const Color neutral900 = Color(0xFF111827);      // Gray 900
  static const Color neutral800 = Color(0xFF1F2937);      // Gray 800
  static const Color neutral700 = Color(0xFF374151);      // Gray 700
  static const Color neutral600 = Color(0xFF4B5563);      // Gray 600
  static const Color neutral500 = Color(0xFF6B7280);      // Gray 500
  static const Color neutral400 = Color(0xFF9CA3AF);      // Gray 400
  static const Color neutral300 = Color(0xFFD1D5DB);      // Gray 300
  static const Color neutral200 = Color(0xFFE5E7EB);      // Gray 200
  static const Color neutral100 = Color(0xFFF3F4F6);      // Gray 100
  static const Color neutral50 = Color(0xFFF9FAFB);       // Gray 50

  // Semantic
  static const Color success = incomeMain;
  static const Color error = expenseMain;
  static const Color warning = Color(0xFFFACC15);         // Amber 400
  static const Color info = primary;

  // Status
  static const Color offline = Color(0xFFF97316);         // Orange 500
  static const Color syncing = Color(0xFF8B5CF6);         // Purple 500
  static const Color synced = incomeMain;

  // Payment Methods
  static const Map<String, Color> paymentMethodColors = {
    'Cash': Color(0xFFFCD34D),                             // Amber 300
    'Bank Mandiri': Color(0xFF FF6B6B),                    // Red
    'Bank Jatim': Color(0xFF3A86FF),                       // Blue
    'Bank Jago': Color(0xFF00D9FF),                        // Cyan
    'Dana': Color(0xFF8338EC),                             // Purple
    'SEA BANK': Color(0xFF2DD4BF),                         // Teal
  };
}
```

---

### Usage Examples

**Transaction Item Card:**

```dart
class TransactionItem extends StatelessWidget {
  final Transaction transaction;

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.category == 'UANG_MASUK';
    final bgColor = isIncome ? AppColors.incomeLight : AppColors.expenseLight;
    final textColor = isIncome ? AppColors.incomeMain : AppColors.expenseMain;
    final iconColor = isIncome ? AppColors.incomeMain : AppColors.expenseMain;

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: textColor.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          // Icon
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              isIncome ? Icons.arrow_downward : Icons.arrow_upward,
              color: Colors.white,
            ),
          ),
          SizedBox(width: 12),
          
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.description,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.neutral800,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  transaction.paymentMethod,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.neutral500,
                  ),
                ),
              ],
            ),
          ),
          
          // Amount
          Text(
            '${isIncome ? '+' : '-'} Rp ${transaction.nominal}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}
```

**Balance Card:**

```dart
class BalanceCard extends StatelessWidget {
  final String methodName;
  final int balance;

  @override
  Widget build(BuildContext context) {
    final color = AppColors.paymentMethodColors[methodName] ?? AppColors.primary;

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.9),
            color.withOpacity(0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            methodName,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.9),
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Rp ${balance.toString()}',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
```

**Dashboard Status Indicator:**

```dart
class SyncStatusBadge extends StatelessWidget {
  final SyncStatus status;

  @override
  Widget build(BuildContext context) {
    late Color bgColor;
    late Color textColor;
    late IconData icon;
    late String label;

    switch (status) {
      case SyncStatus.synced:
        bgColor = AppColors.incomeLight;
        textColor = AppColors.incomeMain;
        icon = Icons.cloud_done;
        label = 'Tersinkron';
        break;

      case SyncStatus.syncing:
        bgColor = Color(0xFFF3E8FF); // Purple 100
        textColor = AppColors.syncing;
        icon = Icons.cloud_upload;
        label = 'Menyinkron...';
        break;

      case SyncStatus.offline:
        bgColor = Color(0xFFFEF3C7); // Amber 100
        textColor = AppColors.offline;
        icon = Icons.cloud_off;
        label = 'Offline';
        break;

      case SyncStatus.error:
        bgColor = AppColors.expenseLight;
        textColor = AppColors.expenseMain;
        icon = Icons.error;
        label = 'Gagal Sinkron';
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: textColor.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: textColor),
          SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}
```

---

### Dark Mode Support

```dart
// lib/presentation/styles/app_theme.dart

class AppTheme {
  static ThemeData lightTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.neutral600,
        tertiary: AppColors.primary,
        error: AppColors.error,
        surface: AppColors.neutral50,
        background: AppColors.neutral50,
      ),
      scaffoldBackgroundColor: AppColors.neutral50,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.neutral800,
        elevation: 0,
      ),
    );
  }

  static ThemeData darkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: AppColors.primaryLight,
        secondary: AppColors.neutral400,
        tertiary: AppColors.primaryLight,
        error: AppColors.expenseLight,
        surface: AppColors.neutral800,
        background: AppColors.neutral900,
      ),
      scaffoldBackgroundColor: AppColors.neutral900,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.neutral800,
        foregroundColor: AppColors.neutral50,
        elevation: 0,
      ),
    );
  }
}
```

---

### Accessibility Considerations

```dart
// ✅ Ensure sufficient contrast
// Income text on income light: #22C55E on #DCFCE7 = WCAG AA ✓
// Expense text on expense light: #EF4444 on #FEE2E2 = WCAG AA ✓

// ✅ Color-blind friendly
// Don't rely on color alone
// Use icons + text labels + patterns

class TransactionIcon extends StatelessWidget {
  final bool isIncome;

  @override
  Widget build(BuildContext context) {
    return Icon(
      isIncome ? Icons.arrow_downward : Icons.arrow_upward,
      color: isIncome ? AppColors.incomeMain : AppColors.expenseMain,
      semanticLabel: isIncome ? 'Income' : 'Expense',
    );
  }
}
```

---

### Color Reference Table

| Component | Light Mode | Dark Mode | Usage |
|-----------|-----------|----------|-------|
| **Income** | #22C55E (Emerald) | #10B981 (Emerald 600) | Transactions masuk, positive balance |
| **Expense** | #EF4444 (Red) | #F87171 (Red 400) | Transactions keluar, debt |
| **Primary** | #3B82F6 (Blue) | #60A5FA (Blue 400) | Buttons, primary actions |
| **Neutral** | #1F2937 (Gray 800) | #F9FAFB (Gray 50) | Text, secondary content |
| **Success** | #22C55E | #10B981 | Sync success, confirmations |
| **Warning** | #FACC15 (Amber) | #FCD34D (Amber 300) | Offline mode, due bills |
| **Error** | #EF4444 | #F87171 | Sync errors, validation |

---

## 🔄 Review & Approval

| Role | Name | Status | Date |
|------|------|--------|------|
| Product Owner | - | Pending | - |
| Tech Lead | - | Pending | - |
| Designer | - | Pending | - |

---

## 📎 Appendices

### A. Firebase Pricing Estimation

**Firestore:**
- Reads: ~1000/day (user browsing) = 30,000/month
- Writes: ~30/day (transactions) = 900/month
- Deletes: ~10/day = 300/month
- Total: 31,200 ops/month < 50k free tier ✅

**Firebase Auth:**
- Users: 1 (personal use) ✅ Free tier

**Cloud Storage:**
- Data: ~10MB/month (transaction records) ✅ Free tier (1GB)

**Estimated Cost:** Free (stays within free tier)

### B. Migration Data Mapping

| Excel Column | Firestore Field | Type | Notes |
|---|---|---|---|
| No | - | - | Auto-generated ID |
| Keterangan | description | string | |
| Penggunaan | - | - | Merge to description |
| Kategori | category | enum | Uang Masuk / Uang Keluar |
| Pembayaran | paymentMethodId / paymentMethodName | string | Match ke `paymentMethods` collection; buat method baru jika belum ada |
| Tanggal | date | timestamp | |
| Nominal | nominal | number | |
| Notes | notes | string | Additional notes |

---

**Document Version:** 1.0  
**Last Updated:** June 2026  
**Next Review:** After Phase 0 completion
