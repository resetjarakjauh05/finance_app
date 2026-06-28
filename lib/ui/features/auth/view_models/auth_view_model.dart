import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../../../domain/models/user_model.dart';
import '../../../../data/repositories/auth_repository.dart';

/// ViewModel untuk authentication state management
class AuthViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;

  /// Expose repository for profile updates
  AuthRepository get authRepository => _authRepository;
  StreamSubscription? _authSubscription;

  AuthViewModel({required AuthRepository authRepository})
      : _authRepository = authRepository {
    _authSubscription = _authRepository.authStateChanges.listen((user) {
      _currentUser = user;
      if (!_disposed) notifyListeners();
    });
  }

  bool _disposed = false;

  UserModel? _currentUser;
  UserModel? get currentUser => _currentUser;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool get isAuthenticated => _currentUser != null;

  /// Sign up
  Future<void> signUp({
    required String email,
    required String password,
    String? displayName,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final user = await _authRepository.signUp(
        email: email,
        password: password,
        displayName: displayName,
      );
      _currentUser = user;
      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      rethrow;
    }
  }

  /// Sign in
  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final user = await _authRepository.signIn(
        email: email,
        password: password,
      );
      _currentUser = user;
      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      rethrow;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    _setLoading(true);
    _clearError();

    try {
      await _authRepository.signOut();
      _currentUser = null;
      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      rethrow;
    }
  }

  /// Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    _setLoading(true);
    _clearError();

    try {
      await _authRepository.sendPasswordResetEmail(email);
      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      rethrow;
    }
  }

  /// Clear error message
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

  @override
  void dispose() {
    _disposed = true;
    _authSubscription?.cancel();
    super.dispose();
  }
}
