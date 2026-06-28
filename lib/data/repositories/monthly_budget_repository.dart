import '../../domain/models/monthly_budget_model.dart';
import '../services/monthly_budget_service.dart';

class MonthlyBudgetRepository {
  final MonthlyBudgetService _service;

  MonthlyBudgetRepository({required MonthlyBudgetService service})
      : _service = service;

  Future<List<MonthlyBudgetModel>> getBudgetsByMonth(
          String userId, String yearMonth) =>
      _service.getBudgetsByMonth(userId, yearMonth);

  Future<List<String>> getDistinctMonths(String userId) =>
      _service.getDistinctMonths(userId);

  Future<MonthlyBudgetModel> createBudget({
    required String userId,
    required String yearMonth,
    required String categoryId,
    required String categoryName,
    required String categoryIcon,
    required int budgetAmount,
    String? notes,
  }) async {
    if (budgetAmount <= 0) throw Exception('Anggaran harus lebih dari 0');
    if (categoryId.isEmpty) throw Exception('Kategori harus dipilih');
    return _service.createBudget(
      userId: userId,
      yearMonth: yearMonth,
      categoryId: categoryId,
      categoryName: categoryName,
      categoryIcon: categoryIcon,
      budgetAmount: budgetAmount,
      notes: notes,
    );
  }

  Future<void> updateBudget(MonthlyBudgetModel budget) async {
    if (budget.budgetAmount <= 0) throw Exception('Anggaran harus lebih dari 0');
    await _service.updateBudget(budget);
  }

  Future<void> deleteBudget(MonthlyBudgetModel budget) =>
      _service.deleteBudget(budget);

  Future<int> getActualSpending(
          String userId, String yearMonth, String categoryId) =>
      _service.getActualSpending(userId, yearMonth, categoryId);
}
