import 'package:flutter/material.dart';
import '../../../../domain/models/category_model.dart';
import '../../../core/icon_helper.dart';
import '../view_models/category_view_model.dart';

/// Daftar warna pilihan
const List<int> kCategoryColors = [
  0xFFE53935, 0xFF1E88E5, 0xFF8E24AA, 0xFFFF8F00, 0xFF43A047,
  0xFF00ACC1, 0xFF6D4C41, 0xFF5D4037, 0xFF00897B, 0xFF757575,
  0xFFD81B60, 0xFF3949AB, 0xFF039BE5, 0xFF00BFA5, 0xFFFF6F00,
  0xFF558B2F, 0xFF6A1B9A, 0xFF283593, 0xFF37474F, 0xFFC62828,
];

class CategoryFormScreen extends StatefulWidget {
  final String userId;
  final CategoryModel? existing;
  final CategoryViewModel viewModel;

  const CategoryFormScreen({
    super.key,
    required this.userId,
    required this.viewModel,
    this.existing,
  });

  @override
  State<CategoryFormScreen> createState() => _CategoryFormScreenState();
}

class _CategoryFormScreenState extends State<CategoryFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  late String _selectedIcon;
  late int _selectedColor;
  bool _isSaving = false;

  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      _nameController.text = widget.existing!.name;
      _selectedIcon = widget.existing!.icon;
      _selectedColor = widget.existing!.color;
    } else {
      _selectedIcon = kCategoryMaterialIcons.first;
      _selectedColor = kCategoryColors.first;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Edit Kategori' : 'Tambah Kategori'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Preview
            _buildPreview(),
            const SizedBox(height: 24),

            // Nama
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nama Kategori',
                hintText: 'cth: Makan Siang, Bensin, Gym...',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.label_outline),
              ),
              maxLength: 30,
              textCapitalization: TextCapitalization.words,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Nama tidak boleh kosong';
                if (v.trim().length < 2) return 'Minimal 2 karakter';
                return null;
              },
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 20),

            // Pilih icon
            Text('Pilih Icon', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            _buildIconPicker(),
            const SizedBox(height: 20),

            // Pilih warna
            Text('Pilih Warna', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            _buildColorPicker(),
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
              label: Text(_isEdit ? 'Simpan Perubahan' : 'Tambah Kategori'),
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
    final name = _nameController.text.trim().isEmpty
        ? 'Nama Kategori'
        : _nameController.text.trim();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: Color(_selectedColor).withValues(alpha: 0.15),
              child: Icon(iconFromHex(_selectedIcon), size: 26, color: Color(_selectedColor)),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: Theme.of(context).textTheme.titleMedium),
                const Text('Kustom', style: TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconPicker() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: kCategoryMaterialIcons.map((hex) {
        final isSelected = hex == _selectedIcon;
        return GestureDetector(
          onTap: () => setState(() => _selectedIcon = hex),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isSelected
                  ? Color(_selectedColor).withValues(alpha: 0.2)
                  : Colors.grey.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: isSelected
                  ? Border.all(color: Color(_selectedColor), width: 2)
                  : null,
            ),
            child: Center(
              child: Icon(
                iconFromHex(hex),
                size: 22,
                color: isSelected ? Color(_selectedColor) : Colors.grey[600],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildColorPicker() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: kCategoryColors.map((color) {
        final isSelected = color == _selectedColor;
        return GestureDetector(
          onTap: () => setState(() => _selectedColor = color),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Color(color),
              shape: BoxShape.circle,
              border: isSelected
                  ? Border.all(color: Colors.white, width: 3)
                  : null,
              boxShadow: isSelected
                  ? [BoxShadow(color: Color(color).withValues(alpha: 0.5), blurRadius: 6)]
                  : null,
            ),
            child: isSelected
                ? const Icon(Icons.check, color: Colors.white, size: 18)
                : null,
          ),
        );
      }).toList(),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    bool ok;
    if (_isEdit) {
      ok = await widget.viewModel.updateCategory(
        widget.existing!.copyWith(
          name: _nameController.text.trim(),
          icon: _selectedIcon,
          color: _selectedColor,
          updatedAt: DateTime.now(),
        ),
      );
    } else {
      ok = await widget.viewModel.createCategory(
        userId: widget.userId,
        name: _nameController.text.trim(),
        icon: _selectedIcon,
        color: _selectedColor,
      );
    }

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (ok) {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.viewModel.errorMessage ?? 'Gagal menyimpan'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
