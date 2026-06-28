// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'monthly_budget_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MonthlyBudgetModelImpl _$$MonthlyBudgetModelImplFromJson(
        Map<String, dynamic> json) =>
    _$MonthlyBudgetModelImpl(
      id: json['id'] as String,
      userId: json['userId'] as String,
      yearMonth: json['yearMonth'] as String,
      categoryId: json['categoryId'] as String,
      categoryName: json['categoryName'] as String,
      categoryIcon: json['categoryIcon'] as String,
      budgetAmount: (json['budgetAmount'] as num).toInt(),
      notes: json['notes'] as String?,
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

Map<String, dynamic> _$$MonthlyBudgetModelImplToJson(
        _$MonthlyBudgetModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'yearMonth': instance.yearMonth,
      'categoryId': instance.categoryId,
      'categoryName': instance.categoryName,
      'categoryIcon': instance.categoryIcon,
      'budgetAmount': instance.budgetAmount,
      'notes': instance.notes,
      'firebaseDocId': instance.firebaseDocId,
      'isSynced': instance.isSynced,
      'syncedAt': instance.syncedAt?.toIso8601String(),
      'localCreatedAt': instance.localCreatedAt.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'isDeleted': instance.isDeleted,
    };
