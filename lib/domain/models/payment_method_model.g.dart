// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_method_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PaymentMethodModelImpl _$$PaymentMethodModelImplFromJson(
        Map<String, dynamic> json) =>
    _$PaymentMethodModelImpl(
      id: json['id'] as String,
      userId: json['userId'] as String,
      name: json['name'] as String,
      type: $enumDecode(_$PaymentMethodTypeEnumMap, json['type']),
      bankName: json['bankName'] as String?,
      accountNumber: json['accountNumber'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      order: (json['order'] as num?)?.toInt() ?? 0,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$PaymentMethodModelImplToJson(
        _$PaymentMethodModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'name': instance.name,
      'type': _$PaymentMethodTypeEnumMap[instance.type]!,
      'bankName': instance.bankName,
      'accountNumber': instance.accountNumber,
      'isActive': instance.isActive,
      'order': instance.order,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

const _$PaymentMethodTypeEnumMap = {
  PaymentMethodType.cash: 'cash',
  PaymentMethodType.bank: 'bank',
  PaymentMethodType.wallet: 'wallet',
  PaymentMethodType.digital: 'digital',
};
