import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../theme/app_theme.dart';
import '../models/credential.dart';
import '../models/category.dart';
import '../providers/providers.dart';
import '../widgets/vault_input.dart';
import '../widgets/strength_bar.dart';
import '../widgets/totp_timer.dart';
import 'password_generator_screen.dart';

/// Add/Edit password screen with sections for credentials and metadata.
class AddEditPasswordScreen extends ConsumerStatefulWidget {
  const AddEditPasswordScreen({
    super.key,
    this.isEditing = false,
    this.credentialId,
  });

  final bool isEditing;
  final String? credentialId;

  @override
  ConsumerState<AddEditPasswordScreen> createState() =>
      _AddEditPasswordScreenState();
}

class _AddEditPasswordScreenState extends ConsumerState<AddEditPasswordScreen> {
  final _itemNameController = TextEditingController();
  final _urlController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _totpController = TextEditingController();
  final _notesController = TextEditingController();

  int _passwordStrength = 0;
  String? _selectedCategoryId;
  final List<String> _tags = [];

  @override
  void initState() {
    super.initState();
    // Prefill when editing an existing credential.
    if (widget.isEditing && widget.credentialId != null) {
      final existing = ref
          .read(credentialRepositoryProvider)
          .getById(widget.credentialId!);
      if (existing != null) {
        _itemNameController.text = existing.name;
        _urlController.text = existing.url ?? '';
        _usernameController.text = existing.username;
        _passwordController.text = existing.password;
        _totpController.text = existing.totpSecret ?? '';
        _notesController.text = existing.notes ?? '';
        _selectedCategoryId = existing.categoryId;
        _tags.addAll(existing.tags);
        _updateStrength(existing.password);
      }
    }
  }

  @override
  void dispose() {
    _itemNameController.dispose();
    _urlController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _totpController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _updateStrength(String value) {
    int score = 0;
    if (value.length >= 8) score++;
    if (value.contains(RegExp(r'[A-Z]'))) score++;
    if (value.contains(RegExp(r'[0-9]'))) score++;
    if (value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) score++;
    setState(() => _passwordStrength = score.clamp(0, 4));
  }

  /// Persist the item: insert or update, then sync to Firestore.
  Future<void> _save() async {
    final notifier = ref.read(appStateProvider.notifier);
    final user = ref.read(authRepositoryProvider).currentUser;
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    if (user == null) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Not logged in.'),
          backgroundColor: AppTheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final name = _itemNameController.text.trim();
    if (name.isEmpty) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Item name is required.'),
          backgroundColor: AppTheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    String? url = _urlController.text.trim();
    if (url.isEmpty) url = null;
    String? totp = _totpController.text.trim();
    if (totp.isEmpty) totp = null;
    String? notes = _notesController.text.trim();
    if (notes.isEmpty) notes = null;

    if (widget.isEditing) {
      final id = widget.credentialId;
      if (id == null) return;
      await notifier.updateCredential(
        id,
        (c) => c.copyWith(
          name: name,
          url: url,
          username: _usernameController.text.trim(),
          password: _passwordController.text,
          totpSecret: totp,
          notes: notes,
          categoryId: _selectedCategoryId,
          tags: List.unmodifiable(_tags),
        ),
      );
    } else {
      final now = DateTime.now();
      await notifier.addCredential(
        Credential(
          id: const Uuid().v4(),
          userId: user.uid,
          type: CredentialType.login,
          name: name,
          url: url,
          username: _usernameController.text.trim(),
          password: _passwordController.text,
          totpSecret: totp,
          notes: notes,
          categoryId: _selectedCategoryId,
          tags: List.unmodifiable(_tags),
          createdAt: now,
          updatedAt: now,
        ),
      );
    }

    if (!mounted) return;
    navigator.pop();
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          widget.isEditing ? 'Changes saved.' : '$name added to your vault.',
        ),
        backgroundColor: AppTheme.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Let the user choose a folder from their categories.
  Future<void> _pickCategory(
    BuildContext context,
    List<CredentialCategory> categories,
  ) async {
    if (categories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No folders yet. Create one in Settings.'),
          backgroundColor: AppTheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final picked = await showModalBottomSheet<CredentialCategory>(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Choose folder',
                style: Theme.of(ctx).textTheme.titleMedium,
              ),
            ),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: [
                  for (final cat in categories)
                    ListTile(
                      leading: const Icon(
                        Icons.folder_outlined,
                        color: AppTheme.primary,
                      ),
                      title: Text(cat.name),
                      trailing: cat.id == _selectedCategoryId
                          ? const Icon(
                              Icons.check_circle,
                              color: AppTheme.primary,
                            )
                          : null,
                      onTap: () => Navigator.pop(ctx, cat),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    if (picked != null && mounted) {
      setState(() => _selectedCategoryId = picked.id);
    }
  }

  /// Prompt the user for a new tag and add it.
  Future<void> _addTag() async {
    final controller = TextEditingController();
    final tag = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: const Text('Add Tag'),
        content: VaultInput(
          controller: controller,
          hintText: 'e.g. Work, Family, Critical',
          prefixIcon: Icons.tag,
          textInputAction: TextInputAction.done,
          onSubmitted: (v) => Navigator.pop(ctx, v),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, controller.text),
            child: const Text('Add'),
          ),
        ],
      ),
    );
    controller.dispose();

    final trimmed = tag?.trim();
    if (trimmed == null || trimmed.isEmpty) return;
    if (_tags.contains(trimmed)) return; // no duplicates
    setState(() => _tags.add(trimmed));
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref
        .watch(categoryRepositoryProvider)
        .all
        .where((c) => !c.isDeleted)
        .toList();
    final selectedCategory = categories
        .where((c) => c.id == _selectedCategoryId)
        .firstOrNull;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.surface.withValues(alpha: 0.8),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(widget.isEditing ? 'Edit Item' : 'Add Item'),
        actions: [
          if (widget.isEditing)
            TextButton(
              onPressed: () async {
                final id = widget.credentialId;
                if (id == null) return;
                await ref.read(appStateProvider.notifier).deleteCredential(id);
                if (context.mounted) Navigator.pop(context);
              },
              style: TextButton.styleFrom(foregroundColor: AppTheme.error),
              child: const Text('Delete'),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Section: Item Name & Vault
            _Section(
              children: [
                _Label('Item Name'),
                VaultInput(
                  controller: _itemNameController,
                  hintText: 'e.g. Work Email, Netflix',
                  prefixIcon: Icons.badge_outlined,
                ),
                const SizedBox(height: 16),
                _Label('Vault / Folder'),
                _VaultPicker(
                  value: selectedCategory?.name ?? 'Select folder',
                  onTap: () => _pickCategory(context, categories),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Section: Core Credentials
            Container(
              decoration: BoxDecoration(
                color: AppTheme.surfaceContainer,
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primary.withValues(alpha: 0.05),
                    Colors.transparent,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // URL
                  _Label('Website URL', color: AppTheme.primary),
                  Row(
                    children: [
                      Expanded(
                        child: VaultInput(
                          controller: _urlController,
                          hintText: 'https://example.com',
                          prefixIcon: Icons.language,
                          keyboardType: TextInputType.url,
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.open_in_new, size: 20),
                        color: AppTheme.onSurfaceVariant,
                      ),
                    ],
                  ),
                  const Divider(color: AppTheme.outlineVariant, height: 24),

                  // Username
                  _Label('Username / Email'),
                  Row(
                    children: [
                      Expanded(
                        child: VaultInput(
                          controller: _usernameController,
                          hintText: 'Enter username',
                          prefixIcon: Icons.person_outline,
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.content_copy, size: 20),
                        color: AppTheme.onSurfaceVariant,
                      ),
                    ],
                  ),
                  const Divider(color: AppTheme.outlineVariant, height: 24),

                  // Password
                  _Label('Password'),
                  VaultInput(
                    controller: _passwordController,
                    hintText: 'Enter password',
                    prefixIcon: Icons.lock_outline,
                    obscureText: true,
                    isCode: true,
                    onChanged: _updateStrength,
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: () async {
                        final password = await showModalBottomSheet<String>(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (ctx) => PasswordGeneratorScreen(
                            onUsePassword: (p) => Navigator.pop(ctx, p),
                          ),
                        );
                        if (password != null && mounted) {
                          _passwordController.text = password;
                          _updateStrength(password);
                        }
                      },
                      icon: const Icon(Icons.auto_fix_high, size: 16),
                      label: const Text('Generate Password'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppTheme.primary,
                        textStyle: Theme.of(context).textTheme.labelSmall,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  StrengthBar(strength: _passwordStrength),
                  const SizedBox(height: 16),

                  // TOTP
                  _Label('Authenticator Code'),
                  Row(
                    children: [
                      Expanded(
                        child: VaultInput(
                          controller: _totpController,
                          hintText: '000 000',
                          prefixIcon: Icons.timer_outlined,
                          isCode: true,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const TOTPTimer(size: 40, strokeWidth: 3),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.content_copy, size: 20),
                        color: AppTheme.onSurfaceVariant,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Section: Additional Details
            _Section(
              children: [
                _Label('Notes'),
                VaultInput(
                  controller: _notesController,
                  hintText: 'Add notes...',
                  prefixIcon: Icons.notes_outlined,
                  maxLines: 4,
                  minLines: 2,
                ),
                const SizedBox(height: 16),
                _Label('Tags'),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final tag in _tags)
                      _TagChip(
                        label: tag,
                        onDelete: () => setState(() => _tags.remove(tag)),
                      ),
                    ActionChip(
                      avatar: const Icon(Icons.add, size: 16),
                      label: const Text('Add'),
                      onPressed: _addTag,
                      backgroundColor: AppTheme.surfaceContainerHigh,
                      side: BorderSide.none,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Save button
            ElevatedButton(
              onPressed: _save,
              child: Text(widget.isEditing ? 'Save Changes' : 'Add Item'),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: children,
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text, {this.color});

  final String text;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: color ?? AppTheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _VaultPicker extends StatelessWidget {
  const _VaultPicker({required this.value, this.onTap});

  final String value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: AppTheme.surfaceContainer,
      borderRadius: BorderRadius.circular(8),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              const Icon(Icons.folder, size: 20, color: AppTheme.secondary),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  value,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const Icon(
                Icons.expand_more,
                size: 20,
                color: AppTheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TagChip extends StatelessWidget {
  const _TagChip({required this.label, this.onDelete});

  final String label;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(label),
      deleteIcon: const Icon(Icons.close, size: 16),
      onDeleted: onDelete,
      backgroundColor: AppTheme.surfaceContainerHigh,
      side: BorderSide.none,
    );
  }
}
