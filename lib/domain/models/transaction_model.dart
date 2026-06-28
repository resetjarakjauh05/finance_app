import 'package:freezed_annotation/freezed_annotation.dart';

part 'transaction_model.freezed.dart';
part 'transaction_model.g.dart';

/// Enum untuk kategori transaksi
enum TransactionCategory {
  income,   // Uang Masuk
  expense,  // Uang Keluar
}

/// Extension untuk display name
extension TransactionCategoryExtension on TransactionCategory {
  String get displayName {
    switch (this) {
      case TransactionCategory.income:
        return 'Uang Masuk';
      case TransactionCategory.expense:
        return 'Uang Keluar';
    }
  }

  String get icon {
    switch (this) {
      case TransactionCategory.income:
        return '⬇️'; // Down arrow (money in)
      case TransactionCategory.expense:
        return '⬆️'; // Up arrow (money out)
    }
  }
}

/// Model untuk transaksi
@freezed
class TransactionModel with _$TransactionModel {
  const factory TransactionModel({
    required int id,
    String? firebaseDocId,
    required String userId,
    required String description,
    required TransactionCategory category,
    required String paymentMethodId,
    required String paymentMethodName,
    required int nominal,
    required DateTime date,
    String? notes,
    /// ID kategori custom (dari CategoryModel)
    String? categoryId,
    String? categoryName,
    @Default(false) bool isSynced,
    DateTime? syncedAt,
    required DateTime localCreatedAt,
    DateTime? updatedAt,
    @Default(false) bool isDeleted,
  }) = _TransactionModel;

  factory TransactionModel.fromJson(Map<String, dynamic> json) =>
      _$TransactionModelFromJson(json);
}

/// Helper untuk konversi SQLite
extension TransactionModelExtension on TransactionModel {
  /// Convert to SQLite map
  Map<String, dynamic> toSqlite() {
    return {
      if (id > 0) 'id': id,
      'firebaseDocId': firebaseDocId,
      'userId': userId,
      'description': description,
      'category': category.name,
      'paymentMethodId': paymentMethodId,
      'paymentMethodName': paymentMethodName,
      'nominal': nominal,
      'date': date.millisecondsSinceEpoch,
      'notes': notes,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'isSynced': isSynced ? 1 : 0,
      'syncedAt': syncedAt?.millisecondsSinceEpoch,
      'localCreatedAt': localCreatedAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt?.millisecondsSinceEpoch,
      'isDeleted': isDeleted ? 1 : 0,
    };
  }

  /// Create from SQLite map
  static TransactionModel fromSqlite(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'] as int,
      firebaseDocId: map['firebaseDocId'] as String?,
      userId: map['userId'] as String,
      description: map['description'] as String,
      category: TransactionCategory.values.firstWhere(
        (e) => e.name == map['category'],
      ),
      paymentMethodId: map['paymentMethodId'] as String,
      paymentMethodName: map['paymentMethodName'] as String,
      nominal: map['nominal'] as int,
      date: DateTime.fromMillisecondsSinceEpoch(map['date'] as int),
      notes: map['notes'] as String?,
      categoryId: map['categoryId'] as String?,
      categoryName: map['categoryName'] as String?,
      isSynced: (map['isSynced'] as int) == 1,
      syncedAt: map['syncedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['syncedAt'] as int)
          : null,
      localCreatedAt:
          DateTime.fromMillisecondsSinceEpoch(map['localCreatedAt'] as int),
      updatedAt: map['updatedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] as int)
          : null,
      isDeleted: (map['isDeleted'] as int) == 1,
    );
  }
}
