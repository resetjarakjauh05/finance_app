import '../../domain/models/spending_limit_model.dart';
import '../services/spending_limit_service.dart';

class SpendingLimitRepository {
  final SpendingLimitService _service;

  SpendingLimitRepository({
    required SpendingLimitService service,
  }) : _service = service;

  Future<List<SpendingLimitModel>> getLimits(String userId) =>
      _service.getLimits(userId);

  Future<SpendingLimitModel> createLimit({
    required String userId,
    required int dailyLimit,
    String? categoryId,
    String? categoryName,
    String? categoryIcon,
    double warningThreshold = 0.8,
  }) async {
    if (dailyLimit <= 0) throw Exception('Limit harus lebih dari 0');
    if (warningThreshold <= 0 || warningThreshold >= 1) {
      throw Exception('Threshold harus antara 0 dan 1');
    }
    return _service.createLimit(
      userId: userId,
      dailyLimit: dailyLimit,
      categoryId: categoryId,
      categoryName: categoryName,
      categoryIcon: categoryIcon,
      warningThreshold: warningThreshold,
    );
  }

  Future<void> updateLimit(SpendingLimitModel limit) async {
    if (limit.dailyLimit <= 0) throw Exception('Limit harus lebih dari 0');
    await _service.updateLimit(limit);
  }

  Future<void> deleteLimit(SpendingLimitModel limit) =>
      _service.deleteLimit(limit);

  Future<int> getTodaySpending(String userId, {String? categoryId}) =>
      _service.getTodaySpending(userId, categoryId: categoryId);

  Future<List<LimitCheckResult>> checkLimits(String userId) =>
      _service.checkLimits(userId);
}
