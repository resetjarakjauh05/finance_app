import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../../../data/services/bill_service.dart';
import '../../../../data/services/payment_method_service.dart';
import '../../../../data/repositories/bill_repository.dart';
import '../../../../data/repositories/payment_method_repository.dart';
import '../../../../domain/models/bill_model.dart';
import '../../../../domain/models/payment_method_model.dart';
import '../../../core/dialogs.dart';
import '../../../core/widgets.dart';
import '../view_models/bill_view_model.dart';
import 'add_edit_bill_screen.dart';

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

  final _currencyFormat = NumberFormat.currency(
    locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0,
  );
  final _dateFormat = DateFormat('dd MMM yyyy', 'id_ID');

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
        builder: (context) =>
            AddEditBillScreen(userId: widget.userId, bill: bill),
      ),
    );
    if (result != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result), backgroundColor: Colors.green,
            duration: const Duration(seconds: 2)),
      );
      _viewModel.init();
    }
  }

  Future<void> _handleDelete(BillModel bill) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Tagihan'),
        content: Text('Yakin hapus "${bill.name}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false),
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
        if (mounted) {
          await showErrorDialog(context, message: e.toString());
        }
      }
    }
  }

  Future<void> _handlePay(BillModel bill) async {
    // Load payment methods dulu
    List<PaymentMethodModel> paymentMethods = [];
    try {
      final all = await PaymentMethodRepository(
        service: PaymentMethodService(),
      ).getAllPaymentMethods(widget.userId);
      paymentMethods = all.where((m) => m.isActive).toList();
    } catch (_) {}

    if (!mounted) return;

    if (paymentMethods.isEmpty) {
      await showErrorDialog(context,
          title: 'Tidak Ada Metode Pembayaran',
          message: 'Tambah metode pembayaran terlebih dahulu.');
      return;
    }

    final controller = TextEditingController(text: bill.remainingAmount.toString());
    PaymentMethodModel? selectedMethod = paymentMethods.first;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          title: Text('${bill.type == BillType.hutang ? 'Bayar' : 'Terima'} "${bill.name}"'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Sisa: ${_currencyFormat.format(bill.remainingAmount)}'),
              const SizedBox(height: 12),
              TextFormField(
                controller: controller,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  labelText: 'Nominal',
                  prefixText: 'Rp ',
                  border: OutlineInputBorder(),
                ),
                autofocus: true,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<PaymentMethodModel>(
                value: selectedMethod,
                decoration: const InputDecoration(
                  labelText: 'Metode Pembayaran',
                  border: OutlineInputBorder(),
                ),
                items: paymentMethods
                    .map((m) => DropdownMenuItem(value: m, child: Text(m.name)))
                    .toList(),
                onChanged: (v) => setStateDialog(() => selectedMethod = v),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(bill.type == BillType.hutang ? 'Bayar' : 'Terima'),
            ),
          ],
        ),
      ),
    );

    if (confirmed == true && selectedMethod != null) {
      final amount = int.tryParse(controller.text) ?? 0;
      if (amount <= 0) { controller.dispose(); return; }
      try {
        await _viewModel.payBill(bill, amount, selectedMethod!);
        if (mounted) {
          await showSuccessDialog(context,
              title: bill.type == BillType.hutang ? 'Pembayaran Berhasil' : 'Penerimaan Berhasil',
              message: '${_currencyFormat.format(amount)} untuk "${bill.name}" telah dicatat sebagai transaksi.',
              icon: Icons.check_circle);
        }
      } catch (e) {
        if (mounted) await showErrorDialog(context, message: e.toString());
      }
    }
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tagihan'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Belum Lunas'),
            Tab(text: 'Lunas'),
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
              _buildList(_viewModel.unpaidBills, showPay: true),
              _buildList(_viewModel.paidBills, showPay: false),
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

  Widget _buildList(List<BillModel> bills, {required bool showPay}) {
    if (bills.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.credit_card_outlined, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(showPay ? 'Tidak ada tagihan' : 'Belum ada tagihan lunas',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.grey)),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: () => _viewModel.init(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: bills.length,
        itemBuilder: (context, index) {
          final bill = bills[index];
          return _buildBillCard(bill, showPay: showPay);
        },
      ),
    );
  }

  Widget _buildBillCard(BillModel bill, {required bool showPay}) {
    final isOverdue = bill.isOverdue;
    final progress = bill.paymentProgress;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
              Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(bill.name,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16)),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: bill.type == BillType.hutang
                                  ? Colors.red.shade50
                                  : Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              bill.type.displayName,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: bill.type == BillType.hutang
                                    ? Colors.red.shade700
                                    : Colors.blue.shade700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            isOverdue ? Icons.warning_amber : Icons.calendar_today,
                            size: 14,
                            color: isOverdue ? Colors.red : Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Jatuh tempo: ${_dateFormat.format(bill.dueDate)}',
                            style: TextStyle(
                              fontSize: 12,
                              color: isOverdue ? Colors.red : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                _statusChip(bill.status),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total: ${_currencyFormat.format(bill.nominal)}',
                    style: Theme.of(context).textTheme.bodySmall),
                Text('Dibayar: ${_currencyFormat.format(bill.paidAmount)}',
                    style: Theme.of(context).textTheme.bodySmall),
                Text('Sisa: ${_currencyFormat.format(bill.remainingAmount)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: bill.remainingAmount > 0 ? Colors.red : Colors.green)),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation(
                  progress >= 1.0 ? Colors.green : Colors.blue,
                ),
                minHeight: 8,
              ),
            ),
            if (bill.notes != null && bill.notes!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(bill.notes!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey)),
            ],
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (showPay && bill.status != BillStatus.paid)
                  TextButton.icon(
                    onPressed: () => _handlePay(bill),
                    icon: const Icon(Icons.payment, size: 16),
                    label: const Text('Bayar'),
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

  Widget _statusChip(BillStatus status) {
    Color color;
    switch (status) {
      case BillStatus.unpaid:  color = Colors.red; break;
      case BillStatus.partial: color = Colors.orange; break;
      case BillStatus.paid:    color = Colors.green; break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(100)),
      ),
      child: Text(status.displayName,
          style: TextStyle(color: color, fontSize: 12,
              fontWeight: FontWeight.bold)),
    );
  }
}
