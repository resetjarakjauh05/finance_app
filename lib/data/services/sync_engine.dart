import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../local/pending_operations_dao.dart';
import '../local/sync_log_dao.dart';
import '../local/transaction_dao.dart';
import '../local/bill_dao.dart';
import '../local/custody_dao.dart';
import '../local/custody_movement_dao.dart';
import '../local/category_dao.dart';
import '../local/payment_method_dao.dart';
import '../local/savings_plan_dao.dart';
import '../../domain/models/payment_method_model.dart';
import 'connectivity_service.dart';

class SyncEngine extends ChangeNotifier {
  final PendingOperationsDao _pendingOpsDao;
  final SyncLogDao _syncLogDao;
  final TransactionDao _transactionDao;
  final BillDao _billDao;
  final CustodyDao _custodyDao;
  final CustodyMovementDao _custodyMovementDao;
  final CategoryDao _categoryDao;
  final PaymentMethodDao _paymentMethodDao;
  final SavingsPlanDao _savingsPlanDao;
  final SavingsAllocationDao _savingsAllocationDao;
  final ConnectivityService _connectivityService;
  final FirebaseFirestore _firestore;

  StreamSubscription<bool>? _connectivitySubscription;

  bool _isSyncing = false;
  bool get isSyncing => _isSyncing;

  int _pendingCount = 0;
  int get pendingCount => _pendingCount;

  String? _lastError;
  String? get lastError => _lastError;

  SyncEngine({
    PendingOperationsDao? pendingOpsDao,
    SyncLogDao? syncLogDao,
    TransactionDao? transactionDao,
    BillDao? billDao,
    CustodyDao? custodyDao,
    CustodyMovementDao? custodyMovementDao,
    CategoryDao? categoryDao,
    PaymentMethodDao? paymentMethodDao,
    SavingsPlanDao? savingsPlanDao,
    SavingsAllocationDao? savingsAllocationDao,
    ConnectivityService? connectivityService,
    FirebaseFirestore? firestore,
  })  : _pendingOpsDao = pendingOpsDao ?? PendingOperationsDao(),
        _syncLogDao = syncLogDao ?? SyncLogDao(),
        _transactionDao = transactionDao ?? TransactionDao(),
        _billDao = billDao ?? BillDao(),
        _custodyDao = custodyDao ?? CustodyDao(),
        _custodyMovementDao = custodyMovementDao ?? CustodyMovementDao(),
        _categoryDao = categoryDao ?? CategoryDao(),
        _paymentMethodDao = paymentMethodDao ?? PaymentMethodDao(),
        _savingsPlanDao = savingsPlanDao ?? SavingsPlanDao(),
        _savingsAllocationDao = savingsAllocationDao ?? SavingsAllocationDao(),
        _connectivityService = connectivityService ?? ConnectivityService(),
        _firestore = firestore ?? FirebaseFirestore.instance;

  // BUG-03 FIX: start() sekarang async agar DB ready sebelum query pending ops
  Future<void> start() async {
    _connectivitySubscription =
        _connectivityService.onConnectivityChanged.listen((isOnline) {
      if (isOnline) syncPendingOperations();
    });
    await _updatePendingCount();
  }

  void stop() {
    _connectivitySubscription?.cancel();
    _connectivitySubscription = null;
  }

  Future<void> syncPendingOperations() async {
    if (_isSyncing) return;
    final isOnline = await _connectivityService.isOnline();
    if (!isOnline) return;

    _isSyncing = true;
    _lastError = null;
    notifyListeners();

    try {
      final pending = await _pendingOpsDao.getAllPending();
      for (final op in pending) {
        await _processOperation(op);
      }
      await _pendingOpsDao.clearCompleted();
    } catch (e) {
      _lastError = e.toString();
    } finally {
      _isSyncing = false;
      await _updatePendingCount();
      notifyListeners();
    }
  }

  Future<void> _processOperation(Map<String, dynamic> op) async {
    final int id = op['id'] as int;
    final String operation = op['operation'] as String;
    final String tableName = op['tableName'] as String;
    final int recordId = op['recordId'] as int;
    final String? firebaseDocId = op['firebaseDocId'] as String?;
    final Map<String, dynamic> data =
        jsonDecode(op['data'] as String) as Map<String, dynamic>;
    final int retryCount = op['retryCount'] as int;

    if (retryCount > 0) {
      await Future.delayed(Duration(seconds: 1 << retryCount));
    }

    try {
      switch (tableName) {
        case 'transactions':
          await _syncTransaction(
            operation: operation, recordId: recordId,
            firebaseDocId: firebaseDocId, data: data,
          );
          break;
        case 'bills':
          await _syncBill(
            operation: operation, recordId: recordId,
            firebaseDocId: firebaseDocId, data: data,
          );
          break;
        case 'custody':
          await _syncCustody(
            operation: operation, recordId: recordId,
            firebaseDocId: firebaseDocId, data: data,
          );
          break;
        case 'custody_movements':
          await _syncCustodyMovement(
            operation: operation, recordId: recordId,
            firebaseDocId: firebaseDocId, data: data,
          );
          break;
        case 'monthly_budgets':
          await _syncGenericUserSubcollection(
            operation: operation, firebaseDocId: firebaseDocId,
            data: data, subcollection: 'monthly_budgets',
          );
          break;
        case 'spending_limits':
          await _syncGenericUserSubcollection(
            operation: operation, firebaseDocId: firebaseDocId,
            data: data, subcollection: 'spending_limits',
          );
          break;
        case 'savings_plans':
          await _syncGenericUserSubcollection(
            operation: operation, firebaseDocId: firebaseDocId,
            data: data, subcollection: 'savings_plans',
          );
          break;
        case 'savings_allocations':
          await _syncSavingsAllocation(
            operation: operation, firebaseDocId: firebaseDocId,
            data: data,
          );
          break;
        case 'payment_methods':
          await _syncPaymentMethod(
            operation: operation,
            firebaseDocId: firebaseDocId,
            data: data,
          );
          break;
        case 'categories':
          await _syncCategory(
            operation: operation,
            firebaseDocId: firebaseDocId,
            data: data,
          );
          break;
      }
      await _pendingOpsDao.updateStatus(id, 'SUCCESS');
      await _syncLogDao.addLog(
        operation: operation, entityType: tableName.toUpperCase(),
        entityId: recordId, firebaseDocId: firebaseDocId, status: 'SUCCESS',
      );
    } catch (e) {
      await _pendingOpsDao.incrementRetryCount(id);
      if (retryCount >= 2) {
        await _pendingOpsDao.updateStatus(id, 'FAILED', error: e.toString());
      }
      await _syncLogDao.addLog(
        operation: operation, entityType: tableName.toUpperCase(),
        entityId: recordId, status: 'FAILED', error: e.toString(),
      );
    }
  }

  Future<void> _syncTransaction({
    required String operation, required int recordId,
    String? firebaseDocId, required Map<String, dynamic> data,
  }) async {
    final String userId = data['userId'] as String;
    final col = _firestore.collection('transactions').doc(userId).collection('items');
    switch (operation) {
      case 'CREATE':
        if (firebaseDocId != null) {
          final doc = await col.doc(firebaseDocId).get();
          if (doc.exists) {
            await _transactionDao.markAsSynced(recordId, firebaseDocId);
            return;
          }
        }
        final docRef = await col.add(_toTransactionFirestore(data));
        await _transactionDao.markAsSynced(recordId, docRef.id);
        break;
      case 'UPDATE':
        if (firebaseDocId == null) return;
        await col.doc(firebaseDocId).update({
          ..._toTransactionFirestore(data),
          'updatedAt': FieldValue.serverTimestamp(),
        });
        await _transactionDao.markAsSynced(recordId, firebaseDocId);
        break;
      case 'DELETE':
        if (firebaseDocId == null) return;
        await col.doc(firebaseDocId).delete();
        break;
    }
  }

  Future<void> _syncBill({
    required String operation, required int recordId,
    String? firebaseDocId, required Map<String, dynamic> data,
  }) async {
    final String userId = data['userId'] as String;
    final col = _firestore.collection('bills').doc(userId).collection('items');
    switch (operation) {
      case 'CREATE':
        // BUG-3 FIX: cek duplicate dulu sebelum add ke Firestore
        if (firebaseDocId != null) {
          final doc = await col.doc(firebaseDocId).get();
          if (doc.exists) {
            await _billDao.markAsSynced(recordId, firebaseDocId);
            return;
          }
        }
        final docRef = await col.add(_toBillFirestore(data));
        await _billDao.markAsSynced(recordId, docRef.id);
        break;
      case 'UPDATE':
        if (firebaseDocId == null) return;
        await col.doc(firebaseDocId).update({
          ..._toBillFirestore(data),
          'updatedAt': FieldValue.serverTimestamp(),
        });
        await _billDao.markAsSynced(recordId, firebaseDocId);
        break;
      case 'DELETE':
        if (firebaseDocId == null) return;
        await col.doc(firebaseDocId).update({
          'isDeleted': true,
          'deletedAt': FieldValue.serverTimestamp(),
        });
        break;
    }
  }

  Future<void> _syncCustody({
    required String operation, required int recordId,
    String? firebaseDocId, required Map<String, dynamic> data,
  }) async {
    final String userId = data['userId'] as String;
    final col = _firestore.collection('custody').doc(userId).collection('items');
    switch (operation) {
      case 'CREATE':
        // Cek duplicate sebelum add ke Firestore
        if (firebaseDocId != null) {
          final doc = await col.doc(firebaseDocId).get();
          if (doc.exists) {
            await _custodyDao.markAsSynced(recordId, firebaseDocId);
            return;
          }
        }
        final docRef = await col.add(_toCustodyFirestore(data));
        await _custodyDao.markAsSynced(recordId, docRef.id);
        break;
      case 'UPDATE':
        if (firebaseDocId == null) return;
        await col.doc(firebaseDocId).update({
          ..._toCustodyFirestore(data),
          'updatedAt': FieldValue.serverTimestamp(),
        });
        await _custodyDao.markAsSynced(recordId, firebaseDocId);
        break;
      case 'DELETE':
        if (firebaseDocId == null) return;
        await col.doc(firebaseDocId).delete();
        break;
    }
  }

  Future<void> _syncPaymentMethod({
    required String operation,
    String? firebaseDocId,
    required Map<String, dynamic> data,
  }) async {
    final String userId = data['userId'] as String;
    final String docId = data['id'] as String? ?? firebaseDocId ?? '';
    final col = _firestore.collection('paymentMethods').doc(userId).collection('methods');

    switch (operation) {
      case 'CREATE':
        // FIX Bug #5: pakai col.add() agar Firestore generate ID baru (bukan UUID lokal)
        // lalu update SQLite dengan firebaseDocId yang benar
        final newDocRef = await col.add({
          'userId': userId,
          'name': data['name'],
          'type': data['type'],
          'bankName': data['bankName'],
          'accountNumber': data['accountNumber'],
          'isActive': data['isActive'] ?? true,
          'order': data['order'] ?? 0,
          'createdAt': data['createdAt'] is String
              ? Timestamp.fromDate(DateTime.parse(data['createdAt'] as String))
              : FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
        // Update SQLite: ganti localId (UUID) → firebaseDocId agar konsisten
        final localId = data['id'] as String?;
        if (localId != null && localId != newDocRef.id) {
          try {
            final type = PaymentMethodType.values.firstWhere(
              (t) => t.name == (data['type'] as String? ?? ''),
              orElse: () => PaymentMethodType.bank,
            );
            await _paymentMethodDao.insertOrReplace(PaymentMethodModel(
              id: newDocRef.id,
              userId: userId,
              name: data['name'] as String,
              type: type,
              bankName: data['bankName'] as String?,
              accountNumber: data['accountNumber'] as String?,
              isActive: (data['isActive'] as bool?) ?? true,
              order: (data['order'] as int?) ?? 0,
              createdAt: data['createdAt'] is String
                  ? DateTime.tryParse(data['createdAt'] as String)
                  : DateTime.now(),
              updatedAt: DateTime.now(),
            ));
            // FIX: hardDelete UUID lokal agar tidak duplicate
            await _paymentMethodDao.hardDelete(localId);
          } catch (e) {
            debugPrint('SyncEngine._syncPaymentMethod update SQLite: $e');
          }
        }
        break;
      case 'UPDATE':
        final targetId = firebaseDocId ?? docId;
        final updates = <String, dynamic>{
          'name': data['name'],
          'type': data['type'],
          'bankName': data['bankName'],
          'accountNumber': data['accountNumber'],
          'isActive': data['isActive'],
          'order': data['order'],
          'updatedAt': FieldValue.serverTimestamp(),
        }..removeWhere((k, v) => v == null);
        await col.doc(targetId).update(updates);
        break;
      case 'DELETE':
        final targetId = firebaseDocId ?? docId;
        await col.doc(targetId).update({
          'isActive': false,
          'updatedAt': FieldValue.serverTimestamp(),
        });
        break;
      case 'PERMANENT_DELETE':
        // Hapus permanen dari Firestore + hardDelete SQLite
        final targetId = firebaseDocId ?? docId;
        if (targetId.isNotEmpty) {
          await col.doc(targetId).delete();
          await _paymentMethodDao.hardDelete(targetId);
        }
        break;
    }
  }

  Future<void> _syncCustodyMovement({
    required String operation,
    required int recordId,
    String? firebaseDocId,
    required Map<String, dynamic> data,
  }) async {
    final String userId = data['userId'] as String;

    // FIX Bug #4: custodyFirebaseDocId mungkin null jika custody dibuat offline
    // → resolve dari SQLite dulu via custodyLocalId
    String? custodyFirebaseDocId = data['custodyFirebaseDocId'] as String?;
    if (custodyFirebaseDocId == null || custodyFirebaseDocId.isEmpty) {
      final int? custodyLocalId = data['custodyLocalId'] as int?;
      if (custodyLocalId != null) {
        final localCustody = await _custodyDao.getById(custodyLocalId);
        custodyFirebaseDocId = localCustody?['firebaseDocId'] as String?;
      }
    }

    // Jika custody belum sync ke Firestore, skip — akan dicoba lagi nanti
    if (custodyFirebaseDocId == null || custodyFirebaseDocId.isEmpty) {
      throw Exception(
          'custody_movement sync skipped: custody belum tersync (custodyFirebaseDocId null)');
    }

    final col = _firestore
        .collection('custody')
        .doc(userId)
        .collection('items')
        .doc(custodyFirebaseDocId)
        .collection('movements');

    switch (operation) {
      case 'CREATE':
        final docRef = await col.add({
          'movementType': data['movementType'],
          'nominal': data['nominal'],
          'date': data['date'] is String
              ? Timestamp.fromDate(DateTime.parse(data['date'] as String))
              : data['date'],
          'description': data['description'],
          'createdAt': data['createdAt'] is String
              ? Timestamp.fromDate(DateTime.parse(data['createdAt'] as String))
              : FieldValue.serverTimestamp(),
        });
        // FIX Bug #3: pakai _custodyMovementDao, bukan _custodyDao
        await _custodyMovementDao.markAsSynced(recordId, docRef.id);
        break;
      case 'DELETE':
        if (firebaseDocId == null) return;
        await col.doc(firebaseDocId).delete();
        break;
    }
  }

  Future<void> _syncCategory({
    required String operation,
    String? firebaseDocId,
    required Map<String, dynamic> data,
  }) async {
    final String userId = data['userId'] as String;
    final String localId = data['id'] as String;
    final col = _firestore.collection('users').doc(userId).collection('categories');

    switch (operation) {
      case 'CREATE':
        // Cek apakah sudah ada di Firestore (idempotent via localId sebagai field)
        final existing = await col.where('id', isEqualTo: localId).limit(1).get();
        if (existing.docs.isNotEmpty) {
          // Sudah ada → update markSynced saja
          await _categoryDao.markSynced(localId, existing.docs.first.id);
          return;
        }
        final docRef = await col.add({
          'id': localId,
          'name': data['name'],
          'icon': data['icon'],
          'color': data['color'],
          'isPreset': data['isPreset'] ?? false,
          'isActive': data['isActive'] ?? true,
          'isDeleted': false,
          'createdAt': FieldValue.serverTimestamp(),
        });
        await _categoryDao.markSynced(localId, docRef.id);
        break;
      case 'UPDATE':
        final targetId = firebaseDocId ?? localId;
        await col.doc(targetId).update({
          'name': data['name'],
          'icon': data['icon'],
          'color': data['color'],
          'updatedAt': FieldValue.serverTimestamp(),
        });
        break;
      case 'DELETE':
        final targetId = firebaseDocId ?? localId;
        await col.doc(targetId).update({
          'isDeleted': true,
          'deletedAt': FieldValue.serverTimestamp(),
        });
        break;
    }
  }

  Future<void> _syncSavingsAllocation({
    required String operation,
    String? firebaseDocId,
    required Map<String, dynamic> data,
  }) async {
    // Sync ke Firestore via generic handler
    await _syncGenericUserSubcollection(
      operation: operation,
      firebaseDocId: firebaseDocId,
      data: data,
      subcollection: 'savings_allocations',
    );

    // Setelah sync, recalculate savedAmount di SQLite + update Firestore plan
    // Ini fix bug: offline allocation tidak update progres saat baru online
    try {
      final planId = data['savingsPlanId'] as String?;
      final userId = data['userId'] as String?;
      if (planId == null || userId == null) return;

      final allocs = await _savingsAllocationDao.getByPlanId(planId);
      final totalSaved = allocs.fold<int>(0, (s, a) => s + a.amount);
      await _savingsPlanDao.updateSavedAmount(planId, totalSaved);

      // Sync savedAmount ke Firestore plan juga
      final plan = await _savingsPlanDao.getById(planId);
      if (plan?.firebaseDocId != null) {
        await _firestore
            .collection('users')
            .doc(userId)
            .collection('savings_plans')
            .doc(plan!.firebaseDocId)
            .update({
          'savedAmount': totalSaved,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      debugPrint('SyncEngine._syncSavingsAllocation recalc error: $e');
    }
  }

  Future<void> _syncGenericUserSubcollection({
    required String operation,
    String? firebaseDocId,
    required Map<String, dynamic> data,
    required String subcollection,
  }) async {
    final String userId = data['userId'] as String;
    final String docId = data['id'] as String;
    final col = _firestore.collection('users').doc(userId).collection(subcollection);

    // Strip non-serializable fields & convert ISO strings to Timestamps
    final cleanData = Map<String, dynamic>.from(data)
      ..remove('updatedAt')
      ..remove('deletedAt');

    // Convert ISO string timestamps → Firestore Timestamps
    if (cleanData['createdAt'] is String) {
      try {
        cleanData['createdAt'] = Timestamp.fromDate(DateTime.parse(cleanData['createdAt'] as String));
      } catch (_) {
        cleanData.remove('createdAt');
      }
    } else {
      cleanData.remove('createdAt');
    }

    if (cleanData['targetDate'] is String) {
      try {
        cleanData['targetDate'] = Timestamp.fromDate(DateTime.parse(cleanData['targetDate'] as String));
      } catch (_) {
        cleanData.remove('targetDate');
      }
    }

    switch (operation) {
      case 'CREATE':
        await col.doc(docId).set({
          ...cleanData,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
        break;
      case 'UPDATE':
        final targetId = firebaseDocId ?? docId;
        await col.doc(targetId).update({
          ...cleanData,
          'updatedAt': FieldValue.serverTimestamp(),
        });
        break;
      case 'DELETE':
        final targetId = firebaseDocId ?? docId;
        await col.doc(targetId).update({
          'isDeleted': true,
          'deletedAt': FieldValue.serverTimestamp(),
        });
        break;
    }
  }

  Map<String, dynamic> _toTransactionFirestore(Map<String, dynamic> data) => {
    'userId': data['userId'],
    'description': data['description'],
    'category': data['category'],
    'paymentMethodId': data['paymentMethodId'],
    'paymentMethodName': data['paymentMethodName'],
    'nominal': data['nominal'],
    'date': data['date'] is int
        ? Timestamp.fromDate(DateTime.fromMillisecondsSinceEpoch(data['date'] as int))
        : data['date'],
    'notes': data['notes'],
    'createdAt': FieldValue.serverTimestamp(),
    'updatedAt': FieldValue.serverTimestamp(),
  };

  Map<String, dynamic> _toBillFirestore(Map<String, dynamic> data) => {
    'userId': data['userId'],
    'name': data['name'],
    'nominal': data['nominal'],
    'paidAmount': data['paidAmount'] ?? 0,
    'dueDate': data['dueDate'] is String
        ? Timestamp.fromDate(DateTime.parse(data['dueDate'] as String))
        : data['dueDate'] is int
            ? Timestamp.fromDate(DateTime.fromMillisecondsSinceEpoch(data['dueDate'] as int))
            : data['dueDate'],
    'status': data['status'],
    'type': data['type'],
    'category': data['category'],
    'categoryId': data['categoryId'],
    'categoryName': data['categoryName'],
    'notes': data['notes'],
    'paymentMethodId': data['paymentMethodId'],
    'paymentMethodName': data['paymentMethodName'],
    'transferFee': data['transferFee'] ?? 0,
    'billingDay': data['billingDay'],
    'maxInstallments': data['maxInstallments'],
    'installmentAmount': data['installmentAmount'],
    'installmentsPaid': data['installmentsPaid'] ?? 0,
    'createdAt': data['createdAt'] is String
        ? Timestamp.fromDate(DateTime.parse(data['createdAt'] as String))
        : FieldValue.serverTimestamp(),
    'updatedAt': FieldValue.serverTimestamp(),
  };

  Map<String, dynamic> _toCustodyFirestore(Map<String, dynamic> data) => {
    'userId': data['userId'],
    'depositorName': data['depositorName'],
    'description': data['description'],
    'totalNominal': data['totalNominal'],
    'type': data['type'],
    'currentBalance': data['currentBalance'] ?? 0,
    'createdAt': data['createdAt'] is String
        ? Timestamp.fromDate(DateTime.parse(data['createdAt'] as String))
        : FieldValue.serverTimestamp(),
    'updatedAt': FieldValue.serverTimestamp(),
  };

  Future<void> _updatePendingCount() async {
    _pendingCount = await _pendingOpsDao.getPendingCount();
    notifyListeners();
  }

  Future<void> manualSync() async => await syncPendingOperations();

  @override
  void dispose() {
    stop();
    _connectivityService.dispose();
    super.dispose();
  }
}
