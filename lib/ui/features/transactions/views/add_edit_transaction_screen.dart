import 'package:flutter/material.dart';
import '../../../../data/services/transaction_service.dart';
import '../../../../data/services/payment_method_service.dart';
import '../../../../data/services/category_service.dart';
import '../../../../data/repositories/transaction_repository.dart';
import '../../../../data/repositories/payment_method_repository.dart';
import '../../../../data/repositories/category_repository.dart';
import '../../../../data/local/category_dao.dart';
import '../view_models/transaction_view_model.dart';
import '../../../../domain/models/transaction_model.dart';
import '../../../../domain/models/category_model.dart';
import '../../../core/dialogs.dart';
import 'package:intl/intl.dart';
import '../../../core/currency_input_formatter.dart';

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

  // Kategori pengeluaran
  CategoryModel? _selectedExpenseCategory;
  List<CategoryModel> _expenseCategories = [];
  bool _loadingCategories = false;

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
    _loadExpenseCategories();

    if (isEditMode) {
      final t = widget.transaction!;
      _descriptionController.text = t.description;
      _selectedCategory = t.category;
      _selectedPaymentMethodId = t.paymentMethodId;
      _nominalController.text = ThousandsSeparatorInputFormatter.formatWithDots(t.nominal.toString());
      _selectedDate = t.date;
      _notesController.text = t.notes ?? '';
    }
  }

  Future<void> _loadExpenseCategories() async {
    setState(() => _loadingCategories = true);
    try {
      final repo = CategoryRepository(
        service: CategoryService(dao: CategoryDao()),
      );
      final cats = await repo.getCategories(widget.userId);
      setState(() {
        _expenseCategories = cats;
        _loadingCategories = false;
        // Set existing category saat edit
        if (isEditMode && widget.transaction!.categoryId != null) {
          _selectedExpenseCategory = cats
              .where((c) => c.id == widget.transaction!.categoryId)
              .firstOrNull;
        }
      });
    } catch (e) {
      setState(() => _loadingCategories = false);
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
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    // Validasi kategori saat expense
    if (_selectedCategory == TransactionCategory.expense &&
        _selectedExpenseCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih kategori pengeluaran'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedPaymentMethodId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih metode pembayaran'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final paymentMethod =
        _viewModel.getPaymentMethod(_selectedPaymentMethodId!);
    if (paymentMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Metode pembayaran tidak valid'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // categoryId hanya untuk expense
    final categoryId = _selectedCategory == TransactionCategory.expense
        ? _selectedExpenseCategory?.id
        : null;
    final categoryName = _selectedCategory == TransactionCategory.expense
        ? _selectedExpenseCategory?.name
        : null;

    // Cek saldo saat expense (hanya create, bukan edit)
    if (!isEditMode &&
        _selectedCategory == TransactionCategory.expense) {
      final nominal = ThousandsSeparatorInputFormatter.parseValue(_nominalController.text);
      final repo = TransactionRepository(service: TransactionService());
      final saldo = await repo.getBalanceForPaymentMethod(
          widget.userId, _selectedPaymentMethodId!);
      if (saldo < nominal) {
        if (!mounted) return;
        await showErrorDialog(
          context,
          title: 'Saldo Tidak Mencukupi',
          message:
              'Saldo ${paymentMethod.name} hanya ${NumberFormat.currency(locale: "id_ID", symbol: "Rp ", decimalDigits: 0).format(saldo)}. '
              'Tidak cukup untuk pengeluaran ${NumberFormat.currency(locale: "id_ID", symbol: "Rp ", decimalDigits: 0).format(nominal)}.',
        );
        return;
      }
    }

    try {
      if (isEditMode) {
        final updatedTransaction = widget.transaction!.copyWith(
          description: _descriptionController.text.trim(),
          category: _selectedCategory,
          paymentMethodId: _selectedPaymentMethodId!,
          paymentMethodName: paymentMethod.name,
          nominal: ThousandsSeparatorInputFormatter.parseValue(_nominalController.text),
          date: _selectedDate,
          notes: _notesController.text.trim().isNotEmpty
              ? _notesController.text.trim()
              : null,
          categoryId: categoryId,
          categoryName: categoryName,
        );
        await _viewModel.updateTransaction(updatedTransaction);
      } else {
        await _viewModel.createTransaction(
          description: _descriptionController.text.trim(),
          category: _selectedCategory,
          paymentMethodId: _selectedPaymentMethodId!,
          paymentMethodName: paymentMethod.name,
          nominal: ThousandsSeparatorInputFormatter.parseValue(_nominalController.text),
          date: _selectedDate,
          notes: _notesController.text.trim().isNotEmpty
              ? _notesController.text.trim()
              : null,
          categoryId: categoryId,
          categoryName: categoryName,
        );
      }

      if (mounted) {
        // BUG-A FIX: showSuccessDialog lalu langsung pop — tidak pakai addPostFrameCallback
        // addPostFrameCallback menyebabkan double-pop setelah dialog ditutup → layar merah
        await showSuccessDialog(
          context,
          message: isEditMode
              ? 'Transaksi berhasil diperbarui'
              : 'Transaksi berhasil disimpan',
        );
        if (mounted) Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        // BUG-B FIX: pakai e.toString() langsung, bukan _viewModel.errorMessage yang stale
        final errMsg = e.toString().replaceFirst('Exception: ', '');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errMsg.isNotEmpty ? errMsg : 'Gagal menyimpan transaksi'),
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
        title: Text(isEditMode ? 'Edit Transaksi' : 'Tambah Transaksi'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Tipe transaksi (income/expense)
            Text(
              'Tipe Transaksi',
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
                  // Reset kategori expense saat ganti tipe
                  if (_selectedCategory == TransactionCategory.income) {
                    _selectedExpenseCategory = null;
                  }
                });
              },
            ),
            const SizedBox(height: 16),

            // Dropdown kategori (wajib expense, opsional income)
            _loadingCategories
                ? const Center(child: CircularProgressIndicator())
                : _expenseCategories.isEmpty
                    ? OutlinedButton.icon(
                        onPressed: _loadExpenseCategories,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Muat Kategori'),
                        style: OutlinedButton.styleFrom(
                            minimumSize: const Size.fromHeight(48)),
                      )
                    : DropdownButtonFormField<CategoryModel>(
                        initialValue: _selectedExpenseCategory,
                        decoration: InputDecoration(
                          labelText: _selectedCategory ==
                                  TransactionCategory.expense
                              ? 'Kategori Pengeluaran *'
                              : 'Kategori (opsional)',
                          prefixIcon: const Icon(Icons.category_outlined),
                          border: const OutlineInputBorder(),
                        ),
                        items: [
                          if (_selectedCategory == TransactionCategory.income)
                            const DropdownMenuItem(
                              value: null,
                              child: Text('— Tanpa Kategori —'),
                            ),
                          ..._expenseCategories.map((cat) => DropdownMenuItem(
                                value: cat,
                                child: Text('${cat.icon} ${cat.name}'),
                              )),
                        ],
                        onChanged: (v) =>
                            setState(() => _selectedExpenseCategory = v),
                        validator: (v) =>
                            _selectedCategory ==
                                        TransactionCategory.expense &&
                                    v == null
                                ? 'Pilih kategori pengeluaran'
                                : null,
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
                final activeMethods =
                    _viewModel.paymentMethods.where((m) => m.isActive).toList();
                // Guard: jika selectedId tidak ada di active list → reset null
                // TAPI hanya jika list sudah terisi (bukan masih loading/kosong)
                // Bug: list kosong saat loading → reset ID yang valid → dropdown kosong
                final validId = activeMethods.isEmpty
                    ? _selectedPaymentMethodId
                    : activeMethods.any((m) => m.id == _selectedPaymentMethodId)
                        ? _selectedPaymentMethodId
                        : null;
                if (activeMethods.isNotEmpty && validId != _selectedPaymentMethodId) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) setState(() => _selectedPaymentMethodId = validId);
                  });
                }
                return DropdownButtonFormField<String>(
                  initialValue: validId,
                  decoration: const InputDecoration(
                    labelText: 'Metode Pembayaran',
                    prefixIcon: Icon(Icons.account_balance_wallet_outlined),
                    border: OutlineInputBorder(),
                  ),
                  items: activeMethods
                      .map((method) => DropdownMenuItem(
                            value: method.id,
                            child: Text(method.name),
                          ))
                      .toList(),
                  onChanged: (value) =>
                      setState(() => _selectedPaymentMethodId = value),
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
              inputFormatters: [ThousandsSeparatorInputFormatter()],
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
                final nominal = ThousandsSeparatorInputFormatter.parseValue(value);
                if (nominal <= 0) {
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
