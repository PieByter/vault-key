import 'dart:async';

import 'package:flutter/material.dart';

import '../services/totp_service.dart';
import '../theme/app_theme.dart';

/// A widget that displays a live TOTP code for a given [secret], updating
/// every second.  Pass `null` or an empty string to hide the code.
class TotpCodeDisplay extends StatefulWidget {
  const TotpCodeDisplay({super.key, required this.secret, this.style});

  /// Base32-encoded TOTP secret.  Empty string means "no secret yet".
  final String secret;

  /// Optional text style for the 6-digit code.
  final TextStyle? style;

  @override
  State<TotpCodeDisplay> createState() => _TotpCodeDisplayState();
}

class _TotpCodeDisplayState extends State<TotpCodeDisplay> {
  Timer? _timer;
  String? _code;
  int _remaining = 30;

  @override
  void initState() {
    super.initState();
    _tick();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  @override
  void didUpdateWidget(covariant TotpCodeDisplay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.secret != widget.secret) _tick();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _tick() {
    if (!mounted) return;
    final s = widget.secret.trim();
    setState(() {
      if (s.isEmpty) {
        _code = null;
        _remaining = 30;
      } else {
        _code = TotpService.generateCode(s);
        _remaining = TotpService.remainingSeconds();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_code == null) return const SizedBox.shrink();

    final double progress = _remaining / 30.0;
    final Color color = _remaining <= 5 ? AppTheme.error : AppTheme.tertiary;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          _code!,
          style:
              widget.style ??
              Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: AppTheme.onSurface,
                letterSpacing: 6,
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 32,
          height: 32,
          child: CircularProgressIndicator(
            value: progress,
            strokeWidth: 2.5,
            backgroundColor: AppTheme.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}
