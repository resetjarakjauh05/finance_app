import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../data/services/transaction_service.dart';
import '../../../../data/services/payment_method_service.dart';
import '../../../../data/repositories/transaction_repository.dart';
import '../../../../data/repositories/payment_method_repository.dart';
import '../../../../domain/models/transaction_model.dart';
import '../../../../domain/models/payment_method_model.dart';
import '../../../core/dialogs.dart';
import '../../../core/currency_input_formatter.dart';

class TransferScreen extends StatefulWidget {
  final String userId;
  const TransferScreen({super.key, required this.userId});

  @override
  State<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends State<TransferScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nominalController = TextEditingController();
  final _feeController = TextEditingController(text: '0');
  final _notesController = TextEditingController();

  List<PaymentMethodModel> _paymentMethods = [];
  PaymentMethodModel? _fromMethod;
  PaymentMethodModel? _toMethod;
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;

  final _dateFormat = DateFormat('dd MMM yyyy', 'id_ID');
  final _currencyFormat = NumberFormat.currency(
    locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    _loadPaymentMethods();
  }

  @override
  void dispose() {
    _nominalController.dispose();
    _feeController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadPaymentMethods() async {
    try {
      final methods = await PaymentMethodRepository(
        service: PaymentMethodService(),
      ).getAllPaymentMethods(widget.userId);
      final activeMethods = methods.where((m) => m.isActive).toList();
      if (mounted) {
        setState(() {
          _paymentMethods = activeMethods;
          if (activeMethods.length >= 2) {
            _fromMethod = activeMethods[0];
            _toMethod = activeMethods[1];
          } else if (activeMethods.isNotEmpty) {
            _fromMethod = activeMethods[0];
          }
        });
      }
    } catch (_) {}
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      locale: const Locale('id', 'ID'),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _handleTransfer() async {
    if (!_formKey.currentState!.validate()) return;
    if (_fromMethod == null || _toMethod == null) {
      await showErrorDialog(context, message: 'Pilih metode pembayaran asal dan tujuan');
      return;
    }
    if (_fromMethod!.id == _toMethod!.id) {
      await showErrorDialog(context, message: 'Metode asal dan tujuan tidak boleh sama');
      return;
    }

    final nominal = ThousandsSeparatorInputFormatter.parseValue(_nominalController.text);
    final fee = ThousandsSeparatorInputFormatter.parseValue(_feeController.text);
    final totalKeluar = nominal + fee;
    final notes = _notesController.text.trim().isNotEmpty
        ? _notesController.text.trim()
        : 'Transfer: ${_fromMethod!.name} → ${_toMethod!.name}';

    // Cek saldo metode asal
    final repo = TransactionRepository(service: TransactionService());
    final saldo = await repo.getBalanceForPaymentMethod(
        widget.userId, _fromMethod!.id);
    if (saldo < totalKeluar) {
      if (!mounted) return;
      await showErrorDialog(
        context,
        title: 'Saldo Tidak Mencukupi',
        message:
            'Saldo ${_fromMethod!.name} hanya ${_currencyFormat.format(saldo)}. '
            'Tidak cukup untuk transfer ${_currencyFormat.format(totalKeluar)}${fee > 0 ? ' (termasuk biaya ${_currencyFormat.format(fee)})' : ''}.',
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final repo = TransactionRepository(service: TransactionService());
      final isOnline = await repo.isOnline();

      // 1. Expense: dari source
      final expenseTransaction = TransactionModel(
        id: 0,
        userId: widget.userId,
        description: 'Transfer ke ${_toMethod!.name}',
        category: TransactionCategory.expense,
        paymentMethodId: _fromMethod!.id,
        paymentMethodName: _fromMethod!.name,
        nominal: totalKeluar,
        date: _selectedDate,
        notes: notes,
        localCreatedAt: DateTime.now(),
      );
      await TransactionService().createTransaction(expenseTransaction, isOnline);

      // 2. Income: ke destination
      final incomeTransaction = TransactionModel(
        id: 0,
        userId: widget.userId,
        description: 'Transfer dari ${_fromMethod!.name}',
        category: TransactionCategory.income,
        paymentMethodId: _toMethod!.id,
        paymentMethodName: _toMethod!.name,
        nominal: nominal,
        date: _selectedDate,
        notes: notes,
        localCreatedAt: DateTime.now(),
      );
      await TransactionService().createTransaction(incomeTransaction, isOnline);

      if (mounted) {
        await showSuccessDialog(
          context,
          title: 'Transfer Berhasil',
          message: 'Transfer ${_currencyFormat.format(nominal)} dari ${_fromMethod!.name} ke ${_toMethod!.name} berhasil dicatat.',
          icon: Icons.swap_horiz,
        );
        if (mounted) Navigator.of(context).pop('transfer_success');
      }
    } catch (e) {
      if (mounted) await showErrorDialog(context, message: e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Transfer Antar Rekening')),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: FilledButton(
            onPressed: _isLoading ? null : _handleTransfer,
            style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
            child: _isLoading
                ? const SizedBox(height: 20, width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Text('Transfer', style: TextStyle(fontSize: 16)),
          ),
        ),
      ),
      body: _paymentMethods.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // From → To visual
                  Card(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              children: [
                                Text('Dari', style: TextStyle(
                                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                                    fontSize: 12)),
                                const SizedBox(height: 4),
                                Text(
                                  _fromMethod?.name ?? '-',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                          Icon(Icons.arrow_forward,
                              color: Theme.of(context).colorScheme.onPrimaryContainer),
                          Expanded(
                            child: Column(
                              children: [
                                Text('Ke', style: TextStyle(
                                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                                    fontSize: 12)),
                                const SizedBox(height: 4),
                                Text(
                                  _toMethod?.name ?? '-',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // From method
                  DropdownButtonFormField<PaymentMethodModel>(
                    initialValue: _fromMethod,
                    decoration: const InputDecoration(
                      labelText: 'Dari Rekening',
                      prefixIcon: Icon(Icons.arrow_upward, color: Colors.red),
                      border: OutlineInputBorder(),
                    ),
                    items: _paymentMethods
                        .map((m) => DropdownMenuItem(value: m, child: Text(m.name)))
                        .toList(),
                    onChanged: (v) => setState(() => _fromMethod = v),
                    validator: (v) => v == null ? 'Pilih rekening asal' : null,
                  ),
                  const SizedBox(height: 12),

                  // To method
                  DropdownButtonFormField<PaymentMethodModel>(
                    value: _toMethod,
                    decoration: const InputDecoration(
                      labelText: 'Ke Rekening',
                      prefixIcon: Icon(Icons.arrow_downward, color: Colors.green),
                      border: OutlineInputBorder(),
                    ),
                    items: _paymentMethods
                        .map((m) => DropdownMenuItem(value: m, child: Text(m.name)))
                        .toList(),
                    onChanged: (v) => setState(() => _toMethod = v),
                    validator: (v) => v == null ? 'Pilih rekening tujuan' : null,
                  ),
                  const SizedBox(height: 12),

                  // Nominal
                  TextFormField(
                    controller: _nominalController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [ThousandsSeparatorInputFormatter()],
                    decoration: const InputDecoration(
                      labelText: 'Nominal Transfer',
                      prefixText: 'Rp ',
                      prefixIcon: Icon(Icons.attach_money),
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Nominal tidak boleh kosong';
                      final val = ThousandsSeparatorInputFormatter.parseValue(v);
                      if (val <= 0) return 'Nominal harus lebih dari 0';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),

                  // Fee
                  TextFormField(
                    controller: _feeController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [ThousandsSeparatorInputFormatter()],
                    decoration: const InputDecoration(
                      labelText: 'Biaya Transfer (opsional)',
                      prefixText: 'Rp ',
                      prefixIcon: Icon(Icons.money_off),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Date
                  InkWell(
                    onTap: _selectDate,
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Tanggal',
                        prefixIcon: Icon(Icons.calendar_today),
                        border: OutlineInputBorder(),
                      ),
                      child: Text(_dateFormat.format(_selectedDate)),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Notes
                  TextFormField(
                    controller: _notesController,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Keterangan (opsional)',
                      prefixIcon: Icon(Icons.notes),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
