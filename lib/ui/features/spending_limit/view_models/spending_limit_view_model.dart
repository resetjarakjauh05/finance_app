import 'package:flutter/foundation.dart';
import '../../../../domain/models/spending_limit_model.dart';
import '../../../../data/repositories/spending_limit_repository.dart';
import '../../../../data/services/spending_limit_service.dart';

enum SpendingLimitLoadStatus { initial, loading, loaded, error }

class SpendingLimitViewModel extends ChangeNotifier {
  final SpendingLimitRepository _repository;

  SpendingLimitViewModel({required SpendingLimitRepository repository})
      : _repository = repository;

  List<SpendingLimitModel> _limits = [];
  Map<String, int> _todaySpending = {}; // limitId → spent
  SpendingLimitLoadStatus _status = SpendingLimitLoadStatus.initial;
  String? _errorMessage;

  List<SpendingLimitModel> get limits => _limits;
  Map<String, int> get todaySpending => _todaySpending;
  SpendingLimitLoadStatus get status => _status;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _status == SpendingLimitLoadStatus.loading;

  /// Load semua limit + hitung spending hari ini → auto reload setelah CRUD
  Future<void> loadLimits(String userId) async {
    _status = SpendingLimitLoadStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _limits = await _repository.getLimits(userId);

      // Hitung spending hari ini untuk setiap limit
      _todaySpending = {};
      for (final limit in _limits) {
        final spent = await _repository.getTodaySpending(
          userId,
          categoryId: limit.categoryId,
        );
        _todaySpending[limit.id] = spent;
      }

      _status = SpendingLimitLoadStatus.loaded;
    } catch (e) {
      _status = SpendingLimitLoadStatus.error;
      _errorMessage = e.toString();
    }
    notifyListeners();
  }

  /// Tambah limit → auto reload
  Future<bool> createLimit({
    required String userId,
    required int dailyLimit,
    String? categoryId,
    String? categoryName,
    String? categoryIcon,
    double warningThreshold = 0.8,
  }) async {
    _errorMessage = null;
    try {
      await _repository.createLimit(
        userId: userId,
        dailyLimit: dailyLimit,
        categoryId: categoryId,
        categoryName: categoryName,
        categoryIcon: categoryIcon,
        warningThreshold: warningThreshold,
      );
      await loadLimits(userId);
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  /// Update limit → auto reload
  Future<bool> updateLimit(SpendingLimitModel limit) async {
    _errorMessage = null;
    try {
      await _repository.updateLimit(limit);
      await loadLimits(limit.userId);
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  /// Delete limit → auto reload
  Future<bool> deleteLimit(SpendingLimitModel limit) async {
    _errorMessage = null;
    try {
      await _repository.deleteLimit(limit);
      await loadLimits(limit.userId);
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  /// Get status untuk limit tertentu
  SpendingLimitStatus statusForLimit(SpendingLimitModel limit) {
    final spent = _todaySpending[limit.id] ?? 0;
    return limit.statusForSpent(spent);
  }

  /// Get spent amount untuk limit tertentu
  int spentForLimit(SpendingLimitModel limit) =>
      _todaySpending[limit.id] ?? 0;

  /// Sisa limit hari ini
  int remainingForLimit(SpendingLimitModel limit) {
    final spent = spentForLimit(limit);
    return (limit.dailyLimit - spent).clamp(0, limit.dailyLimit);
  }

  /// Progress 0.0 - 1.0+
  double progressForLimit(SpendingLimitModel limit) {
    if (limit.dailyLimit == 0) return 0;
    return spentForLimit(limit) / limit.dailyLimit;
  }

  /// List limits yang perlu notifikasi (warning/exceeded)
  List<LimitCheckResult> get limitsNeedingNotification {
    return _limits
        .map((l) => LimitCheckResult(
              limit: l,
              spent: spentForLimit(l),
              status: statusForLimit(l),
            ))
        .where((r) => r.status != SpendingLimitStatus.safe)
        .toList();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
