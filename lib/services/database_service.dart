import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Local encrypted key-value store for vault metadata.
///
/// Uses [FlutterSecureStorage] (hardware-backed Keychain/Keystore).
/// Stores non-credential data: preferences, sync timestamps, categories.
/// Credential data goes through [EncryptionService] separately.
class DatabaseService {
  final FlutterSecureStorage _storage;

  DatabaseService({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  // ── Categories ───────────────────────────────────────────────────────────

  Future<void> saveCategories(
    String userId,
    List<Map<String, dynamic>> categories,
  ) {
    final json = jsonEncode(categories);
    return _storage.write(key: 'categories_$userId', value: json);
  }

  Future<List<Map<String, dynamic>>> loadCategories(String userId) async {
    final json = await _storage.read(key: 'categories_$userId');
    if (json == null) return [];
    return List<Map<String, dynamic>>.from(jsonDecode(json) as List);
  }

  // ── Sync Metadata ────────────────────────────────────────────────────────

  Future<DateTime?> getLastSyncTime(String userId) async {
    final val = await _storage.read(key: 'last_sync_$userId');
    if (val == null) return null;
    return DateTime.tryParse(val);
  }

  Future<void> setLastSyncTime(String userId, DateTime time) {
    return _storage.write(
      key: 'last_sync_$userId',
      value: time.toIso8601String(),
    );
  }

  // ── Preferences ──────────────────────────────────────────────────────────

  Future<bool> getDarkModeEnabled() async {
    final val = await _storage.read(key: 'dark_mode');
    return val != 'false'; // default dark
  }

  Future<void> setDarkModeEnabled(bool enabled) {
    return _storage.write(key: 'dark_mode', value: enabled.toString());
  }

  Future<bool> getBiometricEnabled(String userId) async {
    final val = await _storage.read(key: 'biometric_$userId');
    return val == 'true';
  }

  Future<void> setBiometricEnabled(String userId, bool enabled) {
    return _storage.write(key: 'biometric_$userId', value: enabled.toString());
  }

  Future<int> getAutoLockMinutes(String userId) async {
    final val = await _storage.read(key: 'autolock_$userId');
    return int.tryParse(val ?? '') ?? 5;
  }

  Future<void> setAutoLockMinutes(String userId, int minutes) {
    return _storage.write(key: 'autolock_$userId', value: minutes.toString());
  }

  Future<bool> getClipboardClearEnabled(String userId) async {
    final val = await _storage.read(key: 'clipboard_$userId');
    return val != 'false'; // default true
  }

  Future<void> setClipboardClearEnabled(String userId, bool enabled) {
    return _storage.write(key: 'clipboard_$userId', value: enabled.toString());
  }

  // ── Onboarding ───────────────────────────────────────────────────────────

  Future<bool> hasCompletedOnboarding() async {
    final val = await _storage.read(key: 'onboarding_done');
    return val == 'true';
  }

  Future<void> setOnboardingComplete() {
    return _storage.write(key: 'onboarding_done', value: 'true');
  }

  // ── Clear User Data ──────────────────────────────────────────────────────

  Future<void> clearUserData(String userId) async {
    final keys = [
      'categories_$userId',
      'last_sync_$userId',
      'biometric_$userId',
      'autolock_$userId',
      'clipboard_$userId',
    ];
    await Future.wait(keys.map((k) => _storage.delete(key: k)));
  }

  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
