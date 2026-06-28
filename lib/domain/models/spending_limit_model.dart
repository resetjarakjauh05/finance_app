import 'package:freezed_annotation/freezed_annotation.dart';

part 'spending_limit_model.freezed.dart';
part 'spending_limit_model.g.dart';

@freezed
class SpendingLimitModel with _$SpendingLimitModel {
  const factory SpendingLimitModel({
    required String id,
    required String userId,
    /// null = global (semua kategori), isi = per kategori
    String? categoryId,
    String? categoryName,
    String? categoryIcon,
    /// Nominal limit harian dalam rupiah
    required int dailyLimit,
    /// Threshold notifikasi "hampir habis" (0.0 - 1.0), default 0.8 = 80%
    @Default(0.8) double warningThreshold,
    @Default(true) bool isActive,
    String? firebaseDocId,
    @Default(false) bool isSynced,
    DateTime? syncedAt,
    required DateTime localCreatedAt,
    DateTime? updatedAt,
    @Default(false) bool isDeleted,
  }) = _SpendingLimitModel;

  factory SpendingLimitModel.fromJson(Map<String, dynamic> json) =>
      _$SpendingLimitModelFromJson(json);
}

extension SpendingLimitModelExtension on SpendingLimitModel {
  /// Label untuk tampilan
  String get displayName =>
      categoryName != null ? '$categoryIcon $categoryName' : '🌐 Semua Pengeluaran';

  /// Nominal threshold warning
  int get warningAmount => (dailyLimit * warningThreshold).round();

  /// Status pengeluaran hari ini
  SpendingLimitStatus statusForSpent(int spent) {
    if (spent >= dailyLimit) return SpendingLimitStatus.exceeded;
    if (spent >= warningAmount) return SpendingLimitStatus.warning;
    return SpendingLimitStatus.safe;
  }

  Map<String, dynamic> toSqlite() {
    return {
      'id': id,
      'userId': userId,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'categoryIcon': categoryIcon,
      'dailyLimit': dailyLimit,
      'warningThreshold': warningThreshold,
      'isActive': isActive ? 1 : 0,
      'firebaseDocId': firebaseDocId,
      'isSynced': isSynced ? 1 : 0,
      'syncedAt': syncedAt?.millisecondsSinceEpoch,
      'localCreatedAt': localCreatedAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt?.millisecondsSinceEpoch,
      'isDeleted': isDeleted ? 1 : 0,
    };
  }

  static SpendingLimitModel fromSqlite(Map<String, dynamic> map) {
    return SpendingLimitModel(
      id: map['id'] as String,
      userId: map['userId'] as String,
      categoryId: map['categoryId'] as String?,
      categoryName: map['categoryName'] as String?,
      categoryIcon: map['categoryIcon'] as String?,
      dailyLimit: map['dailyLimit'] as int,
      warningThreshold: (map['warningThreshold'] as num).toDouble(),
      isActive: (map['isActive'] as int) == 1,
      firebaseDocId: map['firebaseDocId'] as String?,
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

enum SpendingLimitStatus {
  safe,     // < 80%
  warning,  // 80% - 99%
  exceeded, // >= 100%
}

extension SpendingLimitStatusExtension on SpendingLimitStatus {
  String get label {
    switch (this) {
      case SpendingLimitStatus.safe: return 'Aman';
      case SpendingLimitStatus.warning: return 'Hampir Habis';
      case SpendingLimitStatus.exceeded: return 'Melewati Limit';
    }
  }

  int get color {
    switch (this) {
      case SpendingLimitStatus.safe: return 0xFF43A047;
      case SpendingLimitStatus.warning: return 0xFFFF8F00;
      case SpendingLimitStatus.exceeded: return 0xFFE53935;
    }
  }
}
