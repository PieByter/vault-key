import 'dart:convert';

import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../models/category.dart';
import '../models/credential.dart';
import '../theme/app_theme.dart';
import '../providers/providers.dart';

/// Settings screen for VaultKey.
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(appStateProvider);
    final notifier = ref.read(appStateProvider.notifier);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.surface.withValues(alpha: 0.8),
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Settings',
          style: theme.textTheme.titleLarge?.copyWith(
            color: AppTheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionHeader('Security'),
            _SettingsCard(
              children: [
                _SwitchTile(
                  icon: Icons.dark_mode_outlined,
                  label: 'Dark Theme',
                  value: AppTheme.isDark,
                  onChanged: (v) {
                    AppTheme.isDark = v;
                    ref.read(themeModeProvider.notifier).state = v
                        ? ThemeMode.dark
                        : ThemeMode.light;
                    ref.read(databaseServiceProvider).setDarkModeEnabled(v);
                  },
                ),
                Divider(color: AppTheme.outlineVariant, height: 1),
                _SwitchTile(
                  icon: Icons.fingerprint,
                  label: 'Biometric Unlock',
                  value: state.biometricEnabled,
                  onChanged: (v) => notifier.setBiometricEnabled(v),
                ),
                Divider(color: AppTheme.outlineVariant, height: 1),
                _SwitchTile(
                  icon: Icons.content_paste_off_outlined,
                  label: 'Clear Clipboard',
                  subtitle: 'Auto-clear after 30 seconds',
                  value: state.clipboardClear,
                  onChanged: (v) => notifier.setClipboardClearEnabled(v),
                ),
                Divider(color: AppTheme.outlineVariant, height: 1),
                _SliderTile(
                  icon: Icons.lock_clock_outlined,
                  label: 'Auto-Lock',
                  value: state.autoLockMinutes.toDouble(),
                  min: 1,
                  max: 30,
                  divisions: 29,
                  labelFormatter: (v) => '${v.round()} min',
                  onChanged: (v) => notifier.setAutoLockMinutes(v.round()),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _SectionHeader('Folders'),
            _SettingsCard(
              children: [
                _ActionTile(
                  icon: Icons.folder_outlined,
                  label: 'Manage Folders',
                  onTap: () => _openFolderManager(context),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _SectionHeader('Data'),
            _SettingsCard(
              children: [
                _ActionTile(
                  icon: Icons.download_outlined,
                  label: 'Export Vault',
                  subtitle: 'Backup as JSON',
                  onTap: () => _exportVault(context),
                ),
                Divider(color: AppTheme.outlineVariant, height: 1),
                _ActionTile(
                  icon: Icons.upload_outlined,
                  label: 'Import Vault',
                  subtitle: 'Restore from JSON backup',
                  onTap: () => _importVault(context),
                ),
                Divider(color: AppTheme.outlineVariant, height: 1),
                _ActionTile(
                  icon: Icons.delete_outline,
                  label: 'Clear All Data',
                  iconColor: AppTheme.error,
                  labelColor: AppTheme.error,
                  onTap: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        backgroundColor: AppTheme.surface,
                        title: const Text('Clear all data?'),
                        content: const Text(
                          'This will permanently delete all vault items, '
                          'including trashed ones. This cannot be undone.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: const Text('Cancel'),
                          ),
                          FilledButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            style: FilledButton.styleFrom(
                              backgroundColor: AppTheme.error,
                            ),
                            child: const Text('Clear Everything'),
                          ),
                        ],
                      ),
                    );
                    if (confirm != true || !context.mounted) return;
                    await ref
                        .read(appStateProvider.notifier)
                        .clearAllCredentials();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('All data cleared.'),
                          backgroundColor: AppTheme.error,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),
            _SectionHeader('About'),
            _SettingsCard(
              children: [
                _InfoTile(
                  icon: Icons.info_outline,
                  label: 'Version',
                  value: '1.0.0',
                ),
                Divider(color: AppTheme.outlineVariant, height: 1),
                _ActionTile(
                  icon: Icons.description_outlined,
                  label: 'Privacy Policy',
                  onTap: () {},
                ),
                Divider(color: AppTheme.outlineVariant, height: 1),
                _ActionTile(
                  icon: Icons.help_outline,
                  label: 'Help & Support',
                  onTap: () {},
                ),
              ],
            ),
            const SizedBox(height: 24),
            _SectionHeader('Account'),
            _SettingsCard(
              children: [
                _ActionTile(
                  icon: Icons.sync,
                  label: 'Sync Now',
                  subtitle: state.isSyncing
                      ? 'Syncing...'
                      : 'Last sync: just now',
                  onTap: () => notifier.manualSync(),
                ),
                Divider(color: AppTheme.outlineVariant, height: 1),
                _ActionTile(
                  icon: Icons.logout,
                  label: 'Log Out',
                  iconColor: AppTheme.error,
                  labelColor: AppTheme.error,
                  onTap: () => notifier.logOut(),
                ),
              ],
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // ── Folder Manager ────────────────────────────────────────────────────

  void _openFolderManager(BuildContext context) {
    final categories = ref
        .watch(categoryRepositoryProvider)
        .all
        .where((c) => !c.isDeleted)
        .toList();

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _FolderManager(categories: categories),
    );
  }

  // ── Export / Import ───────────────────────────────────────────────────

  /// Export all credentials as a JSON backup file.
  Future<void> _exportVault(BuildContext context) async {
    final credentials = ref.read(appStateProvider).credentials;
    final user = ref.read(authRepositoryProvider).currentUser;

    final payload = {
      'app': 'vault_key',
      'version': 1,
      'exportedAt': DateTime.now().toIso8601String(),
      if (user != null) 'userEmail': user.email,
      'items': [
        for (final c in credentials)
          if (!c.isDeleted)
            {
              'id': c.id,
              'name': c.name,
              'username': c.username,
              'password': c.password, // plaintext — warn the user
              'url': c.url,
              'totpSecret': c.totpSecret,
              'notes': c.notes,
              'categoryId': c.categoryId,
              'tags': c.tags,
              'createdAt': c.createdAt.toIso8601String(),
              'updatedAt': c.updatedAt.toIso8601String(),
            },
      ],
    };

    final json = const JsonEncoder.withIndent('  ').convert(payload);

    if (!mounted) return;
    await showModalBottomSheet<String>(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Export Vault', style: Theme.of(ctx).textTheme.titleMedium),
              const SizedBox(height: 8),
              Text(
                '${(json.length / 1024).toStringAsFixed(1)} KB · '
                '${credentials.length} items',
                style: Theme.of(ctx).textTheme.bodySmall?.copyWith(
                  color: AppTheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () async {
                  await FileSaver.instance.saveFile(
                    name:
                        'vault_backup_${DateTime.now().millisecondsSinceEpoch}',
                    bytes: Uint8List.fromList(utf8.encode(json)),
                    fileExtension: 'json',
                    mimeType: MimeType.json,
                  );
                  if (ctx.mounted) Navigator.pop(ctx);
                },
                icon: const Icon(Icons.download),
                label: const Text('Download .json'),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: json));
                  if (ctx.mounted) Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('JSON copied to clipboard'),
                      backgroundColor: AppTheme.primary,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                icon: const Icon(Icons.copy),
                label: const Text('Copy JSON'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Import credentials from a JSON backup (paste into dialog).
  Future<void> _importVault(BuildContext context) async {
    final controller = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: const Text('Import Vault'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              maxLines: 8,
              decoration: const InputDecoration(
                hintText: 'Paste the vault JSON here…',
                border: OutlineInputBorder(),
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
            child: const Text('Import'),
          ),
        ],
      ),
    );
    final text = controller.text.trim();
    controller.dispose();
    if (ok != true || text.isEmpty || !context.mounted) return;

    try {
      final decoded = jsonDecode(text) as Map<String, dynamic>;
      final items = (decoded['items'] as List? ?? [])
          .cast<Map<String, dynamic>>();

      final notifier = ref.read(appStateProvider.notifier);
      final user = ref.read(authRepositoryProvider).currentUser;
      if (user == null) return;

      var count = 0;
      for (final item in items) {
        final id = item['id'] as String? ?? const Uuid().v4();
        // Skip items that already exist
        if (ref.read(credentialRepositoryProvider).getById(id) != null) {
          continue;
        }
        final now = DateTime.now();
        await notifier.addCredential(
          Credential(
            id: id,
            userId: user.uid,
            type: CredentialType.login,
            name: item['name'] as String? ?? 'Imported',
            url: item['url'] as String?,
            username: item['username'] as String? ?? '',
            password: item['password'] as String? ?? '',
            totpSecret: item['totpSecret'] as String?,
            notes: item['notes'] as String?,
            categoryId: item['categoryId'] as String?,
            tags: (item['tags'] as List?)?.cast<String>() ?? const [],
            createdAt:
                DateTime.tryParse(item['createdAt'] as String? ?? '') ?? now,
            updatedAt:
                DateTime.tryParse(item['updatedAt'] as String? ?? '') ?? now,
          ),
        );
        count++;
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Imported $count items'),
            backgroundColor: AppTheme.primary,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Import failed: invalid JSON'),
            backgroundColor: AppTheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}

/// Bottom-sheet folder manager: list, add, rename, delete.
class _FolderManager extends ConsumerStatefulWidget {
  const _FolderManager({required this.categories});
  final List<CredentialCategory> categories;

  @override
  ConsumerState<_FolderManager> createState() => _FolderManagerState();
}

class _FolderManagerState extends ConsumerState<_FolderManager> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cats = ref
        .watch(categoryRepositoryProvider)
        .all
        .where((c) => !c.isDeleted)
        .toList();

    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Row(
                children: [
                  Text('Manage Folders', style: theme.textTheme.titleMedium),
                  const Spacer(),
                  IconButton(
                    icon: Icon(
                      Icons.add_circle_outline,
                      color: AppTheme.primary,
                    ),
                    tooltip: 'Add folder',
                    onPressed: _addFolder,
                  ),
                ],
              ),
            ),
            Divider(color: AppTheme.outlineVariant),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: cats.length,
                itemBuilder: (_, i) {
                  final cat = cats[i];
                  return ListTile(
                    leading: Icon(
                      Icons.folder_outlined,
                      color: cat.isSystem
                          ? AppTheme.onSurfaceVariant.withValues(alpha: 0.4)
                          : AppTheme.primary,
                    ),
                    title: Text(
                      cat.name,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppTheme.onSurface,
                      ),
                    ),
                    subtitle: cat.isSystem
                        ? Text(
                            'Built-in',
                            style: TextStyle(
                              color: AppTheme.onSurfaceVariant,
                              fontSize: 12,
                            ),
                          )
                        : null,
                    trailing: cat.isSystem
                        ? null
                        : PopupMenuButton<String>(
                            icon: Icon(
                              Icons.more_horiz,
                              size: 20,
                              color: AppTheme.onSurfaceVariant,
                            ),
                            onSelected: (action) {
                              if (action == 'rename') _renameFolder(cat);
                              if (action == 'delete') _deleteFolder(cat);
                            },
                            itemBuilder: (_) => [
                              PopupMenuItem(
                                value: 'rename',
                                child: Text('Rename'),
                              ),
                              PopupMenuItem(
                                value: 'delete',
                                child: Text(
                                  'Delete',
                                  style: TextStyle(color: AppTheme.error),
                                ),
                              ),
                            ],
                          ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addFolder() async {
    final controller = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: const Text('New Folder'),
        content: TextField(
          controller: controller,
          autofocus: true,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => Navigator.pop(ctx, true),
          decoration: const InputDecoration(hintText: 'Folder name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Create'),
          ),
        ],
      ),
    );
    final name = controller.text.trim();
    controller.dispose();
    if (ok != true || name.isEmpty || !mounted) return;

    final user = ref.read(authRepositoryProvider).currentUser;
    if (user == null) return;

    final now = DateTime.now();
    await ref
        .read(categoryRepositoryProvider)
        .add(
          CredentialCategory(
            id: const Uuid().v4(),
            userId: user.uid,
            name: name,
            sortOrder: 99,
            isSystem: false,
            createdAt: now,
            updatedAt: now,
          ),
        );
  }

  Future<void> _renameFolder(CredentialCategory cat) async {
    final controller = TextEditingController(text: cat.name);
    controller.selection = TextSelection(
      baseOffset: 0,
      extentOffset: cat.name.length,
    );
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: const Text('Rename Folder'),
        content: TextField(
          controller: controller,
          autofocus: true,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => Navigator.pop(ctx, true),
          decoration: const InputDecoration(hintText: 'New name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Rename'),
          ),
        ],
      ),
    );
    final name = controller.text.trim();
    controller.dispose();
    if (ok != true || name.isEmpty || !mounted) return;

    await ref.read(categoryRepositoryProvider).rename(cat.id, name);
  }

  Future<void> _deleteFolder(CredentialCategory cat) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: const Text('Delete folder?'),
        content: Text(
          '"${cat.name}" will be removed. Credentials in this folder '
          'will become uncategorized.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: AppTheme.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirm != true || !mounted) return;
    await ref.read(categoryRepositoryProvider).delete(cat.id);
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 16, 4, 8),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: AppTheme.onSurfaceVariant,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: Column(children: children),
    );
  }
}

class _SwitchTile extends StatelessWidget {
  const _SwitchTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
    this.subtitle,
  });

  final IconData icon;
  final String label;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      leading: Icon(icon, color: AppTheme.onSurfaceVariant, size: 22),
      title: Text(
        label,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: AppTheme.onSurface,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppTheme.onSurfaceVariant,
              ),
            )
          : null,
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeThumbColor: AppTheme.primary,
        activeTrackColor: AppTheme.primary.withValues(alpha: 0.3),
        inactiveTrackColor: AppTheme.surfaceContainerHigh,
      ),
    );
  }
}

class _SliderTile extends StatelessWidget {
  const _SliderTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.labelFormatter,
    required this.onChanged,
  });

  final IconData icon;
  final String label;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final String Function(double) labelFormatter;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppTheme.onSurfaceVariant, size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Text(
                labelFormatter(value),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            activeColor: AppTheme.primary,
            inactiveColor: AppTheme.surfaceContainerHigh,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.iconColor,
    this.labelColor,
    this.subtitle,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? iconColor;
  final Color? labelColor;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      leading: Icon(
        icon,
        color: iconColor ?? AppTheme.onSurfaceVariant,
        size: 22,
      ),
      title: Text(
        label,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: labelColor ?? AppTheme.onSurface,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppTheme.onSurfaceVariant,
              ),
            )
          : null,
      trailing: Icon(
        Icons.chevron_right,
        color: AppTheme.onSurfaceVariant,
        size: 20,
      ),
      onTap: onTap,
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      leading: Icon(icon, color: AppTheme.onSurfaceVariant, size: 22),
      title: Text(
        label,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: AppTheme.onSurface,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: Text(
        value,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: AppTheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
