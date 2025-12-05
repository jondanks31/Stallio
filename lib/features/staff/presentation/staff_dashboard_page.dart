import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/ui/app_nav_bar.dart';
import '../../../core/ui/gradient_background.dart';
import '../../../core/ui/snackbar_service.dart';
import '../../../core/ui/yard_logo.dart';
import '../../auth/data/auth_repository.dart';
import '../../horses/presentation/dialogs/horse_dialog.dart';
import '../../people/data/people_repository.dart';
import '../../shared/presentation/pages/calendar_page.dart';
import '../../shared/presentation/pages/feed_page.dart';
import '../../user/presentation/pages/menu_page.dart';
import '../../user/presentation/pages/profile_page.dart';
import '../data/consumable_logs_repository.dart';
import '../data/issues_repository.dart';
import '../data/tasks_repository.dart';
import 'pages/issues_page.dart';
import 'pages/tasks_page.dart';
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
  final _tasksRepository = TasksRepository();
  final _issuesRepository = IssuesRepository();
  final _logsRepository = ConsumableLogsRepository();

  bool _isLoggingOut = false;
  int _selectedNavIndex = 0;

  // Profile data for user menu
  String? _userName;
  String? _avatarUrl;

  // Dashboard stats
  int _taskCount = 0;
  int _issueCount = 0;
  int _todayLogCount = 0;
  bool _isLoadingStats = true;

  // Desktop nav items
  static const _desktopNavItems = [
    NavItem(
      label: 'Dashboard',
      icon: Icons.dashboard_outlined,
      activeIcon: Icons.dashboard,
    ),
    NavItem(label: 'Tasks', icon: Icons.task_outlined, activeIcon: Icons.task),
    NavItem(
      label: 'Issues',
      icon: Icons.report_problem_outlined,
      activeIcon: Icons.report_problem,
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

  // Mobile nav items
  static const _mobileNavItems = [
    NavItem(
      label: 'Home',
      icon: Icons.dashboard_outlined,
      activeIcon: Icons.dashboard,
    ),
    NavItem(label: 'Tasks', icon: Icons.task_outlined, activeIcon: Icons.task),
    NavItem(
      label: 'Issues',
      icon: Icons.report_problem_outlined,
      activeIcon: Icons.report_problem,
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
      final taskCounts = await _tasksRepository.getTaskCounts(widget.yardId);
      final issueCounts = await _issuesRepository.getIssueCounts(widget.yardId);
      final todayLogs = await _logsRepository.getTodayLogCount(widget.yardId);

      if (mounted) {
        setState(() {
          _taskCount = taskCounts['mine'] ?? 0;
          _issueCount = issueCounts['total'] ?? 0;
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
                  backgroundColor: const Color(0xFFFFD66B),
                  foregroundColor: Colors.black87,
                  elevation: 4,
                  child: const Icon(Icons.add, size: 28),
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
            _buildMenuItem('add_horse', Icons.pets_outlined, 'Add Horse'),
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
        return TasksPage(yardId: widget.yardId);
      case 2:
        return IssuesPage(yardId: widget.yardId);
      case 3:
        return CalendarPage(yardId: widget.yardId);
      case 4:
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

            // Recent activity sections
            if (isDesktop)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _buildMyTasksSection(isDark)),
                  const SizedBox(width: 24),
                  Expanded(child: _buildRecentIssuesSection(isDark)),
                ],
              )
            else ...[
              _buildMyTasksSection(isDark),
              const SizedBox(height: 24),
              _buildRecentIssuesSection(isDark),
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
            icon: Icons.task_alt,
            label: 'My Tasks',
            value: _isLoadingStats ? '-' : '$_taskCount',
            color: const Color(0xFF3B82F6),
            isDark: isDark,
            onTap: () => setState(() => _selectedNavIndex = 1),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            icon: Icons.report_problem_outlined,
            label: 'Open Issues',
            value: _isLoadingStats ? '-' : '$_issueCount',
            color: const Color(0xFFF59E0B),
            isDark: isDark,
            onTap: () => setState(() => _selectedNavIndex = 2),
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

  Widget _buildMyTasksSection(bool isDark) {
    return _buildSection(
      title: 'My Tasks',
      icon: Icons.task_outlined,
      onViewAll: () => setState(() => _selectedNavIndex = 1),
      isDark: isDark,
      child: FutureBuilder<List<Task>>(
        future: _tasksRepository.getMyTasks(widget.yardId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: CircularProgressIndicator(),
              ),
            );
          }

          final tasks = snapshot.data ?? [];
          if (tasks.isEmpty) {
            return _buildEmptyState(
              icon: Icons.task_alt,
              message: 'No tasks assigned to you',
              isDark: isDark,
            );
          }

          return Column(
            children: tasks
                .take(3)
                .map((task) => _buildTaskItem(task, isDark))
                .toList(),
          );
        },
      ),
    );
  }

  Widget _buildRecentIssuesSection(bool isDark) {
    return _buildSection(
      title: 'Recent Issues',
      icon: Icons.report_problem_outlined,
      onViewAll: () => setState(() => _selectedNavIndex = 2),
      isDark: isDark,
      child: FutureBuilder<List<Issue>>(
        future: _issuesRepository.getIssues(widget.yardId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: CircularProgressIndicator(),
              ),
            );
          }

          final issues = snapshot.data ?? [];
          if (issues.isEmpty) {
            return _buildEmptyState(
              icon: Icons.check_circle_outline,
              message: 'No open issues',
              isDark: isDark,
            );
          }

          return Column(
            children: issues
                .take(3)
                .map((issue) => _buildIssueItem(issue, isDark))
                .toList(),
          );
        },
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

  Widget _buildTaskItem(Task task, bool isDark) {
    final priorityColor = switch (task.priority) {
      TaskPriority.urgent => Colors.red,
      TaskPriority.high => Colors.orange,
      TaskPriority.medium => Colors.blue,
      TaskPriority.low => Colors.grey,
    };

    return InkWell(
      onTap: () => setState(() => _selectedNavIndex = 1),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 40,
              decoration: BoxDecoration(
                color: priorityColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (task.dueDate != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      task.isOverdue
                          ? 'Overdue'
                          : task.isDueToday
                          ? 'Due today'
                          : 'Due ${_formatDate(task.dueDate!)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: task.isOverdue
                            ? Colors.red
                            : (isDark ? Colors.white38 : Colors.black38),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: isDark ? Colors.white38 : Colors.black26,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIssueItem(Issue issue, bool isDark) {
    final statusColor = switch (issue.status) {
      IssueStatus.open => Colors.red,
      IssueStatus.inProgress => Colors.orange,
      IssueStatus.resolved => Colors.green,
    };

    return InkWell(
      onTap: () => setState(() => _selectedNavIndex = 2),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.report_problem_outlined,
                size: 18,
                color: statusColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    issue.title,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    issue.location ?? 'No location',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.white38 : Colors.black38,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                issue.status.displayName,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: statusColor,
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
