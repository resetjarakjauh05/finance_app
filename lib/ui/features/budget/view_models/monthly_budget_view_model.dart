import 'package:flutter/foundation.dart';
import '../../../../domain/models/monthly_budget_model.dart';
import '../../../../data/repositories/monthly_budget_repository.dart';
import '../../../../data/services/monthly_budget_service.dart';

enum MonthlyBudgetStatus { initial, loading, loaded, error }

/// Data per baris budget: model + actual spending
class BudgetItem {
  final MonthlyBudgetModel budget;
  final int actualSpending;

  const BudgetItem({required this.budget, required this.actualSpending});

  BudgetStatus get status => budget.statusForSpent(actualSpending);
  int get remaining => budget.remainingFor(actualSpending);
  double get progress => budget.progressFor(actualSpending);
}

class MonthlyBudgetViewModel extends ChangeNotifier {
  final MonthlyBudgetRepository _repository;

  MonthlyBudgetViewModel({required MonthlyBudgetRepository repository})
      : _repository = repository;

  List<BudgetItem> _items = [];
  List<String> _availableMonths = [];
  String _selectedMonth = MonthlyBudgetService.formatYearMonth(DateTime.now());
  MonthlyBudgetStatus _status = MonthlyBudgetStatus.initial;
  String? _errorMessage;

  List<BudgetItem> get items => _items;
  List<String> get availableMonths => _availableMonths;
  String get selectedMonth => _selectedMonth;
  MonthlyBudgetStatus get status => _status;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _status == MonthlyBudgetStatus.loading;

  /// Total anggaran bulan ini
  int get totalBudget =>
      _items.fold<int>(0, (sum, i) => sum + i.budget.budgetAmount);

  /// Total aktual bulan ini
  int get totalActual =>
      _items.fold<int>(0, (sum, i) => sum + i.actualSpending);

  /// Sisa total
  int get totalRemaining => (totalBudget - totalActual).clamp(0, totalBudget);

  /// Load budget bulan tertentu → auto reload setelah CRUD
  Future<void> loadBudgets(String userId, {String? yearMonth}) async {
    if (yearMonth != null) _selectedMonth = yearMonth;
    _status = MonthlyBudgetStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final budgets =
          await _repository.getBudgetsByMonth(userId, _selectedMonth);
      _availableMonths = await _repository.getDistinctMonths(userId);

      // Generate bulan ini + 11 bulan ke depan
      final now = DateTime.now();
      final futureMonths = List.generate(12, (i) {
        final d = DateTime(now.year, now.month + i, 1);
        return MonthlyBudgetService.formatYearMonth(d);
      });

      // Merge: bulan dari DB (masa lalu) + bulan ke depan, deduplicate, sort desc
      final allMonths = {..._availableMonths, ...futureMonths}.toList()
        ..sort((a, b) => b.compareTo(a));
      _availableMonths = allMonths;

      // Pastikan bulan terpilih ada di list
      if (!_availableMonths.contains(_selectedMonth)) {
        _availableMonths.insert(0, _selectedMonth);
      }

      // Hitung actual spending per budget
      _items = [];
      for (final b in budgets) {
        final actual = await _repository.getActualSpending(
          userId,
          _selectedMonth,
          b.categoryId,
        );
        _items.add(BudgetItem(budget: b, actualSpending: actual));
      }

      _status = MonthlyBudgetStatus.loaded;
    } catch (e) {
      _status = MonthlyBudgetStatus.error;
      _errorMessage = e.toString();
    }
    notifyListeners();
  }

  /// Ganti bulan yang dipilih
  Future<void> selectMonth(String userId, String yearMonth) async {
    await loadBudgets(userId, yearMonth: yearMonth);
  }

  /// Tambah budget → auto reload
  Future<bool> createBudget({
    required String userId,
    required String categoryId,
    required String categoryName,
    required String categoryIcon,
    required int budgetAmount,
    String? notes,
  }) async {
    _errorMessage = null;
    try {
      await _repository.createBudget(
        userId: userId,
        yearMonth: _selectedMonth,
        categoryId: categoryId,
        categoryName: categoryName,
        categoryIcon: categoryIcon,
        budgetAmount: budgetAmount,
        notes: notes,
      );
      await loadBudgets(userId);
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  /// Update budget → auto reload
  Future<bool> updateBudget(MonthlyBudgetModel budget, String userId) async {
    _errorMessage = null;
    try {
      await _repository.updateBudget(budget);
      await loadBudgets(userId);
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  /// Delete budget → auto reload
  Future<bool> deleteBudget(MonthlyBudgetModel budget, String userId) async {
    _errorMessage = null;
    try {
      await _repository.deleteBudget(budget);
      await loadBudgets(userId);
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
