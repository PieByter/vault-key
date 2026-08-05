import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/vault_input.dart';

/// Unlock screen with master password + biometric fallback.
class UnlockScreen extends StatefulWidget {
  const UnlockScreen({
    super.key,
    this.onUnlock,
    this.onBiometricUnlock,
    this.onForgotPassword,
    this.onResetVault,
    this.isLoading = false,
  });

  /// Called with the typed master password when the user taps Unlock.
  final ValueChanged<String>? onUnlock;
  final VoidCallback? onBiometricUnlock;
  final VoidCallback? onForgotPassword;
  final VoidCallback? onResetVault;
  final bool isLoading;

  @override
  State<UnlockScreen> createState() => _UnlockScreenState();
}

class _UnlockScreenState extends State<UnlockScreen> {
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Stack(
        children: [
          // Decorative orbit rings
          Center(
            child: Container(
              width: 384,
              height: 384,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.surfaceVariant, width: 1),
              ),
            ),
          ),
          Center(
            child: Container(
              width: 448,
              height: 448,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppTheme.surfaceVariant.withValues(alpha: 0.5),
                  width: 1,
                ),
              ),
            ),
          ),

          // Main content
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(32),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 48),

                      // Hero shield icon
                      Container(
                        width: 96,
                        height: 96,
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceContainerHigh,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppTheme.surfaceVariant),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.4),
                              blurRadius: 40,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.lock,
                          size: 48,
                          color: AppTheme.primary,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Title
                      Text(
                        'Vault Locked',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: AppTheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Enter your Master Password to proceed.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppTheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 40),

                      // Password input
                      VaultInput(
                        controller: _passwordController,
                        hintText: 'Master Password',
                        prefixIcon: Icons.password,
                        obscureText: true,
                        isCode: true,
                        textAlign: TextAlign.center,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) =>
                            widget.onUnlock?.call(_passwordController.text),
                      ),
                      const SizedBox(height: 16),

                      // Unlock button with shimmer
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: widget.isLoading
                              ? null
                              : () => widget.onUnlock?.call(
                                  _passwordController.text,
                                ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primary,
                            foregroundColor: AppTheme.onPrimary,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            textStyle: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          child: widget.isLoading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppTheme.onPrimary,
                                  ),
                                )
                              : const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text('Unlock Vault'),
                                    SizedBox(width: 8),
                                    Icon(Icons.arrow_forward, size: 20),
                                  ],
                                ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Biometric fallback
                      IconButton(
                        onPressed: widget.onBiometricUnlock,
                        icon: const Icon(
                          Icons.fingerprint,
                          size: 32,
                          color: AppTheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Forgot password
                      TextButton(
                        onPressed: widget.onForgotPassword,
                        child: Text(
                          'Forgot Master Password?',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppTheme.primary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),

                      // Start Fresh — wipe vault & start over
                      TextButton(
                        onPressed: widget.onResetVault,
                        child: Text(
                          'Start Fresh',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppTheme.onSurfaceVariant.withValues(
                              alpha: 0.5,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
