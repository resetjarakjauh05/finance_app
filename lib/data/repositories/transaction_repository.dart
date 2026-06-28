import '../../domain/models/transaction_model.dart';
import '../services/transaction_service.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

/// Repository untuk transaction business logic
class TransactionRepository {
  final TransactionService _service;
  final Connectivity _connectivity;

  TransactionRepository({
    required TransactionService service,
    Connectivity? connectivity,
  })  : _service = service,
        _connectivity = connectivity ?? Connectivity();

  /// Check if device is online
  Future<bool> _isOnline() async {
    final result = await _connectivity.checkConnectivity();
    return !result.contains(ConnectivityResult.none);
  }

  /// Create transaction
  Future<TransactionModel> createTransaction({
    required String userId,
    required String description,
    required TransactionCategory category,
    required String paymentMethodId,
    required String paymentMethodName,
    required int nominal,
    required DateTime date,
    String? notes,
    String? categoryId,
    String? categoryName,
  }) async {
    if (description.trim().isEmpty) {
      throw Exception('Keterangan tidak boleh kosong');
    }
    if (nominal <= 0) {
      throw Exception('Nominal harus lebih dari 0');
    }
    if (paymentMethodId.trim().isEmpty) {
      throw Exception('Metode pembayaran harus dipilih');
    }
    if (category == TransactionCategory.expense && categoryId == null) {
      throw Exception('Kategori pengeluaran harus dipilih');
    }

    final isOnline = await _isOnline();

    final transaction = TransactionModel(
      id: 0,
      userId: userId,
      description: description.trim(),
      category: category,
      paymentMethodId: paymentMethodId,
      paymentMethodName: paymentMethodName,
      nominal: nominal,
      date: date,
      notes: notes?.trim(),
      categoryId: categoryId,
      categoryName: categoryName,
      localCreatedAt: DateTime.now(),
    );

    final localId = await _service.createTransaction(transaction, isOnline);
    return transaction.copyWith(id: localId);
  }

  /// Update transaction
  Future<void> updateTransaction(TransactionModel transaction) async {
    // Validasi
    if (transaction.description.trim().isEmpty) {
      throw Exception('Keterangan tidak boleh kosong');
    }

    if (transaction.nominal <= 0) {
      throw Exception('Nominal harus lebih dari 0');
    }

    if (transaction.paymentMethodId.trim().isEmpty) {
      throw Exception('Metode pembayaran harus dipilih');
    }

    final isOnline = await _isOnline();
    await _service.updateTransaction(transaction, isOnline);
  }

  /// Delete transaction
  Future<void> deleteTransaction(TransactionModel transaction) async {
    final isOnline = await _isOnline();
    await _service.deleteTransaction(
      transaction.id,
      transaction.userId,
      transaction.firebaseDocId,
      isOnline,
    );
  }

  /// Get all transactions
  Future<List<TransactionModel>> getTransactions(
    String userId, {
    int? limit,
    int? offset,
  }) async {
    return await _service.getTransactions(
      userId,
      limit: limit,
      offset: offset,
    );
  }

  /// Get transaction by ID
  Future<TransactionModel?> getTransactionById(int id) async {
    return await _service.getTransactionById(id);
  }

  /// Search transactions
  Future<List<TransactionModel>> searchTransactions(
    String userId,
    String query,
  ) async {
    if (query.trim().isEmpty) {
      return await getTransactions(userId);
    }
    return await _service.searchTransactions(userId, query.trim());
  }

  /// Filter transactions
  Future<List<TransactionModel>> filterTransactions(
    String userId, {
    TransactionCategory? category,
    String? paymentMethodId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    return await _service.filterTransactions(
      userId,
      category: category?.name,
      paymentMethodId: paymentMethodId,
      startDate: startDate,
      endDate: endDate,
    );
  }

  /// Get total income untuk user
  Future<int> getTotalIncome(String userId) async {
    return await _service.getTotalByCategory(
      userId,
      TransactionCategory.income.name,
    );
  }

  /// Get total expense untuk user
  Future<int> getTotalExpense(String userId) async {
    return await _service.getTotalByCategory(
      userId,
      TransactionCategory.expense.name,
    );
  }

  /// Get net balance (income - expense)
  Future<int> getNetBalance(String userId) async {
    final income = await getTotalIncome(userId);
    final expense = await getTotalExpense(userId);
    return income - expense;
  }

  /// Get saldo per payment method (income - expense)
  Future<Map<String, int>> getBalancePerPaymentMethod(String userId) async {
    return await _service.getBalancePerPaymentMethod(userId);
  }

  /// Get saldo untuk satu payment method
  Future<int> getBalanceForPaymentMethod(String userId, String paymentMethodId) async {
    final balances = await _service.getBalancePerPaymentMethod(userId);
    return balances[paymentMethodId] ?? 0;
  }

  /// Initial sync Firestore → SQLite (fresh install / first login)
  Future<void> initialSyncFromFirestore(String userId) async {
    await _service.initialSyncFromFirestore(userId);
  }

  /// Get unsynced count
  Future<int> getUnsyncedCount(String userId) async {
    return await _service.getUnsyncedCount(userId);
  }

  /// Get total income bulan ini
  Future<int> getTotalIncomeThisMonth(String userId) async {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
    final transactions = await _service.filterTransactions(
      userId,
      category: TransactionCategory.income.name,
      startDate: startOfMonth,
      endDate: endOfMonth,
    );
    return transactions.fold<int>(0, (sum, t) => sum + t.nominal);
  }

  /// Get total expense bulan ini
  Future<int> getTotalExpenseThisMonth(String userId) async {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
    final transactions = await _service.filterTransactions(
      userId,
      category: TransactionCategory.expense.name,
      startDate: startOfMonth,
      endDate: endOfMonth,
    );
    return transactions.fold<int>(0, (sum, t) => sum + t.nominal);
  }

  /// Get recent transactions (last N)
  Future<List<TransactionModel>> getRecentTransactions(
    String userId, {
    int limit = 5,
  }) async {
    return await _service.getTransactions(userId, limit: limit);
  }

  /// Get monthly summary (income, expense per bulan)
  Future<List<Map<String, dynamic>>> getMonthlySummary(
    String userId, {
    int months = 6,
  }) async {
    final results = <Map<String, dynamic>>[];
    final now = DateTime.now();
    for (int i = months - 1; i >= 0; i--) {
      final month = DateTime(now.year, now.month - i, 1);
      final endMonth = DateTime(now.year, now.month - i + 1, 0, 23, 59, 59);
      final transactions = await _service.filterTransactions(
        userId,
        startDate: month,
        endDate: endMonth,
      );
      final income = transactions
          .where((t) => t.category == TransactionCategory.income)
          .fold<int>(0, (sum, t) => sum + t.nominal);
      final expense = transactions
          .where((t) => t.category == TransactionCategory.expense)
          .fold<int>(0, (sum, t) => sum + t.nominal);
      results.add({
        'month': month,
        'income': income,
        'expense': expense,
        'net': income - expense,
      });
    }
    return results;
  }

  /// Get category breakdown (expense by categoryName)
  Future<Map<String, int>> getCategoryBreakdown(
    String userId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final transactions = await _service.filterTransactions(
      userId,
      category: TransactionCategory.expense.name,
      startDate: startDate,
      endDate: endDate,
    );
    final breakdown = <String, int>{};
    for (final t in transactions) {
      // Pakai categoryName jika ada, fallback ke paymentMethodName
      final key = t.categoryName ?? t.paymentMethodName;
      breakdown[key] = (breakdown[key] ?? 0) + t.nominal;
    }
    return breakdown;
  }

  /// Check if online
  Future<bool> isOnline() async {
    return await _isOnline();
  }
}
