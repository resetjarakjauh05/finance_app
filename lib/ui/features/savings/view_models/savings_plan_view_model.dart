import 'package:flutter/foundation.dart';
import '../../../../domain/models/savings_plan_model.dart';
import '../../../../data/repositories/savings_plan_repository.dart';

enum SavingsPlanStatus { initial, loading, loaded, error }

class SavingsPlanViewModel extends ChangeNotifier {
  final SavingsPlanRepository _repository;

  SavingsPlanViewModel({required SavingsPlanRepository repository})
      : _repository = repository;

  List<SavingsPlanModel> _plans = [];
  Map<String, List<SavingsAllocationModel>> _allocations = {};
  SavingsPlanStatus _status = SavingsPlanStatus.initial;
  String? _errorMessage;

  List<SavingsPlanModel> get plans => _plans;
  SavingsPlanStatus get status => _status;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _status == SavingsPlanStatus.loading;

  /// Total semua tabungan
  int get totalSaved =>
      _plans.fold<int>(0, (sum, p) => sum + p.savedAmount);
  int get totalTarget =>
      _plans.fold<int>(0, (sum, p) => sum + p.targetAmount);

  /// Get alokasi untuk plan tertentu
  List<SavingsAllocationModel> allocationsFor(String planId) =>
      _allocations[planId] ?? [];

  /// Load semua plan + alokasi → auto reload setelah CRUD
  Future<void> loadPlans(String userId) async {
    _status = SavingsPlanStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _plans = await _repository.getPlans(userId);
      _allocations = {};
      for (final p in _plans) {
        _allocations[p.id] = await _repository.getAllocations(p.id);
      }
      _status = SavingsPlanStatus.loaded;
    } catch (e) {
      _status = SavingsPlanStatus.error;
      _errorMessage = e.toString();
    }
    notifyListeners();
  }

  Future<bool> createPlan({
    required String userId,
    required String name,
    required int targetAmount,
    String? description,
    String? icon,
    int monthlyTarget = 0,
    DateTime? targetDate,
  }) async {
    _errorMessage = null;
    try {
      await _repository.createPlan(
        userId: userId,
        name: name,
        targetAmount: targetAmount,
        description: description,
        icon: icon,
        monthlyTarget: monthlyTarget,
        targetDate: targetDate,
      );
      await loadPlans(userId);
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<bool> updatePlan(SavingsPlanModel plan, String userId) async {
    _errorMessage = null;
    try {
      await _repository.updatePlan(plan);
      await loadPlans(userId);
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<bool> deletePlan(SavingsPlanModel plan, String userId) async {
    _errorMessage = null;
    try {
      await _repository.deletePlan(plan);
      await loadPlans(userId);
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<bool> addAllocation({
    required String userId,
    required String planId,
    required String planName,
    required int amount,
    required String fromPaymentMethodId,
    required String fromPaymentMethodName,
    String? toPaymentMethodId,
    String? toPaymentMethodName,
    int transferFee = 0,
    String? notes,
    DateTime? date,
  }) async {
    _errorMessage = null;
    try {
      await _repository.addAllocation(
        userId: userId,
        planId: planId,
        planName: planName,
        amount: amount,
        fromPaymentMethodId: fromPaymentMethodId,
        fromPaymentMethodName: fromPaymentMethodName,
        toPaymentMethodId: toPaymentMethodId,
        toPaymentMethodName: toPaymentMethodName,
        transferFee: transferFee,
        notes: notes,
        date: date,
      );
      await loadPlans(userId);
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteAllocation({
    required String userId,
    required String planId,
    required String allocationId,
  }) async {
    _errorMessage = null;
    try {
      await _repository.deleteAllocation(
        userId: userId,
        planId: planId,
        allocationId: allocationId,
      );
      await loadPlans(userId);
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
