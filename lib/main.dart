import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'firebase_options.dart';
import 'theme/app_theme.dart';
import 'screens/splash_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/sign_up_screen.dart';
import 'screens/login_screen.dart';
import 'screens/unlock_screen.dart';
import 'screens/vault_home_screen.dart';
import 'screens/authenticator_screen.dart';
import 'screens/reset_password_screen.dart';
import 'screens/add_edit_password_screen.dart';
import 'screens/settings_screen.dart';
import 'providers/providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase with generated options
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const ProviderScope(child: VaultKeyApp()));
}

class VaultKeyApp extends ConsumerWidget {
  const VaultKeyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'VaultKey',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme(context),
      home: const AppShell(),
    );
  }
}

/// App shell drives navigation from [appStateProvider].
///
/// Flow: Splash → Onboarding → Auth (SignUp/LogIn) → Unlock → Main Tabs
class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key});

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  int _currentTab = 0;

  final _tabs = const [
    VaultHomeScreen(),
    AuthenticatorScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(appStateProvider);
    final notifier = ref.read(appStateProvider.notifier);

    // Show error snackbar when error changes
    ref.listen<AppState>(appStateProvider, (prev, next) {
      if (next.error != null && next.error != prev?.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            backgroundColor: AppTheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });

    return switch (state.phase) {
      AppPhase.splash => SplashScreen(onComplete: () => notifier.bootstrap()),
      AppPhase.onboarding => OnboardingScreen(
        onComplete: () => notifier.completeOnboarding(),
      ),
      AppPhase.auth => switch (state.authMode) {
        AuthMode.signUp => SignUpScreen(
          onSignUp: (email, password) => notifier.signUp(email, password),
          onSignIn: () => notifier.switchAuthMode(),
          isLoading: state.isLoading,
        ),
        AuthMode.logIn => LoginScreen(
          key: UniqueKey(),
          onLogin: (email, password) => notifier.logIn(email, password),
          onSignUp: () => notifier.switchAuthMode(),
          onForgotPassword: (email) async {
            final result = await ref
                .read(authRepositoryProvider)
                .sendPasswordReset(email);
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    result.isSuccess
                        ? (result.message ?? 'Password reset email sent.')
                        : (result.error ?? 'Failed to send reset email.'),
                  ),
                  backgroundColor: result.isSuccess
                      ? AppTheme.primary
                      : AppTheme.error,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          },
          isLoading: state.isLoading,
        ),
      },
      AppPhase.unlock => UnlockScreen(
        onUnlock: (password) => notifier.unlock(password),
        onBiometricUnlock: () => notifier.unlockWithBiometric(),
        onForgotPassword: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ResetPasswordScreen()),
        ),
        onResetVault: () => notifier.resetVault(),
        isLoading: state.isLoading,
      ),
      AppPhase.main => Scaffold(
        body: IndexedStack(index: _currentTab, children: _tabs),
        bottomNavigationBar: NavigationBar(
          backgroundColor: AppTheme.surface,
          indicatorColor: AppTheme.primaryContainer.withValues(alpha: 0.2),
          selectedIndex: _currentTab,
          onDestinationSelected: (i) => setState(() => _currentTab = i),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.shield_outlined),
              selectedIcon: Icon(Icons.shield),
              label: 'Vault',
            ),
            NavigationDestination(
              icon: Icon(Icons.timer_outlined),
              selectedIcon: Icon(Icons.timer),
              label: 'Auth',
            ),
            NavigationDestination(
              icon: Icon(Icons.settings_outlined),
              selectedIcon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
        ),
        floatingActionButton: _currentTab == 0
            ? FloatingActionButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AddEditPasswordScreen(),
                  ),
                ),
                child: const Icon(Icons.add),
              )
            : null,
      ),
    };
  }
}
