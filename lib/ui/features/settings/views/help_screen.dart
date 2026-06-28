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
              'Tap tombol "+" di tab Transaksi atau tombol "Transaksi" di Beranda.'),
          _faqItem(context, 'Apa itu Titipan?',
              'Titipan adalah uang yang diterima/diberikan ke orang lain dan perlu dilacak pergerakannya.'),
          _faqItem(context, 'Bagaimana cara transfer antar rekening?',
              'Di Beranda, tap "Transfer Antar Rekening". Pilih rekening asal, tujuan, dan nominal.'),
          _faqItem(context, 'Apakah data tersimpan offline?',
              'Ya. Data tersimpan lokal di SQLite. Saat online, data otomatis tersinkron ke Firebase.'),
          _faqItem(context, 'Bagaimana cara export data?',
              'Buka Laporan → tap ikon download (CSV) di pojok kanan atas.'),
          _faqItem(context, 'Bagaimana cara ganti password?',
              'Buka Pengaturan → Ganti Password.'),

          const SizedBox(height: 16),

          // Fitur section
          _sectionHeader(context, 'Fitur Utama'),
          _featureItem(context, Icons.receipt_long, 'Transaksi',
              'Catat pemasukan & pengeluaran dengan metode pembayaran.'),
          _featureItem(context, Icons.credit_card, 'Tagihan',
              'Track hutang & piutang dengan progress pembayaran.'),
          _featureItem(context, Icons.swap_horiz, 'Titipan',
              'Kelola uang titipan masuk & keluar.'),
          _featureItem(context, Icons.bar_chart, 'Laporan',
              'Ringkasan bulanan, chart, & breakdown per rekening.'),
          _featureItem(context, Icons.sync, 'Sinkronisasi',
              'Data otomatis sync ke cloud saat koneksi tersedia.'),

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
