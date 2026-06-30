import 'package:flutter/foundation.dart';
import '../../../../domain/models/custody_model.dart';
import '../../../../domain/models/custody_movement_model.dart';
import '../../../../domain/models/payment_method_model.dart';
import '../../../../data/repositories/custody_repository.dart';

class CustodyViewModel extends ChangeNotifier {
  final CustodyRepository _repository;
  final String userId;
  bool _disposed = false;

  CustodyViewModel({required CustodyRepository repository, required this.userId})
      : _repository = repository;

  List<CustodyModel> _custodies = [];
  List<CustodyModel> get custodies => _custodies;

  List<CustodyMovementModel> _movements = [];
  List<CustodyMovementModel> get movements => _movements;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> loadCustodies() async {
    _setLoading(true);
    _clearError();
    try {
      _custodies = await _repository.getCustodies(userId);
      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
    }
  }

  Future<void> init() async => await loadCustodies();

  Future<CustodyModel?> createCustody({
    required String depositorName,
    required int totalNominal,
    required CustodyType type,
    String? description,
  }) async {
    _setLoading(true);
    _clearError();
    try {
      final custody = await _repository.createCustody(
        userId: userId,
        depositorName: depositorName,
        totalNominal: totalNominal,
        type: type,
        description: description,
      );
      _setLoading(false);
      await loadCustodies();
      return custody;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      rethrow;
    }
  }

  Future<void> updateCustody(CustodyModel custody) async {
    _setLoading(true);
    _clearError();
    try {
      await _repository.updateCustody(custody);
      _setLoading(false);
      await loadCustodies();
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      rethrow;
    }
  }

  Future<bool> hasMovements(CustodyModel custody) async {
    try {
      final movements = await _repository.getMovements(custody);
      return movements.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  Future<void> deleteCustody(CustodyModel custody) async {
    _clearError();
    try {
      await _repository.deleteCustody(custody);
      await loadCustodies();
    } catch (e) {
      _setError(e.toString());
      rethrow;
    }
  }

  Future<void> loadMovements(CustodyModel custody) async {
    _setLoading(true);
    _clearError();
    try {
      _movements = await _repository.getMovements(custody);
      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
    }
  }

  Future<void> addMovement({
    required CustodyModel custody,
    required MovementType movementType,
    required int nominal,
    int transferFee = 0,
    required DateTime date,
    required PaymentMethodModel paymentMethod,
    String? description,
  }) async {
    _clearError();
    try {
      await _repository.addMovement(
        custody: custody,
        movementType: movementType,
        nominal: nominal,
        transferFee: transferFee,
        date: date,
        paymentMethod: paymentMethod,
        description: description,
      );
      await loadMovements(custody);
      await loadCustodies();
    } catch (e) {
      _setError(e.toString());
      rethrow;
    }
  }

  void _setLoading(bool v) {
    _isLoading = v;
    if (!_disposed) notifyListeners();
  }

  void _setError(String msg) {
    _errorMessage = msg;
    if (!_disposed) notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
