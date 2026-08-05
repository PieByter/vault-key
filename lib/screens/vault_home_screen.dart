import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_theme.dart';
import '../models/credential.dart';
import '../providers/providers.dart';
import '../widgets/vault_app_bar.dart';
import '../widgets/category_chip.dart';
import '../widgets/credential_card.dart';
import 'add_edit_password_screen.dart';

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
                        prefixIcon: const Icon(
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
                    child: const Icon(
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
      onCopy: () {},
      onMore: () {},
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
}
