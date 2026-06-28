import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../data/services/transaction_service.dart';
import '../../../../data/services/payment_method_service.dart';
import '../../../../data/repositories/transaction_repository.dart';
import '../../../../data/repositories/payment_method_repository.dart';
import '../view_models/transaction_view_model.dart';
import '../../../../domain/models/transaction_model.dart';
import '../../../core/dialogs.dart';
import 'package:intl/intl.dart';

class AddEditTransactionScreen extends StatefulWidget {
  final String userId;
  final TransactionModel? transaction;

  const AddEditTransactionScreen({
    super.key,
    required this.userId,
    this.transaction,
  });

  @override
  State<AddEditTransactionScreen> createState() =>
      _AddEditTransactionScreenState();
}

class _AddEditTransactionScreenState extends State<AddEditTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _nominalController = TextEditingController();
  final _notesController = TextEditingController();
  late final TransactionViewModel _viewModel;

  TransactionCategory _selectedCategory = TransactionCategory.expense;
  String? _selectedPaymentMethodId;
  DateTime _selectedDate = DateTime.now();

  bool get isEditMode => widget.transaction != null;

  @override
  void initState() {
    super.initState();
    _viewModel = TransactionViewModel(
      transactionRepository: TransactionRepository(
        service: TransactionService(),
      ),
      paymentMethodRepository: PaymentMethodRepository(
        service: PaymentMethodService(),
      ),
      userId: widget.userId,
    );
    _viewModel.loadPaymentMethods();

    // Load existing data if editing
    if (isEditMode) {
      final transaction = widget.transaction!;
      _descriptionController.text = transaction.description;
      _selectedCategory = transaction.category;
      _selectedPaymentMethodId = transaction.paymentMethodId;
      _nominalController.text = transaction.nominal.toString();
      _selectedDate = transaction.date;
      _notesController.text = transaction.notes ?? '';
    }
  }

  @override
  void dispose() {
    _viewModel.dispose();
    _descriptionController.dispose();
    _nominalController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      locale: const Locale('id', 'ID'),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedPaymentMethodId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih metode pembayaran'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final paymentMethod = _viewModel.getPaymentMethod(_selectedPaymentMethodId!);
    if (paymentMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Metode pembayaran tidak valid'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      if (isEditMode) {
        final updatedTransaction = widget.transaction!.copyWith(
          description: _descriptionController.text.trim(),
          category: _selectedCategory,
          paymentMethodId: _selectedPaymentMethodId!,
          paymentMethodName: paymentMethod.name,
          nominal: int.parse(_nominalController.text),
          date: _selectedDate,
          notes: _notesController.text.trim().isNotEmpty
              ? _notesController.text.trim()
              : null,
        );
        await _viewModel.updateTransaction(updatedTransaction);
      } else {
        await _viewModel.createTransaction(
          description: _descriptionController.text.trim(),
          category: _selectedCategory,
          paymentMethodId: _selectedPaymentMethodId!,
          paymentMethodName: paymentMethod.name,
          nominal: int.parse(_nominalController.text),
          date: _selectedDate,
          notes: _notesController.text.trim().isNotEmpty
              ? _notesController.text.trim()
              : null,
        );
      }

      if (mounted) {
        await showSuccessDialog(
          context,
          title: isEditMode ? 'Berhasil Diperbarui' : 'Berhasil Disimpan',
          message: isEditMode
              ? 'Transaksi berhasil diperbarui.'
              : 'Transaksi berhasil disimpan.',
          icon: isEditMode ? Icons.edit_note : Icons.check_circle,
        );
        if (mounted) {
          Navigator.of(context).pop(
            isEditMode
                ? 'Transaksi berhasil diperbarui'
                : 'Transaksi berhasil disimpan',
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _viewModel.errorMessage ?? 'Gagal menyimpan transaksi',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEditMode ? 'Edit Transaksi' : 'Tambah Transaksi',
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Category selector
            Text(
              'Kategori',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 8),
            SegmentedButton<TransactionCategory>(
              segments: [
                ButtonSegment(
                  value: TransactionCategory.income,
                  label: Text(TransactionCategory.income.displayName),
                  icon: const Icon(Icons.arrow_downward),
                ),
                ButtonSegment(
                  value: TransactionCategory.expense,
                  label: Text(TransactionCategory.expense.displayName),
                  icon: const Icon(Icons.arrow_upward),
                ),
              ],
              selected: {_selectedCategory},
              onSelectionChanged: (Set<TransactionCategory> selection) {
                setState(() {
                  _selectedCategory = selection.first;
                });
              },
            ),
            const SizedBox(height: 16),

            // Description
            TextFormField(
              controller: _descriptionController,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Keterangan',
                hintText: 'Contoh: Belanja bulanan',
                prefixIcon: Icon(Icons.description_outlined),
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Keterangan wajib diisi';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Payment method dropdown
            ListenableBuilder(
              listenable: _viewModel,
              builder: (context, _) {
                final activeMethods = _viewModel.paymentMethods
                    .where((m) => m.isActive)
                    .toList();

                return DropdownButtonFormField<String>(
                  value: _selectedPaymentMethodId,
                  decoration: const InputDecoration(
                    labelText: 'Metode Pembayaran',
                    prefixIcon: Icon(Icons.account_balance_wallet_outlined),
                    border: OutlineInputBorder(),
                  ),
                  items: activeMethods.map((method) {
                    return DropdownMenuItem(
                      value: method.id,
                      child: Text(method.name),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedPaymentMethodId = value;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Pilih metode pembayaran';
                    }
                    return null;
                  },
                );
              },
            ),
            const SizedBox(height: 16),

            // Nominal
            TextFormField(
              controller: _nominalController,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
              decoration: const InputDecoration(
                labelText: 'Nominal',
                hintText: '0',
                prefixIcon: Icon(Icons.attach_money),
                prefixText: 'Rp ',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Nominal wajib diisi';
                }
                final nominal = int.tryParse(value);
                if (nominal == null || nominal <= 0) {
                  return 'Nominal harus lebih dari 0';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Date picker
            InkWell(
              onTap: _selectDate,
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Tanggal',
                  prefixIcon: Icon(Icons.calendar_today_outlined),
                  border: OutlineInputBorder(),
                ),
                child: Text(
                  DateFormat('dd MMMM yyyy', 'id_ID').format(_selectedDate),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Notes (optional)
            TextFormField(
              controller: _notesController,
              textCapitalization: TextCapitalization.sentences,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Catatan (Opsional)',
                hintText: 'Tambahkan catatan jika perlu',
                prefixIcon: Icon(Icons.note_outlined),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),

            // Save button
            ListenableBuilder(
              listenable: _viewModel,
              builder: (context, _) {
                return FilledButton(
                  onPressed: _viewModel.isLoading ? null : _handleSave,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _viewModel.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          isEditMode ? 'Perbarui' : 'Simpan',
                          style: const TextStyle(fontSize: 16),
                        ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
