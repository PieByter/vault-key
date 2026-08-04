import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Password strength indicator (4-segment bar).
///
/// - Weak (1): error
/// - Fair (2): tertiary
/// - Good (3): tertiary + secondary mix
/// - Strong (4): secondary
class StrengthBar extends StatelessWidget {
  const StrengthBar({super.key, required this.strength, this.label})
    : assert(strength >= 0 && strength <= 4);

  /// 0 = empty, 1 = weak, 2 = fair, 3 = good, 4 = strong
  final int strength;
  final String? label;

  Color _segmentColor(int index) {
    if (index >= strength) return AppTheme.surfaceContainerHigh;

    return switch (strength) {
      1 => AppTheme.error,
      2 => AppTheme.tertiary,
      3 => index < 2 ? AppTheme.tertiary : AppTheme.secondary,
      4 => AppTheme.secondary,
      _ => AppTheme.surfaceContainerHigh,
    };
  }

  String get _labelText {
    if (label != null) return label!;
    return switch (strength) {
      0 => 'Enter password',
      1 => 'Weak',
      2 => 'Fair',
      3 => 'Good',
      4 => 'Strong',
      _ => '',
    };
  }

  Color get _labelColor {
    return switch (strength) {
      1 => AppTheme.error,
      2 => AppTheme.tertiary,
      3 => AppTheme.secondary,
      4 => AppTheme.secondary,
      _ => AppTheme.onSurfaceVariant,
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Strength',
              style: theme.textTheme.labelSmall?.copyWith(
                color: AppTheme.onSurfaceVariant,
              ),
            ),
            Text(
              _labelText,
              style: theme.textTheme.labelSmall?.copyWith(
                color: _labelColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: List.generate(4, (index) {
            return Expanded(
              child: Container(
                height: 6,
                margin: EdgeInsets.only(
                  left: index == 0 ? 0 : 4,
                  right: index == 3 ? 0 : 4,
                ),
                decoration: BoxDecoration(
                  color: _segmentColor(index),
                  borderRadius: BorderRadius.horizontal(
                    left: index == 0 ? const Radius.circular(3) : Radius.zero,
                    right: index == 3 ? const Radius.circular(3) : Radius.zero,
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}
