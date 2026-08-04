import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Circular TOTP countdown timer.
///
/// - 30-second window
/// - SVG-style circular progress using CustomPainter
/// - Smooth 100ms updates
class TOTPTimer extends StatefulWidget {
  const TOTPTimer({
    super.key,
    this.durationSeconds = 30,
    this.size = 48,
    this.strokeWidth = 3,
  });

  final int durationSeconds;
  final double size;
  final double strokeWidth;

  @override
  State<TOTPTimer> createState() => _TOTPTimerState();
}

class _TOTPTimerState extends State<TOTPTimer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: widget.durationSeconds),
    );
    _startAnimation();
  }

  void _startAnimation() {
    final now = DateTime.now().millisecondsSinceEpoch / 1000;
    final elapsed = now % widget.durationSeconds;
    final remaining = widget.durationSeconds - elapsed;

    _controller.value = elapsed / widget.durationSeconds;
    _controller.animateTo(
      1,
      duration: Duration(milliseconds: (remaining * 1000).round()),
    );
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _controller.reset();
        _controller.animateTo(
          1,
          duration: Duration(seconds: widget.durationSeconds),
        );
      }
    });
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
        final remaining = ((1 - _controller.value) * widget.durationSeconds)
            .ceil();

        return SizedBox(
          width: widget.size,
          height: widget.size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: Size(widget.size, widget.size),
                painter: _CircularProgressPainter(
                  progress: _controller.value,
                  strokeWidth: widget.strokeWidth,
                  trackColor: AppTheme.surfaceVariant,
                  progressColor: AppTheme.primary,
                ),
              ),
              Text(
                remaining.toString(),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontSize: 10,
                  color: AppTheme.onSurface,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CircularProgressPainter extends CustomPainter {
  _CircularProgressPainter({
    required this.progress,
    required this.strokeWidth,
    required this.trackColor,
    required this.progressColor,
  });

  final double progress;
  final double strokeWidth;
  final Color trackColor;
  final Color progressColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final progressPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // Draw track
    canvas.drawCircle(center, radius, trackPaint);

    // Draw progress arc
    final sweepAngle = 2 * math.pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _CircularProgressPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
