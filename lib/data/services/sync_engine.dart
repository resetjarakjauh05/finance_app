import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../local/pending_operations_dao.dart';
import '../local/sync_log_dao.dart';
import '../local/transaction_dao.dart';
import '../local/bill_dao.dart';
import '../local/custody_dao.dart';
import 'connectivity_service.dart';

class SyncEngine extends ChangeNotifier {
  final PendingOperationsDao _pendingOpsDao;
  final SyncLogDao _syncLogDao;
  final TransactionDao _transactionDao;
  final BillDao _billDao;
  final CustodyDao _custodyDao;
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
    ConnectivityService? connectivityService,
    FirebaseFirestore? firestore,
  })  : _pendingOpsDao = pendingOpsDao ?? PendingOperationsDao(),
        _syncLogDao = syncLogDao ?? SyncLogDao(),
        _transactionDao = transactionDao ?? TransactionDao(),
        _billDao = billDao ?? BillDao(),
        _custodyDao = custodyDao ?? CustodyDao(),
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
          await _syncGenericUserSubcollection(
            operation: operation, firebaseDocId: firebaseDocId,
            data: data, subcollection: 'savings_allocations',
          );
          break;
        case 'payment_methods':
          await _syncPaymentMethod(
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
        await col.doc(firebaseDocId).delete();
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
        await col.doc(docId).set({
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
    'createdAt': FieldValue.serverTimestamp(),
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
