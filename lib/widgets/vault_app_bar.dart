import 'dart:ui';

import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Sticky app bar used across VaultKey screens.
///
/// - Blur + translucent surface background
/// - Brand logo (left) + screen title
/// - Profile avatar (right)
/// - Safe-area aware
class VaultAppBar extends StatelessWidget implements PreferredSizeWidget {
  const VaultAppBar({
    super.key,
    this.title,
    this.showLogo = true,
    this.actions,
    this.bottom,
  });

  final String? title;
  final bool showLogo;
  final List<Widget>? actions;
  final PreferredSizeWidget? bottom;

  @override
  Size get preferredSize =>
      Size.fromHeight(kToolbarHeight + (bottom?.preferredSize.height ?? 0));

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ClipRRect(
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.surface.withValues(alpha: 0.8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 8,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            scrolledUnderElevation: 0,
            centerTitle: false,
            leading: showLogo
                ? Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: Image.asset(
                      'assets/brand/logo.png',
                      height: 32,
                      errorBuilder: (_, _, _) => Icon(
                        Icons.shield_outlined,
                        color: AppTheme.primary,
                        size: 28,
                      ),
                    ),
                  )
                : null,
            leadingWidth: showLogo ? 56 : null,
            title: title != null
                ? Text(
                    title!,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: AppTheme.onSurface,
                    ),
                  )
                : null,
            actions:
                actions ??
                [
                  Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: CircleAvatar(
                      radius: 16,
                      backgroundColor: AppTheme.surfaceContainerHigh,
                      backgroundImage: const AssetImage(
                        'assets/images/profile.png',
                      ),
                      onBackgroundImageError: (_, _) {},
                      child: Icon(
                        Icons.person_outline,
                        size: 18,
                        color: AppTheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
            bottom: bottom,
          ),
        ),
      ),
    );
  }
}
