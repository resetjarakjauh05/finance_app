import 'package:freezed_annotation/freezed_annotation.dart';

part 'payment_method_model.freezed.dart';
part 'payment_method_model.g.dart';

/// Enum untuk tipe metode pembayaran
enum PaymentMethodType {
  cash,
  bank,
  wallet,
  digital,
}

/// Model untuk metode pembayaran
@freezed
class PaymentMethodModel with _$PaymentMethodModel {
  const factory PaymentMethodModel({
    required String id,
    required String userId,
    required String name,
    required PaymentMethodType type,
    String? bankName,
    String? accountNumber,
    @Default(true) bool isActive,
    @Default(0) int order,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _PaymentMethodModel;

  factory PaymentMethodModel.fromJson(Map<String, dynamic> json) =>
      _$PaymentMethodModelFromJson(json);
}

/// Extension untuk display name
extension PaymentMethodTypeExtension on PaymentMethodType {
  String get displayName {
    switch (this) {
      case PaymentMethodType.cash:
        return 'Tunai';
      case PaymentMethodType.bank:
        return 'Bank';
      case PaymentMethodType.wallet:
        return 'Dompet Digital';
      case PaymentMethodType.digital:
        return 'Digital';
    }
  }

  String get icon {
    switch (this) {
      case PaymentMethodType.cash:
        return '💵';
      case PaymentMethodType.bank:
        return '🏦';
      case PaymentMethodType.wallet:
        return '💳';
      case PaymentMethodType.digital:
        return '📱';
    }
  }
}
