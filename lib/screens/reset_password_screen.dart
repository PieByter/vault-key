import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../theme/app_theme.dart';
import '../providers/providers.dart';

/// Full-page explanation & recovery screen when the user forgets the
/// master password.  Accessible via "Forgot Master Password?" on the
/// unlock screen.
class ResetPasswordScreen extends ConsumerWidget {
  const ResetPasswordScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.surface.withValues(alpha: 0.8),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Reset Access'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Explanation card ──────────────────────────────────
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: AppTheme.primary,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Where is my data stored?',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: AppTheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _Bullet(
                      'Master password → stays on this device only '
                      '(never sent to any server).',
                    ),
                    const SizedBox(height: 8),
                    _Bullet(
                      'Encrypted vault items → backed up to your '
                      'Firebase Cloud Firestore automatically.',
                    ),
                    const SizedBox(height: 8),
                    _Bullet(
                      'Without the correct master password the '
                      'encrypted data cannot be read — even by us.',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ── Option 1: Try again ────────────────────────────────
              OutlinedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back),
                label: const Text('I remember now — go back & try again'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.primary,
                  side: BorderSide(color: AppTheme.primary),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
              const SizedBox(height: 16),

              // ── Option 2: Reset Firebase password + local vault ────
              FilledButton.icon(
                onPressed: () => _resetAll(context, ref),
                icon: const Icon(Icons.refresh),
                label: const Text('Reset EVERYTHING & start over'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppTheme.error,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'This wipes the local vault + logs you out. '
                'Then you can reset your Firebase password via email.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.onSurfaceVariant.withValues(alpha: 0.7),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // ── Divider ────────────────────────────────────────────
              Divider(color: AppTheme.outlineVariant),
              const SizedBox(height: 24),

              // ── FAQ ────────────────────────────────────────────────
              Text(
                'FAQ',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: AppTheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 12),
              _FaqItem(
                question: 'What IS my master password?',
                answer:
                    'It is the same password you use to log into your '
                    'VaultKey account (your email + password). '
                    'There is no separate "master password".',
              ),
              _FaqItem(
                question: 'Why can\'t you recover it for me?',
                answer:
                    'The password never leaves your device. We use '
                    'zero-knowledge encryption — even we cannot read '
                    'your vault without the password.',
              ),
              _FaqItem(
                question: 'Will reset delete my cloud backup?',
                answer:
                    'Yes. The encrypted backup in Firestore becomes '
                    'unreadable because the old key was derived from '
                    'the old password. You start fresh.',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _resetAll(BuildContext context, WidgetRef ref) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: const Text('Reset everything?'),
        content: const Text(
          'This will:\n'
          '• Wipe your local encrypted vault\n'
          '• Log you out of Firebase\n'
          '• Make any cloud backup unreadable\n\n'
          'After this, use "Forgot Password" on the login screen '
          'to get a new Firebase password.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: AppTheme.error),
            child: const Text('Reset Everything'),
          ),
        ],
      ),
    );

    if (confirm != true || !context.mounted) return;

    await ref.read(appStateProvider.notifier).resetVault();
  }
}

// ── Helpers ────────────────────────────────────────────────────────────────

class _Bullet extends StatelessWidget {
  const _Bullet(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('• ', style: TextStyle(color: AppTheme.onSurfaceVariant)),
        Expanded(
          child: Text(
            text,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppTheme.onSurfaceVariant),
          ),
        ),
      ],
    );
  }
}

class _FaqItem extends StatefulWidget {
  const _FaqItem({required this.question, required this.answer});
  final String question;
  final String answer;

  @override
  State<_FaqItem> createState() => _FaqItemState();
}

class _FaqItemState extends State<_FaqItem> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainer.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: ExpansionTile(
        collapsedShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        backgroundColor: Colors.transparent,
        collapsedBackgroundColor: Colors.transparent,
        title: Text(
          widget.question,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: AppTheme.onSurface,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(
              widget.answer,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppTheme.onSurfaceVariant.withValues(alpha: 0.8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
