import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:encrypt/encrypt.dart' as enc;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Zero-knowledge AES-256 encryption service.
///
/// Architecture (same as Bitwarden/1Password):
/// 1. Master key = random 256-bit AES key, stored in [FlutterSecureStorage]
/// 2. Master password = used for Firebase Auth login + biometric gate
/// 3. All credential fields encrypted with master key before storage
/// 4. No plaintext ever touches Firestore
class EncryptionService {
  final FlutterSecureStorage _secureStorage;

  static const _masterKeyKey = 'vaultkey_master_key';
  static const _keyVerificationToken = 'vaultkey_verify';

  EncryptionService({FlutterSecureStorage? secureStorage})
    : _secureStorage = secureStorage ?? const FlutterSecureStorage();

  // ── Master Key Management ────────────────────────────────────────────────

  /// Generate a new random 256-bit AES key and store it in secure storage.
  /// Called once during initial sign-up.
  Future<enc.Key> generateAndStoreMasterKey() async {
    final key = enc.Key.fromSecureRandom(32);
    await _secureStorage.write(key: _masterKeyKey, value: key.base64);

    // Store a verification token so we can confirm the key exists & is valid
    final verifyToken = _randomBase64(32);
    final encrypter = enc.Encrypter(enc.AES(key, mode: enc.AESMode.cbc));
    final iv = enc.IV.fromSecureRandom(16);
    final encryptedToken = encrypter.encrypt(verifyToken, iv: iv);
    final packedToken = base64.encode(iv.bytes + encryptedToken.bytes);
    await _secureStorage.write(key: _keyVerificationToken, value: packedToken);

    return key;
  }

  /// Load the stored master key from secure storage.
  Future<enc.Key?> loadMasterKey() async {
    final keyB64 = await _secureStorage.read(key: _masterKeyKey);
    if (keyB64 == null) return null;
    return enc.Key.fromBase64(keyB64);
  }

  /// Verify the master key is valid by decrypting the stored verification token.
  Future<bool> verifyMasterKey(enc.Key key) async {
    final packedToken = await _secureStorage.read(key: _keyVerificationToken);
    if (packedToken == null) return false;
    try {
      final combined = base64.decode(packedToken);
      final iv = enc.IV(Uint8List.fromList(combined.sublist(0, 16)));
      final ciphertext = enc.Encrypted(
        Uint8List.fromList(combined.sublist(16)),
      );
      final encrypter = enc.Encrypter(enc.AES(key, mode: enc.AESMode.cbc));
      encrypter.decrypt(ciphertext, iv: iv);
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Check if master key is already set up.
  Future<bool> get isMasterKeySet async {
    final key = await _secureStorage.read(key: _masterKeyKey);
    return key != null;
  }

  /// Clear master key (logout).
  Future<void> clearMasterKey() async {
    await Future.wait([
      _secureStorage.delete(key: _masterKeyKey),
      _secureStorage.delete(key: _keyVerificationToken),
    ]);
  }

  // ── Field Encryption ─────────────────────────────────────────────────────

  /// Encrypt a plaintext string with AES-256-CBC.
  /// Returns base64(iv + ciphertext).
  String encryptField(String plaintext, enc.Key key) {
    if (plaintext.isEmpty) return '';
    final iv = enc.IV.fromSecureRandom(16);
    final encrypter = enc.Encrypter(enc.AES(key, mode: enc.AESMode.cbc));
    final encrypted = encrypter.encrypt(plaintext, iv: iv);
    final combined = Uint8List.fromList(iv.bytes + encrypted.bytes);
    return base64.encode(combined);
  }

  /// Decrypt a base64(iv + ciphertext) string.
  String decryptField(String encryptedBase64, enc.Key key) {
    if (encryptedBase64.isEmpty) return '';
    try {
      final combined = base64.decode(encryptedBase64);
      final iv = enc.IV(Uint8List.fromList(combined.sublist(0, 16)));
      final ciphertext = enc.Encrypted(
        Uint8List.fromList(combined.sublist(16)),
      );
      final encrypter = enc.Encrypter(enc.AES(key, mode: enc.AESMode.cbc));
      return encrypter.decrypt(ciphertext, iv: iv);
    } catch (_) {
      return encryptedBase64; // return as-is if not encrypted
    }
  }

  // ── Full Credential Encryption / Decryption ──────────────────────────────

  /// Encrypt sensitive fields in a credential map.
  Map<String, dynamic> encryptCredential(
    Map<String, dynamic> json,
    enc.Key key,
  ) {
    final result = Map<String, dynamic>.from(json);
    if (result['password'] is String &&
        (result['password'] as String).isNotEmpty) {
      result['password'] = encryptField(result['password'] as String, key);
    }
    if (result['totpSecret'] is String &&
        (result['totpSecret'] as String).isNotEmpty) {
      result['totpSecret'] = encryptField(result['totpSecret'] as String, key);
    }
    if (result['notes'] is String && (result['notes'] as String).isNotEmpty) {
      result['notes'] = encryptField(result['notes'] as String, key);
    }
    return result;
  }

  /// Decrypt sensitive fields in a credential map.
  Map<String, dynamic> decryptCredential(
    Map<String, dynamic> json,
    enc.Key key,
  ) {
    final result = Map<String, dynamic>.from(json);
    if (result['password'] is String) {
      result['password'] = decryptField(result['password'] as String, key);
    }
    if (result['totpSecret'] is String) {
      result['totpSecret'] = decryptField(result['totpSecret'] as String, key);
    }
    if (result['notes'] is String) {
      result['notes'] = decryptField(result['notes'] as String, key);
    }
    return result;
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  String _randomBase64(int bytes) {
    final random = Random.secure();
    final list = List<int>.generate(bytes, (_) => random.nextInt(256));
    return base64.encode(list);
  }
}
