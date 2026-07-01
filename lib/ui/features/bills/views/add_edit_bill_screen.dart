import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/currency_input_formatter.dart';
import '../../../core/icon_helper.dart';
import '../../../../data/services/bill_service.dart';
import '../../../../data/services/transaction_service.dart';
import '../../../../data/repositories/bill_repository.dart';
import '../../../../data/repositories/category_repository.dart';
import '../../../../data/repositories/payment_method_repository.dart';
import '../../../../data/repositories/transaction_repository.dart';
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
  final _maxInstallmentsController = TextEditingController();
  late final BillViewModel _viewModel;

  DateTime _dueDate = DateTime.now().add(const Duration(days: 7));
  BillType _selectedType = BillType.hutang;
  int? _billingDay; // 1-31, null = tidak set
  final _dateFormat = DateFormat('dd MMM yyyy', 'id_ID');

  // Kategori (hutang saja)
  CategoryModel? _selectedCategory;
  List<CategoryModel> _categories = [];
  bool _loadingCategories = false;

  // Rekening (hutang opsional, piutang opsional)
  PaymentMethodModel? _selectedPaymentMethod;
  List<PaymentMethodModel> _paymentMethods = [];
  bool _loadingMethods = false;

  // Tagihan: apakah ada batas cicilan
  bool _hasMaxInstallments = false;

  bool get isEditMode => widget.bill != null;
  bool get isHutang => _selectedType == BillType.hutang;
  bool get isPiutang => _selectedType == BillType.piutang;
  bool get isTagihan => _selectedType == BillType.tagihan;

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
          ? ThousandsSeparatorInputFormatter.formatWithDots(b.transferFee.toString())
          : '0';
      _dueDate = b.dueDate;
      _selectedType = b.type;
      _billingDay = b.billingDay;
      _hasMaxInstallments = b.maxInstallments != null;
      if (b.maxInstallments != null) {
        _maxInstallmentsController.text = b.maxInstallments.toString();
      }
      // installmentAmount dihitung otomatis dari nominal × maxInstallments
    }
    _loadCategories();
    _loadPaymentMethods();
  }

  Future<void> _loadCategories() async {
    setState(() => _loadingCategories = true);
    try {
      final repo = CategoryRepository(service: CategoryService(dao: CategoryDao()));
      final cats = await repo.getCategories(widget.userId);
      setState(() {
        _categories = cats;
        _loadingCategories = false;
        if (isEditMode && widget.bill!.categoryId != null) {
          _selectedCategory =
              cats.where((c) => c.id == widget.bill!.categoryId).firstOrNull;
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
    _maxInstallmentsController.dispose();
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
    if (isHutang && _selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Pilih kategori untuk tagihan hutang'),
        backgroundColor: Colors.red,
      ));
      return;
    }

    // Validasi kategori wajib untuk tagihan
    if (isTagihan && _selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Pilih kategori untuk tagihan'),
        backgroundColor: Colors.red,
      ));
      return;
    }

    final transferFee =
        ThousandsSeparatorInputFormatter.parseValue(_transferFeeController.text);

    // Cek saldo saat buat piutang baru (uang keluar opsional)
    if (!isEditMode && isPiutang && _selectedPaymentMethod != null) {
      final nominal = ThousandsSeparatorInputFormatter.parseValue(_nominalController.text);
      final totalKeluar = nominal + transferFee;
      final txRepo = TransactionRepository(service: TransactionService());
      final saldo = await txRepo.getBalanceForPaymentMethod(
          widget.userId, _selectedPaymentMethod!.id);
      if (saldo < totalKeluar) {
        if (!mounted) return;
        final fmt = NumberFormat.currency(
            locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
        await showErrorDialog(
          context,
          title: 'Saldo Tidak Mencukupi',
          message:
              'Saldo ${_selectedPaymentMethod!.name} hanya ${fmt.format(saldo)}. '
              'Dibutuhkan ${fmt.format(totalKeluar)} untuk mencatat piutang ini.',
        );
        return;
      }
    }

    // Tagihan: auto-set dueDate dari billingDay (bulan ini atau depan jika sudah lewat)
    if (isTagihan) {
      final now = DateTime.now();
      final day = _billingDay ?? now.day;
      var candidate = DateTime(now.year, now.month, day);
      if (candidate.isBefore(now)) {
        candidate = DateTime(now.year, now.month + 1, day);
      }
      _dueDate = candidate;
    }

    final int? maxInstallments = _hasMaxInstallments &&
            _maxInstallmentsController.text.isNotEmpty
        ? int.tryParse(_maxInstallmentsController.text)
        : null;

    // Saat ada batas cicilan:
    // nominal = perBulan × maxCicilan
    // installmentAmount = perBulan (dari _nominalController)
    final int perBulan = ThousandsSeparatorInputFormatter.parseValue(_nominalController.text);
    final int resolvedNominal = (_hasMaxInstallments && maxInstallments != null && maxInstallments > 0)
        ? perBulan * maxInstallments
        : perBulan;
    final int? resolvedInstallmentAmount = (_hasMaxInstallments && maxInstallments != null)
        ? perBulan
        : null;

    try {
      if (isEditMode) {
        final updated = widget.bill!.copyWith(
          name: _nameController.text.trim(),
          nominal: isTagihan ? resolvedNominal : ThousandsSeparatorInputFormatter.parseValue(_nominalController.text),
          dueDate: _dueDate,
          type: _selectedType,
          categoryId: isHutang ? _selectedCategory?.id : isTagihan ? _selectedCategory?.id : null,
          categoryName: isHutang ? _selectedCategory?.name : isTagihan ? _selectedCategory?.name : null,
          paymentMethodId:
              (isHutang || isPiutang) ? _selectedPaymentMethod?.id : null,
          paymentMethodName:
              (isHutang || isPiutang) ? _selectedPaymentMethod?.name : null,
          transferFee: (isHutang || isPiutang) ? transferFee : 0,
          billingDay: isTagihan ? _billingDay : null,
          maxInstallments: isTagihan ? maxInstallments : null,
          installmentAmount: isTagihan ? resolvedInstallmentAmount : null,
          notes: _notesController.text.trim().isNotEmpty
              ? _notesController.text.trim()
              : null,
          updatedAt: DateTime.now(),
        );
        await _viewModel.updateBill(updated);
      } else {
        await _viewModel.createBill(
          name: _nameController.text.trim(),
          nominal: isTagihan ? resolvedNominal : ThousandsSeparatorInputFormatter.parseValue(_nominalController.text),
          dueDate: _dueDate,
          type: _selectedType,
          categoryId: (isHutang || isTagihan) ? _selectedCategory?.id : null,
          categoryName: (isHutang || isTagihan) ? _selectedCategory?.name : null,
          paymentMethod:
              (isHutang || isPiutang) ? _selectedPaymentMethod : null,
          transferFee: (isHutang || isPiutang) ? transferFee : 0,
          billingDay: isTagihan ? _billingDay : null,
          maxInstallments: isTagihan ? maxInstallments : null,
          installmentAmount: isTagihan ? resolvedInstallmentAmount : null,
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
              ? 'Data berhasil diperbarui.'
              : 'Data berhasil ditambahkan.',
          icon: Icons.check_circle,
        );
        if (mounted) {
          Navigator.of(context).pop(
            isEditMode ? 'Data berhasil diperbarui' : 'Data berhasil ditambahkan',
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
        title: Text(_buildTitle()),
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
            // Tipe (Hutang / Piutang / Tagihan)
            if (!isEditMode) ...[
              Text('Tipe',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: Colors.grey.shade600)),
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
                  ButtonSegment(
                    value: BillType.tagihan,
                    label: Text('Tagihan'),
                    icon: Icon(Icons.receipt_long, size: 16),
                  ),
                ],
                selected: {_selectedType},
                onSelectionChanged: (val) {
                  setState(() {
                    _selectedType = val.first;
                    _selectedCategory = null;
                    _selectedPaymentMethod = null;
                    _transferFeeController.text = '0';
                  });
                },
              ),
              const SizedBox(height: 16),
            ],

            // ── HUTANG ──────────────────────────────────────
            if (isHutang) ..._buildHutangFields(),

            // ── PIUTANG ─────────────────────────────────────
            if (isPiutang) ..._buildPiutangFields(),

            // ── TAGIHAN ─────────────────────────────────────
            if (isTagihan) ..._buildTagihanFields(),

            // ── COMMON FIELDS ───────────────────────────────
            // Nama
            TextFormField(
              controller: _nameController,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                labelText: _nameLabelText(),
                hintText: _nameHintText(),
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
                labelText: isTagihan
                    ? (_hasMaxInstallments
                        ? 'Nominal per Bulan *'
                        : 'Nominal per Bulan')
                    : (isPiutang ? 'Jumlah Pinjaman' : 'Total Nominal'),
                prefixText: 'Rp ',
                prefixIcon: const Icon(Icons.attach_money),
                border: const OutlineInputBorder(),
              ),
              onChanged: (_) => setState(() {}),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Nominal tidak boleh kosong';
                final val = ThousandsSeparatorInputFormatter.parseValue(v);
                if (val <= 0) return 'Nominal harus lebih dari 0';
                return null;
              },
            ),

            // Preview total kalkulasi saat ada batas cicilan
            if (isTagihan && _hasMaxInstallments) ...[
              const SizedBox(height: 8),
              Builder(builder: (context) {
                final perBulan = ThousandsSeparatorInputFormatter.parseValue(
                    _nominalController.text);
                final bulan = int.tryParse(_maxInstallmentsController.text) ?? 0;
                final total = perBulan * bulan;
                final fmt = NumberFormat.currency(
                    locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
                return Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .primaryContainer
                        .withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calculate_outlined, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          bulan > 0 && perBulan > 0
                              ? '${fmt.format(perBulan)} × $bulan bulan = ${fmt.format(total)}'
                              : 'Isi nominal & jumlah cicilan untuk melihat total',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(
                                color:
                                    Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
            const SizedBox(height: 16),

            // Due date / Estimasi (hanya hutang & piutang)
            if (!isTagihan) ...[
              InkWell(
                onTap: _selectDate,
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: _dueDateLabel(),
                    prefixIcon: const Icon(Icons.calendar_today),
                    border: const OutlineInputBorder(),
                  ),
                  child: Text(_dateFormat.format(_dueDate)),
                ),
              ),
              const SizedBox(height: 16),
            ],

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

  String _buildTitle() {
    if (isEditMode) return 'Edit ${widget.bill!.type.displayName}';
    switch (_selectedType) {
      case BillType.hutang:  return 'Tambah Hutang';
      case BillType.piutang: return 'Tambah Piutang';
      case BillType.tagihan: return 'Tambah Tagihan';
    }
  }

  String _nameLabelText() {
    switch (_selectedType) {
      case BillType.hutang:  return 'Nama / Keterangan Hutang';
      case BillType.piutang: return 'Nama Peminjam / Keterangan';
      case BillType.tagihan: return 'Nama Tagihan';
    }
  }

  String _nameHintText() {
    switch (_selectedType) {
      case BillType.hutang:  return 'Contoh: Pinjam ke Pak Budi';
      case BillType.piutang: return 'Contoh: Pinjaman ke Andi';
      case BillType.tagihan: return 'Contoh: Listrik PLN, Netflix';
    }
  }

  String _dueDateLabel() {
    switch (_selectedType) {
      case BillType.hutang:  return 'Jatuh Tempo';
      case BillType.piutang: return 'Estimasi Pengembalian';
      case BillType.tagihan: return 'Jatuh Tempo Pertama';
    }
  }

  List<Widget> _buildHutangFields() => [
    // Info banner
    _infoBanner(
      icon: Icons.info_outline,
      color: Theme.of(context).colorScheme.primaryContainer,
      iconColor: Theme.of(context).colorScheme.primary,
      text: 'Opsional: pilih rekening jika uang hutang masuk ke rekening kamu. '
          'Jika tidak dipilih, saldo tidak akan berubah.',
    ),
    const SizedBox(height: 16),

    // Kategori (wajib hutang)
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
                  child: Row(
                    children: [
                      Icon(iconFromHex(cat.icon), size: 18, color: Color(cat.color)),
                      const SizedBox(width: 8),
                      Text(cat.name),
                    ],
                  ),
                ))
            .toList(),
        onChanged: (v) => setState(() => _selectedCategory = v),
        validator: (v) =>
            isHutang && v == null ? 'Pilih kategori untuk hutang' : null,
      ),
      const SizedBox(height: 16),
    ],

    // Rekening (opsional)
    if (_loadingMethods)
      const Center(child: CircularProgressIndicator())
    else
      DropdownButtonFormField<PaymentMethodModel?>(
        initialValue: _selectedPaymentMethod,
        decoration: const InputDecoration(
          labelText: 'Rekening Masuk (opsional)',
          prefixIcon: Icon(Icons.account_balance_wallet_outlined),
          border: OutlineInputBorder(),
          helperText: 'Rekening yang bertambah saat menerima hutang',
        ),
        items: [
          const DropdownMenuItem<PaymentMethodModel?>(
            value: null,
            child: Text('— Tidak catat saldo —'),
          ),
          ..._paymentMethods.map((m) => DropdownMenuItem(
                value: m,
                child: Text(m.name),
              )),
        ],
        onChanged: (v) => setState(() => _selectedPaymentMethod = v),
      ),
    const SizedBox(height: 16),
  ];

  List<Widget> _buildPiutangFields() => [
    // Info banner
    _infoBanner(
      icon: Icons.info_outline,
      color: Theme.of(context).colorScheme.tertiaryContainer,
      iconColor: Theme.of(context).colorScheme.tertiary,
      text: 'Opsional: pilih rekening yang didebit saat memberi pinjaman. '
          'Jika tidak dipilih, saldo tidak akan berubah — catat manual jika perlu.',
    ),
    const SizedBox(height: 16),

    // Rekening (opsional)
    if (_loadingMethods)
      const Center(child: CircularProgressIndicator())
    else
      DropdownButtonFormField<PaymentMethodModel?>(
        initialValue: _selectedPaymentMethod,
        decoration: const InputDecoration(
          labelText: 'Debit dari Rekening (opsional)',
          prefixIcon: Icon(Icons.account_balance_wallet_outlined),
          border: OutlineInputBorder(),
          helperText: 'Rekening yang berkurang saat memberi pinjaman',
        ),
        items: [
          const DropdownMenuItem<PaymentMethodModel?>(
            value: null,
            child: Text('— Tidak catat saldo —'),
          ),
          ..._paymentMethods.map((m) => DropdownMenuItem(
                value: m,
                child: Text(m.name),
              )),
        ],
        onChanged: (v) => setState(() => _selectedPaymentMethod = v),
      ),
    const SizedBox(height: 16),

    // Biaya transfer (jika ada rekening)
    if (_selectedPaymentMethod != null) ...[
      TextFormField(
        controller: _transferFeeController,
        keyboardType: TextInputType.number,
        inputFormatters: [ThousandsSeparatorInputFormatter()],
        decoration: const InputDecoration(
          labelText: 'Biaya Transfer (opsional)',
          prefixText: 'Rp ',
          prefixIcon: Icon(Icons.swap_horiz),
          border: OutlineInputBorder(),
          helperText: 'Biaya admin transfer (ikut didebit dari rekening)',
        ),
      ),
      const SizedBox(height: 16),
    ],
  ];

  List<Widget> _buildTagihanFields() => [
    // Kategori (wajib untuk tagihan)
    if (_loadingCategories)
      const Center(child: CircularProgressIndicator())
    else ...[
      DropdownButtonFormField<CategoryModel?>(
        initialValue: _selectedCategory,
        decoration: const InputDecoration(
          labelText: 'Kategori *',
          prefixIcon: Icon(Icons.category_outlined),
          border: OutlineInputBorder(),
          helperText: 'Dipakai untuk tracking pengeluaran tagihan',
        ),
        items: _categories
            .map((cat) => DropdownMenuItem(
                  value: cat,
                  child: Row(
                    children: [
                      Icon(iconFromHex(cat.icon), size: 18, color: Color(cat.color)),
                      const SizedBox(width: 8),
                      Text(cat.name),
                    ],
                  ),
                ))
            .toList(),
        onChanged: (v) => setState(() => _selectedCategory = v),
        validator: (v) =>
            isTagihan && v == null ? 'Pilih kategori untuk tagihan' : null,
      ),
      const SizedBox(height: 16),
    ],

    // Tanggal tagih per bulan
    Row(
      children: [
        Expanded(
          child: DropdownButtonFormField<int?>(
            initialValue: _billingDay,
            decoration: const InputDecoration(
              labelText: 'Tanggal Tagih per Bulan (opsional)',
              prefixIcon: Icon(Icons.event_repeat),
              border: OutlineInputBorder(),
              helperText: 'Misal: setiap tgl 5 tiap bulan',
            ),
            items: [
              const DropdownMenuItem<int?>(
                value: null,
                child: Text('— Tidak set —'),
              ),
              ...List.generate(28, (i) => i + 1).map((d) => DropdownMenuItem(
                    value: d,
                    child: Text('Setiap tgl $d'),
                  )),
            ],
            onChanged: (v) => setState(() => _billingDay = v),
          ),
        ),
      ],
    ),
    const SizedBox(height: 16),

    // Batas cicilan
    SwitchListTile(
      value: _hasMaxInstallments,
      onChanged: (v) => setState(() {
        _hasMaxInstallments = v;
        if (!v) _maxInstallmentsController.clear();
      }),
      title: const Text('Ada batas cicilan'),
      subtitle: const Text('Matikan jika tagihan terus setiap bulan'),
      contentPadding: EdgeInsets.zero,
    ),

    if (_hasMaxInstallments) ...[
      const SizedBox(height: 8),
      TextFormField(
        controller: _maxInstallmentsController,
        keyboardType: TextInputType.number,
        onChanged: (_) => setState(() {}),
        decoration: const InputDecoration(
          labelText: 'Jumlah Cicilan (bulan) *',
          prefixIcon: Icon(Icons.format_list_numbered),
          border: OutlineInputBorder(),
          suffixText: 'bulan',
          helperText: 'Misal: 12 = 12 bulan cicilan',
        ),
        validator: (v) {
          if (!_hasMaxInstallments) return null;
          if (v == null || v.isEmpty) return 'Isi jumlah cicilan';
          final n = int.tryParse(v);
          if (n == null || n <= 0) return 'Harus lebih dari 0';
          return null;
        },
      ),
    ],
    const SizedBox(height: 16),
  ];

  Widget _infoBanner({
    required IconData icon,
    required Color color,
    required Color iconColor,
    required String text,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: iconColor),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text,
                style: Theme.of(context).textTheme.bodySmall),
          ),
        ],
      ),
    );
  }
}
