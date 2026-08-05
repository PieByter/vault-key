import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../models/credential.dart';
import '../providers/providers.dart';
import '../services/totp_service.dart';
import '../theme/app_theme.dart';
import '../widgets/totp_code_display.dart';
import '../widgets/vault_app_bar.dart';
import 'qr_scanner_screen.dart';

/// Authenticator tab — like Google Authenticator.
///
/// Lists all credentials that have a TOTP secret, displaying live 6-digit
/// codes.  Tap a code to copy it to the clipboard.
class AuthenticatorScreen extends ConsumerStatefulWidget {
  const AuthenticatorScreen({super.key});

  @override
  ConsumerState<AuthenticatorScreen> createState() =>
      _AuthenticatorScreenState();
}

class _AuthenticatorScreenState extends ConsumerState<AuthenticatorScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final allCredentials = ref.watch(appStateProvider).credentials;
    final totpItems = allCredentials
        .where(
          (c) =>
              c.totpSecret != null && c.totpSecret!.isNotEmpty && !c.isDeleted,
        )
        .toList();

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: const VaultAppBar(title: 'Authenticator'),
      floatingActionButton: FloatingActionButton(
        onPressed: _scanAndAdd,
        backgroundColor: AppTheme.primary,
        child: const Icon(Icons.qr_code_scanner),
      ),
      body: totpItems.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.timer_outlined,
                      size: 64,
                      color: AppTheme.onSurfaceVariant.withValues(alpha: 0.4),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No authenticator codes yet',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: AppTheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tap + to scan a QR code from GitHub,\nGoogle, or any service that supports TOTP.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppTheme.onSurfaceVariant.withValues(alpha: 0.7),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: totpItems.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final cred = totpItems[index];
                return _TotpCard(credential: cred);
              },
            ),
    );
  }

  Future<void> _scanAndAdd() async {
    // Offer two ways to add: scan QR or paste URI
    await showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(
                  Icons.qr_code_scanner,
                  color: AppTheme.primary,
                ),
                title: const Text('Scan QR Code'),
                subtitle: const Text('Use your camera'),
                onTap: () {
                  Navigator.pop(ctx);
                  _openScanner();
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.content_paste,
                  color: AppTheme.primary,
                ),
                title: const Text('Paste setup key'),
                subtitle: const Text('Manually enter the secret'),
                onTap: () {
                  Navigator.pop(ctx);
                  _manualEntry();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openScanner() async {
    final scanned = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (_) =>
            QRScannerScreen(onManualEntry: () => Navigator.pop(context)),
      ),
    );
    if (scanned != null && mounted) await _handleScanned(scanned);
  }

  Future<void> _manualEntry() async {
    final nameC = TextEditingController();
    final secretC = TextEditingController();

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: const Text('Add TOTP Account'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameC,
              decoration: const InputDecoration(
                labelText: 'Service name',
                hintText: 'e.g. GitHub, Google',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: secretC,
              decoration: const InputDecoration(
                labelText: 'Secret (base32)',
                hintText: 'Paste the secret key',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Add'),
          ),
        ],
      ),
    );

    final name = nameC.text.trim();
    final secret = secretC.text.trim();
    nameC.dispose();
    secretC.dispose();

    if (ok != true || !mounted) return;

    if (secret.isEmpty) return;

    // Try parsing as otpauth:// first
    final parsed = TotpService.parseOtpauthUri(secret);
    if (parsed != null) {
      await _addTotpCredential(
        name: parsed.issuer ?? parsed.label,
        username: parsed.issuer != null ? parsed.label : '',
        secret: parsed.secret,
      );
    } else {
      await _addTotpCredential(
        name: name.isNotEmpty ? name : 'TOTP',
        username: '',
        secret: secret,
      );
    }
  }

  Future<void> _handleScanned(String scanned) async {
    final parsed = TotpService.parseOtpauthUri(scanned);
    if (parsed == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invalid QR code. Expected an otpauth:// URI.'),
            backgroundColor: AppTheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }
    await _addTotpCredential(
      name: parsed.issuer ?? parsed.label,
      username: parsed.issuer != null ? parsed.label : '',
      secret: parsed.secret,
    );
  }

  Future<void> _addTotpCredential({
    required String name,
    required String username,
    required String secret,
  }) async {
    final notifier = ref.read(appStateProvider.notifier);
    final user = ref.read(authRepositoryProvider).currentUser;
    if (user == null) return;

    final now = DateTime.now();
    await notifier.addCredential(
      Credential(
        id: const Uuid().v4(),
        userId: user.uid,
        type: CredentialType.login,
        name: name.isNotEmpty ? name : 'TOTP Account',
        username: username,
        password: '',
        totpSecret: secret,
        createdAt: now,
        updatedAt: now,
      ),
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$name added to authenticator.'),
          backgroundColor: AppTheme.primary,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}

/// A single TOTP card showing the account info and live code.
class _TotpCard extends StatelessWidget {
  const _TotpCard({required this.credential});

  final Credential credential;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: AppTheme.surfaceContainer,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Service icon
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppTheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  credential.name.isNotEmpty
                      ? credential.name[0].toUpperCase()
                      : '?',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: AppTheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),

            // Name + account
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    credential.name,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: AppTheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (credential.username.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      credential.username,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.onSurfaceVariant.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),

            // Live TOTP code
            TotpCodeDisplay(
              secret: credential.totpSecret!,
              style: theme.textTheme.headlineSmall?.copyWith(
                color: AppTheme.onSurface,
                letterSpacing: 4,
                fontWeight: FontWeight.w700,
              ),
            ),

            // Copy button
            IconButton(
              onPressed: () {
                final code = TotpService.generateCode(credential.totpSecret!);
                if (code != null) {
                  Clipboard.setData(ClipboardData(text: code));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('$code copied to clipboard.'),
                      backgroundColor: AppTheme.primary,
                      duration: const Duration(seconds: 1),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              icon: const Icon(Icons.copy, size: 18),
              color: AppTheme.onSurfaceVariant.withValues(alpha: 0.5),
              tooltip: 'Copy code',
            ),
          ],
        ),
      ),
    );
  }
}
