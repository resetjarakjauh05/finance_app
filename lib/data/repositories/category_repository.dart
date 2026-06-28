import 'package:connectivity_plus/connectivity_plus.dart';
import '../../domain/models/category_model.dart';
import '../services/category_service.dart';

/// Repository untuk kategori
class CategoryRepository {
  final CategoryService _service;
  final Connectivity _connectivity;

  CategoryRepository({
    required CategoryService service,
    Connectivity? connectivity,
  })  : _service = service,
        _connectivity = connectivity ?? Connectivity();

  Future<bool> _isOnline() async {
    final result = await _connectivity.checkConnectivity();
    return !result.contains(ConnectivityResult.none);
  }

  /// Init preset untuk user baru
  Future<void> initializePresets(String userId) async {
    await _service.initializePresets(userId);
  }

  /// Get semua kategori aktif
  Future<List<CategoryModel>> getCategories(String userId) async {
    return _service.getCategories(userId);
  }

  /// Get kategori by id
  Future<CategoryModel?> getCategoryById(String id) async {
    return _service.getCategoryById(id);
  }

  /// Tambah kategori custom
  Future<CategoryModel> createCategory({
    required String userId,
    required String name,
    required String icon,
    required int color,
  }) async {
    if (name.trim().isEmpty) {
      throw Exception('Nama kategori tidak boleh kosong');
    }
    if (name.trim().length > 30) {
      throw Exception('Nama kategori maksimal 30 karakter');
    }
    return _service.createCategory(
      userId: userId,
      name: name,
      icon: icon,
      color: color,
    );
  }

  /// Update kategori custom
  Future<void> updateCategory(CategoryModel category) async {
    if (category.isPreset) {
      throw Exception('Kategori preset tidak dapat diubah');
    }
    if (category.name.trim().isEmpty) {
      throw Exception('Nama kategori tidak boleh kosong');
    }
    await _service.updateCategory(category);
  }

  /// Delete kategori custom
  Future<void> deleteCategory(CategoryModel category) async {
    if (category.isPreset) {
      throw Exception('Kategori preset tidak dapat dihapus');
    }
    await _service.deleteCategory(category);
  }

  Future<bool> isOnline() async => _isOnline();
}
