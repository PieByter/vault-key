import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_theme.dart';
import '../models/credential.dart';
import '../providers/providers.dart';
import '../widgets/vault_app_bar.dart';
import '../widgets/category_chip.dart';
import '../widgets/credential_card.dart';
import 'add_edit_password_screen.dart';
import 'trash_screen.dart';

/// Main vault home with search, categories, and credential list.
class VaultHomeScreen extends ConsumerStatefulWidget {
  const VaultHomeScreen({super.key});

  @override
  ConsumerState<VaultHomeScreen> createState() => _VaultHomeScreenState();
}

class _VaultHomeScreenState extends ConsumerState<VaultHomeScreen> {
  final _searchController = TextEditingController();
  int _selectedCategory = 0;

  final _categories = const [
    'All Items',
    'Logins',
    'Cards',
    'Secure Notes',
    'Identity',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final credentials = ref.watch(filteredCredentialsProvider);
    final notifier = ref.read(appStateProvider.notifier);

    // Split into pinned (favorited) and rest
    final pinned = credentials.where((c) => c.isFavorite).toList();
    final all = credentials.where((c) => !c.isFavorite).toList();

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: const VaultAppBar(title: 'Vault'),
      floatingActionButton: FloatingActionButton.small(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const TrashScreen()),
        ),
        backgroundColor: AppTheme.surfaceContainerHigh,
        tooltip: 'Trash',
        child: Icon(
          Icons.delete_outline,
          color: AppTheme.onSurfaceVariant,
          size: 20,
        ),
      ),
      body: CustomScrollView(
        slivers: [
          // Sticky search header
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              decoration: BoxDecoration(
                color: AppTheme.background.withValues(alpha: 0.95),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: AppTheme.onSurface,
                      ),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: AppTheme.surfaceContainer,
                        hintText: 'Search vault...',
                        hintStyle: theme.textTheme.bodyLarge?.copyWith(
                          color: AppTheme.onSurfaceVariant.withValues(
                            alpha: 0.5,
                          ),
                        ),
                        prefixIcon: Icon(
                          Icons.search,
                          color: AppTheme.onSurfaceVariant,
                        ),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, size: 18),
                                onPressed: () {
                                  _searchController.clear();
                                  notifier.searchCredentials('');
                                },
                              )
                            : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      onChanged: (q) => notifier.searchCredentials(q),
                    ),
                  ),
                  const SizedBox(width: 12),
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: AppTheme.surfaceContainerHigh,
                    backgroundImage: const AssetImage(
                      'assets/images/profile.png',
                    ),
                    onBackgroundImageError: (_, _) {},
                    child: Icon(
                      Icons.person_outline,
                      size: 20,
                      color: AppTheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Category chips
          SliverToBoxAdapter(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Row(
                children: List.generate(_categories.length, (index) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: CategoryChip(
                      label: _categories[index],
                      isActive: index == _selectedCategory,
                      onTap: () => setState(() => _selectedCategory = index),
                    ),
                  );
                }),
              ),
            ),
          ),

          // Pinned section
          if (pinned.isNotEmpty) ...[
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              sliver: SliverToBoxAdapter(
                child: Text(
                  'Pinned',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: AppTheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _buildCard(pinned[index], notifier),
                  ),
                  childCount: pinned.length,
                ),
              ),
            ),
          ],

          // All Accounts section
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
            sliver: SliverToBoxAdapter(
              child: Row(
                children: [
                  Text(
                    'All Accounts',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: AppTheme.onSurfaceVariant,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${all.length} items',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: AppTheme.outline,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
            sliver: credentials.isEmpty
                ? const SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.all(48),
                        child: Text(
                          'No credentials yet.\nTap + to add your first one.',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  )
                : SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: _buildCard(all[index], notifier),
                      ),
                      childCount: all.length,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(Credential cred, dynamic notifier) {
    final iconData = switch (cred.type) {
      CredentialType.login => Icons.language,
      CredentialType.card => Icons.credit_card,
      CredentialType.note => Icons.note_alt_outlined,
      CredentialType.identity => Icons.person_outline,
    };

    final iconColor = switch (cred.type) {
      CredentialType.login => AppTheme.tertiary,
      CredentialType.card => AppTheme.secondary,
      CredentialType.note => AppTheme.onSurfaceVariant,
      CredentialType.identity => AppTheme.primary,
    };

    return CredentialCard(
      icon: iconData,
      title: cred.name,
      subtitle: cred.username,
      iconColor: iconColor,
      onCopy: () => _copyUsername(context, cred),
      onMore: () => _showCardMenu(context, cred),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                AddEditPasswordScreen(isEditing: true, credentialId: cred.id),
          ),
        );
      },
    );
  }

  void _copyUsername(BuildContext context, Credential cred) {
    if (cred.username.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No username to copy.'),
          backgroundColor: AppTheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    Clipboard.setData(ClipboardData(text: cred.username));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Username copied'),
        backgroundColor: AppTheme.primary,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showCardMenu(BuildContext context, Credential cred) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.person_outline, color: AppTheme.primary),
              title: const Text('Copy Username'),
              onTap: () {
                Navigator.pop(ctx);
                _copyUsername(context, cred);
              },
            ),
            ListTile(
              leading: Icon(Icons.lock_outline, color: AppTheme.primary),
              title: const Text('Copy Password'),
              onTap: () {
                Navigator.pop(ctx);
                if (cred.password.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('No password to copy.'),
                      backgroundColor: AppTheme.error,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  return;
                }
                Clipboard.setData(ClipboardData(text: cred.password));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Password copied'),
                    backgroundColor: AppTheme.primary,
                    duration: const Duration(seconds: 2),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),
            if (cred.url != null && cred.url!.isNotEmpty)
              ListTile(
                leading: Icon(Icons.open_in_new, color: AppTheme.primary),
                title: const Text('Open URL'),
                onTap: () {
                  Navigator.pop(ctx);
                  _openUrl(cred.url!);
                },
              ),
            ListTile(
              leading: Icon(
                cred.isFavorite ? Icons.star : Icons.star_border,
                color: cred.isFavorite ? AppTheme.tertiary : AppTheme.primary,
              ),
              title: Text(cred.isFavorite ? 'Unpin' : 'Pin to Top'),
              onTap: () {
                Navigator.pop(ctx);
                ref.read(appStateProvider.notifier).toggleFavorite(cred.id);
              },
            ),
            Divider(color: AppTheme.outlineVariant, height: 1),
            ListTile(
              leading: Icon(
                Icons.edit_outlined,
                color: AppTheme.onSurfaceVariant,
              ),
              title: const Text('Edit'),
              onTap: () {
                Navigator.pop(ctx);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AddEditPasswordScreen(
                      isEditing: true,
                      credentialId: cred.id,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openUrl(String url) async {
    var target = url.trim();
    if (!target.startsWith('http://') && !target.startsWith('https://')) {
      target = 'https://$target';
    }
    // Web / mobile launch
    await launchUrl(Uri.parse(target));
  }
}
