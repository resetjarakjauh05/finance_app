import '../../domain/models/custody_model.dart';
import '../../domain/models/custody_movement_model.dart';
import '../../domain/models/payment_method_model.dart';
import '../../domain/models/transaction_model.dart';
import '../services/custody_service.dart';
import '../services/transaction_service.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class CustodyRepository {
  final CustodyService _service;
  final TransactionService _transactionService;
  final Connectivity _connectivity;

  CustodyRepository({
    required CustodyService service,
    TransactionService? transactionService,
    Connectivity? connectivity,
  })  : _service = service,
        _transactionService = transactionService ?? TransactionService(),
        _connectivity = connectivity ?? Connectivity();

  Future<bool> _isOnline() async {
    final result = await _connectivity.checkConnectivity();
    return !result.contains(ConnectivityResult.none);
  }

  Future<List<CustodyModel>> getCustodies(String userId) async {
    return await _service.getCustodies(userId);
  }

  Future<CustodyModel> createCustody({
    required String userId,
    required String depositorName,
    required int totalNominal,
    required CustodyType type,
    String? description,
  }) async {
    if (depositorName.trim().isEmpty) throw Exception('Nama tidak boleh kosong');

    final isOnline = await _isOnline();
    final custody = CustodyModel(
      id: 0,
      userId: userId,
      depositorName: depositorName.trim(),
      description: description?.trim(),
      totalNominal: totalNominal,
      type: type,
      currentBalance: 0,
      localCreatedAt: DateTime.now(),
    );
    final localId = await _service.createCustody(custody, isOnline);
    return custody.copyWith(id: localId);
  }

  Future<void> updateCustody(CustodyModel custody) async {
    if (custody.depositorName.trim().isEmpty) throw Exception('Nama tidak boleh kosong');
    final isOnline = await _isOnline();
    await _service.updateCustody(custody, isOnline);
  }

  Future<void> deleteCustody(CustodyModel custody) async {
    final isOnline = await _isOnline();
    await _service.deleteCustody(custody.id, custody.userId, custody.firebaseDocId, isOnline);
  }

  Future<List<CustodyMovementModel>> getMovements(CustodyModel custody) async {
    return await _service.getMovements(custody.id, custody.userId, custody.firebaseDocId);
  }

  Future<CustodyMovementModel> addMovement({
    required CustodyModel custody,
    required MovementType movementType,
    required int nominal,
    required DateTime date,
    required PaymentMethodModel paymentMethod,
    String? description,
  }) async {
    if (nominal <= 0) throw Exception('Nominal harus lebih dari 0');
    final isOnline = await _isOnline();

    final movement = CustodyMovementModel(
      id: 0,
      custodyId: custody.id,
      custodyFirebaseDocId: custody.firebaseDocId,
      movementType: movementType,
      nominal: nominal,
      date: date,
      description: description?.trim(),
      localCreatedAt: DateTime.now(),
    );

    final localId = await _service.addMovement(
        movement, custody.userId, custody.firebaseDocId, isOnline);

    // Auto-create transaction
    // MASUK = income (uang masuk), KELUAR = expense (uang keluar)
    final category = movementType == MovementType.masuk
        ? TransactionCategory.income
        : TransactionCategory.expense;

    final transaction = TransactionModel(
      id: 0,
      userId: custody.userId,
      description: '${movementType == MovementType.masuk ? 'Terima' : 'Keluar'} Titipan - ${custody.depositorName}',
      category: category,
      paymentMethodId: paymentMethod.id,
      paymentMethodName: paymentMethod.name,
      nominal: nominal,
      date: date,
      notes: description ?? 'Titipan: ${custody.depositorName}',
      localCreatedAt: DateTime.now(),
    );
    await _transactionService.createTransaction(transaction, isOnline);

    // Calculate balance dari movements list (Firestore-first, tidak bergantung local id)
    final allMovements = await _service.getMovements(
        custody.id, custody.userId, custody.firebaseDocId);
    final newBalance = allMovements.fold<int>(0, (sum, m) =>
        m.movementType == MovementType.masuk ? sum + m.nominal : sum - m.nominal);

    await _service.updateCustody(
        custody.copyWith(currentBalance: newBalance, updatedAt: DateTime.now()),
        isOnline);

    return movement.copyWith(id: localId);
  }

  Future<int> calculateBalance(int custodyId) async {
    return await _service.calculateBalance(custodyId);
  }
}
