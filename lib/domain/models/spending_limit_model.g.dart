// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'spending_limit_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SpendingLimitModel _$SpendingLimitModelFromJson(Map<String, dynamic> json) =>
    _SpendingLimitModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      categoryId: json['categoryId'] as String?,
      categoryName: json['categoryName'] as String?,
      categoryIcon: json['categoryIcon'] as String?,
      dailyLimit: (json['dailyLimit'] as num).toInt(),
      warningThreshold: (json['warningThreshold'] as num?)?.toDouble() ?? 0.8,
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

Map<String, dynamic> _$SpendingLimitModelToJson(_SpendingLimitModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'categoryId': instance.categoryId,
      'categoryName': instance.categoryName,
      'categoryIcon': instance.categoryIcon,
      'dailyLimit': instance.dailyLimit,
      'warningThreshold': instance.warningThreshold,
      'isActive': instance.isActive,
      'firebaseDocId': instance.firebaseDocId,
      'isSynced': instance.isSynced,
      'syncedAt': instance.syncedAt?.toIso8601String(),
      'localCreatedAt': instance.localCreatedAt.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'isDeleted': instance.isDeleted,
    };
