import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Horizontal scrollable category filter chip.
///
/// - Active: primary background, on-primary text, glow shadow
/// - Inactive: surface-container background, on-surface-variant text
class CategoryChip extends StatelessWidget {
  const CategoryChip({
    super.key,
    required this.label,
    this.isActive = false,
    this.onTap,
  });

  final String label;
  final bool isActive;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final bgColor = isActive ? AppTheme.primary : AppTheme.surfaceContainer;
    final textColor = isActive ? AppTheme.onPrimary : AppTheme.onSurfaceVariant;
    final shadow = isActive
        ? BoxShadow(
            color: AppTheme.primary.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          )
        : BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 1),
          );

    return Material(
      color: bgColor,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [shadow],
          ),
          child: Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: textColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
