import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../theme/app_theme.dart';

/// Real QR code scanner using the device camera (mobile_scanner).
///
/// Detects a QR code and pops the screen with its raw value (e.g. an
/// `otpauth://` URI).  Falls back gracefully when the camera is
/// unavailable (e.g. some desktop builds) by offering manual entry.
class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key, this.onManualEntry});

  /// Called when the user taps "Manual Entry".
  final VoidCallback? onManualEntry;

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  final MobileScannerController _controller = MobileScannerController(
    formats: const [BarcodeFormat.qrCode],
    detectionSpeed: DetectionSpeed.noDuplicates,
  );

  bool _handled = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_handled) return;
    final raw = capture.barcodes.firstOrNull?.rawValue;
    if (raw == null || raw.isEmpty) return;
    _handled = true;
    // Stop scanning immediately and return the result
    _controller.stop();
    Navigator.pop(context, raw);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera preview
          Positioned.fill(
            child: MobileScanner(
              controller: _controller,
              onDetect: _onDetect,
              errorBuilder: (context, error) =>
                  _CameraUnavailable(onManualEntry: widget.onManualEntry),
            ),
          ),

          // Viewfinder overlay
          IgnorePointer(
            child: Positioned.fill(
              child: Column(
                children: [
                  // Top shade
                  Expanded(flex: 1, child: Container(color: Colors.black54)),
                  // Middle row with scan area
                  Row(
                    children: [
                      Expanded(child: Container(color: Colors.black54)),
                      SizedBox(
                        width: 280,
                        height: 280,
                        child: CustomPaint(painter: _ViewfinderPainter()),
                      ),
                      Expanded(child: Container(color: Colors.black54)),
                    ],
                  ),
                  // Bottom shade with text
                  Expanded(
                    flex: 2,
                    child: Container(
                      color: Colors.black54,
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        children: [
                          Icon(
                            Icons.qr_code_scanner,
                            size: 40,
                            color: AppTheme.primary,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Point your camera at a QR code',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'For TOTP, scan the QR code shown by GitHub, '
                            'Google, or any authenticator setup page.',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.white70,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          OutlinedButton.icon(
                            onPressed: widget.onManualEntry,
                            icon: const Icon(Icons.keyboard, size: 18),
                            label: const Text('Manual Entry'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: const BorderSide(color: Colors.white38),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Close button
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Align(
                alignment: Alignment.topRight,
                child: CircleAvatar(
                  backgroundColor: Colors.black38,
                  child: IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                    color: Colors.white,
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

/// Shown when the camera cannot start (web/desktop without camera).
class _CameraUnavailable extends StatelessWidget {
  const _CameraUnavailable({this.onManualEntry});

  final VoidCallback? onManualEntry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.no_photography_outlined,
                size: 64,
                color: AppTheme.onSurfaceVariant,
              ),
              const SizedBox(height: 16),
              Text(
                'Camera not available',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: AppTheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Use manual entry instead to paste your setup key.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: onManualEntry,
                icon: const Icon(Icons.keyboard, size: 18),
                label: const Text('Manual Entry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Draws the scan-frame corner brackets.
class _ViewfinderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    const corner = 32.0;
    final s = size;

    // Top-left
    canvas.drawPath(
      Path()
        ..moveTo(0, corner)
        ..lineTo(0, 0)
        ..lineTo(corner, 0),
      paint,
    );
    // Top-right
    canvas.drawPath(
      Path()
        ..moveTo(s.width - corner, 0)
        ..lineTo(s.width, 0)
        ..lineTo(s.width, corner),
      paint,
    );
    // Bottom-left
    canvas.drawPath(
      Path()
        ..moveTo(0, s.height - corner)
        ..lineTo(0, s.height)
        ..lineTo(corner, s.height),
      paint,
    );
    // Bottom-right
    canvas.drawPath(
      Path()
        ..moveTo(s.width - corner, s.height)
        ..lineTo(s.width, s.height)
        ..lineTo(s.width, s.height - corner),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
