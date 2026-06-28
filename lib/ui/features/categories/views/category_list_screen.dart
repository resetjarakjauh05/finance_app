import 'package:flutter/material.dart';
import '../../../../domain/models/category_model.dart';
import '../../../../data/repositories/category_repository.dart';
import '../../../../data/services/category_service.dart';
import '../../../../data/local/category_dao.dart';
import '../view_models/category_view_model.dart';
import 'category_form_screen.dart';

class CategoryListScreen extends StatefulWidget {
  final String userId;
  const CategoryListScreen({super.key, required this.userId});

  @override
  State<CategoryListScreen> createState() => _CategoryListScreenState();
}

class _CategoryListScreenState extends State<CategoryListScreen> {
  late final CategoryViewModel _vm;

  @override
  void initState() {
    super.initState();
    _vm = CategoryViewModel(
      repository: CategoryRepository(
        service: CategoryService(dao: CategoryDao()),
      ),
    );
    _vm.loadCategories(widget.userId);
  }

  @override
  void dispose() {
    _vm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kategori'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Tambah Kategori',
            onPressed: () => _openForm(context),
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: _vm,
        builder: (context, _) {
          if (_vm.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (_vm.status == CategoryStatus.error) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 12),
                  Text(_vm.errorMessage ?? 'Terjadi kesalahan'),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: () => _vm.loadCategories(widget.userId),
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            );
          }

          if (_vm.categories.isEmpty) {
            return const Center(child: Text('Belum ada kategori'));
          }

          return RefreshIndicator(
            onRefresh: () => _vm.loadCategories(widget.userId),
            child: ListView(
              padding: const EdgeInsets.only(bottom: 80),
              children: [
                // Preset section
                if (_vm.presetCategories.isNotEmpty) ...[
                  _SectionHeader(title: 'Kategori Umum (${_vm.presetCategories.length})'),
                  ..._vm.presetCategories.map((cat) => _CategoryTile(
                        category: cat,
                        onEdit: null,
                        onDelete: null,
                      )),
                ],
                // Custom section
                if (_vm.customCategories.isNotEmpty) ...[
                  _SectionHeader(title: 'Kategori Kustom (${_vm.customCategories.length})'),
                  ..._vm.customCategories.map((cat) => _CategoryTile(
                        category: cat,
                        onEdit: () => _openForm(context, existing: cat),
                        onDelete: () => _confirmDelete(context, cat),
                      )),
                ],
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(context),
        icon: const Icon(Icons.add),
        label: const Text('Tambah Kategori'),
      ),
    );
  }

  Future<void> _openForm(BuildContext context, {CategoryModel? existing}) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => CategoryFormScreen(
          userId: widget.userId,
          existing: existing,
          viewModel: _vm,
        ),
      ),
    );
    if (result == true) {
      await _vm.loadCategories(widget.userId);
    }
  }

  Future<void> _confirmDelete(BuildContext context, CategoryModel cat) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Kategori'),
        content: Text('Hapus kategori "${cat.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      final ok = await _vm.deleteCategory(cat);
      if (!ok && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_vm.errorMessage ?? 'Gagal menghapus'), backgroundColor: Colors.red),
        );
      }
    }
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  final CategoryModel category;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const _CategoryTile({
    required this.category,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Color(category.color).withValues(alpha: 0.15),
        child: Text(category.icon, style: const TextStyle(fontSize: 20)),
      ),
      title: Text(category.name),
      subtitle: category.isPreset
          ? const Text('Preset', style: TextStyle(fontSize: 12))
          : const Text('Kustom', style: TextStyle(fontSize: 12)),
      trailing: category.isPreset
          ? const Icon(Icons.lock_outline, size: 18, color: Colors.grey)
          : PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'edit') onEdit?.call();
                if (value == 'delete') onDelete?.call();
              },
              itemBuilder: (_) => [
                const PopupMenuItem(value: 'edit', child: Text('Edit')),
                const PopupMenuItem(
                  value: 'delete',
                  child: Text('Hapus', style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
    );
  }
}
