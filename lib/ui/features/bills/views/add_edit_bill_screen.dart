import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/currency_input_formatter.dart';
import '../../../../data/services/bill_service.dart';
import '../../../../data/repositories/bill_repository.dart';
import '../../../../data/repositories/category_repository.dart';
import '../../../../data/repositories/payment_method_repository.dart';
import '../../../../data/services/category_service.dart';
import '../../../../data/services/payment_method_service.dart';
import '../../../../data/local/category_dao.dart';
import '../../../../domain/models/bill_model.dart';
import '../../../../domain/models/category_model.dart';
import '../../../../domain/models/payment_method_model.dart';
import '../../../core/dialogs.dart';
import '../view_models/bill_view_model.dart';

class AddEditBillScreen extends StatefulWidget {
  final String userId;
  final BillModel? bill;

  const AddEditBillScreen({super.key, required this.userId, this.bill});

  @override
  State<AddEditBillScreen> createState() => _AddEditBillScreenState();
}

class _AddEditBillScreenState extends State<AddEditBillScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _nominalController = TextEditingController();
  final _notesController = TextEditingController();
  final _transferFeeController = TextEditingController(text: '0');
  late final BillViewModel _viewModel;

  DateTime _dueDate = DateTime.now().add(const Duration(days: 7));
  BillType _selectedType = BillType.hutang;
  final _dateFormat = DateFormat('dd MMM yyyy', 'id_ID');

  // Kategori
  CategoryModel? _selectedCategory;
  List<CategoryModel> _categories = [];
  bool _loadingCategories = false;

  // Rekening (hanya untuk piutang — debit saldo saat memberi pinjaman)
  PaymentMethodModel? _selectedPaymentMethod;
  List<PaymentMethodModel> _paymentMethods = [];
  bool _loadingMethods = false;

  bool get isEditMode => widget.bill != null;
  bool get isPiutang => _selectedType == BillType.piutang;

  @override
  void initState() {
    super.initState();
    _viewModel = BillViewModel(
      repository: BillRepository(service: BillService()),
      userId: widget.userId,
    );
    if (isEditMode) {
      final b = widget.bill!;
      _nameController.text = b.name;
      _nominalController.text =
          ThousandsSeparatorInputFormatter.formatWithDots(b.nominal.toString());
      _notesController.text = b.notes ?? '';
      _transferFeeController.text = b.transferFee > 0
          ? ThousandsSeparatorInputFormatter.formatWithDots(
              b.transferFee.toString())
          : '0';
      _dueDate = b.dueDate;
      _selectedType = b.type;
    }
    _loadCategories();
    _loadPaymentMethods();
  }

  Future<void> _loadCategories() async {
    setState(() => _loadingCategories = true);
    try {
      final repo = CategoryRepository(
        service: CategoryService(dao: CategoryDao()),
      );
      final cats = await repo.getCategories(widget.userId);
      setState(() {
        _categories = cats;
        _loadingCategories = false;
        if (isEditMode && widget.bill!.categoryId != null) {
          _selectedCategory = cats
              .where((c) => c.id == widget.bill!.categoryId)
              .firstOrNull;
        }
      });
    } catch (e) {
      setState(() => _loadingCategories = false);
    }
  }

  Future<void> _loadPaymentMethods() async {
    setState(() => _loadingMethods = true);
    try {
      final repo = PaymentMethodRepository(service: PaymentMethodService());
      final methods = await repo.getAllPaymentMethods(widget.userId);
      setState(() {
        _paymentMethods = methods.where((m) => m.isActive).toList();
        _loadingMethods = false;
        if (isEditMode && widget.bill!.paymentMethodId != null) {
          _selectedPaymentMethod = _paymentMethods
              .where((m) => m.id == widget.bill!.paymentMethodId)
              .firstOrNull;
        }
      });
    } catch (e) {
      setState(() => _loadingMethods = false);
    }
  }

  @override
  void dispose() {
    _viewModel.dispose();
    _nameController.dispose();
    _nominalController.dispose();
    _notesController.dispose();
    _transferFeeController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
      locale: const Locale('id', 'ID'),
    );
    if (picked != null) setState(() => _dueDate = picked);
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    // Validasi kategori wajib untuk hutang
    if (_selectedType == BillType.hutang && _selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih kategori untuk tagihan hutang'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Validasi rekening wajib untuk piutang (create baru)
    if (!isEditMode && isPiutang && _selectedPaymentMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih rekening untuk piutang'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final transferFee =
        ThousandsSeparatorInputFormatter.parseValue(_transferFeeController.text);

    try {
      if (isEditMode) {
        final updated = widget.bill!.copyWith(
          name: _nameController.text.trim(),
          nominal: ThousandsSeparatorInputFormatter.parseValue(
              _nominalController.text),
          dueDate: _dueDate,
          type: _selectedType,
          categoryId:
              _selectedType == BillType.hutang ? _selectedCategory?.id : null,
          categoryName: _selectedType == BillType.hutang
              ? _selectedCategory?.name
              : null,
          paymentMethodId: isPiutang ? _selectedPaymentMethod?.id : null,
          paymentMethodName: isPiutang ? _selectedPaymentMethod?.name : null,
          transferFee: isPiutang ? transferFee : 0,
          notes: _notesController.text.trim().isNotEmpty
              ? _notesController.text.trim()
              : null,
          updatedAt: DateTime.now(),
        );
        await _viewModel.updateBill(updated);
      } else {
        await _viewModel.createBill(
          name: _nameController.text.trim(),
          nominal: ThousandsSeparatorInputFormatter.parseValue(
              _nominalController.text),
          dueDate: _dueDate,
          type: _selectedType,
          categoryId:
              _selectedType == BillType.hutang ? _selectedCategory?.id : null,
          categoryName: _selectedType == BillType.hutang
              ? _selectedCategory?.name
              : null,
          paymentMethod: isPiutang ? _selectedPaymentMethod : null,
          transferFee: isPiutang ? transferFee : 0,
          notes: _notesController.text.trim().isNotEmpty
              ? _notesController.text.trim()
              : null,
        );
      }

      if (mounted) {
        await showSuccessDialog(
          context,
          title: isEditMode ? 'Berhasil Diperbarui' : 'Berhasil Ditambahkan',
          message: isEditMode
              ? 'Tagihan berhasil diperbarui.'
              : 'Tagihan berhasil ditambahkan.',
          icon: Icons.check_circle,
        );
        if (mounted) {
          Navigator.of(context).pop(
            isEditMode
                ? 'Tagihan berhasil diperbarui'
                : 'Tagihan berhasil ditambahkan',
          );
        }
      }
    } catch (e) {
      if (mounted) {
        await showErrorDialog(
          context,
          title: 'Gagal Menyimpan',
          message: _viewModel.errorMessage ?? e.toString(),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading =
        _viewModel.isLoading || _loadingCategories || _loadingMethods;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditMode ? 'Edit Tagihan' : 'Tambah Tagihan'),
      ),
      bottomNavigationBar: ListenableBuilder(
        listenable: _viewModel,
        builder: (context, _) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: FilledButton(
              onPressed: isLoading ? null : _handleSave,
              style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16)),
              child: _viewModel.isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : Text(isEditMode ? 'Perbarui' : 'Simpan',
                      style: const TextStyle(fontSize: 16)),
            ),
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Tipe tagihan (Hutang/Piutang)
            Text(
              'Tipe',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 8),
            SegmentedButton<BillType>(
              segments: const [
                ButtonSegment(
                  value: BillType.hutang,
                  label: Text('Hutang'),
                  icon: Icon(Icons.arrow_upward, size: 16),
                ),
                ButtonSegment(
                  value: BillType.piutang,
                  label: Text('Piutang'),
                  icon: Icon(Icons.arrow_downward, size: 16),
                ),
              ],
              selected: {_selectedType},
              onSelectionChanged: (val) {
                setState(() {
                  _selectedType = val.first;
                  if (_selectedType == BillType.piutang) {
                    _selectedCategory = null;
                  } else {
                    _selectedPaymentMethod = null;
                    _transferFeeController.text = '0';
                  }
                });
              },
            ),
            const SizedBox(height: 16),

            // Kategori (wajib hutang, hidden piutang)
            if (!isPiutang) ...[
              if (_loadingCategories)
                const Center(child: CircularProgressIndicator())
              else if (_categories.isNotEmpty) ...[
                DropdownButtonFormField<CategoryModel>(
                  initialValue: _selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Kategori *',
                    prefixIcon: Icon(Icons.category_outlined),
                    border: OutlineInputBorder(),
                  ),
                  items: _categories
                      .map((cat) => DropdownMenuItem(
                            value: cat,
                            child: Text('${cat.icon} ${cat.name}'),
                          ))
                      .toList(),
                  onChanged: (v) => setState(() => _selectedCategory = v),
                  validator: (v) => _selectedType == BillType.hutang && v == null
                      ? 'Pilih kategori untuk hutang'
                      : null,
                ),
                const SizedBox(height: 16),
              ],
            ],

            // Rekening + biaya transfer (hanya piutang)
            if (isPiutang) ...[
              // Info piutang
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .tertiaryContainer
                      .withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline,
                        size: 16,
                        color: Theme.of(context).colorScheme.tertiary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Saldo rekening yang dipilih akan dikurangi sebesar nominal + biaya transfer.',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Dropdown rekening
              if (_loadingMethods)
                const Center(child: CircularProgressIndicator())
              else
                DropdownButtonFormField<PaymentMethodModel>(
                  initialValue: _selectedPaymentMethod,
                  decoration: const InputDecoration(
                    labelText: 'Debit dari Rekening *',
                    prefixIcon: Icon(Icons.account_balance_wallet_outlined),
                    border: OutlineInputBorder(),
                    helperText: 'Rekening yang berkurang saat memberi pinjaman',
                  ),
                  items: _paymentMethods
                      .map((m) => DropdownMenuItem(
                            value: m,
                            child: Text(m.name),
                          ))
                      .toList(),
                  onChanged: (v) =>
                      setState(() => _selectedPaymentMethod = v),
                  validator: (v) => !isEditMode && v == null
                      ? 'Pilih rekening untuk piutang'
                      : null,
                ),
              const SizedBox(height: 16),

              // Biaya transfer
              TextFormField(
                controller: _transferFeeController,
                keyboardType: TextInputType.number,
                inputFormatters: [ThousandsSeparatorInputFormatter()],
                decoration: const InputDecoration(
                  labelText: 'Biaya Transfer (opsional)',
                  prefixText: 'Rp ',
                  prefixIcon: Icon(Icons.swap_horiz),
                  border: OutlineInputBorder(),
                  helperText: 'Biaya admin transfer yang ikut didebit',
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Nama tagihan
            TextFormField(
              controller: _nameController,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                labelText: isPiutang ? 'Nama Peminjam / Keterangan' : 'Nama Tagihan',
                hintText: isPiutang
                    ? 'Contoh: Pinjaman ke Budi'
                    : 'Contoh: Cicilan Motor, Listrik',
                prefixIcon: const Icon(Icons.receipt_long),
                border: const OutlineInputBorder(),
              ),
              validator: (v) =>
                  v == null || v.isEmpty ? 'Nama tidak boleh kosong' : null,
            ),
            const SizedBox(height: 16),

            // Nominal
            TextFormField(
              controller: _nominalController,
              keyboardType: TextInputType.number,
              inputFormatters: [ThousandsSeparatorInputFormatter()],
              decoration: InputDecoration(
                labelText: isPiutang ? 'Jumlah Pinjaman' : 'Total Nominal',
                prefixText: 'Rp ',
                prefixIcon: const Icon(Icons.attach_money),
                border: const OutlineInputBorder(),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Nominal tidak boleh kosong';
                final val = ThousandsSeparatorInputFormatter.parseValue(v);
                if (val <= 0) return 'Nominal harus lebih dari 0';
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Due date
            InkWell(
              onTap: _selectDate,
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: isPiutang ? 'Estimasi Pengembalian' : 'Jatuh Tempo',
                  prefixIcon: const Icon(Icons.calendar_today),
                  border: const OutlineInputBorder(),
                ),
                child: Text(_dateFormat.format(_dueDate)),
              ),
            ),
            const SizedBox(height: 16),

            // Notes
            TextFormField(
              controller: _notesController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Catatan (opsional)',
                prefixIcon: Icon(Icons.notes),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
