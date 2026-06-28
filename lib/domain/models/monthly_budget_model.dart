import 'package:freezed_annotation/freezed_annotation.dart';

part 'monthly_budget_model.freezed.dart';
part 'monthly_budget_model.g.dart';

/// Plan anggaran bulanan per kategori
@freezed
class MonthlyBudgetModel with _$MonthlyBudgetModel {
  const factory MonthlyBudgetModel({
    required String id,
    required String userId,
    /// Format: 'yyyy-MM' misal '2026-06'
    required String yearMonth,
    required String categoryId,
    required String categoryName,
    required String categoryIcon,
    /// Target anggaran bulan ini
    required int budgetAmount,
    String? notes,
    String? firebaseDocId,
    @Default(false) bool isSynced,
    DateTime? syncedAt,
    required DateTime localCreatedAt,
    DateTime? updatedAt,
    @Default(false) bool isDeleted,
  }) = _MonthlyBudgetModel;

  factory MonthlyBudgetModel.fromJson(Map<String, dynamic> json) =>
      _$MonthlyBudgetModelFromJson(json);
}

extension MonthlyBudgetModelExtension on MonthlyBudgetModel {
  /// Label bulan untuk tampilan
  String get monthLabel {
    final parts = yearMonth.split('-');
    if (parts.length != 2) return yearMonth;
    final months = [
      '', 'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    final month = int.tryParse(parts[1]) ?? 0;
    return '${months[month]} ${parts[0]}';
  }

  /// Status anggaran berdasarkan pengeluaran aktual
  BudgetStatus statusForSpent(int spent) {
    if (spent > budgetAmount) return BudgetStatus.exceeded;
    if (spent >= (budgetAmount * 0.8).round()) return BudgetStatus.warning;
    return BudgetStatus.safe;
  }

  /// Sisa anggaran
  int remainingFor(int spent) =>
      (budgetAmount - spent).clamp(0, budgetAmount);

  /// Progress 0.0 - 1.0+
  double progressFor(int spent) =>
      budgetAmount > 0 ? spent / budgetAmount : 0.0;

  Map<String, dynamic> toSqlite() {
    return {
      'id': id,
      'userId': userId,
      'yearMonth': yearMonth,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'categoryIcon': categoryIcon,
      'budgetAmount': budgetAmount,
      'notes': notes,
      'firebaseDocId': firebaseDocId,
      'isSynced': isSynced ? 1 : 0,
      'syncedAt': syncedAt?.millisecondsSinceEpoch,
      'localCreatedAt': localCreatedAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt?.millisecondsSinceEpoch,
      'isDeleted': isDeleted ? 1 : 0,
    };
  }

  static MonthlyBudgetModel fromSqlite(Map<String, dynamic> map) {
    return MonthlyBudgetModel(
      id: map['id'] as String,
      userId: map['userId'] as String,
      yearMonth: map['yearMonth'] as String,
      categoryId: map['categoryId'] as String,
      categoryName: map['categoryName'] as String,
      categoryIcon: map['categoryIcon'] as String,
      budgetAmount: map['budgetAmount'] as int,
      notes: map['notes'] as String?,
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

enum BudgetStatus { safe, warning, exceeded }

extension BudgetStatusExtension on BudgetStatus {
  String get label {
    switch (this) {
      case BudgetStatus.safe: return 'Aman';
      case BudgetStatus.warning: return 'Hampir Habis';
      case BudgetStatus.exceeded: return 'Melebihi Anggaran';
    }
  }

  int get color {
    switch (this) {
      case BudgetStatus.safe: return 0xFF43A047;
      case BudgetStatus.warning: return 0xFFFF8F00;
      case BudgetStatus.exceeded: return 0xFFE53935;
    }
  }
}
