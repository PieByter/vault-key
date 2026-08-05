import 'package:firebase_auth/firebase_auth.dart';

import '../services/auth_service.dart';
import '../services/biometric_service.dart';
import '../repositories/credential_repository.dart';
import '../repositories/category_repository.dart';

/// Repository that coordinates the entire auth + unlock flow.
class AuthRepository {
  final AuthService _authService;
  final BiometricService _biometricService;
  final CredentialRepository _credentialRepo;
  final CategoryRepository _categoryRepo;

  AuthRepository({
    required AuthService authService,
    required BiometricService biometricService,
    required CredentialRepository credentialRepo,
    required CategoryRepository categoryRepo,
  }) : _authService = authService,
       _biometricService = biometricService,
       _credentialRepo = credentialRepo,
       _categoryRepo = categoryRepo;

  // ── State ────────────────────────────────────────────────────────────────

  bool get isLoggedIn => _authService.isLoggedIn;
  User? get currentUser => _authService.currentUser;
  Stream<User?> get authStateChanges => _authService.authStateChanges;

  // ── Sign Up ──────────────────────────────────────────────────────────────

  Future<AuthResult> signUp(String email, String password) async {
    try {
      final user = await _authService.signUp(email, password);
      return AuthResult.success(user);
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(_mapFirebaseError(e));
    } catch (e) {
      return AuthResult.failure(e.toString());
    }
  }

  // ── Log In ───────────────────────────────────────────────────────────────

  Future<AuthResult> logIn(String email, String password) async {
    try {
      final user = await _authService.logIn(email, password);
      return AuthResult.success(user);
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(_mapFirebaseError(e));
    } on AuthException catch (e) {
      return AuthResult.failure(e.message);
    } catch (e) {
      return AuthResult.failure(e.toString());
    }
  }

  // ── Unlock ───────────────────────────────────────────────────────────────

  /// Unlock with master password (after Firebase login).
  Future<AuthResult> unlock(String masterPassword) async {
    final result = await _authService.unlock(masterPassword);
    if (result.keyMissing) {
      return AuthResult.failure(
        'Unable to unlock vault. The encryption key is missing or invalid.',
      );
    }
    if (result.keyInvalid) {
      return AuthResult.failure('Incorrect master password.');
    }
    if (!result.success) {
      return AuthResult.failure('Unlock failed.');
    }

    await _establishSession(result.key);
    return AuthResult.success(_authService.currentUser);
  }

  /// Unlock with biometric.
  Future<bool> unlockWithBiometric() async {
    final bioOk = await _biometricService.unlock();
    if (!bioOk) return false;

    final result = await _authService.unlockWithBiometric();
    if (!result.success) return false;

    await _establishSession(result.key);
    return true;
  }

  /// Set up repositories with the unlocked key and load data.
  Future<void> _establishSession(dynamic key) async {
    final user = _authService.currentUser;
    if (user == null) throw StateError('Not logged in.');

    _credentialRepo.setSession(masterKey: key, userId: user.uid);
    _categoryRepo.setSession(masterKey: key, userId: user.uid);

    // Load data (offline-first — never block unlock on the network).
    await _categoryRepo.load();
    try {
      await _credentialRepo.loadFromCloud().timeout(const Duration(seconds: 4));
    } catch (_) {
      // Offline or slow network — proceed with local data, sync happens later.
    }
  }

  // ── Log Out ──────────────────────────────────────────────────────────────

  Future<void> logOut() async {
    _credentialRepo.clearSession();
    _categoryRepo.clearSession();
    await _authService.logOut();
  }

  // ── Password Reset ───────────────────────────────────────────────────────

  Future<AuthResult> sendPasswordReset(String email) async {
    try {
      await _authService.sendPasswordReset(email);
      return AuthResult.success(null, message: 'Password reset email sent.');
    } catch (e) {
      return AuthResult.failure(e.toString());
    }
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  String _mapFirebaseError(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'This email is already registered.';
      case 'invalid-email':
        return 'Invalid email address.';
      case 'weak-password':
        return 'Password is too weak. Use at least 8 characters.';
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      default:
        return e.message ?? 'An error occurred.';
    }
  }
}

/// Result of an auth operation.
class AuthResult {
  final bool isSuccess;
  final User? user;
  final String? error;
  final String? message;

  const AuthResult._({
    required this.isSuccess,
    this.user,
    this.error,
    this.message,
  });

  factory AuthResult.success(User? user, {String? message}) {
    return AuthResult._(isSuccess: true, user: user, message: message);
  }

  factory AuthResult.failure(String error) {
    return AuthResult._(isSuccess: false, error: error);
  }
}
