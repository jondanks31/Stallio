import 'package:flutter/material.dart';

import '../../../core/ui/app_nav_bar.dart';
import '../../../core/ui/feed_widgets.dart';
import '../../../core/ui/gradient_background.dart';
import '../../../core/ui/snackbar_service.dart';
import '../../../core/ui/yard_logo.dart';
import '../../auth/data/auth_repository.dart';
import '../../horses/data/horses_repository.dart';
import '../../people/data/people_repository.dart';
import '../../people/presentation/pages/people_page.dart';
import '../../shared/presentation/pages/calendar_page.dart';
import '../../shared/presentation/pages/feed_page.dart';
import '../../user/presentation/pages/billing_page.dart';
import '../../user/presentation/pages/menu_page.dart';
import '../../user/presentation/pages/my_horses_page.dart';
import '../../yard/presentation/pages/yard_management_page.dart';

/// Owner Dashboard - the main landing page after login for yard owners.
class OwnerDashboardPage extends StatefulWidget {
  const OwnerDashboardPage({super.key, required this.yardId});

  final String yardId;

  @override
  State<OwnerDashboardPage> createState() => _OwnerDashboardPageState();
}

class _OwnerDashboardPageState extends State<OwnerDashboardPage> {
  final _authRepository = AuthRepository();
  final _peopleRepository = PeopleRepository();
  final _horsesRepository = HorsesRepository();

  bool _isLoggingOut = false;
  int _selectedNavIndex = 0;

  // Stats
  int _memberCount = 0;
  int _horseCount = 0;
  int _pendingCount = 0;
  bool _statsLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    try {
      final counts = await _peopleRepository.getPeopleCounts(widget.yardId);
      final horses = await _horsesRepository.getHorsesInYard(widget.yardId);

      if (mounted) {
        setState(() {
          _memberCount = counts['active'] ?? 0;
          _horseCount = horses.length;
          _pendingCount = counts['invited'] ?? 0;
          _statsLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _statsLoading = false);
      }
    }
  }

  // Desktop nav - full menu
  // 0: Dashboard, 1: Feed, 2: People, 3: My Horses, 4: Calendar, 5: Billing, 6: Manage Yard
  static const _desktopNavItems = [
    NavItem(
      label: 'Dashboard',
      icon: Icons.dashboard_outlined,
      activeIcon: Icons.dashboard,
    ),
    NavItem(
      label: 'Feed',
      icon: Icons.dynamic_feed_outlined,
      activeIcon: Icons.dynamic_feed,
    ),
    NavItem(
      label: 'People',
      icon: Icons.people_outline,
      activeIcon: Icons.people,
    ),
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
    NavItem(
      label: 'Manage Yard',
      icon: Icons.business_outlined,
      activeIcon: Icons.business,
    ),
  ];

  // Mobile nav - key pages only (max 5 items)
  // 0: Home (Dashboard), 1: Feed, 2: Calendar, 3: Billing, 4: Menu
  static const _mobileNavItems = [
    NavItem(
      label: 'Home',
      icon: Icons.dashboard_outlined,
      activeIcon: Icons.dashboard,
    ),
    NavItem(
      label: 'Feed',
      icon: Icons.dynamic_feed_outlined,
      activeIcon: Icons.dynamic_feed,
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
                  left:
                      isDesktop &&
                          (_selectedNavIndex == 1 || _selectedNavIndex == 4)
                      ? 0
                      : 24,
                  right:
                      isDesktop &&
                          (_selectedNavIndex == 1 || _selectedNavIndex == 4)
                      ? 0
                      : 24,
                  bottom: 24,
                ),
                child: _buildSelectedPage(isDesktop),
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
                  onItemTapped: (index) {
                    setState(() => _selectedNavIndex = index);
                    // Refresh stats when returning to dashboard
                    if (index == 0) _loadStats();
                  },
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
            onItemTapped: (index) {
              setState(() => _selectedNavIndex = index);
              // Refresh stats when returning to dashboard
              if (index == 0) _loadStats();
            },
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
            if (value == 'signout') _signOut();
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'profile',
              child: Row(
                children: [
                  Icon(Icons.person_outline, size: 20),
                  SizedBox(width: 12),
                  Text('Profile'),
                ],
              ),
            ),
            const PopupMenuDivider(),
            PopupMenuItem(
              value: 'signout',
              child: Row(
                children: [
                  Icon(
                    Icons.logout,
                    size: 20,
                    color: _isLoggingOut ? Colors.grey : null,
                  ),
                  const SizedBox(width: 12),
                  Text(_isLoggingOut ? 'Signing out...' : 'Sign out'),
                ],
              ),
            ),
          ],
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFFFFD66B),
              borderRadius: BorderRadius.circular(999),
            ),
            child: const Icon(Icons.person, size: 18, color: Colors.black87),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileMenu() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return PopupMenuButton<String>(
      icon: Icon(Icons.menu, color: isDark ? Colors.white70 : Colors.black54),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      offset: const Offset(0, 48),
      onSelected: (value) {
        switch (value) {
          case 'manage_yard':
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => YardManagementPage(yardId: widget.yardId),
              ),
            );
            break;
          case 'settings':
            SnackbarService.showInfo(context, 'Settings coming soon!');
            break;
          case 'signout':
            _signOut();
            break;
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'manage_yard',
          child: Row(
            children: [
              Icon(Icons.business_outlined, size: 20),
              SizedBox(width: 12),
              Text('Manage Yard'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'settings',
          child: Row(
            children: [
              Icon(Icons.settings_outlined, size: 20),
              SizedBox(width: 12),
              Text('Settings'),
            ],
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem(
          value: 'signout',
          child: Row(
            children: [
              Icon(
                Icons.logout,
                size: 20,
                color: _isLoggingOut ? Colors.grey : null,
              ),
              const SizedBox(width: 12),
              Text(_isLoggingOut ? 'Signing out...' : 'Sign out'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSelectedPage(bool isDesktop) {
    // Desktop: 0=Dashboard, 1=Feed, 2=People, 3=My Horses, 4=Calendar, 5=Billing, 6=Manage Yard
    // Mobile: 0=Home(Dashboard), 1=Feed, 2=Calendar, 3=Billing, 4=Menu
    if (isDesktop) {
      switch (_selectedNavIndex) {
        case 0:
          return _buildDashboardContent(); // Owner's dashboard with welcome + stats
        case 1:
          return FeedPage(yardId: widget.yardId, showWelcomeHeader: false);
        case 2:
          return PeoplePage(yardId: widget.yardId);
        case 3:
          return MyHorsesPage(yardId: widget.yardId);
        case 4:
          return CalendarPage(yardId: widget.yardId);
        case 5:
          return BillingPage(yardId: widget.yardId);
        case 6:
          return YardManagementPage(yardId: widget.yardId);
        default:
          return _buildDashboardContent();
      }
    } else {
      switch (_selectedNavIndex) {
        case 0:
          return _buildDashboardContent(); // Owner's dashboard with welcome + stats
        case 1:
          return FeedPage(yardId: widget.yardId, showWelcomeHeader: false);
        case 2:
          return CalendarPage(yardId: widget.yardId);
        case 3:
          return BillingPage(yardId: widget.yardId);
        case 4:
          return MenuPage(yardId: widget.yardId);
        default:
          return _buildDashboardContent();
      }
    }
  }

  /// Owner's Dashboard page with welcome header, weather, and quick stats.
  Widget _buildDashboardContent() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isDesktop = MediaQuery.of(context).size.width > 600;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Mobile header
          if (!isDesktop) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                YardLogo(yardId: widget.yardId),
                Row(
                  children: [
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.notifications_outlined),
                      style: IconButton.styleFrom(
                        foregroundColor: isDark
                            ? Colors.white70
                            : Colors.black54,
                      ),
                    ),
                    _buildMobileMenu(),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
          // Welcome header with greeting and weather
          const WelcomeHeader(subtitle: 'Here\'s your yard overview'),
          const SizedBox(height: 24),
          // Quick stats section
          _buildQuickStats(isDark),
          const SizedBox(height: 24),
          // Recent activity or other dashboard content
          _buildRecentActivity(isDark),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildQuickStats(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          title: 'Quick Stats',
          icon: Icons.analytics_outlined,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Members',
                _statsLoading ? '--' : '$_memberCount',
                Icons.people,
                isDark,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Horses',
                _statsLoading ? '--' : '$_horseCount',
                Icons.pets,
                isDark,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Pending',
                _statsLoading ? '--' : '$_pendingCount',
                Icons.pending_actions,
                isDark,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.white12 : Colors.black.withValues(alpha: 0.08),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 24, color: const Color(0xFFFFD66B)),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.white54 : Colors.black45,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivity(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Recent Activity', icon: Icons.history),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark
                  ? Colors.white12
                  : Colors.black.withValues(alpha: 0.08),
            ),
          ),
          child: Center(
            child: Column(
              children: [
                Icon(
                  Icons.inbox_outlined,
                  size: 48,
                  color: isDark ? Colors.white24 : Colors.black12,
                ),
                const SizedBox(height: 16),
                Text(
                  'No recent activity',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white54 : Colors.black45,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Activity from your yard will appear here',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.white38 : Colors.black26,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
