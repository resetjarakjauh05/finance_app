import 'package:flutter/foundation.dart';
import '../../../../domain/models/category_model.dart';
import '../../../../data/repositories/category_repository.dart';

/// State enum untuk loading/error/success
enum CategoryStatus { initial, loading, loaded, error }

class CategoryViewModel extends ChangeNotifier {
  final CategoryRepository _repository;

  CategoryViewModel({required CategoryRepository repository})
      : _repository = repository;

  List<CategoryModel> _categories = [];
  CategoryStatus _status = CategoryStatus.initial;
  String? _errorMessage;

  List<CategoryModel> get categories => _categories;
  CategoryStatus get status => _status;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _status == CategoryStatus.loading;

  /// Preset kategori (tidak bisa dihapus/edit)
  List<CategoryModel> get presetCategories =>
      _categories.where((c) => c.isPreset).toList();

  /// Kategori custom buatan user
  List<CategoryModel> get customCategories =>
      _categories.where((c) => !c.isPreset).toList();

  /// Load semua kategori — auto reload setelah CRUD
  Future<void> loadCategories(String userId) async {
    _status = CategoryStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _categories = await _repository.getCategories(userId);
      _status = CategoryStatus.loaded;
    } catch (e) {
      _status = CategoryStatus.error;
      _errorMessage = e.toString();
    }
    notifyListeners();
  }

  /// Tambah kategori custom → auto reload
  Future<bool> createCategory({
    required String userId,
    required String name,
    required String icon,
    required int color,
  }) async {
    _errorMessage = null;
    try {
      await _repository.createCategory(
        userId: userId,
        name: name,
        icon: icon,
        color: color,
      );
      await loadCategories(userId); // auto reload
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  /// Update kategori custom → auto reload
  Future<bool> updateCategory(CategoryModel category) async {
    _errorMessage = null;
    try {
      await _repository.updateCategory(category);
      await loadCategories(category.userId); // auto reload
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  /// Delete kategori custom → auto reload
  Future<bool> deleteCategory(CategoryModel category) async {
    _errorMessage = null;
    try {
      await _repository.deleteCategory(category);
      await loadCategories(category.userId); // auto reload
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
