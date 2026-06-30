// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'savings_plan_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SavingsPlanModel _$SavingsPlanModelFromJson(Map<String, dynamic> json) =>
    _SavingsPlanModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      icon: json['icon'] as String?,
      targetAmount: (json['targetAmount'] as num).toInt(),
      savedAmount: (json['savedAmount'] as num?)?.toInt() ?? 0,
      monthlyTarget: (json['monthlyTarget'] as num?)?.toInt() ?? 0,
      targetDate: json['targetDate'] == null
          ? null
          : DateTime.parse(json['targetDate'] as String),
      isActive: json['isActive'] as bool? ?? true,
      firebaseDocId: json['firebaseDocId'] as String?,
      isSynced: json['isSynced'] as bool? ?? false,
      syncedAt: json['syncedAt'] == null
          ? null
          : DateTime.parse(json['syncedAt'] as String),
      localCreatedAt: DateTime.parse(json['localCreatedAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
      isDeleted: json['isDeleted'] as bool? ?? false,
    );

Map<String, dynamic> _$SavingsPlanModelToJson(_SavingsPlanModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'name': instance.name,
      'description': instance.description,
      'icon': instance.icon,
      'targetAmount': instance.targetAmount,
      'savedAmount': instance.savedAmount,
      'monthlyTarget': instance.monthlyTarget,
      'targetDate': instance.targetDate?.toIso8601String(),
      'isActive': instance.isActive,
      'firebaseDocId': instance.firebaseDocId,
      'isSynced': instance.isSynced,
      'syncedAt': instance.syncedAt?.toIso8601String(),
      'localCreatedAt': instance.localCreatedAt.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'isDeleted': instance.isDeleted,
    };

_SavingsAllocationModel _$SavingsAllocationModelFromJson(
  Map<String, dynamic> json,
) => _SavingsAllocationModel(
  id: json['id'] as String,
  userId: json['userId'] as String,
  savingsPlanId: json['savingsPlanId'] as String,
  amount: (json['amount'] as num).toInt(),
  notes: json['notes'] as String?,
  date: DateTime.parse(json['date'] as String),
  fromPaymentMethodId: json['fromPaymentMethodId'] as String,
  fromPaymentMethodName: json['fromPaymentMethodName'] as String,
  toPaymentMethodId: json['toPaymentMethodId'] as String?,
  toPaymentMethodName: json['toPaymentMethodName'] as String?,
  transferFee: (json['transferFee'] as num?)?.toInt() ?? 0,
  firebaseDocId: json['firebaseDocId'] as String?,
  isSynced: json['isSynced'] as bool? ?? false,
  localCreatedAt: DateTime.parse(json['localCreatedAt'] as String),
  isDeleted: json['isDeleted'] as bool? ?? false,
);

Map<String, dynamic> _$SavingsAllocationModelToJson(
  _SavingsAllocationModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'userId': instance.userId,
  'savingsPlanId': instance.savingsPlanId,
  'amount': instance.amount,
  'notes': instance.notes,
  'date': instance.date.toIso8601String(),
  'fromPaymentMethodId': instance.fromPaymentMethodId,
  'fromPaymentMethodName': instance.fromPaymentMethodName,
  'toPaymentMethodId': instance.toPaymentMethodId,
  'toPaymentMethodName': instance.toPaymentMethodName,
  'transferFee': instance.transferFee,
  'firebaseDocId': instance.firebaseDocId,
  'isSynced': instance.isSynced,
  'localCreatedAt': instance.localCreatedAt.toIso8601String(),
  'isDeleted': instance.isDeleted,
};
