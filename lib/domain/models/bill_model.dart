import 'package:freezed_annotation/freezed_annotation.dart';

part 'bill_model.freezed.dart';
part 'bill_model.g.dart';

/// Tipe tagihan
enum BillType {
  hutang,   // Kita yang berutang ke orang
  piutang,  // Kita memberi pinjaman ke orang
  tagihan,  // Tagihan rutin bulanan (listrik, langganan, cicilan, dll)
}

extension BillTypeExtension on BillType {
  String get displayName {
    switch (this) {
      case BillType.hutang:   return 'Hutang';
      case BillType.piutang:  return 'Piutang';
      case BillType.tagihan:  return 'Tagihan';
    }
  }

  String get name {
    switch (this) {
      case BillType.hutang:   return 'HUTANG';
      case BillType.piutang:  return 'PIUTANG';
      case BillType.tagihan:  return 'TAGIHAN';
    }
  }

  static BillType fromString(String value) {
    switch (value.toUpperCase()) {
      case 'PIUTANG': return BillType.piutang;
      case 'TAGIHAN': return BillType.tagihan;
      default:        return BillType.hutang;
    }
  }
}

/// Status tagihan
enum BillStatus {
  unpaid,   // Belum Bayar
  partial,  // Sebagian
  paid,     // Lunas
}

extension BillStatusExtension on BillStatus {
  String get displayName {
    switch (this) {
      case BillStatus.unpaid:  return 'Belum Bayar';
      case BillStatus.partial: return 'Sebagian';
      case BillStatus.paid:    return 'Lunas';
    }
  }

  String get name {
    switch (this) {
      case BillStatus.unpaid:  return 'UNPAID';
      case BillStatus.partial: return 'PARTIAL';
      case BillStatus.paid:    return 'PAID';
    }
  }

  static BillStatus fromString(String value) {
    switch (value.toUpperCase()) {
      case 'PARTIAL': return BillStatus.partial;
      case 'PAID':    return BillStatus.paid;
      default:        return BillStatus.unpaid;
    }
  }
}

/// Model tagihan/hutang
@freezed
abstract class BillModel with _$BillModel {
  const factory BillModel({
    required int id,
    String? firebaseDocId,
    required String userId,
    required String name,
    required int nominal,
    @Default(0) int paidAmount,
    required DateTime dueDate,
    required BillStatus status,
    @Default(BillType.hutang) BillType type,
    String? category,
    String? categoryId,
    String? categoryName,
    String? notes,
    // Field piutang/hutang: rekening yang terlibat saat create
    String? paymentMethodId,
    String? paymentMethodName,
    // Biaya transfer saat create piutang/hutang atau saat bayar
    @Default(0) int transferFee,
    // Field tagihan recurring
    int? billingDay,           // Tanggal tagih per bulan (1-31), null = tidak recurring
    int? maxInstallments,      // Batas cicilan, null = unlimited (tagihan terus setiap bulan)
    int? installmentAmount,    // Nominal per cicilan, null = pakai nominal/maxInstallments
    @Default(0) int installmentsPaid, // Cicilan yang sudah dibayar
    @Default(false) bool isSynced,
    DateTime? syncedAt,
    required DateTime localCreatedAt,
    DateTime? updatedAt,
    @Default(false) bool isDeleted,
  }) = _BillModel;

  factory BillModel.fromJson(Map<String, dynamic> json) =>
      _$BillModelFromJson(json);
}

extension BillModelExtension on BillModel {
  /// Sisa yang belum dibayar
  int get remainingAmount => nominal - paidAmount;

  /// Progress pembayaran (0.0 - 1.0)
  double get paymentProgress =>
      nominal > 0 ? (paidAmount / nominal).clamp(0.0, 1.0) : 0.0;

  /// Apakah sudah jatuh tempo
  bool get isOverdue =>
      status != BillStatus.paid && dueDate.isBefore(DateTime.now());

  /// Hitung status otomatis berdasarkan paidAmount
  BillStatus get calculatedStatus {
    if (paidAmount <= 0) return BillStatus.unpaid;
    if (paidAmount >= nominal) return BillStatus.paid;
    return BillStatus.partial;
  }

  Map<String, dynamic> toSqlite() {
    return {
      if (id > 0) 'id': id,
      'firebaseDocId': firebaseDocId,
      'userId': userId,
      'name': name,
      'nominal': nominal,
      'paidAmount': paidAmount,
      'dueDate': dueDate.millisecondsSinceEpoch,
      'status': status.name,
      'type': type.name,
      'category': category,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'notes': notes,
      'paymentMethodId': paymentMethodId,
      'paymentMethodName': paymentMethodName,
      'transferFee': transferFee,
      'billingDay': billingDay,
      'maxInstallments': maxInstallments,
      'installmentAmount': installmentAmount,
      'installmentsPaid': installmentsPaid,
      'isSynced': isSynced ? 1 : 0,
      'syncedAt': syncedAt?.millisecondsSinceEpoch,
      'localCreatedAt': localCreatedAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt?.millisecondsSinceEpoch,
      'isDeleted': isDeleted ? 1 : 0,
    };
  }

  static BillModel fromSqlite(Map<String, dynamic> map) {
    return BillModel(
      id: map['id'] as int,
      firebaseDocId: map['firebaseDocId'] as String?,
      userId: map['userId'] as String,
      name: map['name'] as String,
      nominal: map['nominal'] as int,
      paidAmount: (map['paidAmount'] as int?) ?? 0,
      dueDate: DateTime.fromMillisecondsSinceEpoch(map['dueDate'] as int),
      status: BillStatusExtension.fromString(map['status'] as String),
      type: BillTypeExtension.fromString((map['type'] as String?) ?? 'HUTANG'),
      category: map['category'] as String?,
      categoryId: map['categoryId'] as String?,
      categoryName: map['categoryName'] as String?,
      notes: map['notes'] as String?,
      paymentMethodId: map['paymentMethodId'] as String?,
      paymentMethodName: map['paymentMethodName'] as String?,
      transferFee: (map['transferFee'] as int?) ?? 0,
      billingDay: map['billingDay'] as int?,
      maxInstallments: map['maxInstallments'] as int?,
      installmentAmount: map['installmentAmount'] as int?,
      installmentsPaid: (map['installmentsPaid'] as int?) ?? 0,
      isSynced: (map['isSynced'] as int) == 1,
      syncedAt: map['syncedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['syncedAt'] as int)
          : null,
      localCreatedAt:
          DateTime.fromMillisecondsSinceEpoch(map['localCreatedAt'] as int),
      updatedAt: map['updatedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] as int)
          : null,
      isDeleted: (map['isDeleted'] as int? ?? 0) == 1,
    );
  }
}
