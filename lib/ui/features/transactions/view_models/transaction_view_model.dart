import 'package:flutter/foundation.dart';
import '../../../../domain/models/transaction_model.dart';
import '../../../../domain/models/payment_method_model.dart';
import '../../../../data/repositories/transaction_repository.dart';
import '../../../../data/repositories/payment_method_repository.dart';

/// ViewModel untuk transaction management
class TransactionViewModel extends ChangeNotifier {
  final TransactionRepository _transactionRepository;
  final PaymentMethodRepository _paymentMethodRepository;
  final String userId;

  TransactionViewModel({
    required TransactionRepository transactionRepository,
    required PaymentMethodRepository paymentMethodRepository,
    required this.userId,
  })  : _transactionRepository = transactionRepository,
        _paymentMethodRepository = paymentMethodRepository;

  List<TransactionModel> _transactions = [];
  List<TransactionModel> get transactions => _transactions;

  List<PaymentMethodModel> _paymentMethods = [];
  List<PaymentMethodModel> get paymentMethods => _paymentMethods;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isOnline = false;
  bool get isOnline => _isOnline;

  int _unsyncedCount = 0;
  int get unsyncedCount => _unsyncedCount;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // Filter states
  TransactionCategory? _filterCategory;
  TransactionCategory? get filterCategory => _filterCategory;

  String? _filterPaymentMethodId;
  String? get filterPaymentMethodId => _filterPaymentMethodId;

  DateTime? _filterStartDate;
  DateTime? get filterStartDate => _filterStartDate;

  DateTime? _filterEndDate;
  DateTime? get filterEndDate => _filterEndDate;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  /// Initialize data
  Future<void> init() async {
    await loadPaymentMethods();
    // Initial sync Firestore → SQLite (fresh install)
    await _transactionRepository.initialSyncFromFirestore(userId);
    await loadTransactions();
    await checkOnlineStatus();
    await loadUnsyncedCount();
  }

  /// Load transactions
  Future<void> loadTransactions() async {
    _setLoading(true);
    _clearError();

    try {
      if (_searchQuery.isNotEmpty) {
        _transactions = await _transactionRepository.searchTransactions(
          userId,
          _searchQuery,
        );
      } else if (_hasActiveFilters()) {
        _transactions = await _transactionRepository.filterTransactions(
          userId,
          category: _filterCategory,
          paymentMethodId: _filterPaymentMethodId,
          startDate: _filterStartDate,
          endDate: _filterEndDate,
        );
      } else {
        _transactions = await _transactionRepository.getTransactions(
          userId,
          limit: 100,
        );
      }
      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
    }
  }

  /// Load payment methods
  Future<void> loadPaymentMethods() async {
    try {
      _paymentMethods =
          await _paymentMethodRepository.getAllPaymentMethods(userId);
      notifyListeners();
    } catch (e) {
      // Silent fail for payment methods
    }
  }

  /// Create transaction
  Future<void> createTransaction({
    required String description,
    required TransactionCategory category,
    required String paymentMethodId,
    required String paymentMethodName,
    required int nominal,
    required DateTime date,
    String? notes,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      await _transactionRepository.createTransaction(
        userId: userId,
        description: description,
        category: category,
        paymentMethodId: paymentMethodId,
        paymentMethodName: paymentMethodName,
        nominal: nominal,
        date: date,
        notes: notes,
      );

      await loadTransactions();
      await loadUnsyncedCount();
      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      rethrow;
    }
  }

  /// Update transaction
  Future<void> updateTransaction(TransactionModel transaction) async {
    _setLoading(true);
    _clearError();

    try {
      await _transactionRepository.updateTransaction(transaction);
      await loadTransactions();
      await loadUnsyncedCount();
      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      rethrow;
    }
  }

  /// Delete transaction
  Future<void> deleteTransaction(TransactionModel transaction) async {
    _setLoading(true);
    _clearError();

    try {
      await _transactionRepository.deleteTransaction(transaction);
      await loadTransactions();
      await loadUnsyncedCount();
      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      rethrow;
    }
  }

  /// Search transactions
  Future<void> search(String query) async {
    _searchQuery = query;
    await loadTransactions();
  }

  /// Apply filters
  Future<void> applyFilters({
    TransactionCategory? category,
    String? paymentMethodId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    _filterCategory = category;
    _filterPaymentMethodId = paymentMethodId;
    _filterStartDate = startDate;
    _filterEndDate = endDate;
    _searchQuery = ''; // Clear search when filtering
    await loadTransactions();
  }

  /// Clear filters
  Future<void> clearFilters() async {
    _filterCategory = null;
    _filterPaymentMethodId = null;
    _filterStartDate = null;
    _filterEndDate = null;
    _searchQuery = '';
    await loadTransactions();
  }

  /// Check if has active filters
  bool _hasActiveFilters() {
    return _filterCategory != null ||
        _filterPaymentMethodId != null ||
        _filterStartDate != null ||
        _filterEndDate != null;
  }

  /// Get total income
  Future<int> getTotalIncome() async {
    return await _transactionRepository.getTotalIncome(userId);
  }

  /// Get total expense
  Future<int> getTotalExpense() async {
    return await _transactionRepository.getTotalExpense(userId);
  }

  /// Get net balance
  Future<int> getNetBalance() async {
    return await _transactionRepository.getNetBalance(userId);
  }

  /// Check online status
  Future<void> checkOnlineStatus() async {
    _isOnline = await _transactionRepository.isOnline();
    notifyListeners();
  }

  /// Load unsynced count
  Future<void> loadUnsyncedCount() async {
    _unsyncedCount = await _transactionRepository.getUnsyncedCount(userId);
    notifyListeners();
  }

  /// Get payment method by ID
  PaymentMethodModel? getPaymentMethod(String id) {
    try {
      return _paymentMethods.firstWhere((m) => m.id == id);
    } catch (e) {
      return null;
    }
  }

  void clearError() {
    _clearError();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
