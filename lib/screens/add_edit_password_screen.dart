import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/vault_input.dart';
import '../widgets/strength_bar.dart';
import '../widgets/totp_timer.dart';

/// Add/Edit password screen with sections for credentials and metadata.
class AddEditPasswordScreen extends StatefulWidget {
  const AddEditPasswordScreen({super.key, this.isEditing = false});

  final bool isEditing;

  @override
  State<AddEditPasswordScreen> createState() => _AddEditPasswordScreenState();
}

class _AddEditPasswordScreenState extends State<AddEditPasswordScreen> {
  final _itemNameController = TextEditingController(
    text: 'Acme Corp Dashboard',
  );
  final _urlController = TextEditingController(
    text: 'https://dashboard.acmecorp.com',
  );
  final _usernameController = TextEditingController(text: 'j.doe@acmecorp.com');
  final _passwordController = TextEditingController();
  final _totpController = TextEditingController();
  final _notesController = TextEditingController();

  int _passwordStrength = 0;
  final String _selectedVault = 'Work Credentials';

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

  @override
  Widget build(BuildContext context) {
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
              onPressed: () {},
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
                _VaultPicker(value: _selectedVault, onTap: () {}),
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
                    _TagChip(label: 'Work', onDelete: () {}),
                    _TagChip(label: 'Critical', onDelete: () {}),
                    ActionChip(
                      avatar: const Icon(Icons.add, size: 16),
                      label: const Text('Add'),
                      onPressed: () {},
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
              onPressed: () => Navigator.pop(context),
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
