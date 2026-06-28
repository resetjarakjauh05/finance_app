import 'package:freezed_annotation/freezed_annotation.dart';

part 'savings_plan_model.freezed.dart';
part 'savings_plan_model.g.dart';

@freezed
class SavingsPlanModel with _$SavingsPlanModel {
  const factory SavingsPlanModel({
    required String id,
    required String userId,
    required String name,
    String? description,
    String? icon,
    /// Target total tabungan
    required int targetAmount,
    /// Sudah terkumpul (akumulasi dari semua alokasi)
    @Default(0) int savedAmount,
    /// Target per bulan (opsional, sebagai panduan)
    @Default(0) int monthlyTarget,
    /// Deadline target (opsional)
    DateTime? targetDate,
    @Default(true) bool isActive,
    String? firebaseDocId,
    @Default(false) bool isSynced,
    DateTime? syncedAt,
    required DateTime localCreatedAt,
    DateTime? updatedAt,
    @Default(false) bool isDeleted,
  }) = _SavingsPlanModel;

  factory SavingsPlanModel.fromJson(Map<String, dynamic> json) =>
      _$SavingsPlanModelFromJson(json);
}

extension SavingsPlanModelExtension on SavingsPlanModel {
  /// Progress 0.0 - 1.0
  double get progress =>
      targetAmount > 0 ? (savedAmount / targetAmount).clamp(0.0, 1.0) : 0.0;

  /// Sisa yang perlu ditabung
  int get remaining => (targetAmount - savedAmount).clamp(0, targetAmount);

  /// Sudah tercapai
  bool get isAchieved => savedAmount >= targetAmount;

  /// Status label
  String get statusLabel {
    if (isAchieved) return 'Tercapai';
    if (progress >= 0.75) return 'Hampir Tercapai';
    if (progress >= 0.5) return 'Setengah Jalan';
    return 'Baru Mulai';
  }

  int get statusColor {
    if (isAchieved) return 0xFF43A047;
    if (progress >= 0.75) return 0xFF00ACC1;
    if (progress >= 0.5) return 0xFFFF8F00;
    return 0xFF1E88E5;
  }

  Map<String, dynamic> toSqlite() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'description': description,
      'icon': icon,
      'targetAmount': targetAmount,
      'savedAmount': savedAmount,
      'monthlyTarget': monthlyTarget,
      'targetDate': targetDate?.millisecondsSinceEpoch,
      'isActive': isActive ? 1 : 0,
      'firebaseDocId': firebaseDocId,
      'isSynced': isSynced ? 1 : 0,
      'syncedAt': syncedAt?.millisecondsSinceEpoch,
      'localCreatedAt': localCreatedAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt?.millisecondsSinceEpoch,
      'isDeleted': isDeleted ? 1 : 0,
    };
  }

  static SavingsPlanModel fromSqlite(Map<String, dynamic> map) {
    return SavingsPlanModel(
      id: map['id'] as String,
      userId: map['userId'] as String,
      name: map['name'] as String,
      description: map['description'] as String?,
      icon: map['icon'] as String?,
      targetAmount: map['targetAmount'] as int,
      savedAmount: map['savedAmount'] as int? ?? 0,
      monthlyTarget: map['monthlyTarget'] as int? ?? 0,
      targetDate: map['targetDate'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['targetDate'] as int)
          : null,
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

/// Model untuk riwayat alokasi ke tabungan
@freezed
class SavingsAllocationModel with _$SavingsAllocationModel {
  const factory SavingsAllocationModel({
    required String id,
    required String userId,
    required String savingsPlanId,
    required int amount,
    String? notes,
    required DateTime date,
    /// Rekening sumber (uang diambil dari sini)
    required String fromPaymentMethodId,
    required String fromPaymentMethodName,
    /// Rekening tujuan/tempat simpan (opsional, bisa sama)
    String? toPaymentMethodId,
    String? toPaymentMethodName,
    /// Biaya transfer opsional (dibebankan ke rekening sumber)
    @Default(0) int transferFee,
    String? firebaseDocId,
    @Default(false) bool isSynced,
    required DateTime localCreatedAt,
    @Default(false) bool isDeleted,
  }) = _SavingsAllocationModel;

  factory SavingsAllocationModel.fromJson(Map<String, dynamic> json) =>
      _$SavingsAllocationModelFromJson(json);
}

extension SavingsAllocationModelExtension on SavingsAllocationModel {
  Map<String, dynamic> toSqlite() {
    return {
      'id': id,
      'userId': userId,
      'savingsPlanId': savingsPlanId,
      'amount': amount,
      'notes': notes,
      'date': date.millisecondsSinceEpoch,
      'fromPaymentMethodId': fromPaymentMethodId,
      'fromPaymentMethodName': fromPaymentMethodName,
      'toPaymentMethodId': toPaymentMethodId,
      'toPaymentMethodName': toPaymentMethodName,
      'transferFee': transferFee,
      'firebaseDocId': firebaseDocId,
      'isSynced': isSynced ? 1 : 0,
      'localCreatedAt': localCreatedAt.millisecondsSinceEpoch,
      'isDeleted': isDeleted ? 1 : 0,
    };
  }

  static SavingsAllocationModel fromSqlite(Map<String, dynamic> map) {
    return SavingsAllocationModel(
      id: map['id'] as String,
      userId: map['userId'] as String,
      savingsPlanId: map['savingsPlanId'] as String,
      amount: map['amount'] as int,
      notes: map['notes'] as String?,
      date: DateTime.fromMillisecondsSinceEpoch(map['date'] as int),
      fromPaymentMethodId: map['fromPaymentMethodId'] as String? ?? '',
      fromPaymentMethodName: map['fromPaymentMethodName'] as String? ?? '',
      toPaymentMethodId: map['toPaymentMethodId'] as String?,
      toPaymentMethodName: map['toPaymentMethodName'] as String?,
      transferFee: (map['transferFee'] as int?) ?? 0,
      firebaseDocId: map['firebaseDocId'] as String?,
      isSynced: (map['isSynced'] as int) == 1,
      localCreatedAt:
          DateTime.fromMillisecondsSinceEpoch(map['localCreatedAt'] as int),
      isDeleted: (map['isDeleted'] as int) == 1,
    );
  }
}
