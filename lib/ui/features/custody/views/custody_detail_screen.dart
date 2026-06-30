import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../data/services/custody_service.dart';
import '../../../../data/services/payment_method_service.dart';
import '../../../../data/repositories/custody_repository.dart';
import '../../../../data/repositories/payment_method_repository.dart';
import '../../../../domain/models/custody_model.dart';
import '../../../../domain/models/custody_movement_model.dart';
import '../../../../domain/models/payment_method_model.dart';
import '../../../core/currency_input_formatter.dart';
import '../../../core/dialogs.dart';
import '../view_models/custody_view_model.dart';
import 'add_edit_custody_screen.dart';

class CustodyDetailScreen extends StatefulWidget {
  final String userId;
  final CustodyModel custody;

  const CustodyDetailScreen({
    super.key,
    required this.userId,
    required this.custody,
  });

  @override
  State<CustodyDetailScreen> createState() => _CustodyDetailScreenState();
}

class _CustodyDetailScreenState extends State<CustodyDetailScreen> {
  late final CustodyViewModel _viewModel;
  late CustodyModel _custody;

  final _currencyFormat = NumberFormat.currency(
    locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0,
  );
  final _dateFormat = DateFormat('dd MMM yyyy', 'id_ID');

  @override
  void initState() {
    super.initState();
    _custody = widget.custody;
    _viewModel = CustodyViewModel(
      repository: CustodyRepository(service: CustodyService()),
      userId: widget.userId,
    );
    _viewModel.loadMovements(_custody);
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _showAddMovementDialog() async {
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

    final nominalController = TextEditingController();
    final transferFeeController = TextEditingController();
    final descController = TextEditingController();
    MovementType selectedType = MovementType.masuk;
    DateTime selectedDate = DateTime.now();
    PaymentMethodModel? selectedMethod = paymentMethods.first;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          title: const Text('Tambah Pergerakan'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SegmentedButton<MovementType>(
                  segments: const [
                    ButtonSegment(value: MovementType.masuk, label: Text('Masuk')),
                    ButtonSegment(value: MovementType.keluar, label: Text('Keluar')),
                  ],
                  selected: {selectedType},
                  onSelectionChanged: (v) =>
                      setStateDialog(() => selectedType = v.first),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: nominalController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [ThousandsSeparatorInputFormatter()],
                  decoration: const InputDecoration(
                    labelText: 'Nominal',
                    prefixText: 'Rp ',
                    border: OutlineInputBorder(),
                  ),
                  autofocus: true,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<PaymentMethodModel>(
                  initialValue: selectedMethod,
                  decoration: const InputDecoration(
                    labelText: 'Metode Pembayaran',
                    border: OutlineInputBorder(),
                  ),
                  items: paymentMethods
                      .map((m) => DropdownMenuItem(value: m, child: Text(m.name)))
                      .toList(),
                  onChanged: (v) => setStateDialog(() => selectedMethod = v),
                ),
                const SizedBox(height: 12),
                InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                      locale: const Locale('id', 'ID'),
                    );
                    if (picked != null) {
                      setStateDialog(() => selectedDate = picked);
                    }
                  },
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Tanggal',
                      prefixIcon: Icon(Icons.calendar_today),
                      border: OutlineInputBorder(),
                    ),
                    child: Text(DateFormat('dd MMM yyyy', 'id_ID').format(selectedDate)),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: transferFeeController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [ThousandsSeparatorInputFormatter()],
                  decoration: const InputDecoration(
                    labelText: 'Biaya Transfer (opsional)',
                    prefixText: 'Rp ',
                    border: OutlineInputBorder(),
                    helperText: 'Kosongkan jika tidak ada biaya transfer',
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: descController,
                  decoration: const InputDecoration(
                    labelText: 'Keterangan (opsional)',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );

    if (confirmed == true && selectedMethod != null && mounted) {
      final amount = ThousandsSeparatorInputFormatter.parseValue(nominalController.text);
      final fee = ThousandsSeparatorInputFormatter.parseValue(transferFeeController.text);
      if (amount <= 0) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          nominalController.dispose();
          transferFeeController.dispose();
          descController.dispose();
        });
        return;
      }
      try {
        await _viewModel.addMovement(
          custody: _custody,
          movementType: selectedType,
          nominal: amount,
          transferFee: fee,
          date: selectedDate,
          paymentMethod: selectedMethod!,
          description: descController.text.trim().isNotEmpty
              ? descController.text.trim()
              : null,
        );
        final delta = selectedType == MovementType.masuk ? amount : -amount;
        final newBal = _custody.currentBalance + delta;
        setState(() => _custody = _custody.copyWith(currentBalance: newBal));

        if (mounted) {
          await showSuccessDialog(context,
              title: 'Berhasil',
              message: 'Pergerakan berhasil dicatat dan tersimpan di transaksi.',
              icon: Icons.check_circle);
        }
      } catch (e) {
        if (mounted) await showErrorDialog(context, message: e.toString());
      }
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      nominalController.dispose();
      transferFeeController.dispose();
      descController.dispose();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDiterima = _custody.type == CustodyType.diterima;
    return Scaffold(
      appBar: AppBar(
        title: Text(_custody.depositorName),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context);
              final result = await Navigator.of(context).push<String>(
                MaterialPageRoute(
                  builder: (context) => AddEditCustodyScreen(
                    userId: widget.userId,
                    custody: _custody,
                  ),
                ),
              );
              if (result != null) {
                messenger.showSnackBar(
                  SnackBar(content: Text(result), backgroundColor: Colors.green),
                );
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Header card
          Container(
            width: double.infinity,
            color: isDiterima ? Colors.blue.shade700 : Colors.orange.shade700,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(50),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _custody.type.displayName,
                        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  _custody.depositorName,
                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                if (_custody.description != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    _custody.description!,
                    style: TextStyle(color: Colors.white.withAlpha(200), fontSize: 13),
                  ),
                ],
                const SizedBox(height: 12),
                Text(
                  'Saldo',
                  style: TextStyle(color: Colors.white.withAlpha(180), fontSize: 13),
                ),
                const SizedBox(height: 2),
                Text(
                  _currencyFormat.format(_custody.currentBalance),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Movements list
          Expanded(
            child: ListenableBuilder(
              listenable: _viewModel,
              builder: (context, _) {
                if (_viewModel.isLoading && _viewModel.movements.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (_viewModel.movements.isEmpty) {
                  return Center(
                    child: Text('Belum ada pergerakan',
                        style: Theme.of(context).textTheme.bodyMedium
                            ?.copyWith(color: Colors.grey)),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _viewModel.movements.length,
                  itemBuilder: (context, index) {
                    final m = _viewModel.movements[index];
                    final isMasuk = m.movementType == MovementType.masuk;
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: isMasuk
                            ? Colors.green.shade50
                            : Colors.red.shade50,
                        child: Icon(
                          isMasuk ? Icons.arrow_downward : Icons.arrow_upward,
                          color: isMasuk ? Colors.green : Colors.red,
                          size: 18,
                        ),
                      ),
                      title: Text(m.description ?? m.movementType.displayName),
                      subtitle: Text(_dateFormat.format(m.date)),
                      trailing: Text(
                        '${isMasuk ? '+' : '-'}${_currencyFormat.format(m.nominal)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isMasuk ? Colors.green : Colors.red,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'custody_detail_fab',
        onPressed: _showAddMovementDialog,
        icon: const Icon(Icons.add),
        label: const Text('Pergerakan'),
      ),
    );
  }
}
