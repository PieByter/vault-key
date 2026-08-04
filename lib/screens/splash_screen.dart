import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Splash screen with brand logo, loading bar, and secure enclave status.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key, this.onComplete});

  final VoidCallback? onComplete;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    // Simulate initialization
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) widget.onComplete?.call();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Stack(
        children: [
          // Background glow
          Center(
            child: Container(
              width: 800,
              height: 800,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primary.withOpacity(0.2),
              ),
            ),
          ),

          // Main content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo with bounce
                SizedBox(
                  width: 128,
                  height: 128,
                  child: Image.asset(
                    'assets/brand/logo.png',
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.shield_outlined,
                      size: 80,
                      color: AppTheme.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // App name
                Text(
                  'VaultKey',
                  style: theme.textTheme.headlineLarge?.copyWith(
                    color: Colors.white,
                    letterSpacing: -0.02 * 32,
                  ),
                ),
                const SizedBox(height: 4),

                // Tagline
                Text(
                  'Enterprise Security',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.onSurfaceVariant.withOpacity(0.7),
                    letterSpacing: 4,
                  ),
                ),
              ],
            ),
          ),

          // Bottom loading bar
          Positioned(
            left: 32,
            right: 32,
            bottom: 64,
            child: Column(
              children: [
                // Progress bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    backgroundColor: AppTheme.surfaceContainerHighest,
                    color: AppTheme.primary,
                    minHeight: 4,
                  ),
                ),
                const SizedBox(height: 16),

                // Status text
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppTheme.onSurfaceVariant.withOpacity(0.5),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Initializing Secure Enclave',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: AppTheme.onSurfaceVariant.withOpacity(0.5),
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
