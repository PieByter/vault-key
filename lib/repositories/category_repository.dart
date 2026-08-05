import 'package:encrypt/encrypt.dart' as enc;

import '../models/category.dart';
import '../services/database_service.dart';
import '../services/sync_service.dart';

/// Repository for credential categories.
class CategoryRepository {
  final DatabaseService _database;
  final SyncService _sync;

  final List<CredentialCategory> _categories = [];
  enc.Key? _masterKey;
  String? _userId;

  CategoryRepository({
    required DatabaseService database,
    required SyncService sync,
  }) : _database = database,
       _sync = sync;

  void setSession({required enc.Key masterKey, required String userId}) {
    _masterKey = masterKey;
    _userId = userId;
  }

  void clearSession() {
    _masterKey = null;
    _userId = null;
    _categories.clear();
  }

  List<CredentialCategory> get all => List.unmodifiable(_categories);

  /// Load categories from local storage, falling back to defaults.
  Future<void> load() async {
    if (_userId == null) return;

    // Try local first
    final stored = await _database.loadCategories(_userId!);
    if (stored.isNotEmpty) {
      _categories
        ..clear()
        ..addAll(stored.map((j) => CredentialCategory.fromJson(j)));
      return;
    }

    // Load defaults
    final defaults = CredentialCategory.defaults(_userId!);
    _categories
      ..clear()
      ..addAll(defaults);
    await _database.saveCategories(
      _userId!,
      defaults.map((c) => c.toJson()).toList(),
    );
  }

  /// Add a custom category.
  Future<CredentialCategory> add(CredentialCategory category) async {
    _categories.add(category);
    await _save();
    await _trySync();
    return category;
  }

  /// Delete a category (only non-system ones).
  Future<bool> delete(String id) async {
    final index = _categories.indexWhere((c) => c.id == id && !c.isSystem);
    if (index == -1) return false;
    _categories[index] = _categories[index].copyWith(
      isDeleted: true,
      updatedAt: DateTime.now(),
    );
    await _save();
    await _trySync();
    return true;
  }

  Future<void> _save() async {
    if (_userId == null) return;
    await _database.saveCategories(
      _userId!,
      _categories.map((c) => c.toJson()).toList(),
    );
  }

  Future<void> _trySync() async {
    try {
      if (_masterKey == null || _userId == null) return;
      await _sync.sync(
        localCredentials: [],
        localCategories: _categories,
        key: _masterKey!,
        userId: _userId!,
      );
    } catch (_) {}
  }
}
