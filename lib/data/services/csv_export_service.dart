import '../../domain/models/transaction_model.dart';

class CsvExportService {
  /// Export transactions to CSV string
  static String exportTransactions(List<TransactionModel> transactions) {
    final buffer = StringBuffer();
    
    // Header
    buffer.writeln('Tanggal,Keterangan,Kategori,Metode Pembayaran,Nominal,Catatan');
    
    // Data rows
    for (final t in transactions) {
      final date = '${t.date.day}/${t.date.month}/${t.date.year}';
      final category = t.category == TransactionCategory.income ? 'Pemasukan' : 'Pengeluaran';
      final description = _escapeCsv(t.description);
      final paymentMethod = _escapeCsv(t.paymentMethodName);
      final notes = _escapeCsv(t.notes ?? '');
      
      buffer.writeln('$date,$description,$category,$paymentMethod,${t.nominal},$notes');
    }
    
    return buffer.toString();
  }

  static String _escapeCsv(String value) {
    if (value.contains(',') || value.contains('"') || value.contains('\n')) {
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
  }
}
