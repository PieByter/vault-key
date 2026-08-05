import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import 'encryption_service.dart';
import 'database_service.dart';
import 'firebase_service.dart';

/// Orchestrates authentication flow across Firebase, encryption, and local storage.
///
/// Key flows:
/// 1. Sign Up → Firebase Auth creates user → generate master key → store in secure storage
/// 2. Log In → Firebase Auth verifies → load master key from secure storage → verify
/// 3. Unlock → biometric or master password → load master key into memory
/// 4. Log Out → clear master key from secure storage
class AuthService {
  final FirebaseService _firebase;
  final EncryptionService _encryption;
  final DatabaseService _database;

  AuthService({
    required FirebaseService firebase,
    required EncryptionService encryption,
    required DatabaseService database,
  }) : _firebase = firebase,
       _encryption = encryption,
       _database = database;

  // ── State ────────────────────────────────────────────────────────────────

  /// Whether a user is currently authenticated with Firebase.
  bool get isLoggedIn => _firebase.currentUser != null;

  /// The current Firebase user.
  User? get currentUser => _firebase.currentUser;

  /// Stream of auth state changes.
  Stream<User?> get authStateChanges => _firebase.authStateChanges;

  // ── Sign Up ──────────────────────────────────────────────────────────────

  /// Create new account: Firebase Auth + derive master key from password.
  /// Returns the Firebase [User] on success.
  Future<User> signUp(String email, String password) async {
    final credential = await _firebase.signUp(email, password);
    final user = credential.user!;

    // Create the master encryption key FROM the master password (PBKDF2)
    await _encryption.createMasterKey(password);

    // Initialize default categories
    final defaults = _defaultCategories(user.uid);
    await _database.saveCategories(user.uid, defaults);

    debugPrint('✅ VaultKey: Sign-up complete for ${user.email}');
    return user;
  }

  // ── Log In ───────────────────────────────────────────────────────────────

  /// Log in: Firebase Auth verifies the password.
  Future<User> logIn(String email, String password) async {
    final credential = await _firebase.signIn(email, password);
    final user = credential.user!;

    // If the vault is not set up on this device yet (e.g. account created
    // before the password-key change), initialize it with this password.
    if (!await _encryption.isMasterKeySet) {
      await _encryption.createMasterKey(password);
    }

    debugPrint('✅ VaultKey: Login complete for ${user.email}');
    return user;
  }

  // ── Log Out ──────────────────────────────────────────────────────────────

  Future<void> logOut() async {
    // Only the convenience device key is cleared; salt + verification token
    // stay so the user can unlock again after logging back in.
    await _encryption.clearDeviceKey();
    await _firebase.signOut();
    debugPrint('✅ VaultKey: Logged out');
  }

  // ── Unlock (after login, biometric, or timeout) ──────────────────────────

  /// Unlock the vault with the master password: re-derive the key from
  /// the password (PBKDF2) and verify it. Returns the key on success.
  ///
  /// If the vault was never set up on this device (legacy account created
  /// before the password-key change, or fresh device), it is initialized
  /// with the typed password — the account password was already verified
  /// by Firebase at login.
  Future<UnlockResult> unlock(String masterPassword) async {
    if (masterPassword.isEmpty) {
      return UnlockResult(keyInvalid: true);
    }

    if (!await _encryption.isMasterKeySet) {
      // Legacy migration: create the vault with the entered password.
      final key = await _encryption.createMasterKey(masterPassword);
      await _encryption.storeDeviceKey(key);
      return UnlockResult(success: true, key: key);
    }

    final key = await _encryption.unlockWithPassword(masterPassword);
    if (key == null) {
      return UnlockResult(keyInvalid: true); // wrong master password
    }
    // Keep a copy for biometric convenience during this device session
    await _encryption.storeDeviceKey(key);
    return UnlockResult(success: true, key: key);
  }

  /// Unlock with biometrics: load the device key stored after the last
  /// successful password unlock.
  Future<UnlockResult> unlockWithBiometric() async {
    final key = await _encryption.loadDeviceKey();
    if (key == null) {
      return UnlockResult(keyMissing: true);
    }
    final valid = await _encryption.verifyMasterKey(key);
    if (!valid) {
      return UnlockResult(keyInvalid: true);
    }
    return UnlockResult(success: true, key: key);
  }

  // ── Password Reset ───────────────────────────────────────────────────────

  Future<void> sendPasswordReset(String email) async {
    await _firebase.sendPasswordResetEmail(email);
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  List<Map<String, dynamic>> _defaultCategories(String userId) {
    final now = DateTime.now().toIso8601String();
    return [
      {
        'id': 'sys_logins',
        'userId': userId,
        'name': 'Logins',
        'icon': 'key',
        'sortOrder': 0,
        'isSystem': true,
        'createdAt': now,
        'updatedAt': now,
      },
      {
        'id': 'sys_cards',
        'userId': userId,
        'name': 'Cards',
        'icon': 'credit_card',
        'sortOrder': 1,
        'isSystem': true,
        'createdAt': now,
        'updatedAt': now,
      },
      {
        'id': 'sys_notes',
        'userId': userId,
        'name': 'Secure Notes',
        'icon': 'note',
        'sortOrder': 2,
        'isSystem': true,
        'createdAt': now,
        'updatedAt': now,
      },
      {
        'id': 'sys_identity',
        'userId': userId,
        'name': 'Identity',
        'icon': 'person',
        'sortOrder': 3,
        'isSystem': true,
        'createdAt': now,
        'updatedAt': now,
      },
    ];
  }
}

/// Result of an unlock attempt.
class UnlockResult {
  final bool success;
  final bool keyMissing;
  final bool keyInvalid;
  final dynamic key; // enc.Key — kept as dynamic to avoid coupling

  const UnlockResult({
    this.success = false,
    this.keyMissing = false,
    this.keyInvalid = false,
    this.key,
  });
}

/// Auth-related exceptions.
class AuthException implements Exception {
  final String message;
  const AuthException(this.message);

  @override
  String toString() => 'AuthException: $message';
}
