// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bill_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_BillModel _$BillModelFromJson(Map<String, dynamic> json) => _BillModel(
  id: (json['id'] as num).toInt(),
  firebaseDocId: json['firebaseDocId'] as String?,
  userId: json['userId'] as String,
  name: json['name'] as String,
  nominal: (json['nominal'] as num).toInt(),
  paidAmount: (json['paidAmount'] as num?)?.toInt() ?? 0,
  dueDate: DateTime.parse(json['dueDate'] as String),
  status: $enumDecode(_$BillStatusEnumMap, json['status']),
  type: $enumDecodeNullable(_$BillTypeEnumMap, json['type']) ?? BillType.hutang,
  category: json['category'] as String?,
  categoryId: json['categoryId'] as String?,
  categoryName: json['categoryName'] as String?,
  notes: json['notes'] as String?,
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

Map<String, dynamic> _$BillModelToJson(_BillModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'firebaseDocId': instance.firebaseDocId,
      'userId': instance.userId,
      'name': instance.name,
      'nominal': instance.nominal,
      'paidAmount': instance.paidAmount,
      'dueDate': instance.dueDate.toIso8601String(),
      'status': _$BillStatusEnumMap[instance.status]!,
      'type': _$BillTypeEnumMap[instance.type]!,
      'category': instance.category,
      'categoryId': instance.categoryId,
      'categoryName': instance.categoryName,
      'notes': instance.notes,
      'isSynced': instance.isSynced,
      'syncedAt': instance.syncedAt?.toIso8601String(),
      'localCreatedAt': instance.localCreatedAt.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'isDeleted': instance.isDeleted,
    };

const _$BillStatusEnumMap = {
  BillStatus.unpaid: 'unpaid',
  BillStatus.partial: 'partial',
  BillStatus.paid: 'paid',
};

const _$BillTypeEnumMap = {
  BillType.hutang: 'hutang',
  BillType.piutang: 'piutang',
};
