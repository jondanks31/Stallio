import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/services/role_service.dart';
import '../../../../core/ui/gradient_background.dart';
import '../../../../core/ui/snackbar_service.dart';
import '../../../auth/data/auth_repository.dart';
import '../../../horses/presentation/dialogs/horse_dialog.dart';
import '../../../people/data/people_repository.dart';
import '../../../people/presentation/pages/people_page.dart';
import '../../../yard/presentation/pages/yard_management_page.dart';
import 'profile_page.dart';

/// Menu page for all yard members.
/// Shows profile, settings, yard info, and other options.
/// Menu items are filtered based on user role.
class MenuPage extends StatefulWidget {
  const MenuPage({
    super.key,
    required this.yardId,
    this.userRole = YardRole.user,
  });

  final String yardId;
  final YardRole userRole;

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  final _supabase = Supabase.instance.client;
  final _authRepository = AuthRepository();
  bool _isLoggingOut = false;

  String? _fullName;
  String? _avatarUrl;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    try {
      final response = await _supabase
          .from('profiles')
          .select('full_name, avatar_url')
          .eq('user_id', userId)
          .maybeSingle();

      if (mounted && response != null) {
        setState(() {
          _fullName = response['full_name'] as String?;
          _avatarUrl = response['avatar_url'] as String?;
        });
      }
    } catch (e) {
      debugPrint('Error loading profile: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 600;

    // Constrain width on desktop
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Profile section
        _buildProfileSection(isDark),
        const SizedBox(height: 24),

        // Menu items
        _buildMenuSection('Account', [
          _MenuItem(
            icon: Icons.pets_outlined,
            label: 'Add Horse',
            onTap: () async {
              await showHorseDialog(context);
            },
          ),
          _MenuItem(
            icon: Icons.notifications_outlined,
            label: 'Notifications',
            onTap: () {
              SnackbarService.showInfo(context, 'Notifications coming soon');
            },
          ),
        ], isDark),
        const SizedBox(height: 16),

        _buildMenuSection('Yard', _buildYardMenuItems(isDark), isDark),
        const SizedBox(height: 16),

        _buildMenuSection('Support', [
          _MenuItem(
            icon: Icons.help_outline,
            label: 'Help & FAQ',
            onTap: () {
              SnackbarService.showInfo(context, 'Help coming soon');
            },
          ),
          _MenuItem(
            icon: Icons.chat_bubble_outline,
            label: 'Contact Support',
            onTap: () {
              SnackbarService.showInfo(context, 'Support contact coming soon');
            },
          ),
          _MenuItem(
            icon: Icons.description_outlined,
            label: 'Terms & Privacy',
            onTap: () {
              SnackbarService.showInfo(context, 'Terms coming soon');
            },
          ),
        ], isDark),
        const SizedBox(height: 24),

        // Sign out button
        _buildSignOutButton(isDark),
        const SizedBox(height: 16),

        // App version
        Center(
          child: Text(
            'Stallio v1.0.0',
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.white38 : Colors.black26,
            ),
          ),
        ),
        const SizedBox(height: 100),
      ],
    );

    if (isDesktop) {
      return SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: content,
          ),
        ),
      );
    }

    return SingleChildScrollView(child: content);
  }

  Widget _buildProfileSection(bool isDark) {
    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ProfilePage(yardId: widget.yardId)),
        );
        // Reload profile when returning
        _loadProfile();
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark
                ? Colors.white12
                : Colors.black.withValues(alpha: 0.08),
          ),
        ),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFFFD66B).withValues(alpha: 0.2),
                image: _avatarUrl != null
                    ? DecorationImage(
                        image: NetworkImage(_avatarUrl!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: _avatarUrl == null
                  ? const Icon(Icons.person, size: 24, color: Color(0xFFFFD66B))
                  : null,
            ),
            const SizedBox(width: 12),
            // Name
            Expanded(
              child: Text(
                _fullName ?? 'Set up your profile',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: _fullName != null
                      ? (isDark ? Colors.white : Colors.black87)
                      : (isDark ? Colors.white38 : Colors.black38),
                ),
              ),
            ),
            // Chevron
            Icon(
              Icons.chevron_right,
              color: isDark ? Colors.white38 : Colors.black26,
            ),
          ],
        ),
      ),
    );
  }

  /// Build yard menu items based on user role
  List<_MenuItem> _buildYardMenuItems(bool isDark) {
    final items = <_MenuItem>[];

    // People - visible to managers and owners only (they can invite)
    if (RoleService.canInvite(widget.userRole)) {
      items.add(
        _MenuItem(
          icon: Icons.people_outline,
          label: 'People',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => Scaffold(
                  extendBodyBehindAppBar: true,
                  appBar: AppBar(
                    title: const Text('People'),
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                  ),
                  body: GradientBackground(
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: PeoplePage(yardId: widget.yardId),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      );
    }

    // Manage Yard - only for owners
    if (RoleService.canManageYard(widget.userRole)) {
      items.add(
        _MenuItem(
          icon: Icons.business_outlined,
          label: 'Manage Yard',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => YardManagementPage(yardId: widget.yardId),
              ),
            );
          },
        ),
      );
    }

    // Report Issue - available to all
    items.add(
      _MenuItem(
        icon: Icons.report_problem_outlined,
        label: 'Report Issue',
        onTap: () {
          SnackbarService.showInfo(context, 'Issue reporting coming soon');
        },
      ),
    );

    // Yard Info - available to all (read-only view of yard details)
    items.add(
      _MenuItem(
        icon: Icons.info_outline,
        label: 'Yard Info',
        onTap: () {
          SnackbarService.showInfo(context, 'Yard info coming soon');
        },
      ),
    );

    return items;
  }

  Widget _buildMenuSection(String title, List<_MenuItem> items, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white38 : Colors.black38,
              letterSpacing: 0.5,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark
                  ? Colors.white12
                  : Colors.black.withValues(alpha: 0.08),
            ),
          ),
          child: Column(
            children: items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final isLast = index == items.length - 1;

              return Column(
                children: [
                  ListTile(
                    leading: Icon(
                      item.icon,
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                    title: Text(
                      item.label,
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    trailing: Icon(
                      Icons.chevron_right,
                      color: isDark ? Colors.white38 : Colors.black26,
                    ),
                    onTap: item.onTap,
                  ),
                  if (!isLast)
                    Divider(
                      height: 1,
                      indent: 56,
                      color: isDark
                          ? Colors.white12
                          : Colors.black.withValues(alpha: 0.08),
                    ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildSignOutButton(bool isDark) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: _isLoggingOut ? null : _handleSignOut,
        icon: _isLoggingOut
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Icon(Icons.logout, color: Colors.red[400]),
        label: Text('Sign Out', style: TextStyle(color: Colors.red[400])),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          side: BorderSide(color: Colors.red[400]!.withValues(alpha: 0.5)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Future<void> _handleSignOut() async {
    setState(() => _isLoggingOut = true);
    try {
      await _authRepository.signOut();
    } catch (e) {
      if (mounted) {
        SnackbarService.showError(context, 'Failed to sign out');
        setState(() => _isLoggingOut = false);
      }
    }
  }
}

class _MenuItem {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  _MenuItem({required this.icon, required this.label, required this.onTap});
}
