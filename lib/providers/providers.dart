import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/credential.dart';
import '../models/category.dart';
import '../models/sync_status.dart';
import '../services/encryption_service.dart';
import '../services/database_service.dart';
import '../services/firebase_service.dart';
import '../services/sync_service.dart';
import '../services/auth_service.dart';
import '../services/biometric_service.dart';
import '../repositories/credential_repository.dart';
import '../repositories/category_repository.dart';
import '../repositories/auth_repository.dart';

// ═══════════════════════════════════════════════════════════════════════════
// Services (singletons)
// ═══════════════════════════════════════════════════════════════════════════

final encryptionServiceProvider = Provider<EncryptionService>((ref) {
  return EncryptionService();
});

final databaseServiceProvider = Provider<DatabaseService>((ref) {
  return DatabaseService();
});

final firebaseServiceProvider = Provider<FirebaseService>((ref) {
  return FirebaseService();
});

final biometricServiceProvider = Provider<BiometricService>((ref) {
  return BiometricService();
});

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(
    firebase: ref.watch(firebaseServiceProvider),
    encryption: ref.watch(encryptionServiceProvider),
    database: ref.watch(databaseServiceProvider),
  );
});

final syncServiceProvider = Provider<SyncService>((ref) {
  return SyncService(
    encryption: ref.watch(encryptionServiceProvider),
    database: ref.watch(databaseServiceProvider),
    firebase: ref.watch(firebaseServiceProvider),
  );
});

// ═══════════════════════════════════════════════════════════════════════════
// Repositories
// ═══════════════════════════════════════════════════════════════════════════

final credentialRepositoryProvider = Provider<CredentialRepository>((ref) {
  return CredentialRepository(
    encryption: ref.watch(encryptionServiceProvider),
    sync: ref.watch(syncServiceProvider),
  );
});

final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  return CategoryRepository(
    database: ref.watch(databaseServiceProvider),
    sync: ref.watch(syncServiceProvider),
  );
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    authService: ref.watch(authServiceProvider),
    biometricService: ref.watch(biometricServiceProvider),
    credentialRepo: ref.watch(credentialRepositoryProvider),
    categoryRepo: ref.watch(categoryRepositoryProvider),
  );
});

// ═══════════════════════════════════════════════════════════════════════════
// App State
// ═══════════════════════════════════════════════════════════════════════════

enum AppPhase { splash, onboarding, auth, unlock, main }

enum AuthMode { signUp, logIn }

/// Central app state notifier.
class AppStateNotifier extends StateNotifier<AppState> {
  final AuthRepository _authRepo;
  final CredentialRepository _credentialRepo;
  final DatabaseService _database;

  AppStateNotifier({
    required AuthRepository authRepo,
    required CredentialRepository credentialRepo,
    required CategoryRepository categoryRepo,
    required DatabaseService database,
    required EncryptionService encryption,
  }) : _authRepo = authRepo,
       _credentialRepo = credentialRepo,
       _database = database,
       super(const AppState());

  // ── Bootstrap ──────────────────────────────────────────────────────────

  /// Called after splash screen. Determines next phase.
  Future<void> bootstrap() async {
    // Check if onboarding is done
    final onboardingDone = await _database.hasCompletedOnboarding();

    // Check if already logged in
    if (_authRepo.isLoggedIn) {
      state = state.copyWith(phase: AppPhase.unlock);
    } else if (onboardingDone) {
      state = state.copyWith(phase: AppPhase.auth, authMode: AuthMode.logIn);
    } else {
      state = state.copyWith(phase: AppPhase.onboarding);
    }
  }

  // ── Onboarding ─────────────────────────────────────────────────────────

  void completeOnboarding() {
    _database.setOnboardingComplete();
    state = state.copyWith(phase: AppPhase.auth, authMode: AuthMode.signUp);
  }

  // ── Auth ───────────────────────────────────────────────────────────────

  void switchAuthMode() {
    final newMode = state.authMode == AuthMode.signUp
        ? AuthMode.logIn
        : AuthMode.signUp;
    state = state.copyWith(authMode: newMode);
  }

  Future<void> signUp(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    final result = await _authRepo.signUp(email, password);
    if (result.isSuccess) {
      state = state.copyWith(phase: AppPhase.unlock, isLoading: false);
    } else {
      state = state.copyWith(isLoading: false, error: result.error);
    }
  }

  Future<void> logIn(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    final result = await _authRepo.logIn(email, password);
    if (result.isSuccess) {
      state = state.copyWith(phase: AppPhase.unlock, isLoading: false);
    } else {
      state = state.copyWith(isLoading: false, error: result.error);
    }
  }

  // ── Unlock ─────────────────────────────────────────────────────────────

  Future<void> unlock() async {
    state = state.copyWith(isLoading: true, error: null);
    final result = await _authRepo.unlock();
    if (result.isSuccess) {
      state = state.copyWith(phase: AppPhase.main, isLoading: false);
    } else {
      state = state.copyWith(isLoading: false, error: result.error);
    }
  }

  Future<void> unlockWithBiometric() async {
    final success = await _authRepo.unlockWithBiometric();
    if (success) {
      state = state.copyWith(phase: AppPhase.main);
    } else {
      state = state.copyWith(error: 'Biometric unlock failed');
    }
  }

  // ── Logout ─────────────────────────────────────────────────────────────

  Future<void> logOut() async {
    await _authRepo.logOut();
    state = const AppState(); // reset to initial
  }

  // ── Vault Operations ───────────────────────────────────────────────────

  Future<void> addCredential(Credential credential) async {
    await _credentialRepo.add(credential);
    state = state.copyWith(
      credentials: _credentialRepo.all,
      version: state.version + 1,
    );
  }

  Future<void> updateCredential(
    String id,
    Credential Function(Credential) transform,
  ) async {
    await _credentialRepo.update(id, transform);
    state = state.copyWith(
      credentials: _credentialRepo.all,
      version: state.version + 1,
    );
  }

  Future<void> deleteCredential(String id) async {
    await _credentialRepo.delete(id);
    state = state.copyWith(
      credentials: _credentialRepo.all,
      version: state.version + 1,
    );
  }

  void searchCredentials(String query) {
    state = state.copyWith(searchQuery: query);
  }

  // ── Settings ───────────────────────────────────────────────────────────

  Future<void> setBiometricEnabled(bool enabled) async {
    if (_authRepo.currentUser == null) return;
    await _database.setBiometricEnabled(_authRepo.currentUser!.uid, enabled);
    state = state.copyWith(biometricEnabled: enabled);
  }

  Future<void> setAutoLockMinutes(int minutes) async {
    if (_authRepo.currentUser == null) return;
    await _database.setAutoLockMinutes(_authRepo.currentUser!.uid, minutes);
    state = state.copyWith(autoLockMinutes: minutes);
  }

  Future<void> setClipboardClearEnabled(bool enabled) async {
    if (_authRepo.currentUser == null) return;
    await _database.setClipboardClearEnabled(
      _authRepo.currentUser!.uid,
      enabled,
    );
    state = state.copyWith(clipboardClear: enabled);
  }

  // ── Sync ───────────────────────────────────────────────────────────────

  Future<void> manualSync() async {
    state = state.copyWith(isSyncing: true);
    try {
      await _credentialRepo.loadFromCloud();
      state = state.copyWith(
        credentials: _credentialRepo.all,
        version: state.version + 1,
        isSyncing: false,
      );
    } catch (_) {
      state = state.copyWith(isSyncing: false);
    }
  }
}

/// Centralized app state.
class AppState {
  final AppPhase phase;
  final AuthMode authMode;
  final bool isLoading;
  final String? error;
  final String searchQuery;
  final List<Credential> credentials;
  final List<CredentialCategory> categories;
  final bool biometricEnabled;
  final int autoLockMinutes;
  final bool clipboardClear;
  final bool isSyncing;
  final int version; // increments on data changes to trigger UI rebuilds

  const AppState({
    this.phase = AppPhase.splash,
    this.authMode = AuthMode.signUp,
    this.isLoading = false,
    this.error,
    this.searchQuery = '',
    this.credentials = const [],
    this.categories = const [],
    this.biometricEnabled = true,
    this.autoLockMinutes = 5,
    this.clipboardClear = true,
    this.isSyncing = false,
    this.version = 0,
  });

  AppState copyWith({
    AppPhase? phase,
    AuthMode? authMode,
    bool? isLoading,
    String? error,
    String? searchQuery,
    List<Credential>? credentials,
    List<CredentialCategory>? categories,
    bool? biometricEnabled,
    int? autoLockMinutes,
    bool? clipboardClear,
    bool? isSyncing,
    int? version,
  }) {
    return AppState(
      phase: phase ?? this.phase,
      authMode: authMode ?? this.authMode,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      searchQuery: searchQuery ?? this.searchQuery,
      credentials: credentials ?? this.credentials,
      categories: categories ?? this.categories,
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
      autoLockMinutes: autoLockMinutes ?? this.autoLockMinutes,
      clipboardClear: clipboardClear ?? this.clipboardClear,
      isSyncing: isSyncing ?? this.isSyncing,
      version: version ?? this.version,
    );
  }
}

/// The main app state provider.
final appStateProvider = StateNotifierProvider<AppStateNotifier, AppState>((
  ref,
) {
  return AppStateNotifier(
    authRepo: ref.watch(authRepositoryProvider),
    credentialRepo: ref.watch(credentialRepositoryProvider),
    categoryRepo: ref.watch(categoryRepositoryProvider),
    database: ref.watch(databaseServiceProvider),
    encryption: ref.watch(encryptionServiceProvider),
  );
});

// ═══════════════════════════════════════════════════════════════════════════
// Derived Providers
// ═══════════════════════════════════════════════════════════════════════════

/// Filtered credentials based on search query.
final filteredCredentialsProvider = Provider<List<Credential>>((ref) {
  final state = ref.watch(appStateProvider);
  final query = state.searchQuery;
  if (query.isEmpty) return state.credentials;
  final lower = query.toLowerCase();
  return state.credentials.where((c) {
    return c.name.toLowerCase().contains(lower) ||
        c.username.toLowerCase().contains(lower) ||
        (c.url?.toLowerCase().contains(lower) ?? false);
  }).toList();
});

/// Credentials grouped by category.
final credentialsByCategoryProvider = Provider.family<List<Credential>, String>(
  (ref, categoryId) {
    final state = ref.watch(appStateProvider);
    return state.credentials.where((c) => c.categoryId == categoryId).toList();
  },
);

/// Current user.
final currentUserProvider = Provider((ref) {
  final authRepo = ref.watch(authRepositoryProvider);
  return authRepo.currentUser;
});

/// Sync status.
final syncStatusProvider = Provider<SyncStatus>((ref) {
  final state = ref.watch(appStateProvider);
  return state.isSyncing ? SyncStatus.pendingUpload : SyncStatus.synced;
});
