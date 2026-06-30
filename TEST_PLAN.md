# Test Plan: Offline/Online Sync

## TASK 1 — Payment Method Offline CRUD
**Pre:** Login online → matikan internet

| # | Action | Expected |
|---|--------|----------|
| 1 | Buka PM screen | Data lama tampil |
| 2 | Tambah PM pertama | Muncul di list |
| 3 | Tambah PM kedua | **Keduanya** tampil |
| 4 | Tambah PM ketiga | **Ketiganya** tampil |
| 5 | Hapus PM (soft delete) | Hilang dari list |
| 6 | Hapus PM permanent | Hilang, tidak kembali |
| 7 | Nyalakan internet | Semua PM sync ke Firestore |

---

## TASK 2 — Custody (Titipan) Offline
**Pre:** Login online → matikan internet

| # | Action | Expected |
|---|--------|----------|
| 1 | Create custody baru | Tampil di list |
| 2 | Tambah pergerakan masuk | Balance bertambah |
| 3 | Tambah pergerakan keluar | Balance berkurang |
| 4 | Nyalakan internet | Custody + pergerakan sync |
| 5 | Cek Firestore console | Doc ada di `custody/{userId}/items` |

---

## TASK 3 — Custody Online Create
**Pre:** Online

| # | Action | Expected |
|---|--------|----------|
| 1 | Create custody | Langsung tampil |
| 2 | Refresh screen | Data tetap ada |
| 3 | Cek Firestore | Doc tersimpan |

---

## TASK 4 — Tabungan (Savings)
**Pre:** Ada data tabungan lama di Firestore (sebelum field `isActive` ada)

| # | Action | Expected |
|---|--------|----------|
| 1 | Buka tabungan screen online | **Semua** data lama tampil |
| 2 | Tambah tabungan baru | Tampil di list |
| 3 | Offline → buka tabungan | Data tetap ada dari SQLite |
| 4 | Tambah tabungan offline | Tampil, sync saat online |

---

## TASK 5 — Tagihan Hutang + Piutang
**Pre:** Online, ada PM aktif

| # | Action | Expected |
|---|--------|----------|
| 1 | Buat tagihan **hutang** | Status: Belum Bayar |
| 2 | Bayar sebagian hutang | Progress bar **biru** partial, label "Dibayar" |
| 3 | Bayar lunas hutang | Progress bar **hijau**, status Lunas |
| 4 | Cek transaksi | Ada **expense** dengan PM dipilih |
| 5 | Buat tagihan **piutang** | Status: Belum Bayar |
| 6 | Terima sebagian piutang | Progress bar **teal** partial, label "Diterima" |
| 7 | Terima lunas piutang | Progress bar **hijau** |
| 8 | Cek transaksi | Ada **income** dengan PM dipilih |

---

## TASK 6 — Full Offline → Online Sync
**Pre:** Fresh state (pending_operations kosong)

| # | Action | Expected |
|---|--------|----------|
| 1 | Offline: buat PM | Tampil lokal |
| 2 | Offline: buat custody + pergerakan | Tampil lokal |
| 3 | Offline: buat transaksi | Tampil lokal |
| 4 | Offline: buat tagihan | Tampil lokal |
| 5 | Nyalakan internet | SyncEngine jalan otomatis |
| 6 | Tunggu sync selesai | Pending count → 0 |
| 7 | Cek Firestore console | Semua data ada |
| 8 | Login device lain | Data sama persis |

---

## TASK 7 — Regression: Toggle Online/Offline
**Pre:** Online dengan data penuh

| # | Action | Expected |
|---|--------|----------|
| 1 | Online: cek semua fitur | Tampil normal |
| 2 | Matikan internet | Data tetap ada |
| 3 | Tambah data offline (PM, transaksi) | Data baru tampil |
| 4 | Nyalakan internet | Data lama + baru tampil semua |
| 5 | Matikan internet lagi | Semua data tetap ada |
| 6 | Nyalakan internet | Tidak ada data hilang |

---

## Urutan Eksekusi
```
Task 1 → Task 2 → Task 3 → Task 4 → Task 5 → Task 6 → Task 7
```

## Checklist Known Bugs (sudah fix)
- [x] PM offline create ke-2+ tertimpa (id='' → UUID)
- [x] Tabungan hilang online (filter isActive client-side)
- [x] Custody movement tidak sync (custodyMovementDao.markAsSynced)
- [x] Movement queue skip jika custodyFirebaseDocId null
- [x] PM permanent delete offline tidak queue
- [x] PM stream race condition (pure Future-based load)
- [x] Piutang label "Diterima" + progress teal
