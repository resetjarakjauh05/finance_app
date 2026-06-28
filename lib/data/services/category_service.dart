import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../../domain/models/category_model.dart';
import '../local/category_dao.dart';

/// Service untuk kategori — Firestore + SQLite
class CategoryService {
  final FirebaseFirestore _firestore;
  final CategoryDao _dao;
  final _uuid = const Uuid();

  CategoryService({
    FirebaseFirestore? firestore,
    CategoryDao? dao,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _dao = dao ?? CategoryDao();

  CollectionReference<Map<String, dynamic>> _col(String userId) =>
      _firestore.collection('users').doc(userId).collection('categories');

  /// Inisialisasi preset categories untuk user baru
  Future<void> initializePresets(String userId) async {
    final hasPresets = await _dao.hasPresets(userId);
    if (hasPresets) return;

    final presets = kPresetCategories
        .map((p) => CategoryModel.fromPreset(p, userId))
        .toList();

    await _dao.insertBatch(presets);
    debugPrint('CategoryService: ${presets.length} presets initialized for $userId');
  }

  /// Get semua kategori aktif (stream dari SQLite via periodic refresh)
  Future<List<CategoryModel>> getCategories(String userId) async {
    await initializePresets(userId);
    return _dao.getCategories(userId);
  }

  /// Get kategori by id
  Future<CategoryModel?> getCategoryById(String id) async {
    return _dao.getCategoryById(id);
  }

  /// Tambah kategori custom baru
  Future<CategoryModel> createCategory({
    required String userId,
    required String name,
    required String icon,
    required int color,
  }) async {
    final id = 'custom_${_uuid.v4()}';
    final category = CategoryModel(
      id: id,
      userId: userId,
      name: name.trim(),
      icon: icon,
      color: color,
      isPreset: false,
      localCreatedAt: DateTime.now(),
    );

    await _dao.insertOrReplace(category);

    // Sync ke Firestore
    try {
      final docRef = await _col(userId).add({
        'id': id,
        'name': category.name,
        'icon': icon,
        'color': color,
        'isPreset': false,
        'isActive': true,
        'isDeleted': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
      await _dao.markSynced(id, docRef.id);
    } catch (e) {
      debugPrint('CategoryService.createCategory sync error: $e');
    }

    return category;
  }

  /// Update kategori custom
  Future<void> updateCategory(CategoryModel category) async {
    if (category.isPreset) {
      throw Exception('Kategori preset tidak dapat diubah');
    }

    final updated = category.copyWith(updatedAt: DateTime.now());
    await _dao.update(updated);

    // Sync ke Firestore
    try {
      if (category.firebaseDocId != null) {
        await _col(category.userId).doc(category.firebaseDocId).update({
          'name': category.name,
          'icon': category.icon,
          'color': category.color,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      debugPrint('CategoryService.updateCategory sync error: $e');
    }
  }

  /// Delete kategori custom (soft delete)
  Future<void> deleteCategory(CategoryModel category) async {
    if (category.isPreset) {
      throw Exception('Kategori preset tidak dapat dihapus');
    }

    await _dao.softDelete(category.id);

    // Sync ke Firestore
    try {
      if (category.firebaseDocId != null) {
        await _col(category.userId).doc(category.firebaseDocId).update({
          'isDeleted': true,
          'deletedAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      debugPrint('CategoryService.deleteCategory sync error: $e');
    }
  }
}
