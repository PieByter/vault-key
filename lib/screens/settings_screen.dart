import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../models/category.dart';
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
                  icon: Icons.fingerprint,
                  label: 'Biometric Unlock',
                  value: state.biometricEnabled,
                  onChanged: (v) => notifier.setBiometricEnabled(v),
                ),
                const Divider(color: AppTheme.outlineVariant, height: 1),
                _SwitchTile(
                  icon: Icons.content_paste_off_outlined,
                  label: 'Clear Clipboard',
                  subtitle: 'Auto-clear after 30 seconds',
                  value: state.clipboardClear,
                  onChanged: (v) => notifier.setClipboardClearEnabled(v),
                ),
                const Divider(color: AppTheme.outlineVariant, height: 1),
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
                  onTap: () {},
                ),
                const Divider(color: AppTheme.outlineVariant, height: 1),
                _ActionTile(
                  icon: Icons.upload_outlined,
                  label: 'Import Vault',
                  onTap: () {},
                ),
                const Divider(color: AppTheme.outlineVariant, height: 1),
                _ActionTile(
                  icon: Icons.delete_outline,
                  label: 'Clear All Data',
                  iconColor: AppTheme.error,
                  labelColor: AppTheme.error,
                  onTap: () {},
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
                const Divider(color: AppTheme.outlineVariant, height: 1),
                _ActionTile(
                  icon: Icons.description_outlined,
                  label: 'Privacy Policy',
                  onTap: () {},
                ),
                const Divider(color: AppTheme.outlineVariant, height: 1),
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
                const Divider(color: AppTheme.outlineVariant, height: 1),
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
                    icon: const Icon(
                      Icons.add_circle_outline,
                      color: AppTheme.primary,
                    ),
                    tooltip: 'Add folder',
                    onPressed: _addFolder,
                  ),
                ],
              ),
            ),
            const Divider(color: AppTheme.outlineVariant),
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
                        ? const Text(
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
                            icon: const Icon(
                              Icons.more_horiz,
                              size: 20,
                              color: AppTheme.onSurfaceVariant,
                            ),
                            onSelected: (action) {
                              if (action == 'rename') _renameFolder(cat);
                              if (action == 'delete') _deleteFolder(cat);
                            },
                            itemBuilder: (_) => const [
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
