import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../data/local/transaction_dao.dart';
import '../../../../domain/models/bill_model.dart';
import '../../../../domain/models/transaction_model.dart';

class BillHistoryScreen extends StatefulWidget {
  final String userId;
  final BillModel bill;

  const BillHistoryScreen({
    super.key,
    required this.userId,
    required this.bill,
  });

  @override
  State<BillHistoryScreen> createState() => _BillHistoryScreenState();
}

class _BillHistoryScreenState extends State<BillHistoryScreen> {
  final _dao = TransactionDao();
  final _currencyFormat =
      NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
  final _dateFormat = DateFormat('dd MMM yyyy, HH:mm', 'id_ID');

  List<TransactionModel> _transactions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    try {
      // Search by bill name — transaksi dicatat dengan description mengandung nama bill
      final rows = await _dao.search(widget.userId, widget.bill.name);
      setState(() {
        _transactions = rows
            .map((r) => TransactionModelExtension.fromSqlite(r))
            .toList()
          ..sort((a, b) => b.date.compareTo(a.date));
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bill = widget.bill;
    final totalPaid = _transactions
        .where((t) => t.category == TransactionCategory.expense ||
            t.category == TransactionCategory.income)
        .fold<int>(0, (sum, t) => sum + t.nominal);

    return Scaffold(
      appBar: AppBar(
        title: Text('Riwayat: ${bill.name}'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Summary card
                _buildSummary(bill, totalPaid),
                const Divider(height: 1),
                // Transaction list
                Expanded(
                  child: _transactions.isEmpty
                      ? _buildEmpty()
                      : ListView.separated(
                          padding: const EdgeInsets.all(12),
                          itemCount: _transactions.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: 8),
                          itemBuilder: (_, i) =>
                              _buildTxCard(_transactions[i]),
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildSummary(BillModel bill, int totalPaid) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _typeBadge(bill),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  bill.name,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              _statusChip(bill),
            ],
          ),
          const SizedBox(height: 12),
          if (bill.type == BillType.tagihan) ...[
            _summaryRow(
              'Nominal per Cicilan',
              _currencyFormat
                  .format(bill.installmentAmount ?? bill.nominal),
            ),
            if (bill.maxInstallments != null) ...[
              _summaryRow(
                'Cicilan Dibayar',
                '${bill.installmentsPaid} / ${bill.maxInstallments} bulan',
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: bill.installmentsPaid / bill.maxInstallments!,
                  backgroundColor: Colors.grey.shade200,
                  color: Colors.orange,
                  minHeight: 6,
                ),
              ),
            ] else
              _summaryRow(
                  'Total Dibayar', '${bill.installmentsPaid} bulan'),
          ] else ...[
            _summaryRow(
                'Total Tagihan', _currencyFormat.format(bill.nominal)),
            _summaryRow(
                'Sudah Dibayar', _currencyFormat.format(bill.paidAmount)),
            _summaryRow(
              'Sisa',
              _currencyFormat.format(bill.remainingAmount),
              valueColor: bill.remainingAmount > 0 ? Colors.red : Colors.green,
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: bill.paymentProgress,
                backgroundColor: Colors.grey.shade200,
                color: bill.paymentProgress >= 1.0
                    ? Colors.green
                    : Theme.of(context).colorScheme.primary,
                minHeight: 6,
              ),
            ),
          ],
          const SizedBox(height: 4),
          Text(
            '${_transactions.length} transaksi tercatat',
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value, {Color? valueColor}) =>
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: Colors.grey.shade600)),
            Text(
              value,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: valueColor,
                  ),
            ),
          ],
        ),
      );

  Widget _buildTxCard(TransactionModel tx) {
    final isIncome = tx.category == TransactionCategory.income;
    final color = isIncome ? Colors.green : Colors.red;
    final prefix = isIncome ? '+' : '-';

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
            color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                isIncome
                    ? Icons.arrow_downward_rounded
                    : Icons.arrow_upward_rounded,
                color: color,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tx.description,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(fontWeight: FontWeight.w500),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${tx.paymentMethodName} · ${_dateFormat.format(tx.date)}',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: Colors.grey),
                  ),
                  if (tx.notes != null && tx.notes!.isNotEmpty)
                    Text(
                      tx.notes!,
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: Colors.grey.shade500),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Nominal
            Text(
              '$prefix${_currencyFormat.format(tx.nominal)}',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.receipt_long_outlined,
                size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 12),
            Text('Belum ada riwayat transaksi',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(color: Colors.grey)),
            const SizedBox(height: 4),
            Text('Transaksi akan muncul setelah pembayaran dicatat',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: Colors.grey)),
          ],
        ),
      );

  Widget _typeBadge(BillModel bill) {
    final Color bg;
    final Color fg;
    switch (bill.type) {
      case BillType.hutang:
        bg = Colors.blue.shade50;
        fg = Colors.blue.shade700;
      case BillType.piutang:
        bg = Colors.teal.shade50;
        fg = Colors.teal.shade700;
      case BillType.tagihan:
        bg = Colors.orange.shade50;
        fg = Colors.orange.shade700;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
          color: bg, borderRadius: BorderRadius.circular(6)),
      child: Text(bill.type.displayName,
          style: TextStyle(
              fontSize: 11, color: fg, fontWeight: FontWeight.w600)),
    );
  }

  Widget _statusChip(BillModel bill) {
    final Color color;
    switch (bill.status) {
      case BillStatus.paid:
        color = Colors.green;
      case BillStatus.partial:
        color = Colors.orange;
      case BillStatus.unpaid:
        color = bill.isOverdue ? Colors.red : Colors.grey;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3))),
      child: Text(bill.status.displayName,
          style: TextStyle(
              fontSize: 11, color: color, fontWeight: FontWeight.w600)),
    );
  }
}
