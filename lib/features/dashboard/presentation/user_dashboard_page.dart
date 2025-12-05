import 'package:flutter/material.dart';

import '../../../core/ui/app_nav_bar.dart';
import '../../people/data/people_repository.dart';
import '../../../core/ui/gradient_background.dart';
import '../../../core/ui/snackbar_service.dart';
import '../../../core/ui/yard_logo.dart';
import '../../auth/data/auth_repository.dart';
import '../../shared/presentation/pages/calendar_page.dart';
import '../../shared/presentation/pages/feed_page.dart';
import '../../user/presentation/pages/billing_page.dart';
import '../../user/presentation/pages/menu_page.dart';
import '../../user/presentation/pages/my_horses_page.dart';

/// User Dashboard - the main landing page for regular yard members (not owners/managers).
/// Uses the same navigation pattern as OwnerDashboardPage for brand consistency.
class UserDashboardPage extends StatefulWidget {
  const UserDashboardPage({super.key, required this.yardId});

  final String yardId;

  @override
  State<UserDashboardPage> createState() => _UserDashboardPageState();
}

class _UserDashboardPageState extends State<UserDashboardPage> {
  final _authRepository = AuthRepository();
  bool _isLoggingOut = false;
  int _selectedNavIndex = 0;

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
          onPressed: () {},
          icon: const Icon(Icons.notifications_outlined, size: 20),
          style: IconButton.styleFrom(foregroundColor: Colors.black54),
        ),
        const SizedBox(width: 4),
        PopupMenuButton<String>(
          offset: const Offset(0, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          onSelected: (value) {
            switch (value) {
              case 'profile':
                SnackbarService.showInfo(context, 'Profile coming soon');
                break;
              case 'horses':
                SnackbarService.showInfo(
                  context,
                  'Horse management coming soon',
                );
                break;
              case 'notifications':
                SnackbarService.showInfo(context, 'Notifications coming soon');
                break;
              case 'yard_info':
                SnackbarService.showInfo(context, 'Yard info coming soon');
                break;
              case 'yard_members':
                SnackbarService.showInfo(context, 'Members list coming soon');
                break;
              case 'report_issue':
                SnackbarService.showInfo(
                  context,
                  'Issue reporting coming soon',
                );
                break;
              case 'help':
                SnackbarService.showInfo(context, 'Help coming soon');
                break;
              case 'contact':
                SnackbarService.showInfo(
                  context,
                  'Support contact coming soon',
                );
                break;
              case 'terms':
                SnackbarService.showInfo(context, 'Terms coming soon');
                break;
              case 'signout':
                _signOut();
                break;
            }
          },
          itemBuilder: (context) => [
            // Account section
            const PopupMenuItem(
              enabled: false,
              height: 32,
              child: Text(
                'Account',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                ),
              ),
            ),
            const PopupMenuItem(
              value: 'profile',
              child: Row(
                children: [
                  Icon(Icons.person_outline, size: 20),
                  SizedBox(width: 12),
                  Text('My Profile'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'horses',
              child: Row(
                children: [
                  Icon(Icons.pets_outlined, size: 20),
                  SizedBox(width: 12),
                  Text('My Horses'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'notifications',
              child: Row(
                children: [
                  Icon(Icons.notifications_outlined, size: 20),
                  SizedBox(width: 12),
                  Text('Notifications'),
                ],
              ),
            ),
            const PopupMenuDivider(),
            // Yard section
            const PopupMenuItem(
              enabled: false,
              height: 32,
              child: Text(
                'Yard',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                ),
              ),
            ),
            const PopupMenuItem(
              value: 'yard_info',
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 20),
                  SizedBox(width: 12),
                  Text('Yard Info'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'yard_members',
              child: Row(
                children: [
                  Icon(Icons.people_outline, size: 20),
                  SizedBox(width: 12),
                  Text('Yard Members'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'report_issue',
              child: Row(
                children: [
                  Icon(Icons.report_problem_outlined, size: 20),
                  SizedBox(width: 12),
                  Text('Report Issue'),
                ],
              ),
            ),
            const PopupMenuDivider(),
            // Support section
            const PopupMenuItem(
              enabled: false,
              height: 32,
              child: Text(
                'Support',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                ),
              ),
            ),
            const PopupMenuItem(
              value: 'help',
              child: Row(
                children: [
                  Icon(Icons.help_outline, size: 20),
                  SizedBox(width: 12),
                  Text('Help & FAQ'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'contact',
              child: Row(
                children: [
                  Icon(Icons.chat_bubble_outline, size: 20),
                  SizedBox(width: 12),
                  Text('Contact Support'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'terms',
              child: Row(
                children: [
                  Icon(Icons.description_outlined, size: 20),
                  SizedBox(width: 12),
                  Text('Terms & Privacy'),
                ],
              ),
            ),
            const PopupMenuDivider(),
            PopupMenuItem(
              value: 'signout',
              child: Row(
                children: [
                  Icon(Icons.logout, size: 20, color: Colors.redAccent),
                  SizedBox(width: 12),
                  Text('Sign out', style: TextStyle(color: Colors.redAccent)),
                ],
              ),
            ),
          ],
          child: _isLoggingOut
              ? const SizedBox(
                  width: 32,
                  height: 32,
                  child: Padding(
                    padding: EdgeInsets.all(6),
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              : Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFFFFD66B),
                  ),
                  child: const Icon(
                    Icons.person,
                    size: 18,
                    color: Colors.black87,
                  ),
                ),
        ),
      ],
    );
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
