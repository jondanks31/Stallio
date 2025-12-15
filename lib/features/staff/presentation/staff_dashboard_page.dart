import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/ui/app_nav_bar.dart';
import '../../../core/ui/gradient_background.dart';
import '../../../core/ui/snackbar_service.dart';
import '../../../core/ui/yard_logo.dart';
import '../../auth/data/auth_repository.dart';
import '../../user/presentation/pages/my_horses_page.dart';
import '../../people/data/people_repository.dart';
import '../../shared/presentation/pages/calendar_page.dart';
import '../../shared/presentation/pages/feed_page.dart';
import '../../user/presentation/pages/menu_page.dart';
import '../../user/presentation/pages/profile_page.dart';
import '../data/consumable_logs_repository.dart';
import '../data/work_list_repository.dart';
import 'pages/work_list_page.dart';
import 'widgets/quick_log_sheet.dart';

/// Staff Dashboard - the main landing page for staff and managers.
/// Focused on operational tasks: logging consumables, managing tasks, viewing issues.
class StaffDashboardPage extends StatefulWidget {
  const StaffDashboardPage({
    super.key,
    required this.yardId,
    this.userRole = YardRole.staff,
  });

  final String yardId;
  final YardRole userRole;

  @override
  State<StaffDashboardPage> createState() => _StaffDashboardPageState();
}

class _StaffDashboardPageState extends State<StaffDashboardPage> {
  final _supabase = Supabase.instance.client;
  final _authRepository = AuthRepository();
  final _logsRepository = ConsumableLogsRepository();
  final _workListRepository = WorkListRepository();

  bool _isLoggingOut = false;
  int _selectedNavIndex = 0;

  // Profile data for user menu
  String? _userName;
  String? _avatarUrl;

  // Dashboard stats
  int _workItemCount = 0;
  int _urgentCount = 0;
  int _todayLogCount = 0;
  bool _isLoadingStats = true;

  // Desktop nav items - unified Work List replaces Tasks + Issues
  static const _desktopNavItems = [
    NavItem(
      label: 'Dashboard',
      icon: Icons.dashboard_outlined,
      activeIcon: Icons.dashboard,
    ),
    NavItem(
      label: 'Work List',
      icon: Icons.checklist_outlined,
      activeIcon: Icons.checklist,
    ),
    NavItem(
      label: 'Calendar',
      icon: Icons.calendar_today_outlined,
      activeIcon: Icons.calendar_today,
    ),
    NavItem(
      label: 'Feed',
      icon: Icons.dynamic_feed_outlined,
      activeIcon: Icons.dynamic_feed,
    ),
  ];

  // Mobile nav items - unified Work List replaces Tasks + Issues
  static const _mobileNavItems = [
    NavItem(
      label: 'Home',
      icon: Icons.dashboard_outlined,
      activeIcon: Icons.dashboard,
    ),
    NavItem(
      label: 'Work List',
      icon: Icons.checklist_outlined,
      activeIcon: Icons.checklist,
    ),
    NavItem(
      label: 'Calendar',
      icon: Icons.calendar_today_outlined,
      activeIcon: Icons.calendar_today,
    ),
    NavItem(label: 'Menu', icon: Icons.menu, activeIcon: Icons.menu),
  ];

  @override
  void initState() {
    super.initState();
    _loadProfile();
    _loadStats();
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

  Future<void> _loadStats() async {
    setState(() => _isLoadingStats = true);
    try {
      final workCounts = await _workListRepository.getCounts(widget.yardId);
      final todayLogs = await _logsRepository.getTodayLogCount(widget.yardId);

      if (mounted) {
        setState(() {
          _workItemCount = workCounts['total'] ?? 0;
          _urgentCount = workCounts['urgent'] ?? 0;
          _todayLogCount = todayLogs;
          _isLoadingStats = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingStats = false);
      }
    }
  }

  Future<void> _signOut() async {
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

  void _openQuickLog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => QuickLogSheet(
        yardId: widget.yardId,
        onLogComplete: () {
          _loadStats();
          SnackbarService.showSuccess(context, 'Logs saved successfully');
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 600;

    return Scaffold(
      body: GradientBackground(
        child: Stack(
          children: [
            // Main content
            SafeArea(
              bottom: false,
              child: Padding(
                padding: EdgeInsets.only(
                  top: isDesktop ? 80 : 24,
                  left: 24,
                  right: 24,
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
                  onItemTapped: (index) =>
                      setState(() => _selectedNavIndex = index),
                ),
              ),
            // Mobile: FAB floating above nav bar
            if (!isDesktop && _selectedNavIndex == 0)
              Positioned(
                bottom: MediaQuery.of(context).padding.bottom + 90,
                right: 24,
                child: FloatingActionButton(
                  onPressed: _openQuickLog,
                  backgroundColor: Colors.black,
                  shape: const CircleBorder(),
                  elevation: 4,
                  child: const Icon(Icons.add, size: 28, color: Colors.white),
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
          YardLogo(yardId: widget.yardId),
          const Spacer(),
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
        // Quick log button for desktop
        FilledButton.icon(
          onPressed: _openQuickLog,
          icon: const Icon(Icons.add, size: 18),
          label: const Text('Log'),
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFFFFD66B),
            foregroundColor: Colors.black87,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
        ),
        const SizedBox(width: 16),
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
                        Text(
                          widget.userRole.displayName,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black45,
                          ),
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
            _buildMenuItem('my_horses', Icons.pets_outlined, 'My Horses'),
            _buildMenuItem(
              'notifications',
              Icons.notifications_outlined,
              'Notifications',
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
      case 'my_horses':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => Scaffold(
              extendBodyBehindAppBar: true,
              appBar: AppBar(
                title: const Text('My Horses'),
                backgroundColor: Colors.transparent,
                elevation: 0,
              ),
              body: GradientBackground(
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: MyHorsesPage(yardId: widget.yardId),
                  ),
                ),
              ),
            ),
          ),
        );
        break;
      case 'notifications':
        SnackbarService.showInfo(context, 'Notifications coming soon');
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

  Widget _buildSelectedPage(bool isDesktop) {
    switch (_selectedNavIndex) {
      case 0:
        return _buildDashboardContent(isDesktop);
      case 1:
        return WorkListPage(yardId: widget.yardId);
      case 2:
        return CalendarPage(yardId: widget.yardId);
      case 3:
        return isDesktop
            ? FeedPage(yardId: widget.yardId)
            : MenuPage(yardId: widget.yardId, userRole: widget.userRole);
      default:
        return _buildDashboardContent(isDesktop);
    }
  }

  Widget _buildDashboardContent(bool isDesktop) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return RefreshIndicator(
      onRefresh: _loadStats,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome header
            _buildWelcomeHeader(isDark),
            const SizedBox(height: 24),

            // Quick stats
            _buildQuickStats(isDark),
            const SizedBox(height: 24),

            // Recent work items section
            if (isDesktop)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 2, child: _buildWorkItemsSection(isDark)),
                  const SizedBox(width: 24),
                  Expanded(child: _buildRecentIssuesSection(isDark)),
                ],
              )
            else ...[
              _buildWorkItemsSection(isDark),
            ],

            // Bottom padding for FAB
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeHeader(bool isDark) {
    final hour = DateTime.now().hour;
    String greeting;
    if (hour < 12) {
      greeting = 'Good morning';
    } else if (hour < 17) {
      greeting = 'Good afternoon';
    } else {
      greeting = 'Good evening';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          greeting,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          "Here's your daily overview",
          style: TextStyle(
            fontSize: 16,
            color: isDark ? Colors.white54 : Colors.black45,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickStats(bool isDark) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            icon: Icons.checklist,
            label: 'Work Items',
            value: _isLoadingStats ? '-' : '$_workItemCount',
            color: const Color(0xFF3B82F6),
            isDark: isDark,
            onTap: () => setState(() => _selectedNavIndex = 1),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            icon: Icons.priority_high,
            label: 'Urgent',
            value: _isLoadingStats ? '-' : '$_urgentCount',
            color: const Color(0xFFEF4444),
            isDark: isDark,
            onTap: () => setState(() => _selectedNavIndex = 1),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            icon: Icons.edit_note,
            label: 'Logged Today',
            value: _isLoadingStats ? '-' : '$_todayLogCount',
            color: const Color(0xFF10B981),
            isDark: isDark,
            onTap: _openQuickLog,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required bool isDark,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 20, color: color),
            ),
            const SizedBox(height: 12),
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
                fontSize: 13,
                color: isDark ? Colors.white54 : Colors.black45,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkItemsSection(bool isDark) {
    return _buildSection(
      title: 'My Work',
      icon: Icons.checklist_outlined,
      onViewAll: () => setState(() => _selectedNavIndex = 1),
      isDark: isDark,
      child: FutureBuilder<List<WorkItem>>(
        future: _workListRepository.getMyWorkItems(widget.yardId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: CircularProgressIndicator(),
              ),
            );
          }

          final items = snapshot.data ?? [];
          if (items.isEmpty) {
            return _buildEmptyState(
              icon: Icons.task_alt,
              message: 'No work assigned to you',
              isDark: isDark,
            );
          }

          return Column(
            children: items
                .take(5)
                .map((item) => _buildWorkItem(item, isDark))
                .toList(),
          );
        },
      ),
    );
  }

  Widget _buildRecentIssuesSection(bool isDark) {
    return _buildSection(
      title: 'Unassigned',
      icon: Icons.person_add_outlined,
      onViewAll: () => setState(() => _selectedNavIndex = 1),
      isDark: isDark,
      child: FutureBuilder<List<WorkItem>>(
        future: _workListRepository.getUnassignedWorkItems(widget.yardId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: CircularProgressIndicator(),
              ),
            );
          }

          final items = snapshot.data ?? [];
          if (items.isEmpty) {
            return _buildEmptyState(
              icon: Icons.check_circle_outline,
              message: 'All work assigned!',
              isDark: isDark,
            );
          }

          return Column(
            children: items
                .take(3)
                .map((item) => _buildUnassignedItem(item, isDark))
                .toList(),
          );
        },
      ),
    );
  }

  Widget _buildUnassignedItem(WorkItem item, bool isDark) {
    final priorityColor = switch (item.priority) {
      WorkItemPriority.urgent => Colors.red,
      WorkItemPriority.high => Colors.orange,
      WorkItemPriority.medium => Colors.blue,
      WorkItemPriority.low => Colors.grey,
    };
    final typeColor = item.isTask ? Colors.blue : Colors.orange;

    return InkWell(
      onTap: () => setState(() => _selectedNavIndex = 1),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: typeColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                item.isTask
                    ? Icons.check_circle_outline
                    : Icons.report_problem_outlined,
                size: 14,
                color: typeColor,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                item.title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white : Colors.black87,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: priorityColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                item.priority.displayName,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: priorityColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required VoidCallback onViewAll,
    required bool isDark,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white12 : Colors.black.withValues(alpha: 0.08),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: isDark ? Colors.white54 : Colors.black45,
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const Spacer(),
                TextButton(onPressed: onViewAll, child: const Text('View all')),
              ],
            ),
          ),
          Divider(
            height: 1,
            color: isDark
                ? Colors.white12
                : Colors.black.withValues(alpha: 0.08),
          ),
          child,
        ],
      ),
    );
  }

  Widget _buildWorkItem(WorkItem item, bool isDark) {
    final priorityColor = switch (item.priority) {
      WorkItemPriority.urgent => Colors.red,
      WorkItemPriority.high => Colors.orange,
      WorkItemPriority.medium => Colors.blue,
      WorkItemPriority.low => Colors.grey,
    };
    final typeColor = item.isTask ? Colors.blue : Colors.orange;

    return InkWell(
      onTap: () => setState(() => _selectedNavIndex = 1),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Type icon
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: typeColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                item.isTask
                    ? Icons.check_circle_outline
                    : Icons.report_problem_outlined,
                size: 16,
                color: typeColor,
              ),
            ),
            const SizedBox(width: 12),
            // Priority bar
            Container(
              width: 3,
              height: 36,
              decoration: BoxDecoration(
                color: priorityColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(
                        item.type.displayName,
                        style: TextStyle(
                          fontSize: 11,
                          color: typeColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (item.location != null) ...[
                        Text(
                          ' • ${item.location}',
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark ? Colors.white38 : Colors.black38,
                          ),
                        ),
                      ] else if (item.dueDate != null) ...[
                        Text(
                          ' • ${item.isOverdue
                              ? "Overdue"
                              : item.isDueToday
                              ? "Due today"
                              : "Due ${_formatDate(item.dueDate!)}"}',
                          style: TextStyle(
                            fontSize: 11,
                            color: item.isOverdue
                                ? Colors.red
                                : (isDark ? Colors.white38 : Colors.black38),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            // Priority badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: priorityColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                item.priority.displayName,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: priorityColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String message,
    required bool isDark,
  }) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Column(
          children: [
            Icon(
              icon,
              size: 40,
              color: isDark ? Colors.white24 : Colors.black12,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: TextStyle(color: isDark ? Colors.white38 : Colors.black38),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = date.difference(now).inDays;

    if (diff == 0) return 'today';
    if (diff == 1) return 'tomorrow';
    if (diff < 7) return 'in $diff days';

    return '${date.day}/${date.month}';
  }
}
