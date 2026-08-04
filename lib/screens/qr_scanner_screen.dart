import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// QR scanner screen with viewfinder overlay and scan animation.
class QRScannerScreen extends StatelessWidget {
  const QRScannerScreen({super.key, this.onManualEntry});

  final VoidCallback? onManualEntry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Stack(
        children: [
          // Simulated camera feed background
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(color: AppTheme.surfaceContainerLowest),
            ),
          ),

          // Viewfinder overlay
          Positioned.fill(
            child: Column(
              children: [
                // Top shade
                Expanded(
                  flex: 1,
                  child: Container(
                    color: AppTheme.background.withValues(alpha: 0.8),
                  ),
                ),

                // Middle row with scan area
                Row(
                  children: [
                    // Left shade
                    Expanded(
                      child: Container(
                        color: AppTheme.background.withValues(alpha: 0.8),
                      ),
                    ),

                    // Scan area
                    SizedBox(
                      width: 288,
                      height: 288,
                      child: Stack(
                        children: [
                          // Corner brackets
                          Positioned(
                            top: 0,
                            left: 0,
                            child: _CornerBracket(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(12),
                              ),
                              shadows: const [
                                BoxShadow(
                                  color: AppTheme.secondary,
                                  blurRadius: 0,
                                  spreadRadius: 2,
                                  offset: Offset(2, 2),
                                ),
                              ],
                            ),
                          ),
                          Positioned(
                            top: 0,
                            right: 0,
                            child: _CornerBracket(
                              borderRadius: const BorderRadius.only(
                                topRight: Radius.circular(12),
                              ),
                              shadows: const [
                                BoxShadow(
                                  color: AppTheme.secondary,
                                  blurRadius: 0,
                                  spreadRadius: 2,
                                  offset: Offset(-2, 2),
                                ),
                              ],
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            left: 0,
                            child: _CornerBracket(
                              borderRadius: const BorderRadius.only(
                                bottomLeft: Radius.circular(12),
                              ),
                              shadows: const [
                                BoxShadow(
                                  color: AppTheme.secondary,
                                  blurRadius: 0,
                                  spreadRadius: 2,
                                  offset: Offset(2, -2),
                                ),
                              ],
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: _CornerBracket(
                              borderRadius: const BorderRadius.only(
                                bottomRight: Radius.circular(12),
                              ),
                              shadows: const [
                                BoxShadow(
                                  color: AppTheme.secondary,
                                  blurRadius: 0,
                                  spreadRadius: 2,
                                  offset: Offset(-2, -2),
                                ),
                              ],
                            ),
                          ),

                          // Scanning line animation
                          const _ScanLine(),
                        ],
                      ),
                    ),

                    // Right shade
                    Expanded(
                      child: Container(
                        color: AppTheme.background.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),

                // Bottom shade with text
                Expanded(
                  flex: 2,
                  child: Container(
                    color: AppTheme.background.withValues(alpha: 0.8),
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.qr_code_scanner,
                          size: 48,
                          color: AppTheme.onSurfaceVariant,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Scan Authenticator Code',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: AppTheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Align the QR code within the frame to automatically add a new TOTP entry.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppTheme.onSurfaceVariant,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 32),

                        // Manual entry button
                        ElevatedButton.icon(
                          onPressed: onManualEntry,
                          icon: const Icon(Icons.keyboard, size: 18),
                          label: const Text('Manual Entry'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.surfaceContainer,
                            foregroundColor: AppTheme.primary,
                            elevation: 0,
                            side: const BorderSide(
                              color: AppTheme.outlineVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Close button
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Align(
                alignment: Alignment.topRight,
                child: CircleAvatar(
                  backgroundColor: AppTheme.background.withValues(alpha: 0.6),
                  child: IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                    color: AppTheme.onSurface,
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

class _CornerBracket extends StatelessWidget {
  const _CornerBracket({required this.borderRadius, required this.shadows});

  final BorderRadius borderRadius;
  final List<BoxShadow> shadows;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerHighest,
        borderRadius: borderRadius,
        boxShadow: shadows,
      ),
    );
  }
}

class _ScanLine extends StatefulWidget {
  const _ScanLine();

  @override
  State<_ScanLine> createState() => _ScanLineState();
}

class _ScanLineState extends State<_ScanLine>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Positioned(
          top: _controller.value * 280,
          left: 0,
          right: 0,
          child: Container(
            height: 2,
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.8),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primary.withValues(alpha: 0.5),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
