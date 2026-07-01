import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bantuan')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // FAQ section
          _sectionHeader(context, 'FAQ'),
          _faqItem(context, 'Bagaimana cara menambah transaksi?',
              'Tap tombol "+" di tab Transaksi atau tombol "Transaksi" di Beranda. Pilih kategori Uang Masuk atau Uang Keluar, isi nominal, pilih metode pembayaran & kategori, lalu simpan.'),
          _faqItem(context, 'Bagaimana cara mencatat hutang atau piutang?',
              'Buka menu Tagihan → tap "+". Pilih tipe Hutang (kamu berhutang) atau Piutang (orang lain berhutang ke kamu). Isi nominal, tanggal jatuh tempo, dan metode pembayaran.'),
          _faqItem(context, 'Bagaimana cara bayar hutang/piutang?',
              'Buka Tagihan → tap tagihan yang ingin dibayar → tap "Bayar". Sistem otomatis mencatat transaksi pembayaran dan mengurangi saldo rekening yang dipilih.'),
          _faqItem(context, 'Apa itu Titipan?',
              'Titipan adalah uang yang diterima atau diberikan ke orang lain dan perlu dilacak. Contoh: menitipkan uang ke teman atau menerima titipan. Buka menu Titipan → tap "+" untuk mulai mencatat.'),
          _faqItem(context, 'Bagaimana cara transfer antar rekening?',
              'Di Beranda, tap "Transfer Antar Rekening". Pilih rekening asal, rekening tujuan, nominal, dan biaya transfer jika ada.'),
          _faqItem(context, 'Apakah data tersimpan saat offline?',
              'Ya. Semua transaksi tersimpan langsung ke perangkat (SQLite). Saat koneksi tersedia, data otomatis tersinkron ke cloud (Firebase). Tidak ada data yang hilang selama offline.'),
          _faqItem(context, 'Kenapa saldo baru muncul setelah kembali online?',
              'Saldo selalu dihitung dari data lokal di perangkat. Jika ada transaksi offline yang belum sync, saldo sudah terhitung benar. Tidak perlu khawatir — data aman.'),
          _faqItem(context, 'Bagaimana cara mengatur kategori pengeluaran?',
              'Buka menu Lainnya → Kategori. Kamu bisa tambah, edit, atau hapus kategori sesuai kebutuhan. Kategori preset (bawaan) tidak bisa dihapus.'),
          _faqItem(context, 'Apa itu Anggaran Bulanan?',
              'Fitur untuk menetapkan batas pengeluaran per kategori setiap bulan. Buka Lainnya → Anggaran Bulanan. App akan memberikan notifikasi saat mendekati atau melewati batas.'),
          _faqItem(context, 'Apa itu Batas Pengeluaran?',
              'Batas maksimal pengeluaran dalam periode tertentu. Berbeda dengan Anggaran Bulanan yang per kategori, Batas Pengeluaran bisa diatur per rekening atau keseluruhan.'),
          _faqItem(context, 'Bagaimana cara menabung?',
              'Buka Lainnya → Rencana Tabungan → tap "+". Isi target nominal dan tanggal target. Tambah alokasi tabungan secara berkala untuk melacak progres.'),
          _faqItem(context, 'Bagaimana cara export data ke Excel/CSV?',
              'Buka Laporan → tap ikon unduh (⬇) di pojok kanan atas. File CSV akan tersimpan di perangkat dan bisa dibuka di Excel atau Google Sheets.'),
          _faqItem(context, 'Bagaimana cara ganti password?',
              'Buka Lainnya → Pengaturan → Ganti Password. Masukkan password lama dan password baru.'),
          _faqItem(context, 'Bagaimana jika lupa password?',
              'Di halaman login, tap "Lupa Password". Masukkan email yang terdaftar — link reset password akan dikirim ke email kamu.'),
          _faqItem(context, 'Apakah data aman jika ganti HP atau reinstall?',
              'Ya. Semua data tersimpan di cloud (Firebase). Cukup login dengan akun yang sama di HP baru — data akan otomatis tersinkron kembali ke perangkat.'),

          const SizedBox(height: 16),

          // Fitur section
          _sectionHeader(context, 'Fitur Utama'),
          _featureItem(context, Icons.receipt_long, 'Transaksi',
              'Catat pemasukan & pengeluaran dengan kategori dan metode pembayaran. Mendukung filter, pencarian, dan laporan per periode.'),
          _featureItem(context, Icons.credit_card, 'Tagihan',
              'Kelola hutang & piutang dengan tracking progress pembayaran, tanggal jatuh tempo, dan notifikasi otomatis.'),
          _featureItem(context, Icons.account_balance_wallet, 'Titipan',
              'Lacak uang titipan masuk & keluar lengkap dengan riwayat pergerakan dan saldo terkini.'),
          _featureItem(context, Icons.swap_horiz, 'Transfer Rekening',
              'Transfer antar rekening/metode pembayaran dengan pencatatan biaya transfer otomatis.'),
          _featureItem(context, Icons.category, 'Kategori',
              'Organisir transaksi dengan kategori custom. Tersedia kategori preset + bisa tambah kategori sendiri.'),
          _featureItem(context, Icons.pie_chart, 'Anggaran Bulanan',
              'Tetapkan batas pengeluaran per kategori setiap bulan. Monitor progres secara real-time di dashboard.'),
          _featureItem(context, Icons.savings, 'Rencana Tabungan',
              'Buat target tabungan dengan nominal & deadline. Tambah alokasi dan pantau progres pencapaian.'),
          _featureItem(context, Icons.bar_chart, 'Laporan',
              'Ringkasan bulanan, grafik tren, breakdown per kategori & rekening, dan ekspor CSV.'),
          _featureItem(context, Icons.sync, 'Sinkronisasi Otomatis',
              'Data tersimpan offline-first di perangkat. Otomatis sync ke cloud saat koneksi tersedia — tidak ada data yang hilang.'),
          _featureItem(context, Icons.notifications, 'Notifikasi',
              'Pengingat tagihan jatuh tempo, peringatan batas pengeluaran, dan update status sync.'),

          const SizedBox(height: 16),

          // Contact section
          _sectionHeader(context, 'Hubungi Developer'),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.person, color: Colors.blue),
                      SizedBox(width: 8),
                      Text('resetjarakjauhDev',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text('Dukung pengembang:',
                      style: TextStyle(color: Colors.grey, fontSize: 13)),
                  const SizedBox(height: 8),
                  InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () {
                      Clipboard.setData(const ClipboardData(
                          text: 'https://saweria.co/Atoilahputra'));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Link Saweria disalin ke clipboard'),
                          backgroundColor: Colors.green,
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.orange.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.favorite, color: Colors.orange.shade700),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Saweria',
                                    style: TextStyle(
                                      color: Colors.orange.shade700,
                                      fontWeight: FontWeight.bold,
                                    )),
                                Text('saweria.co/Atoilahputra',
                                    style: TextStyle(
                                      color: Colors.orange.shade600,
                                      fontSize: 12,
                                    )),
                              ],
                            ),
                          ),
                          Icon(Icons.copy, size: 16,
                              color: Colors.orange.shade700),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 4),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _faqItem(BuildContext context, String question, String answer) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ExpansionTile(
        title: Text(question,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(answer,
                style: TextStyle(color: Colors.grey.shade700, fontSize: 13)),
          ),
        ],
      ),
    );
  }

  Widget _featureItem(BuildContext context, IconData icon, String title,
      String description) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        child: Icon(icon,
            color: Theme.of(context).colorScheme.primary, size: 20),
      ),
      title: Text(title,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
      subtitle: Text(description, style: const TextStyle(fontSize: 13)),
    );
  }
}

