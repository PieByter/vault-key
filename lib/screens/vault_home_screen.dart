import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/vault_app_bar.dart';
import '../widgets/category_chip.dart';
import '../widgets/credential_card.dart';

/// Main vault home with search, categories, and credential list.
class VaultHomeScreen extends StatefulWidget {
  const VaultHomeScreen({super.key});

  @override
  State<VaultHomeScreen> createState() => _VaultHomeScreenState();
}

class _VaultHomeScreenState extends State<VaultHomeScreen> {
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
                color: AppTheme.background.withOpacity(0.95),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
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
                          color: AppTheme.onSurfaceVariant.withOpacity(0.5),
                        ),
                        prefixIcon: const Icon(
                          Icons.search,
                          color: AppTheme.onSurfaceVariant,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: AppTheme.surfaceContainerHigh,
                    backgroundImage: const AssetImage(
                      'assets/images/profile.png',
                    ),
                    onBackgroundImageError: (_, __) {},
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

          // Section header: Pinned
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

          // Pinned credentials
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                CredentialCard(
                  icon: Icons.code,
                  title: 'GitHub / Enterprise',
                  subtitle: 'dev_ops_admin',
                  iconColor: AppTheme.primary,
                  onCopy: () {},
                  onMore: () {},
                ),
                const SizedBox(height: 8),
                CredentialCard(
                  icon: Icons.mail_outline,
                  title: 'Gmail',
                  subtitle: 'j.doe@gmail.com',
                  iconColor: const Color(0xFFEA4335),
                  onCopy: () {},
                  onMore: () {},
                ),
              ]),
            ),
          ),

          // Section header: All Accounts
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
            sliver: SliverToBoxAdapter(
              child: Text(
                'All Accounts',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: AppTheme.onSurfaceVariant,
                ),
              ),
            ),
          ),

          // All credentials
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                CredentialCard(
                  icon: Icons.language,
                  title: 'Acme Corp Dashboard',
                  subtitle: 'j.doe@acmecorp.com',
                  iconColor: AppTheme.tertiary,
                  onCopy: () {},
                  onMore: () {},
                ),
                const SizedBox(height: 8),
                CredentialCard(
                  icon: Icons.credit_card,
                  title: 'Visa •••• 4242',
                  subtitle: 'Expires 12/26',
                  iconColor: AppTheme.secondary,
                  onCopy: () {},
                  onMore: () {},
                ),
                const SizedBox(height: 8),
                CredentialCard(
                  icon: Icons.note_alt_outlined,
                  title: 'WiFi Password',
                  subtitle: 'Home Network',
                  iconColor: AppTheme.onSurfaceVariant,
                  onCopy: () {},
                  onMore: () {},
                ),
              ]),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
    );
  }
}
