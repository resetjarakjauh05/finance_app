import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../../domain/models/savings_plan_model.dart';
import '../../domain/models/transaction_model.dart';
import '../local/savings_plan_dao.dart';
import 'connectivity_service.dart';
import 'transaction_service.dart';

class SavingsPlanService {
  final FirebaseFirestore _firestore;
  final SavingsPlanDao _dao;
  final SavingsAllocationDao _allocDao;
  final ConnectivityService _connectivity;
  final _uuid = const Uuid();

  SavingsPlanService({
    FirebaseFirestore? firestore,
    SavingsPlanDao? dao,
    SavingsAllocationDao? allocDao,
    ConnectivityService? connectivity,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _dao = dao ?? SavingsPlanDao(),
        _allocDao = allocDao ?? SavingsAllocationDao(),
        _connectivity = connectivity ?? ConnectivityService();

  CollectionReference<Map<String, dynamic>> _col(String userId) =>
      _firestore.collection('users').doc(userId).collection('savings_plans');

  CollectionReference<Map<String, dynamic>> _allocCol(String userId) =>
      _firestore.collection('users').doc(userId).collection('savings_allocations');

  /// Get plans — Firestore-first, fallback SQLite
  Future<List<SavingsPlanModel>> getPlans(String userId) async {
    final isOnline = await _connectivity.isOnline();
    if (isOnline) {
      try {
        final snap = await _col(userId)
            .where('isDeleted', isEqualTo: false)
            .where('isActive', isEqualTo: true)
            .get();
        final plans = snap.docs
            .map((d) => _planFromFirestore(d.id, d.data(), userId))
            .toList();
        _cachePlansToSqlite(plans);
        return plans;
      } catch (e) {
        debugPrint('SavingsPlanService.getPlans Firestore error: $e');
      }
    }
    return _dao.getPlans(userId);
  }

  /// Get allocations — Firestore-first, fallback SQLite
  Future<List<SavingsAllocationModel>> getAllocations(String planId) async {
    return _allocDao.getByPlanId(planId);
  }

  /// Create plan — Firestore-first
  Future<SavingsPlanModel> createPlan({
    required String userId,
    required String name,
    required int targetAmount,
    String? description,
    String? icon,
    int monthlyTarget = 0,
    DateTime? targetDate,
  }) async {
    final id = 'savings_${_uuid.v4()}';
    final plan = SavingsPlanModel(
      id: id,
      userId: userId,
      name: name.trim(),
      description: description,
      icon: icon ?? '🐷',
      targetAmount: targetAmount,
      monthlyTarget: monthlyTarget,
      targetDate: targetDate,
      localCreatedAt: DateTime.now(),
    );

    final isOnline = await _connectivity.isOnline();
    if (isOnline) {
      try {
        final docRef = await _col(userId).add(_planToFirestore(plan));
        final synced = plan.copyWith(
            firebaseDocId: docRef.id, isSynced: true, syncedAt: DateTime.now());
        await _dao.insertOrReplace(synced);
        return synced;
      } catch (e) {
        debugPrint('SavingsPlanService.createPlan Firestore error: $e');
      }
    }
    await _dao.insertOrReplace(plan);
    return plan;
  }

  /// Update plan — Firestore-first
  Future<void> updatePlan(SavingsPlanModel plan) async {
    final updated = plan.copyWith(updatedAt: DateTime.now());
    final isOnline = await _connectivity.isOnline();
    if (isOnline && plan.firebaseDocId != null) {
      try {
        await _col(plan.userId).doc(plan.firebaseDocId).update(
            {..._planToFirestore(updated), 'updatedAt': FieldValue.serverTimestamp()});
        await _dao.update(updated.copyWith(isSynced: true, syncedAt: DateTime.now()));
        return;
      } catch (e) {
        debugPrint('SavingsPlanService.updatePlan Firestore error: $e');
      }
    }
    await _dao.update(updated.copyWith(isSynced: false));
  }

  /// Delete plan — Firestore-first
  Future<void> deletePlan(SavingsPlanModel plan) async {
    final isOnline = await _connectivity.isOnline();
    if (isOnline && plan.firebaseDocId != null) {
      try {
        await _col(plan.userId).doc(plan.firebaseDocId).update({
          'isDeleted': true,
          'deletedAt': FieldValue.serverTimestamp(),
        });
      } catch (e) {
        debugPrint('SavingsPlanService.deletePlan Firestore error: $e');
      }
    }
    await _dao.softDelete(plan.id);
  }

  /// Add allocation — Firestore-first + auto-create expense tx dari rekening sumber
  Future<SavingsAllocationModel> addAllocation({
    required String userId,
    required String savingsPlanId,
    required int amount,
    required String fromPaymentMethodId,
    required String fromPaymentMethodName,
    String? toPaymentMethodId,
    String? toPaymentMethodName,
    int transferFee = 0,
    String? notes,
    DateTime? date,
    required String planName,
  }) async {
    final alloc = SavingsAllocationModel(
      id: 'alloc_${_uuid.v4()}',
      userId: userId,
      savingsPlanId: savingsPlanId,
      amount: amount,
      notes: notes,
      date: date ?? DateTime.now(),
      fromPaymentMethodId: fromPaymentMethodId,
      fromPaymentMethodName: fromPaymentMethodName,
      toPaymentMethodId: toPaymentMethodId,
      toPaymentMethodName: toPaymentMethodName,
      transferFee: transferFee,
      localCreatedAt: DateTime.now(),
    );

    final isOnline = await _connectivity.isOnline();
    if (isOnline) {
      try {
        await _allocCol(userId).add({
          'id': alloc.id,
          'savingsPlanId': savingsPlanId,
          'amount': amount,
          'notes': notes,
          'date': Timestamp.fromDate(alloc.date),
          'fromPaymentMethodId': fromPaymentMethodId,
          'fromPaymentMethodName': fromPaymentMethodName,
          'toPaymentMethodId': toPaymentMethodId,
          'toPaymentMethodName': toPaymentMethodName,
          'transferFee': transferFee,
          'isDeleted': false,
          'createdAt': FieldValue.serverTimestamp(),
        });
      } catch (e) {
        debugPrint('SavingsPlanService.addAllocation Firestore error: $e');
      }
    }

    await _allocDao.insert(alloc);

    // Auto-create expense transaction dari rekening sumber (tabungan + biaya transfer)
    final txService = TransactionService();
    final totalDebit = amount + transferFee;
    final expenseTx = TransactionModel(
      id: 0,
      userId: userId,
      description: 'Tabungan: $planName',
      category: TransactionCategory.expense,
      paymentMethodId: fromPaymentMethodId,
      paymentMethodName: fromPaymentMethodName,
      nominal: totalDebit,
      date: alloc.date,
      notes: transferFee > 0
          ? '${notes != null ? "$notes | " : ""}Biaya transfer: Rp${transferFee.toString()}'
          : notes,
      categoryName: 'Tabungan',
      localCreatedAt: DateTime.now(),
    );
    await txService.createTransaction(expenseTx, isOnline);

    // Auto-create income transaction ke rekening tujuan (jika berbeda)
    if (toPaymentMethodId != null && toPaymentMethodId != fromPaymentMethodId) {
      final incomeTx = TransactionModel(
        id: 0,
        userId: userId,
        description: 'Tabungan masuk: $planName',
        category: TransactionCategory.income,
        paymentMethodId: toPaymentMethodId,
        paymentMethodName: toPaymentMethodName ?? toPaymentMethodId,
        nominal: amount,
        date: alloc.date,
        notes: notes,
        categoryName: 'Tabungan',
        localCreatedAt: DateTime.now(),
      );
      await txService.createTransaction(incomeTx, isOnline);
    }

    // Update savedAmount
    final allAllocs = await _allocDao.getByPlanId(savingsPlanId);
    final totalSaved = allAllocs.fold<int>(0, (s, a) => s + a.amount);
    await _dao.updateSavedAmount(savingsPlanId, totalSaved);

    // Sync savedAmount ke Firestore
    if (isOnline) {
      try {
        final plan = await _dao.getById(savingsPlanId);
        if (plan?.firebaseDocId != null) {
          await _col(userId).doc(plan!.firebaseDocId).update({
            'savedAmount': totalSaved,
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }
      } catch (e) {
        debugPrint('SavingsPlanService.addAllocation update savedAmount error: $e');
      }
    }
    return alloc;
  }

  /// Delete allocation — Firestore-first
  Future<void> deleteAllocation({
    required String userId,
    required String planId,
    required String allocationId,
  }) async {
    final isOnline = await _connectivity.isOnline();
    if (isOnline) {
      try {
        final snap = await _allocCol(userId)
            .where('id', isEqualTo: allocationId)
            .get();
        for (final doc in snap.docs) {
          await doc.reference.update({
            'isDeleted': true,
            'deletedAt': FieldValue.serverTimestamp(),
          });
        }
      } catch (e) {
        debugPrint('SavingsPlanService.deleteAllocation Firestore error: $e');
      }
    }
    await _allocDao.softDelete(allocationId);

    // Recalculate savedAmount
    final allAllocs = await _allocDao.getByPlanId(planId);
    final totalSaved = allAllocs.fold<int>(0, (s, a) => s + a.amount);
    await _dao.updateSavedAmount(planId, totalSaved);

    if (isOnline) {
      try {
        final plan = await _dao.getById(planId);
        if (plan?.firebaseDocId != null) {
          await _col(userId).doc(plan!.firebaseDocId).update({
            'savedAmount': totalSaved,
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }
      } catch (e) {
        debugPrint('SavingsPlanService.deleteAllocation update savedAmount error: $e');
      }
    }
  }

  // ─── Helpers ───────────────────────────────────────────────────────────────

  SavingsPlanModel _planFromFirestore(
      String docId, Map<String, dynamic> data, String userId) {
    return SavingsPlanModel(
      id: data['id'] as String? ?? docId,
      userId: userId,
      firebaseDocId: docId,
      name: data['name'] as String,
      description: data['description'] as String?,
      icon: data['icon'] as String? ?? '🐷',
      targetAmount: (data['targetAmount'] as num).toInt(),
      savedAmount: (data['savedAmount'] as num?)?.toInt() ?? 0,
      monthlyTarget: (data['monthlyTarget'] as num?)?.toInt() ?? 0,
      targetDate: data['targetDate'] != null
          ? (data['targetDate'] as Timestamp).toDate()
          : null,
      isActive: data['isActive'] as bool? ?? true,
      isSynced: true,
      syncedAt: DateTime.now(),
      localCreatedAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> _planToFirestore(SavingsPlanModel p) => {
        'id': p.id,
        'name': p.name,
        'description': p.description,
        'icon': p.icon,
        'targetAmount': p.targetAmount,
        'savedAmount': p.savedAmount,
        'monthlyTarget': p.monthlyTarget,
        'targetDate': p.targetDate != null
            ? Timestamp.fromDate(p.targetDate!)
            : null,
        'isActive': p.isActive,
        'isDeleted': p.isDeleted,
        'createdAt': FieldValue.serverTimestamp(),
      };

  void _cachePlansToSqlite(List<SavingsPlanModel> plans) async {
    try {
      for (final p in plans) {
        await _dao.insertOrReplace(p);
      }
    } catch (e) {
      debugPrint('SavingsPlanService._cachePlansToSqlite error: $e');
    }
  }
}
