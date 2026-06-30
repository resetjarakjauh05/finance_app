import '../../domain/models/savings_plan_model.dart';
import '../services/savings_plan_service.dart';

class SavingsPlanRepository {
  final SavingsPlanService _service;

  SavingsPlanRepository({required SavingsPlanService service})
      : _service = service;

  Future<List<SavingsPlanModel>> getPlans(String userId) =>
      _service.getPlans(userId);

  Future<List<SavingsAllocationModel>> getAllocations(String planId) =>
      _service.getAllocations(planId);

  Future<SavingsPlanModel> createPlan({
    required String userId,
    required String name,
    required int targetAmount,
    String? description,
    String? icon,
    int monthlyTarget = 0,
    DateTime? targetDate,
    String? savingsPaymentMethodId,
    String? savingsPaymentMethodName,
  }) async {
    if (name.trim().isEmpty) throw Exception('Nama tabungan tidak boleh kosong');
    if (targetAmount <= 0) throw Exception('Target harus lebih dari 0');
    return _service.createPlan(
      userId: userId,
      name: name,
      targetAmount: targetAmount,
      description: description,
      icon: icon,
      monthlyTarget: monthlyTarget,
      targetDate: targetDate,
      savingsPaymentMethodId: savingsPaymentMethodId,
      savingsPaymentMethodName: savingsPaymentMethodName,
    );
  }

  Future<void> updatePlan(SavingsPlanModel plan) async {
    if (plan.name.trim().isEmpty) throw Exception('Nama tabungan tidak boleh kosong');
    if (plan.targetAmount <= 0) throw Exception('Target harus lebih dari 0');
    await _service.updatePlan(plan);
  }

  Future<void> deletePlan(SavingsPlanModel plan) => _service.deletePlan(plan);

  Future<SavingsAllocationModel> addAllocation({
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
    if (amount <= 0) throw Exception('Nominal harus lebih dari 0');
    if (fromPaymentMethodId.isEmpty) throw Exception('Pilih rekening sumber');
    if (transferFee < 0) throw Exception('Biaya transfer tidak boleh negatif');
    return _service.addAllocation(
      userId: userId,
      savingsPlanId: planId,
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
  }

  Future<void> deleteAllocation({
    required String userId,
    required String planId,
    required String allocationId,
  }) =>
      _service.deleteAllocation(
        userId: userId,
        planId: planId,
        allocationId: allocationId,
      );
}
