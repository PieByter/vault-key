import 'package:flutter/foundation.dart';
import 'package:local_auth/local_auth.dart';

/// Biometric authentication wrapper (fingerprint / face).
class BiometricService {
  final LocalAuthentication _auth;

  BiometricService({LocalAuthentication? auth})
    : _auth = auth ?? LocalAuthentication();

  /// Check if biometric hardware is available.
  Future<bool> get isAvailable async {
    try {
      return await _auth.canCheckBiometrics && await _auth.isDeviceSupported();
    } catch (e) {
      debugPrint('Biometric check failed: $e');
      return false;
    }
  }

  /// Get list of available biometric types.
  Future<List<BiometricType>> get availableBiometrics async {
    try {
      return await _auth.getAvailableBiometrics();
    } catch (_) {
      return [];
    }
  }

  /// Prompt the user to authenticate with biometrics.
  /// Returns true if authentication succeeded.
  Future<bool> authenticate({
    String reason = 'Unlock your vault',
    bool sticky = true,
  }) async {
    try {
      return await _auth.authenticate(
        localizedReason: reason,
        options: AuthenticationOptions(stickyAuth: sticky, biometricOnly: true),
      );
    } catch (e) {
      debugPrint('Biometric auth failed: $e');
      return false;
    }
  }

  /// Quick check: can use biometric and authenticate.
  Future<bool> unlock() async {
    if (!await isAvailable) return false;
    return authenticate(reason: 'Unlock VaultKey to access your passwords');
  }
}
