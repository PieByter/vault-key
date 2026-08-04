import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/vault_home_screen.dart';
import 'screens/authenticator_screen.dart';

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

/// App shell handles navigation flow: Splash → Auth → Main tabs.
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  bool _showSplash = true;
  bool _isAuthenticated = false;
  int _currentTab = 0;

  final _tabs = const [VaultHomeScreen(), AuthenticatorScreen()];

  void _onSplashComplete() {
    setState(() => _showSplash = false);
  }

  void _onLogin() {
    setState(() => _isAuthenticated = true);
  }

  @override
  Widget build(BuildContext context) {
    if (_showSplash) {
      return SplashScreen(onComplete: _onSplashComplete);
    }

    if (!_isAuthenticated) {
      return LoginScreen(key: UniqueKey());
    }

    return Scaffold(
      body: IndexedStack(index: _currentTab, children: _tabs),
      bottomNavigationBar: NavigationBar(
        backgroundColor: AppTheme.surface,
        indicatorColor: AppTheme.primaryContainer.withOpacity(0.2),
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
    );
  }
}
