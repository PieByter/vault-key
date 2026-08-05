import 'dart:async';

import 'package:encrypt/encrypt.dart' as enc;
import 'package:flutter/foundation.dart';

import '../models/credential.dart';
import '../models/category.dart';
import '../models/sync_status.dart';
import 'encryption_service.dart';
import 'database_service.dart';
import 'firebase_service.dart';

/// Offline-first sync orchestrator.
///
/// Strategy:
/// - Local = source of truth, always accessible
/// - Firestore = encrypted backup + cross-device sync
/// - Sync triggers: on app open, after add/edit/delete, on pull-to-refresh
/// - Conflict resolution: last-write-wins by [updatedAt]
class SyncService {
  final EncryptionService _encryption;
  final DatabaseService _database;
  final FirebaseService _firebase;

  SyncService({
    required EncryptionService encryption,
    required DatabaseService database,
    required FirebaseService firebase,
  }) : _encryption = encryption,
       _database = database,
       _firebase = firebase;

  // ── Public API ───────────────────────────────────────────────────────────

  /// Full sync: push local changes, then pull remote changes.
  /// [localCredentials] = current decrypted local state.
  /// [key] = master encryption key.
  /// Returns merged credential list + sync info.
  Future<SyncResult> sync({
    required List<Credential> localCredentials,
    required List<CredentialCategory> localCategories,
    required enc.Key key,
    required String userId,
  }) async {
    final info = <String>[];

    // 1. Push local changes to Firestore
    final pushCount = await _pushChanges(
      localCredentials,
      localCategories,
      key,
    );
    if (pushCount > 0) info.add('Pushed $pushCount items');

    // 2. Pull remote changes from Firestore
    final pulled = await _pullChanges(userId);
    final pullCount = pulled.credentials.length + pulled.categories.length;
    if (pullCount > 0) info.add('Pulled $pullCount items');

    // 3. Merge: decrypt remote, compare by updatedAt
    final merged = _mergeCredentials(localCredentials, pulled.credentials, key);
    final mergedCats = _mergeCategories(localCategories, pulled.categories);

    // 4. Update sync timestamp
    final now = DateTime.now();
    await _database.setLastSyncTime(userId, now);

    return SyncResult(
      credentials: merged,
      categories: mergedCats,
      syncInfo: SyncInfo(
        lastSyncAt: now,
        pendingUploads: 0,
        pendingDownloads: 0,
        status: SyncStatus.synced,
      ),
      message: info.isEmpty ? 'Already synced' : info.join(', '),
    );
  }

  // ── Push ─────────────────────────────────────────────────────────────────

  Future<int> _pushChanges(
    List<Credential> credentials,
    List<CredentialCategory> categories,
    enc.Key key,
  ) async {
    int count = 0;

    // Push credentials (encrypt sensitive fields first)
    for (final cred in credentials) {
      final json = _encryption.encryptCredential(cred.toJson(), key);
      await _firebase.upsertCredential(json);
      count++;
    }

    // Push categories (no sensitive fields, but push anyway)
    for (final cat in categories) {
      await _firebase.upsertCategory(cat.toJson());
      count++;
    }

    return count;
  }

  // ── Pull ─────────────────────────────────────────────────────────────────

  Future<
    ({
      List<Map<String, dynamic>> credentials,
      List<Map<String, dynamic>> categories,
    })
  >
  _pullChanges(String userId) async {
    final lastSync = await _database.getLastSyncTime(userId);

    final List<Map<String, dynamic>> credentials;
    final List<Map<String, dynamic>> categories;

    if (lastSync == null) {
      // First sync — pull everything
      credentials = await _firebase.fetchAllCredentials();
      categories = await _firebase.fetchAllCategories();
    } else {
      // Incremental sync
      credentials = await _firebase.fetchCredentialsSince(lastSync);
      categories = await _firebase
          .fetchAllCategories(); // categories are small, full sync
    }

    return (credentials: credentials, categories: categories);
  }

  // ── Merge ────────────────────────────────────────────────────────────────

  List<Credential> _mergeCredentials(
    List<Credential> local,
    List<Map<String, dynamic>> remoteEncrypted,
    enc.Key key,
  ) {
    final merged = <String, Credential>{};

    // Index local by ID
    for (final c in local) {
      merged[c.id] = c;
    }

    // Merge remote (newer wins)
    for (final remoteJson in remoteEncrypted) {
      final decrypted = _encryption.decryptCredential(remoteJson, key);
      final remote = Credential.fromJson(decrypted);

      if (remote.isDeleted) {
        merged.remove(remote.id);
        continue;
      }

      final existing = merged[remote.id];
      if (existing == null || remote.updatedAt.isAfter(existing.updatedAt)) {
        merged[remote.id] = remote;
      }
    }

    return merged.values.toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  List<CredentialCategory> _mergeCategories(
    List<CredentialCategory> local,
    List<Map<String, dynamic>> remote,
  ) {
    final merged = <String, CredentialCategory>{};

    for (final c in local) {
      merged[c.id] = c;
    }

    for (final r in remote) {
      final cat = CredentialCategory.fromJson(r);
      if (cat.isDeleted) {
        merged.remove(cat.id);
        continue;
      }
      final existing = merged[cat.id];
      if (existing == null || cat.updatedAt.isAfter(existing.updatedAt)) {
        merged[cat.id] = cat;
      }
    }

    return merged.values.toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
  }
}

/// Result of a sync operation.
class SyncResult {
  final List<Credential> credentials;
  final List<CredentialCategory> categories;
  final SyncInfo syncInfo;
  final String message;

  const SyncResult({
    required this.credentials,
    required this.categories,
    required this.syncInfo,
    required this.message,
  });
}
