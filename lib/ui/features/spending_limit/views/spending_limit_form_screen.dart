import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../domain/models/spending_limit_model.dart';
import '../../../../domain/models/category_model.dart';
import '../../../../data/repositories/category_repository.dart';
import '../view_models/spending_limit_view_model.dart';

class SpendingLimitFormScreen extends StatefulWidget {
  final String userId;
  final SpendingLimitModel? existing;
  final SpendingLimitViewModel viewModel;
  final CategoryRepository categoryRepository;

  const SpendingLimitFormScreen({
    super.key,
    required this.userId,
    required this.viewModel,
    required this.categoryRepository,
    this.existing,
  });

  @override
  State<SpendingLimitFormScreen> createState() =>
      _SpendingLimitFormScreenState();
}

class _SpendingLimitFormScreenState extends State<SpendingLimitFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _limitController = TextEditingController();
  final _currency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

  CategoryModel? _selectedCategory;
  double _warningThreshold = 0.8;
  bool _isSaving = false;
  List<CategoryModel> _categories = [];
  bool _loadingCategories = true;

  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      _limitController.text = widget.existing!.dailyLimit.toString();
      _warningThreshold = widget.existing!.warningThreshold;
    }
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final cats = await widget.categoryRepository.getCategories(widget.userId);
      setState(() {
        _categories = cats;
        _loadingCategories = false;
        if (_isEdit && widget.existing!.categoryId != null) {
          _selectedCategory = cats
              .where((c) => c.id == widget.existing!.categoryId)
              .firstOrNull;
        }
      });
    } catch (e) {
      setState(() => _loadingCategories = false);
    }
  }

  @override
  void dispose() {
    _limitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Edit Limit' : 'Tambah Limit'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Preview card
            _buildPreview(),
            const SizedBox(height: 24),

            // Kategori
            Text('Kategori', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            _loadingCategories
                ? const Center(child: CircularProgressIndicator())
                : _buildCategorySelector(),
            const SizedBox(height: 20),

            // Nominal limit
            TextFormField(
              controller: _limitController,
              decoration: const InputDecoration(
                labelText: 'Limit Harian (Rp)',
                hintText: 'cth: 100000',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.price_change_outlined),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: false),
              enableInteractiveSelection: true,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Nominal tidak boleh kosong';
                final cleaned = v.replaceAll(RegExp(r'[^0-9]'), '');
                final val = int.tryParse(cleaned);
                if (val == null || val <= 0) return 'Nominal harus lebih dari 0';
                return null;
              },
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 20),

            // Warning threshold
            Text('Notifikasi Peringatan',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(
              'Kirim notifikasi saat pengeluaran mencapai ${(_warningThreshold * 100).round()}% dari limit',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
            ),
            Slider(
              value: _warningThreshold,
              min: 0.5,
              max: 0.95,
              divisions: 9,
              label: '${(_warningThreshold * 100).round()}%',
              onChanged: (v) => setState(() => _warningThreshold = v),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('50%', style: TextStyle(fontSize: 12, color: Colors.grey)),
                Text(
                  'Peringatan di ${(_warningThreshold * 100).round()}%',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text('95%', style: TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
            const SizedBox(height: 32),

            // Tombol simpan
            FilledButton.icon(
              onPressed: _isSaving ? null : _save,
              icon: _isSaving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.check),
              label: Text(_isEdit ? 'Simpan Perubahan' : 'Tambah Limit'),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreview() {
    final raw = _limitController.text.replaceAll(RegExp(r'[^0-9]'), '');
    final limitVal = int.tryParse(raw) ?? 0;
    final warningVal = (limitVal * _warningThreshold).round();
    final catName = _selectedCategory != null
        ? '${_selectedCategory!.icon} ${_selectedCategory!.name}'
        : '🌐 Semua Pengeluaran';

    return Card(
      color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(catName, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              'Limit: ${limitVal > 0 ? _currency.format(limitVal) : '-'}',
              style: const TextStyle(fontSize: 13),
            ),
            Text(
              'Notifikasi: ${warningVal > 0 ? _currency.format(warningVal) : '-'} (${(_warningThreshold * 100).round()}%)',
              style: const TextStyle(fontSize: 13, color: Colors.orange),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySelector() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        ChoiceChip(
          label: const Text('🌐 Semua'),
          selected: _selectedCategory == null,
          onSelected: (_) => setState(() => _selectedCategory = null),
        ),
        ..._categories.map((cat) => ChoiceChip(
              label: Text('${cat.icon} ${cat.name}'),
              selected: _selectedCategory?.id == cat.id,
              onSelected: (_) => setState(() => _selectedCategory = cat),
            )),
      ],
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final raw = _limitController.text.replaceAll(RegExp(r'[^0-9]'), '');
    final limitVal = int.parse(raw);
    bool ok;

    if (_isEdit) {
      ok = await widget.viewModel.updateLimit(
        widget.existing!.copyWith(
          dailyLimit: limitVal,
          categoryId: _selectedCategory?.id,
          categoryName: _selectedCategory?.name,
          categoryIcon: _selectedCategory?.icon,
          warningThreshold: _warningThreshold,
          updatedAt: DateTime.now(),
        ),
      );
    } else {
      ok = await widget.viewModel.createLimit(
        userId: widget.userId,
        dailyLimit: limitVal,
        categoryId: _selectedCategory?.id,
        categoryName: _selectedCategory?.name,
        categoryIcon: _selectedCategory?.icon,
        warningThreshold: _warningThreshold,
      );
    }

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (ok) {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(widget.viewModel.errorMessage ?? 'Gagal menyimpan'),
        backgroundColor: Colors.red,
      ));
    }
  }
}
