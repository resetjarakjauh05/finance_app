import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../../../data/services/bill_service.dart';
import '../../../../data/repositories/bill_repository.dart';
import '../../../../data/repositories/category_repository.dart';
import '../../../../data/services/category_service.dart';
import '../../../../data/local/category_dao.dart';
import '../../../../domain/models/bill_model.dart';
import '../../../../domain/models/category_model.dart';
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
  late final BillViewModel _viewModel;

  DateTime _dueDate = DateTime.now().add(const Duration(days: 7));
  BillType _selectedType = BillType.hutang;
  final _dateFormat = DateFormat('dd MMM yyyy', 'id_ID');

  // Kategori
  CategoryModel? _selectedCategory;
  List<CategoryModel> _categories = [];
  bool _loadingCategories = false;

  bool get isEditMode => widget.bill != null;

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
      _nominalController.text = b.nominal.toString();
      _notesController.text = b.notes ?? '';
      _dueDate = b.dueDate;
      _selectedType = b.type;
    }
    _loadCategories();
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
        // Set existing category saat edit
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

  @override
  void dispose() {
    _viewModel.dispose();
    _nameController.dispose();
    _nominalController.dispose();
    _notesController.dispose();
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

    try {
      if (isEditMode) {
        final updated = widget.bill!.copyWith(
          name: _nameController.text.trim(),
          nominal: int.parse(_nominalController.text),
          dueDate: _dueDate,
          type: _selectedType,
          categoryId: _selectedType == BillType.hutang
              ? _selectedCategory?.id
              : null,
          categoryName: _selectedType == BillType.hutang
              ? _selectedCategory?.name
              : null,
          notes: _notesController.text.trim().isNotEmpty
              ? _notesController.text.trim()
              : null,
          updatedAt: DateTime.now(),
        );
        await _viewModel.updateBill(updated);
      } else {
        await _viewModel.createBill(
          name: _nameController.text.trim(),
          nominal: int.parse(_nominalController.text),
          dueDate: _dueDate,
          type: _selectedType,
          categoryId: _selectedType == BillType.hutang
              ? _selectedCategory?.id
              : null,
          categoryName: _selectedType == BillType.hutang
              ? _selectedCategory?.name
              : null,
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
              onPressed: (_viewModel.isLoading || _loadingCategories) ? null : _handleSave,
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
                  // Reset kategori saat ganti ke piutang
                  if (_selectedType == BillType.piutang) {
                    _selectedCategory = null;
                  }
                });
              },
            ),
            const SizedBox(height: 16),

            // Kategori (wajib hutang, opsional piutang)
            if (_loadingCategories)
              const Center(child: CircularProgressIndicator())
            else if (_categories.isNotEmpty) ...[
              DropdownButtonFormField<CategoryModel>(
                value: _selectedCategory,
                decoration: InputDecoration(
                  labelText: _selectedType == BillType.hutang
                      ? 'Kategori *'
                      : 'Kategori (opsional)',
                  prefixIcon: const Icon(Icons.category_outlined),
                  border: const OutlineInputBorder(),
                ),
                items: _categories
                    .map((cat) => DropdownMenuItem(
                          value: cat,
                          child: Text('${cat.icon} ${cat.name}'),
                        ))
                    .toList(),
                onChanged: (v) => setState(() => _selectedCategory = v),
                validator: (v) =>
                    _selectedType == BillType.hutang && v == null
                        ? 'Pilih kategori untuk hutang'
                        : null,
              ),
              const SizedBox(height: 16),
            ],

            // Nama tagihan
            TextFormField(
              controller: _nameController,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Nama Tagihan',
                hintText: 'Contoh: Cicilan Motor, Listrik',
                prefixIcon: Icon(Icons.receipt_long),
                border: OutlineInputBorder(),
              ),
              validator: (v) =>
                  v == null || v.isEmpty ? 'Nama tidak boleh kosong' : null,
            ),
            const SizedBox(height: 16),

            // Nominal
            TextFormField(
              controller: _nominalController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                labelText: 'Total Nominal',
                prefixText: 'Rp ',
                prefixIcon: Icon(Icons.attach_money),
                border: OutlineInputBorder(),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Nominal tidak boleh kosong';
                if (int.tryParse(v) == null || int.parse(v) <= 0) {
                  return 'Nominal harus lebih dari 0';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Due date
            InkWell(
              onTap: _selectDate,
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Jatuh Tempo',
                  prefixIcon: Icon(Icons.calendar_today),
                  border: OutlineInputBorder(),
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
