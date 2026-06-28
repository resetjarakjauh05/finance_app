import '../../domain/models/user_model.dart';
import '../services/auth_service.dart';

/// Repository untuk authentication logic
class AuthRepository {
  final AuthService _authService;

  AuthRepository({required AuthService authService})
      : _authService = authService;

  /// Get current user as domain model
  UserModel? get currentUser {
    final user = _authService.currentUser;
    if (user == null) return null;

    return UserModel(
      id: user.uid,
      email: user.email ?? '',
      displayName: user.displayName,
      photoUrl: user.photoURL,
      createdAt: user.metadata.creationTime,
      lastLoginAt: user.metadata.lastSignInTime,
    );
  }

  /// Stream of user auth state
  Stream<UserModel?> get authStateChanges {
    return _authService.authStateChanges.map((user) {
      if (user == null) return null;

      return UserModel(
        id: user.uid,
        email: user.email ?? '',
        displayName: user.displayName,
        photoUrl: user.photoURL,
        createdAt: user.metadata.creationTime,
        lastLoginAt: user.metadata.lastSignInTime,
      );
    });
  }

  /// Sign up dengan email dan password
  Future<UserModel> signUp({
    required String email,
    required String password,
    String? displayName,
  }) async {
    // Validasi input
    if (email.isEmpty) {
      throw Exception('Email tidak boleh kosong');
    }

    if (password.isEmpty) {
      throw Exception('Password tidak boleh kosong');
    }

    if (password.length < 6) {
      throw Exception('Password minimal 6 karakter');
    }

    // Validasi email format
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email)) {
      throw Exception('Format email tidak valid');
    }

    final credential = await _authService.signUpWithEmail(
      email: email,
      password: password,
      displayName: displayName,
    );

    final user = credential.user;
    if (user == null) {
      throw Exception('Gagal membuat akun. Silakan coba lagi.');
    }

    return UserModel(
      id: user.uid,
      email: user.email ?? '',
      displayName: user.displayName,
      photoUrl: user.photoURL,
      createdAt: user.metadata.creationTime,
      lastLoginAt: user.metadata.lastSignInTime,
    );
  }

  /// Sign in dengan email dan password
  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    // Validasi input
    if (email.isEmpty) {
      throw Exception('Email tidak boleh kosong');
    }

    if (password.isEmpty) {
      throw Exception('Password tidak boleh kosong');
    }

    final credential = await _authService.signInWithEmail(
      email: email,
      password: password,
    );

    final user = credential.user;
    if (user == null) {
      throw Exception('Gagal login. Silakan coba lagi.');
    }

    return UserModel(
      id: user.uid,
      email: user.email ?? '',
      displayName: user.displayName,
      photoUrl: user.photoURL,
      createdAt: user.metadata.creationTime,
      lastLoginAt: user.metadata.lastSignInTime,
    );
  }

  /// Sign out
  Future<void> signOut() async {
    await _authService.signOut();
  }

  /// Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    if (email.isEmpty) {
      throw Exception('Email tidak boleh kosong');
    }

    // Validasi email format
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email)) {
      throw Exception('Format email tidak valid');
    }

    await _authService.sendPasswordResetEmail(email);
  }

  /// Update display name
  Future<void> updateDisplayName(String displayName) async {
    if (displayName.trim().isEmpty) throw Exception('Nama tidak boleh kosong');
    await _authService.updateDisplayName(displayName.trim());
  }

  /// Update password
  Future<void> updatePassword(String newPassword) async {
    if (newPassword.length < 6) throw Exception('Password minimal 6 karakter');
    await _authService.updatePassword(newPassword);
  }

  /// Delete user account
  Future<void> deleteAccount() async {
    await _authService.deleteAccount();
  }
}
