import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/ui/app_nav_bar.dart';
import '../../../core/ui/feed_widgets.dart';
import '../../../core/ui/gradient_background.dart';
import '../../../core/ui/operations_sidebar.dart';
import '../../../core/ui/snackbar_service.dart';
import '../../../core/ui/yard_logo.dart';
import '../../auth/data/auth_repository.dart';
import '../../horses/data/horses_repository.dart';
import '../../people/data/people_repository.dart';
import '../../people/presentation/pages/people_page.dart';
import '../../shared/presentation/pages/calendar_page.dart';
import '../../shared/presentation/pages/feed_page.dart';
import '../../staff/presentation/pages/issues_page.dart';
import '../../staff/presentation/pages/tasks_page.dart';
import '../../staff/presentation/widgets/quick_log_sheet.dart';
import '../../user/data/billing_repository.dart';
import '../../user/presentation/pages/my_horses_page.dart';
import '../../yard/presentation/pages/yard_management_page.dart';
import 'owner_billing_page.dart';

/// Helper class for menu items
class _MenuItemData {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  _MenuItemData(this.icon, this.label, this.onTap);
}

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
  final _billingRepository = BillingRepository();

  bool _isLoggingOut = false;

  // Stats
  int _memberCount = 0;
  int _horseCount = 0;
  int _pendingCount = 0;
  bool _statsLoading = true;

  // Recent activity
  List<ConsumableCharge> _recentActivity = [];
  bool _activityLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
    _loadRecentActivity();
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

  Future<void> _loadRecentActivity() async {
    debugPrint(
      'OwnerDashboard: loading recent activity for yard ${widget.yardId}',
    );
    try {
      final activity = await _billingRepository.getRecentActivity(
        widget.yardId,
      );
      debugPrint('OwnerDashboard: got ${activity.length} activity items');
      if (mounted) {
        setState(() {
          _recentActivity = activity;
          _activityLoading = false;
        });
      }
    } catch (e) {
      debugPrint('OwnerDashboard activity error: $e');
      if (mounted) {
        setState(() => _activityLoading = false);
      }
    }
  }

  // === DESKTOP NAVIGATION ===
  // Top bar: Personal items (Feed, My Horses, Calendar)
  static const _desktopPersonalNavItems = [
    NavItem(
      label: 'Feed',
      icon: Icons.dynamic_feed_outlined,
      activeIcon: Icons.dynamic_feed,
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
  ];

  // Sidebar: Operations items
  static const _desktopOpsNavItems = [
    NavItem(
      label: 'Dashboard',
      icon: Icons.dashboard_outlined,
      activeIcon: Icons.dashboard,
    ),
    NavItem(
      label: 'People',
      icon: Icons.people_outline,
      activeIcon: Icons.people,
    ),
    NavItem(
      label: 'Tasks',
      icon: Icons.task_alt_outlined,
      activeIcon: Icons.task_alt,
    ),
    NavItem(
      label: 'Billing',
      icon: Icons.receipt_long_outlined,
      activeIcon: Icons.receipt_long,
    ),
  ];

  // Sidebar bottom: Management items
  static const _desktopOpsBottomItems = [
    NavItem(
      label: 'Issues',
      icon: Icons.warning_amber_outlined,
      activeIcon: Icons.warning_amber,
    ),
    NavItem(
      label: 'Manage Yard',
      icon: Icons.settings_outlined,
      activeIcon: Icons.settings,
    ),
  ];

  // === MOBILE NAVIGATION ===
  // Bottom bar: Operations (4 main + Menu)
  static const _mobileNavItems = [
    NavItem(
      label: 'Dash',
      icon: Icons.dashboard_outlined,
      activeIcon: Icons.dashboard,
    ),
    NavItem(
      label: 'People',
      icon: Icons.people_outline,
      activeIcon: Icons.people,
    ),
    NavItem(
      label: 'Tasks',
      icon: Icons.task_alt_outlined,
      activeIcon: Icons.task_alt,
    ),
    NavItem(
      label: 'Billing',
      icon: Icons.receipt_long_outlined,
      activeIcon: Icons.receipt_long,
    ),
    NavItem(label: 'Menu', icon: Icons.menu, activeIcon: Icons.menu),
  ];

  // Track which nav is active
  int _selectedOpsIndex = 0; // Operations sidebar
  int _selectedPersonalIndex = -1; // Personal top nav (-1 = none, showing ops)
  int _selectedOpsBottomIndex = -1; // Ops bottom section

  void _openQuickLog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => QuickLogSheet(
        yardId: widget.yardId,
        onLogComplete: () {
          SnackbarService.showSuccess(context, 'Logs saved successfully');
        },
      ),
    );
  }

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
        child: SafeArea(
          bottom: false,
          child: isDesktop ? _buildDesktopLayout() : _buildMobileLayout(),
        ),
      ),
    );
  }

  // ============ DESKTOP LAYOUT ============
  Widget _buildDesktopLayout() {
    return Stack(
      children: [
        Row(
          children: [
            // Left sidebar for operations (icon-only with tooltips)
            Padding(
              padding: const EdgeInsets.only(left: 16, top: 80, bottom: 24),
              child: OperationsSidebar(
                items: _desktopOpsNavItems,
                selectedIndex: _selectedPersonalIndex == -1
                    ? _selectedOpsIndex
                    : -1,
                onItemTapped: (index) {
                  setState(() {
                    _selectedOpsIndex = index;
                    _selectedPersonalIndex = -1;
                    _selectedOpsBottomIndex = -1;
                  });
                  if (index == 0) _loadStats();
                },
                bottomItems: _desktopOpsBottomItems,
                selectedBottomIndex: _selectedOpsBottomIndex,
                onBottomItemTapped: (index) {
                  setState(() {
                    _selectedOpsBottomIndex = index;
                    _selectedOpsIndex = -1;
                    _selectedPersonalIndex = -1;
                  });
                },
              ),
            ),
            // Main content area
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(
                  top: 80,
                  left: 24,
                  right: 24,
                  bottom: 24,
                ),
                child: _buildSelectedPage(),
              ),
            ),
          ],
        ),
        // Top header bar
        Positioned(top: 16, left: 0, right: 0, child: _buildDesktopHeader()),
        // Quick Log FAB
        if (_selectedOpsIndex == 0 &&
            _selectedPersonalIndex == -1 &&
            _selectedOpsBottomIndex == -1)
          Positioned(
            bottom: 24,
            right: 24,
            child: FloatingActionButton(
              onPressed: _openQuickLog,
              backgroundColor: const Color(0xFFFFD66B),
              foregroundColor: Colors.black87,
              elevation: 4,
              child: const Icon(Icons.add, size: 28),
            ),
          ),
      ],
    );
  }

  Widget _buildDesktopHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          // Logo
          YardLogo(yardId: widget.yardId),
          const Spacer(),
          // Personal nav bar (Feed, My Horses, Calendar)
          AppNavBar(
            items: _desktopPersonalNavItems,
            selectedIndex: _selectedPersonalIndex,
            onItemTapped: (index) {
              setState(() {
                _selectedPersonalIndex = index;
                _selectedOpsIndex = -1;
                _selectedOpsBottomIndex = -1;
              });
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

  // ============ MOBILE LAYOUT ============
  Widget _buildMobileLayout() {
    return Stack(
      children: [
        // Main content
        Padding(
          padding: const EdgeInsets.only(
            top: 24,
            left: 24,
            right: 24,
            bottom: 24,
          ),
          child: _buildSelectedPage(),
        ),
        // Bottom nav bar
        Positioned(
          bottom: MediaQuery.of(context).padding.bottom + 24,
          left: 0,
          right: 0,
          child: AppNavBar(
            items: _mobileNavItems,
            selectedIndex: _selectedOpsIndex,
            onItemTapped: (index) {
              if (index == 4) {
                // Menu - show menu page
                _showMobileMenu();
              } else {
                setState(() {
                  _selectedOpsIndex = index;
                  _selectedPersonalIndex = -1;
                  _selectedOpsBottomIndex = -1;
                });
                if (index == 0) _loadStats();
              }
            },
          ),
        ),
        // Quick Log FAB
        if (_selectedOpsIndex == 0 && _selectedPersonalIndex == -1)
          Positioned(
            bottom: MediaQuery.of(context).padding.bottom + 100,
            right: 24,
            child: FloatingActionButton(
              onPressed: _openQuickLog,
              backgroundColor: const Color(0xFFFFD66B),
              foregroundColor: Colors.black87,
              elevation: 4,
              child: const Icon(Icons.add, size: 28),
            ),
          ),
      ],
    );
  }

  void _showMobileMenu() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Handle
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white24 : Colors.black12,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Operations section
              _buildMenuSection('OPERATIONS', [
                _MenuItemData(Icons.warning_amber_outlined, 'Issues', () {
                  Navigator.pop(context);
                  setState(() {
                    _selectedOpsBottomIndex = 0;
                    _selectedOpsIndex = -1;
                    _selectedPersonalIndex = -1;
                  });
                }),
                _MenuItemData(Icons.settings_outlined, 'Manage Yard', () {
                  Navigator.pop(context);
                  setState(() {
                    _selectedOpsBottomIndex = 1;
                    _selectedOpsIndex = -1;
                    _selectedPersonalIndex = -1;
                  });
                }),
              ], isDark),
              const SizedBox(height: 8),
              Divider(
                color: isDark ? Colors.white12 : Colors.black12,
                indent: 16,
                endIndent: 16,
              ),
              const SizedBox(height: 8),
              // Personal section
              _buildMenuSection('PERSONAL', [
                _MenuItemData(Icons.dynamic_feed_outlined, 'Feed', () {
                  Navigator.pop(context);
                  setState(() {
                    _selectedPersonalIndex = 0;
                    _selectedOpsIndex = -1;
                    _selectedOpsBottomIndex = -1;
                  });
                }),
                _MenuItemData(Icons.pets_outlined, 'My Horses', () {
                  Navigator.pop(context);
                  setState(() {
                    _selectedPersonalIndex = 1;
                    _selectedOpsIndex = -1;
                    _selectedOpsBottomIndex = -1;
                  });
                }),
                _MenuItemData(Icons.calendar_today_outlined, 'Calendar', () {
                  Navigator.pop(context);
                  setState(() {
                    _selectedPersonalIndex = 2;
                    _selectedOpsIndex = -1;
                    _selectedOpsBottomIndex = -1;
                  });
                }),
              ], isDark),
              const SizedBox(height: 8),
              Divider(
                color: isDark ? Colors.white12 : Colors.black12,
                indent: 16,
                endIndent: 16,
              ),
              const SizedBox(height: 8),
              // Sign out
              _buildMenuItem(
                Icons.logout,
                'Sign Out',
                _signOut,
                isDark,
                isDestructive: true,
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuSection(
    String title,
    List<_MenuItemData> items,
    bool isDark,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 1,
              color: isDark ? Colors.white38 : Colors.black38,
            ),
          ),
        ),
        ...items.map(
          (item) => _buildMenuItem(item.icon, item.label, item.onTap, isDark),
        ),
      ],
    );
  }

  Widget _buildMenuItem(
    IconData icon,
    String label,
    VoidCallback onTap,
    bool isDark, {
    bool isDestructive = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Row(
            children: [
              Icon(
                icon,
                size: 22,
                color: isDestructive
                    ? Colors.red
                    : (isDark ? Colors.white70 : Colors.black54),
              ),
              const SizedBox(width: 16),
              Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: isDestructive
                      ? Colors.red
                      : (isDark ? Colors.white : Colors.black87),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============ PAGE ROUTING ============
  Widget _buildSelectedPage() {
    // Personal pages (top nav on desktop, menu on mobile)
    if (_selectedPersonalIndex >= 0) {
      switch (_selectedPersonalIndex) {
        case 0:
          return FeedPage(yardId: widget.yardId, showWelcomeHeader: false);
        case 1:
          return MyHorsesPage(yardId: widget.yardId);
        case 2:
          return CalendarPage(yardId: widget.yardId);
      }
    }

    // Operations bottom section (Issues, Manage Yard)
    if (_selectedOpsBottomIndex >= 0) {
      switch (_selectedOpsBottomIndex) {
        case 0:
          return IssuesPage(yardId: widget.yardId);
        case 1:
          return YardManagementPage(yardId: widget.yardId);
      }
    }

    // Operations main section (Dashboard, People, Tasks, Billing)
    switch (_selectedOpsIndex) {
      case 0:
        return _buildDashboardContent();
      case 1:
        return PeoplePage(yardId: widget.yardId);
      case 2:
        return TasksPage(yardId: widget.yardId);
      case 3:
        return OwnerBillingPage(yardId: widget.yardId);
      default:
        return _buildDashboardContent();
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
                    IconButton(
                      onPressed: _showMobileMenu,
                      icon: Icon(
                        Icons.more_vert,
                        color: isDark ? Colors.white70 : Colors.black54,
                      ),
                    ),
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
        if (_activityLoading)
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark
                    ? Colors.white12
                    : Colors.black.withValues(alpha: 0.08),
              ),
            ),
            child: const Center(child: CircularProgressIndicator()),
          )
        else if (_recentActivity.isEmpty)
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.white,
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
          )
        else
          Container(
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark
                    ? Colors.white12
                    : Colors.black.withValues(alpha: 0.08),
              ),
            ),
            child: Column(
              children: _recentActivity.take(10).map((activity) {
                return _buildActivityItem(activity, isDark);
              }).toList(),
            ),
          ),
      ],
    );
  }

  Widget _buildActivityItem(ConsumableCharge activity, bool isDark) {
    final timeAgo = _formatTimeAgo(activity.loggedAt);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isDark
                ? Colors.white12
                : Colors.black.withValues(alpha: 0.05),
          ),
        ),
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFFFD66B).withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.inventory_2_outlined,
              size: 18,
              color: Color(0xFFFFD66B),
            ),
          ),
          const SizedBox(width: 12),
          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${activity.horseName} - ${activity.consumableName}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${activity.quantity.toStringAsFixed(1)} ${activity.unit} by ${activity.loggedByName ?? 'Unknown'}',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white54 : Colors.black45,
                  ),
                ),
              ],
            ),
          ),
          // Time and cost
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '£${activity.totalCost.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              Text(
                timeAgo,
                style: TextStyle(
                  fontSize: 11,
                  color: isDark ? Colors.white38 : Colors.black38,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';

    return DateFormat('d MMM').format(dateTime);
  }
}
