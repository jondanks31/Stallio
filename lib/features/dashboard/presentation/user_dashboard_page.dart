import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/ui/app_nav_bar.dart';
import '../../people/data/people_repository.dart';
import '../../../core/ui/gradient_background.dart';
import '../../../core/ui/snackbar_service.dart';
import '../../../core/ui/yard_logo.dart';
import '../../auth/data/auth_repository.dart';
import '../../horses/presentation/dialogs/horse_dialog.dart';
import '../../shared/presentation/pages/calendar_page.dart';
import '../../shared/presentation/pages/feed_page.dart';
import '../../user/presentation/pages/billing_page.dart';
import '../../user/presentation/pages/menu_page.dart';
import '../../user/presentation/pages/my_horses_page.dart';
import '../../user/presentation/pages/profile_page.dart';

/// User Dashboard - the main landing page for regular yard members (not owners/managers).
/// Uses the same navigation pattern as OwnerDashboardPage for brand consistency.
class UserDashboardPage extends StatefulWidget {
  const UserDashboardPage({super.key, required this.yardId});

  final String yardId;

  @override
  State<UserDashboardPage> createState() => _UserDashboardPageState();
}

class _UserDashboardPageState extends State<UserDashboardPage> {
  final _supabase = Supabase.instance.client;
  final _authRepository = AuthRepository();
  bool _isLoggingOut = false;
  int _selectedNavIndex = 0;

  // Profile data for user menu
  String? _userName;
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
          _userName = response['full_name'] as String?;
          _avatarUrl = response['avatar_url'] as String?;
        });
      }
    } catch (e) {
      debugPrint('Error loading profile: $e');
    }
  }

  // Desktop nav - full menu
  static const _desktopNavItems = [
    NavItem(label: 'Home', icon: Icons.home_outlined, activeIcon: Icons.home),
    NavItem(
      label: 'My Horses',
      icon: Icons.pets_outlined,
      activeIcon: Icons.pets,
    ),
    NavItem(
      label: 'Calendar',
      icon: Icons.calendar_today_outlined,
      activeIcon: Icons.calendar_today,
    ),
    NavItem(
      label: 'Billing',
      icon: Icons.receipt_long_outlined,
      activeIcon: Icons.receipt_long,
    ),
  ];

  // Mobile nav - includes Menu for settings access
  static const _mobileNavItems = [
    NavItem(label: 'Home', icon: Icons.home_outlined, activeIcon: Icons.home),
    NavItem(label: 'Horses', icon: Icons.pets_outlined, activeIcon: Icons.pets),
    NavItem(
      label: 'Calendar',
      icon: Icons.calendar_today_outlined,
      activeIcon: Icons.calendar_today,
    ),
    NavItem(
      label: 'Billing',
      icon: Icons.receipt_long_outlined,
      activeIcon: Icons.receipt_long,
    ),
    NavItem(label: 'Menu', icon: Icons.menu, activeIcon: Icons.menu),
  ];

  Future<void> _signOut() async {
    setState(() => _isLoggingOut = true);

    try {
      await _authRepository.signOut();
    } catch (e) {
      if (mounted) {
        SnackbarService.showError(
          context,
          'Failed to sign out. Please try again.',
        );
        setState(() => _isLoggingOut = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 600;

    return Scaffold(
      body: GradientBackground(
        child: Stack(
          children: [
            // Main content with SafeArea
            SafeArea(
              bottom: false, // Don't add bottom padding - nav bar floats over
              child: Padding(
                padding: EdgeInsets.only(
                  top: isDesktop ? 80 : 24,
                  left: 24,
                  right: 24,
                  bottom: 24,
                ),
                child: _buildSelectedPage(),
              ),
            ),
            // Desktop: Top nav bar
            if (isDesktop)
              Positioned(
                top: MediaQuery.of(context).padding.top + 16,
                left: 0,
                right: 0,
                child: _buildDesktopHeader(),
              ),
            // Mobile: Bottom floating nav bar
            if (!isDesktop)
              Positioned(
                bottom: MediaQuery.of(context).padding.bottom + 24,
                left: 0,
                right: 0,
                child: AppNavBar(
                  items: _mobileNavItems,
                  selectedIndex: _selectedNavIndex < _mobileNavItems.length
                      ? _selectedNavIndex
                      : 0,
                  onItemTapped: (index) =>
                      setState(() => _selectedNavIndex = index),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          // Logo - uses yard's custom branding if set
          YardLogo(yardId: widget.yardId),
          const Spacer(),
          // Nav bar
          AppNavBar(
            items: _desktopNavItems,
            selectedIndex: _selectedNavIndex,
            onItemTapped: (index) => setState(() => _selectedNavIndex = index),
            trailing: _buildUserMenu(),
          ),
        ],
      ),
    );
  }

  Widget _buildUserMenu() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: () {
            SnackbarService.showInfo(context, 'Notifications coming soon');
          },
          icon: const Icon(Icons.notifications_outlined, size: 20),
          style: IconButton.styleFrom(foregroundColor: Colors.black54),
        ),
        const SizedBox(width: 4),
        PopupMenuButton<String>(
          offset: const Offset(0, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          color: Colors.white,
          surfaceTintColor: Colors.transparent,
          constraints: const BoxConstraints(minWidth: 220),
          onSelected: _handleMenuAction,
          itemBuilder: (context) => [
            // Profile header
            PopupMenuItem(
              enabled: false,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
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
                        ? const Icon(
                            Icons.person,
                            size: 20,
                            color: Color(0xFFFFD66B),
                          )
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _userName ?? 'Set up profile',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: _userName != null
                                ? Colors.black87
                                : Colors.black38,
                          ),
                        ),
                        const Text(
                          'Member',
                          style: TextStyle(fontSize: 12, color: Colors.black45),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const PopupMenuDivider(),

            // Account section
            _buildMenuHeader('Account'),
            _buildMenuItem('profile', Icons.person_outline, 'My Profile'),
            _buildMenuItem('add_horse', Icons.pets_outlined, 'Add Horse'),
            _buildMenuItem(
              'notifications',
              Icons.notifications_outlined,
              'Notifications',
            ),
            const PopupMenuDivider(),

            // Yard section
            _buildMenuHeader('Yard'),
            _buildMenuItem('yard_info', Icons.info_outline, 'Yard Info'),
            _buildMenuItem(
              'report_issue',
              Icons.report_problem_outlined,
              'Report Issue',
            ),
            const PopupMenuDivider(),

            // Support section
            _buildMenuHeader('Support'),
            _buildMenuItem('help', Icons.help_outline, 'Help & FAQ'),
            _buildMenuItem(
              'contact',
              Icons.chat_bubble_outline,
              'Contact Support',
            ),
            _buildMenuItem(
              'terms',
              Icons.description_outlined,
              'Terms & Privacy',
            ),
            const PopupMenuDivider(),

            // Sign out
            PopupMenuItem(
              value: 'signout',
              child: Row(
                children: [
                  Icon(
                    Icons.logout,
                    size: 20,
                    color: _isLoggingOut ? Colors.grey : Colors.red.shade400,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    _isLoggingOut ? 'Signing out...' : 'Sign out',
                    style: TextStyle(
                      color: _isLoggingOut ? Colors.grey : Colors.red.shade400,
                    ),
                  ),
                ],
              ),
            ),
          ],
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFFFD66B),
              borderRadius: BorderRadius.circular(999),
              image: _avatarUrl != null
                  ? DecorationImage(
                      image: NetworkImage(_avatarUrl!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: _avatarUrl == null
                ? const Icon(Icons.person, size: 20, color: Colors.black87)
                : null,
          ),
        ),
      ],
    );
  }

  PopupMenuItem<String> _buildMenuItem(
    String value,
    IconData icon,
    String label,
  ) {
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.black54),
          const SizedBox(width: 12),
          Text(label),
        ],
      ),
    );
  }

  PopupMenuItem<String> _buildMenuHeader(String title) {
    return PopupMenuItem(
      enabled: false,
      height: 32,
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.black38,
        ),
      ),
    );
  }

  void _handleMenuAction(String value) {
    switch (value) {
      case 'profile':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ProfilePage(yardId: widget.yardId)),
        ).then((_) => _loadProfile());
        break;
      case 'add_horse':
        showHorseDialog(context).then((result) {
          if (result != null && mounted) {
            SnackbarService.showSuccess(context, 'Horse added!');
          }
        });
        break;
      case 'notifications':
        SnackbarService.showInfo(context, 'Notifications coming soon');
        break;
      case 'yard_info':
        SnackbarService.showInfo(context, 'Yard info coming soon');
        break;
      case 'report_issue':
        SnackbarService.showInfo(context, 'Issue reporting coming soon');
        break;
      case 'help':
        SnackbarService.showInfo(context, 'Help coming soon');
        break;
      case 'contact':
        SnackbarService.showInfo(context, 'Support contact coming soon');
        break;
      case 'terms':
        SnackbarService.showInfo(context, 'Terms coming soon');
        break;
      case 'signout':
        _signOut();
        break;
    }
  }

  Widget _buildSelectedPage() {
    switch (_selectedNavIndex) {
      case 0:
        // User's "Home" is the feed with welcome header
        return FeedPage(yardId: widget.yardId, showWelcomeHeader: true);
      case 1:
        return MyHorsesPage(yardId: widget.yardId);
      case 2:
        return CalendarPage(yardId: widget.yardId);
      case 3:
        return BillingPage(yardId: widget.yardId);
      case 4:
        return MenuPage(yardId: widget.yardId, userRole: YardRole.user);
      default:
        return FeedPage(yardId: widget.yardId, showWelcomeHeader: true);
    }
  }
}
