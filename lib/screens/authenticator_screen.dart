import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/vault_app_bar.dart';
import '../widgets/totp_timer.dart';

/// TOTP authenticator screen with countdown timer and code list.
class AuthenticatorScreen extends StatelessWidget {
  const AuthenticatorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: const VaultAppBar(title: 'Authenticator'),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with global timer
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Authenticator',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: AppTheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'One-time passwords for your accounts',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppTheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const TOTPTimer(size: 48, strokeWidth: 3),
              ],
            ),
            const SizedBox(height: 24),

            // High Priority section
            Text(
              'High Priority',
              style: theme.textTheme.labelSmall?.copyWith(
                color: AppTheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            _TOTPEntry(
              icon: Icons.work_outline,
              iconColor: AppTheme.primary,
              title: 'Acme Corp VPN',
              subtitle: 'admin@acmecorp.com',
              code: '812 490',
              isHighPriority: true,
            ),
            const SizedBox(height: 24),

            // All Accounts section
            Text(
              'All Accounts',
              style: theme.textTheme.labelSmall?.copyWith(
                color: AppTheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView(
                children: const [
                  _TOTPEntry(
                    icon: Icons.cloud_outlined,
                    iconColor: AppTheme.secondary,
                    title: 'AWS Console',
                    subtitle: 'root@acmecorp.com',
                    code: '593 201',
                  ),
                  SizedBox(height: 8),
                  _TOTPEntry(
                    icon: Icons.storage_outlined,
                    iconColor: AppTheme.tertiary,
                    title: 'Google Workspace',
                    subtitle: 'admin@acmecorp.com',
                    code: '147 882',
                  ),
                  SizedBox(height: 8),
                  _TOTPEntry(
                    icon: Icons.code,
                    iconColor: AppTheme.primary,
                    title: 'GitHub',
                    subtitle: 'dev@acmecorp.com',
                    code: '639 014',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TOTPEntry extends StatelessWidget {
  const _TOTPEntry({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.code,
    this.isHighPriority = false,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String code;
  final bool isHighPriority;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: isHighPriority
          ? AppTheme.surfaceContainer
          : AppTheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {},
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: isHighPriority
                ? LinearGradient(
                    colors: [
                      AppTheme.primary.withOpacity(0.1),
                      Colors.transparent,
                    ],
                    begin: Alignment.centerRight,
                    end: Alignment.centerLeft,
                  )
                : null,
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, color: iconColor, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: AppTheme.onSurface,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppTheme.onSurfaceVariant,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.content_copy_outlined,
                    size: 20,
                    color: AppTheme.onSurfaceVariant.withOpacity(0.5),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  code,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: 24,
                    color: AppTheme.primary,
                    letterSpacing: 0.2 * 24,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
