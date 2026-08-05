import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart' as crypt;
import 'package:encrypt/encrypt.dart' as enc;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Zero-knowledge AES-256 encryption service.
///
/// Architecture (same as Bitwarden/1Password):
/// 1. Master key = derived from the master password via PBKDF2 (never stored)
/// 2. Only a random salt + verification token are stored locally
/// 3. All credential fields encrypted with master key before storage
/// 4. No plaintext ever touches Firestore
class EncryptionService {
  final FlutterSecureStorage _secureStorage;

  static const _saltKey = 'vaultkey_master_salt';
  static const _keyVerificationToken = 'vaultkey_verify';
  static const _deviceKeyKey = 'vaultkey_device_key';

  /// PBKDF2 iterations (100k — balanced for Flutter web: ~0.8s native,
  /// ~2-3s on web. OWASP recommends 600k for native apps.).
  static const _pbkdf2Iterations = 100000;

  EncryptionService({FlutterSecureStorage? secureStorage})
    : _secureStorage = secureStorage ?? const FlutterSecureStorage();

  // ── Master Key Management ────────────────────────────────────────────────

  /// Derive a 256-bit AES key from [masterPassword] + stored salt (PBKDF2).
  Future<enc.Key> _deriveKey(String masterPassword, String saltB64) async {
    final pbkdf2 = crypt.Pbkdf2(
      macAlgorithm: crypt.Hmac.sha256(),
      iterations: _pbkdf2Iterations,
      bits: 256,
    );
    final secretKey = await pbkdf2.deriveKeyFromPassword(
      password: masterPassword,
      nonce: base64.decode(saltB64),
    );
    final bytes = await secretKey.extractBytes();
    return enc.Key(Uint8List.fromList(bytes));
  }

  /// Create the vault from a master password (called on sign-up).
  /// Stores a random salt + verification token. The password itself is
  /// NEVER stored — the key is re-derived on every unlock.
  Future<enc.Key> createMasterKey(String masterPassword) async {
    final salt = _randomBase64(16);
    final key = await _deriveKey(masterPassword, salt);
    await _secureStorage.write(key: _saltKey, value: salt);
    await _writeVerificationToken(key);
    return key;
  }

  /// Unlock with the master password: re-derive the key from the stored
  /// salt and verify it against the verification token.
  /// Returns `null` when the password is wrong or the vault is not set up.
  Future<enc.Key?> unlockWithPassword(String masterPassword) async {
    final salt = await _secureStorage.read(key: _saltKey);
    if (salt == null) return null;
    final key = await _deriveKey(masterPassword, salt);
    if (!await verifyMasterKey(key)) return null;
    return key;
  }

  /// Store the derived key for biometric convenience (called after a
  /// successful password unlock). Cleared on logout.
  Future<void> storeDeviceKey(enc.Key key) async {
    await _secureStorage.write(key: _deviceKeyKey, value: key.base64);
  }

  /// Load the device key for biometric unlock.
  Future<enc.Key?> loadDeviceKey() async {
    final b64 = await _secureStorage.read(key: _deviceKeyKey);
    if (b64 == null) return null;
    return enc.Key.fromBase64(b64);
  }

  /// Whether the vault is set up (salt exists) on this device.
  Future<bool> get isMasterKeySet async {
    final salt = await _secureStorage.read(key: _saltKey);
    return salt != null;
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

  /// Clear the convenience device key (logout). The salt + verification
  /// token stay so the user can unlock again after logging back in.
  Future<void> clearDeviceKey() async {
    await _secureStorage.delete(key: _deviceKeyKey);
  }

  /// Fully reset the vault (re-registration): remove salt, token, device key.
  Future<void> resetVault() async {
    await Future.wait([
      _secureStorage.delete(key: _saltKey),
      _secureStorage.delete(key: _keyVerificationToken),
      _secureStorage.delete(key: _deviceKeyKey),
    ]);
  }

  Future<void> _writeVerificationToken(enc.Key key) async {
    final verifyToken = _randomBase64(32);
    final encrypter = enc.Encrypter(enc.AES(key, mode: enc.AESMode.cbc));
    final iv = enc.IV.fromSecureRandom(16);
    final encryptedToken = encrypter.encrypt(verifyToken, iv: iv);
    final packedToken = base64.encode(iv.bytes + encryptedToken.bytes);
    await _secureStorage.write(key: _keyVerificationToken, value: packedToken);
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
