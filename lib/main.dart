import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'screens/splash_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/sign_up_screen.dart';
import 'screens/login_screen.dart';
import 'screens/unlock_screen.dart';
import 'screens/vault_home_screen.dart';
import 'screens/authenticator_screen.dart';
import 'screens/add_edit_password_screen.dart';

void main() {
  runApp(const VaultKeyApp());
}

class VaultKeyApp extends StatelessWidget {
  const VaultKeyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VaultKey',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme(context),
      home: const AppShell(),
    );
  }
}

/// App shell handles navigation flow:
/// Splash → Onboarding → (Sign Up | Log In) → Unlock → Main tabs.
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

enum _AppPhase { splash, onboarding, auth, unlock, main }

class _AppShellState extends State<AppShell> {
  _AppPhase _phase = _AppPhase.splash;
  bool _isNewUser = true;
  int _currentTab = 0;

  final _tabs = const [VaultHomeScreen(), AuthenticatorScreen()];

  void _onSplashComplete() {
    setState(() => _phase = _AppPhase.onboarding);
  }

  void _onOnboardingComplete() {
    setState(() => _phase = _AppPhase.auth);
  }

  void _onSignUp() {
    setState(() {
      _isNewUser = false;
      _phase = _AppPhase.unlock;
    });
  }

  void _onLogin() {
    setState(() => _phase = _AppPhase.unlock);
  }

  void _onUnlock() {
    setState(() => _phase = _AppPhase.main);
  }

  @override
  Widget build(BuildContext context) {
    return switch (_phase) {
      _AppPhase.splash => SplashScreen(onComplete: _onSplashComplete),
      _AppPhase.onboarding => OnboardingScreen(
        onComplete: _onOnboardingComplete,
      ),
      _AppPhase.auth =>
        _isNewUser
            ? SignUpScreen(
                onSignUp: _onSignUp,
                onSignIn: () => setState(() => _isNewUser = false),
              )
            : LoginScreen(
                key: UniqueKey(),
                onLogin: _onLogin,
                onSignUp: () => setState(() => _isNewUser = true),
                onForgotPassword: () {},
              ),
      _AppPhase.unlock => UnlockScreen(
        onUnlock: _onUnlock,
        onForgotPassword: () {},
      ),
      _AppPhase.main => Scaffold(
        body: IndexedStack(index: _currentTab, children: _tabs),
        bottomNavigationBar: NavigationBar(
          backgroundColor: AppTheme.surface,
          indicatorColor: AppTheme.primaryContainer.withValues(alpha: 0.2),
          selectedIndex: _currentTab,
          onDestinationSelected: (index) => setState(() => _currentTab = index),
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
