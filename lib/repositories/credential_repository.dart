import 'package:encrypt/encrypt.dart' as enc;

import '../models/credential.dart';
import '../services/encryption_service.dart';
import '../services/sync_service.dart';

/// Repository: single source of truth for credentials.
///
/// Coordinates between:
/// - In-memory cache (fast UI reads)
/// - [EncryptionService] (encrypt/decrypt)
/// - [SyncService] (push/pull to Firestore)
///
/// All writes go to in-memory cache first → encrypt → sync to Firestore.
/// All reads come from in-memory cache (decrypted on load).
class CredentialRepository {
  final SyncService _sync;

  /// In-memory decrypted cache.
  final List<Credential> _credentials = [];

  enc.Key? _masterKey;
  String? _userId;

  CredentialRepository({required SyncService sync}) : _sync = sync;

  // ── Session ──────────────────────────────────────────────────────────────

  /// Set the active session (called after login/unlock).
  void setSession({required enc.Key masterKey, required String userId}) {
    _masterKey = masterKey;
    _userId = userId;
  }

  /// Clear session (called on logout).
  void clearSession() {
    _masterKey = null;
    _userId = null;
    _credentials.clear();
  }

  bool get hasSession => _masterKey != null && _userId != null;

  // ── Query ────────────────────────────────────────────────────────────────

  /// All credentials, sorted by most recently updated.
  List<Credential> get all => List.unmodifiable(_credentials);

  /// Filtered by search query.
  List<Credential> search(String query) {
    if (query.isEmpty) return all;
    final lower = query.toLowerCase();
    return _credentials.where((c) {
      return c.name.toLowerCase().contains(lower) ||
          c.username.toLowerCase().contains(lower) ||
          (c.url?.toLowerCase().contains(lower) ?? false);
    }).toList();
  }

  /// Filtered by category.
  List<Credential> byCategory(String categoryId) {
    return _credentials.where((c) => c.categoryId == categoryId).toList();
  }

  /// Filtered by type.
  List<Credential> byType(CredentialType type) {
    return _credentials.where((c) => c.type == type).toList();
  }

  /// Get a single credential by ID.
  Credential? getById(String id) {
    try {
      return _credentials.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  // ── Mutations ────────────────────────────────────────────────────────────

  /// Add a new credential.
  Future<Credential> add(Credential credential) async {
    _requireSession();
    _credentials.insert(0, credential);
    await _trySync();
    return credential;
  }

  /// Update an existing credential.
  Future<Credential?> update(
    String id,
    Credential Function(Credential) transform,
  ) async {
    _requireSession();
    final index = _credentials.indexWhere((c) => c.id == id);
    if (index == -1) return null;

    final updated = transform(
      _credentials[index],
    ).copyWith(updatedAt: DateTime.now());
    _credentials[index] = updated;
    await _trySync();
    return updated;
  }

  /// Soft-delete a credential.
  Future<bool> delete(String id) async {
    _requireSession();
    final index = _credentials.indexWhere((c) => c.id == id);
    if (index == -1) return false;

    _credentials[index] = _credentials[index].copyWith(
      isDeleted: true,
      updatedAt: DateTime.now(),
    );
    await _trySync();
    return true;
  }

  /// Permanently remove from local cache and Firestore.
  Future<bool> permanentDelete(String id) async {
    _requireSession();
    _credentials.removeWhere((c) => c.id == id);
    await _trySync();
    return true;
  }

  /// Load credentials from Firestore into memory (decrypting).
  Future<int> loadFromCloud() async {
    _requireSession();
    final result = await _sync.sync(
      localCredentials: _credentials,
      localCategories: [], // handled separately
      key: _masterKey!,
      userId: _userId!,
    );
    _credentials
      ..clear()
      ..addAll(result.credentials);
    return _credentials.length;
  }

  // ── Sync ─────────────────────────────────────────────────────────────────

  Future<void> _trySync() async {
    try {
      if (_masterKey == null || _userId == null) return;
      await _sync.sync(
        localCredentials: _credentials,
        localCategories: [],
        key: _masterKey!,
        userId: _userId!,
      );
    } catch (e) {
      // Offline — data is safe locally, will sync later
    }
  }

  void _requireSession() {
    if (!hasSession)
      throw StateError('No active session. Call setSession() first.');
  }
}
