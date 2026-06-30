import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../data/services/bill_service.dart';
import '../../../../data/services/payment_method_service.dart';
import '../../../../data/repositories/bill_repository.dart';
import '../../../../data/repositories/payment_method_repository.dart';
import '../../../../domain/models/bill_model.dart';
import '../../../../domain/models/payment_method_model.dart';
import '../../../core/dialogs.dart';
import '../../../core/currency_input_formatter.dart';
import '../../../core/widgets.dart';
import '../view_models/bill_view_model.dart';
import 'add_edit_bill_screen.dart';
import 'bill_history_screen.dart';

class BillsScreen extends StatefulWidget {
  final String userId;
  const BillsScreen({super.key, required this.userId});

  @override
  State<BillsScreen> createState() => _BillsScreenState();
}

class _BillsScreenState extends State<BillsScreen>
    with SingleTickerProviderStateMixin {
  late final BillViewModel _viewModel;
  late final TabController _tabController;

  final _currencyFormat =
      NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
  final _dateFormat = DateFormat('dd MMM yyyy', 'id_ID');

  // Filter state per tipe — 0=Semua, 1=Belum Lunas, 2=Lunas
  final Map<BillType, int> _filterIndex = {
    BillType.hutang: 0,
    BillType.piutang: 0,
    BillType.tagihan: 0,
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _viewModel = BillViewModel(
      repository: BillRepository(service: BillService()),
      userId: widget.userId,
    );
    _viewModel.init();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  void _navigateToAddEdit({BillModel? bill}) async {
    final result = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (_) => AddEditBillScreen(userId: widget.userId, bill: bill),
      ),
    );
    if (result != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(result),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ));
      _viewModel.init();
    }
  }

  Future<void> _handleDelete(BillModel bill) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Hapus ${bill.type.displayName}'),
        content: Text('Yakin hapus "${bill.name}"?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Batal')),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      try {
        await _viewModel.deleteBill(bill);
        if (mounted) {
          await showSuccessDialog(context,
              title: 'Berhasil Dihapus',
              message: '"${bill.name}" berhasil dihapus.',
              icon: Icons.delete_outline);
        }
      } catch (e) {
        if (mounted) await showErrorDialog(context, message: e.toString());
      }
    }
  }

  Future<void> _handlePay(BillModel bill) async {
    List<PaymentMethodModel> methods = [];
    try {
      final all = await PaymentMethodRepository(service: PaymentMethodService())
          .getAllPaymentMethods(widget.userId);
      methods = all.where((m) => m.isActive).toList();
    } catch (_) {}

    if (!mounted) return;

    if (methods.isEmpty) {
      await showErrorDialog(context,
          title: 'Tidak Ada Metode Pembayaran',
          message: 'Tambah metode pembayaran terlebih dahulu.');
      return;
    }

    final result = await showDialog<_PayResult>(
      context: context,
      builder: (_) => _PayDialog(
        bill: bill,
        paymentMethods: methods,
        currencyFormat: _currencyFormat,
      ),
    );

    if (result != null && result.amount > 0 && mounted) {
      try {
        await _viewModel.payBill(bill, result.amount, result.method,
            transferFee: result.transferFee);
        if (mounted) {
          final totalDesc = result.transferFee > 0
              ? '${_currencyFormat.format(result.amount)} + biaya transfer ${_currencyFormat.format(result.transferFee)}'
              : _currencyFormat.format(result.amount);

          String title;
          if (bill.type == BillType.hutang) {
            title = 'Pembayaran Berhasil';
          } else if (bill.type == BillType.piutang) {
            title = 'Penerimaan Berhasil';
          } else {
            title = 'Tagihan Dibayar';
          }

          await showSuccessDialog(context,
              title: title,
              message: '$totalDesc untuk "${bill.name}" telah dicatat.',
              icon: Icons.check_circle);
          _viewModel.init();
        }
      } catch (e) {
        if (mounted) await showErrorDialog(context, message: e.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tagihan & Pinjaman'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Hutang'),
            Tab(text: 'Piutang'),
            Tab(text: 'Tagihan'),
          ],
        ),
      ),
      body: ListenableBuilder(
        listenable: _viewModel,
        builder: (context, _) {
          if (_viewModel.isLoading && _viewModel.bills.isEmpty) {
            return const LoadingListWidget();
          }
          return TabBarView(
            controller: _tabController,
            children: [
              _buildTypeList(BillType.hutang),
              _buildTypeList(BillType.piutang),
              _buildTypeList(BillType.tagihan),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'bills_fab',
        onPressed: () => _navigateToAddEdit(),
        icon: const Icon(Icons.add),
        label: const Text('Tambah'),
      ),
    );
  }

  Widget _buildTypeList(BillType type) {
    final all = _viewModel.bills
        .where((b) => b.type == type && !b.isDeleted)
        .toList()
      ..sort((a, b) => a.dueDate.compareTo(b.dueDate));

    if (all.isEmpty) return _buildEmptyState(type);

    final filterIdx = _filterIndex[type]!;
    final filtered = switch (filterIdx) {
      1 => all.where((b) => b.status != BillStatus.paid).toList(),
      2 => all.where((b) => b.status == BillStatus.paid).toList(),
      _ => all,
    };

    final unpaid = filtered.where((b) => b.status != BillStatus.paid).toList();
    final paid   = filtered.where((b) => b.status == BillStatus.paid).toList();

    return Column(
      children: [
        // Filter chips
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          alignment: Alignment.centerLeft,
          child: Wrap(
            spacing: 8,
            children: [
              _filterChip(type, 0, 'Semua'),
              _filterChip(type, 1, type == BillType.tagihan ? 'Aktif' : 'Belum Lunas'),
              _filterChip(type, 2, 'Lunas'),
            ],
          ),
        ),
        const Divider(height: 1),
        // List
        Expanded(
          child: filtered.isEmpty
              ? Center(
                  child: Text(
                    'Tidak ada data',
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: Colors.grey),
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.all(12),
                  children: [
                    if (unpaid.isNotEmpty && filterIdx != 2) ...[
                      _sectionHeader(
                          type == BillType.tagihan ? 'Aktif' : 'Belum Lunas',
                          unpaid.length),
                      ...unpaid.map((b) => _buildCard(b, showPay: true)),
                    ],
                    if (paid.isNotEmpty && filterIdx != 1) ...[
                      if (unpaid.isNotEmpty && filterIdx == 0)
                        const SizedBox(height: 8),
                      _sectionHeader('Lunas', paid.length),
                      ...paid.map((b) => _buildCard(b, showPay: false)),
                    ],
                  ],
                ),
        ),
      ],
    );
  }

  Widget _filterChip(BillType type, int index, String label) {
    return FilterChip(
      label: Text(label),
      selected: _filterIndex[type] == index,
      onSelected: (_) => setState(() => _filterIndex[type] = index),
      showCheckmark: false,
      visualDensity: VisualDensity.compact,
    );
  }

  Widget _sectionHeader(String title, int count) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Row(
          children: [
            Text(title,
                style: Theme.of(context)
                    .textTheme
                    .titleSmall
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(width: 8),
            Chip(
              label: Text('$count'),
              padding: EdgeInsets.zero,
              visualDensity: VisualDensity.compact,
            ),
          ],
        ),
      );

  Widget _buildEmptyState(BillType type) {
    final Map<BillType, (IconData, String, String)> info = {
      BillType.hutang: (
        Icons.arrow_upward_rounded,
        'Belum ada hutang',
        'Catat hutang kamu di sini'
      ),
      BillType.piutang: (
        Icons.arrow_downward_rounded,
        'Belum ada piutang',
        'Catat uang yang kamu pinjamkan'
      ),
      BillType.tagihan: (
        Icons.receipt_long_outlined,
        'Belum ada tagihan',
        'Catat tagihan rutin bulanan kamu'
      ),
    };
    final (icon, title, subtitle) = info[type]!;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 12),
          Text(title,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(color: Colors.grey)),
          const SizedBox(height: 4),
          Text(subtitle,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildCard(BillModel bill, {required bool showPay}) {
    final isOverdue = bill.isOverdue;
    final progress = bill.paymentProgress;
    final color = _cardColor(bill);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isOverdue
              ? Colors.red.shade200
              : Theme.of(context).colorScheme.outlineVariant,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              children: [
                _typeBadge(bill),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(bill.name,
                      style: Theme.of(context)
                          .textTheme
                          .titleSmall
                          ?.copyWith(fontWeight: FontWeight.bold)),
                ),
                if (isOverdue)
                  const Icon(Icons.warning_amber_rounded,
                      size: 16, color: Colors.red),
              ],
            ),
            const SizedBox(height: 8),

            // Nominal + progress
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (bill.type == BillType.tagihan) ...[
                      Text(
                        _tagihanProgressText(bill),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      Text(
                        _currencyFormat.format(
                            bill.installmentAmount ?? bill.nominal),
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ] else ...[
                      Text(
                        'Total: ${_currencyFormat.format(bill.nominal)}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      Text(
                        'Sisa: ${_currencyFormat.format(bill.remainingAmount)}',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: bill.remainingAmount > 0
                                ? (bill.type == BillType.piutang
                                    ? Colors.orange
                                    : Colors.red)
                                : Colors.green),
                      ),
                    ],
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _statusChip(bill),
                    const SizedBox(height: 4),
                    Text(
                      bill.type == BillType.tagihan
                          ? (bill.billingDay != null
                              ? 'Tgl ${bill.billingDay} tiap bulan'
                              : _dateFormat.format(bill.dueDate))
                          : _dateFormat.format(bill.dueDate),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: isOverdue ? Colors.red : null),
                    ),
                  ],
                ),
              ],
            ),

            // Progress bar
            if (bill.type != BillType.tagihan ||
                bill.maxInstallments != null) ...[
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: bill.type == BillType.tagihan
                      ? (bill.maxInstallments != null
                          ? bill.installmentsPaid / bill.maxInstallments!
                          : 0)
                      : progress,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation(color),
                  minHeight: 6,
                ),
              ),
            ],

            // Tagihan recurring info
            if (bill.type == BillType.tagihan) ...[
              const SizedBox(height: 4),
              // Indikator sudah bayar bulan ini
              Builder(builder: (context) {
                final now = DateTime.now();
                final paidThisMonth = bill.updatedAt != null &&
                    bill.updatedAt!.year == now.year &&
                    bill.updatedAt!.month == now.month &&
                    bill.installmentsPaid > 0 &&
                    bill.status != BillStatus.unpaid;
                if (paidThisMonth) {
                  return Container(
                    margin: const EdgeInsets.only(top: 4),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: Colors.green.shade200),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_circle,
                            size: 12,
                            color: Colors.green.shade600),
                        const SizedBox(width: 4),
                        Text(
                          'Sudah dibayar bulan ini',
                          style: TextStyle(
                              fontSize: 11,
                              color: Colors.green.shade700,
                              fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  );
                }
                return const SizedBox.shrink();
              }),
              if (bill.maxInstallments != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    '${bill.installmentsPaid}/${bill.maxInstallments} cicilan dibayar',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: Colors.grey),
                  ),
                ),
            ],

            // Notes
            if (bill.notes != null && bill.notes!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(bill.notes!,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: Colors.grey)),
              ),

            // Rekening info (hutang/piutang)
            if ((bill.type == BillType.hutang || bill.type == BillType.piutang) &&
                bill.paymentMethodName != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Row(
                  children: [
                    Icon(Icons.account_balance_wallet_outlined,
                        size: 12, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(bill.paymentMethodName!,
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: Colors.grey)),
                  ],
                ),
              ),

            // Actions
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => BillHistoryScreen(
                        userId: widget.userId,
                        bill: bill,
                      ),
                    ),
                  ),
                  icon: const Icon(Icons.history, size: 16),
                  label: const Text('Riwayat'),
                ),
                if (showPay && bill.status != BillStatus.paid)
                  TextButton.icon(
                    onPressed: () => _handlePay(bill),
                    icon: const Icon(Icons.payment, size: 16),
                    label: Text(_payLabel(bill)),
                  ),
                TextButton.icon(
                  onPressed: () => _navigateToAddEdit(bill: bill),
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text('Edit'),
                ),
                TextButton.icon(
                  onPressed: () => _handleDelete(bill),
                  icon: const Icon(Icons.delete, size: 16, color: Colors.red),
                  label: const Text('Hapus',
                      style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _payLabel(BillModel bill) {
    switch (bill.type) {
      case BillType.hutang:  return 'Bayar';
      case BillType.piutang: return 'Terima';
      case BillType.tagihan: return 'Bayar Bulan Ini';
    }
  }

  String _tagihanProgressText(BillModel bill) {
    if (bill.maxInstallments != null) {
      return 'Cicilan ${bill.installmentsPaid + 1}/${bill.maxInstallments}';
    }
    return 'Bulan ke-${bill.installmentsPaid + 1}';
  }

  Color _cardColor(BillModel bill) {
    switch (bill.type) {
      case BillType.hutang:
        return bill.status == BillStatus.paid ? Colors.green : Colors.blue;
      case BillType.piutang:
        return bill.status == BillStatus.paid ? Colors.green : Colors.teal;
      case BillType.tagihan:
        return bill.status == BillStatus.paid ? Colors.green : Colors.orange;
    }
  }

  Widget _typeBadge(BillModel bill) {
    final Color bg;
    final Color fg;
    final IconData icon;
    switch (bill.type) {
      case BillType.hutang:
        bg = Colors.blue.shade50;
        fg = Colors.blue.shade700;
        icon = Icons.arrow_upward_rounded;
      case BillType.piutang:
        bg = Colors.teal.shade50;
        fg = Colors.teal.shade700;
        icon = Icons.arrow_downward_rounded;
      case BillType.tagihan:
        bg = Colors.orange.shade50;
        fg = Colors.orange.shade700;
        icon = Icons.receipt_long;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
          color: bg, borderRadius: BorderRadius.circular(6)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: fg),
          const SizedBox(width: 4),
          Text(bill.type.displayName,
              style: TextStyle(
                  fontSize: 11, color: fg, fontWeight: FontWeight.w600)),
        ],
      ),
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
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

// ─── Pay Result ───────────────────────────────────────────────────────────────

class _PayResult {
  final int amount;
  final int transferFee;
  final PaymentMethodModel method;
  const _PayResult(
      {required this.amount,
      required this.transferFee,
      required this.method});
}

// ─── Pay Dialog ───────────────────────────────────────────────────────────────

class _PayDialog extends StatefulWidget {
  final BillModel bill;
  final List<PaymentMethodModel> paymentMethods;
  final NumberFormat currencyFormat;

  const _PayDialog({
    required this.bill,
    required this.paymentMethods,
    required this.currencyFormat,
  });

  @override
  State<_PayDialog> createState() => _PayDialogState();
}

class _PayDialogState extends State<_PayDialog> {
  late final TextEditingController _amountController;
  late final TextEditingController _feeController;
  late PaymentMethodModel _selectedMethod;

  @override
  void initState() {
    super.initState();
    // Default nominal: installmentAmount untuk tagihan, remainingAmount untuk lainnya
    final defaultAmount = widget.bill.type == BillType.tagihan
        ? (widget.bill.installmentAmount ?? widget.bill.nominal)
        : widget.bill.remainingAmount;
    _amountController = TextEditingController(
        text: ThousandsSeparatorInputFormatter.formatWithDots(
            defaultAmount.toString()));
    _feeController = TextEditingController(text: '0');
    _selectedMethod = widget.paymentMethods.first;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _feeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bill = widget.bill;
    final isTagihan = bill.type == BillType.tagihan;
    final isPiutang = bill.type == BillType.piutang;

    String title;
    if (isPiutang) {
      title = 'Terima "${bill.name}"';
    } else if (isTagihan) {
      title = 'Bayar "${bill.name}"';
    } else {
      title = 'Bayar "${bill.name}"';
    }

    return AlertDialog(
      title: Text(title),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info tagihan cicilan
            if (isTagihan) ...[
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      bill.maxInstallments != null
                          ? 'Cicilan ${bill.installmentsPaid + 1}/${bill.maxInstallments}'
                          : 'Bulan ke-${bill.installmentsPaid + 1}',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    if (bill.maxInstallments != null) ...[
                      const SizedBox(height: 4),
                      LinearProgressIndicator(
                        value: bill.installmentsPaid / bill.maxInstallments!,
                        backgroundColor: Colors.orange.shade100,
                        color: Colors.orange,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ] else ...[
              Text('Sisa: ${widget.currencyFormat.format(bill.remainingAmount)}'),
              const SizedBox(height: 12),
            ],

            // Nominal
            TextFormField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              inputFormatters: [ThousandsSeparatorInputFormatter()],
              autofocus: true,
              decoration: InputDecoration(
                labelText: isPiutang ? 'Nominal Diterima' : 'Nominal Bayar',
                prefixText: 'Rp ',
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            // Biaya transfer
            TextFormField(
              controller: _feeController,
              keyboardType: TextInputType.number,
              inputFormatters: [ThousandsSeparatorInputFormatter()],
              decoration: const InputDecoration(
                labelText: 'Biaya Transfer',
                prefixText: 'Rp ',
                border: OutlineInputBorder(),
                helperText: 'Isi 0 jika tidak ada biaya transfer',
              ),
            ),
            const SizedBox(height: 12),

            // Metode pembayaran
            DropdownButtonFormField<PaymentMethodModel>(
              initialValue: _selectedMethod,
              decoration: const InputDecoration(
                labelText: 'Metode Pembayaran',
                border: OutlineInputBorder(),
              ),
              items: widget.paymentMethods
                  .map((m) =>
                      DropdownMenuItem(value: m, child: Text(m.name)))
                  .toList(),
              onChanged: (v) {
                if (v != null) setState(() => _selectedMethod = v);
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Batal'),
        ),
        FilledButton(
          onPressed: () {
            final amount = ThousandsSeparatorInputFormatter.parseValue(
                _amountController.text);
            if (amount <= 0) return;
            final fee = ThousandsSeparatorInputFormatter.parseValue(
                _feeController.text);
            Navigator.of(context).pop(
              _PayResult(
                  amount: amount, transferFee: fee, method: _selectedMethod),
            );
          },
          child: Text(isPiutang ? 'Terima' : 'Bayar'),
        ),
      ],
    );
  }
}
