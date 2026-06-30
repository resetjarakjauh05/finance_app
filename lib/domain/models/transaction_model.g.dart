// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TransactionModel _$TransactionModelFromJson(Map<String, dynamic> json) =>
    _TransactionModel(
      id: (json['id'] as num).toInt(),
      firebaseDocId: json['firebaseDocId'] as String?,
      userId: json['userId'] as String,
      description: json['description'] as String,
      category: $enumDecode(_$TransactionCategoryEnumMap, json['category']),
      paymentMethodId: json['paymentMethodId'] as String,
      paymentMethodName: json['paymentMethodName'] as String,
      nominal: (json['nominal'] as num).toInt(),
      date: DateTime.parse(json['date'] as String),
      notes: json['notes'] as String?,
      categoryId: json['categoryId'] as String?,
      categoryName: json['categoryName'] as String?,
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

Map<String, dynamic> _$TransactionModelToJson(_TransactionModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'firebaseDocId': instance.firebaseDocId,
      'userId': instance.userId,
      'description': instance.description,
      'category': _$TransactionCategoryEnumMap[instance.category]!,
      'paymentMethodId': instance.paymentMethodId,
      'paymentMethodName': instance.paymentMethodName,
      'nominal': instance.nominal,
      'date': instance.date.toIso8601String(),
      'notes': instance.notes,
      'categoryId': instance.categoryId,
      'categoryName': instance.categoryName,
      'isSynced': instance.isSynced,
      'syncedAt': instance.syncedAt?.toIso8601String(),
      'localCreatedAt': instance.localCreatedAt.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'isDeleted': instance.isDeleted,
    };

const _$TransactionCategoryEnumMap = {
  TransactionCategory.income: 'income',
  TransactionCategory.expense: 'expense',
};
