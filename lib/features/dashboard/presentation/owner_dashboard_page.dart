import 'package:flutter/material.dart';

import '../../../core/ui/app_nav_bar.dart';
import '../../../core/ui/gradient_background.dart';
import '../../../core/ui/snackbar_service.dart';
import '../../auth/data/auth_repository.dart';
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
  bool _isLoggingOut = false;
  int _selectedNavIndex = 0;

  // Desktop nav - full menu
  static const _desktopNavItems = [
    NavItem(
      label: 'Dashboard',
      icon: Icons.dashboard_outlined,
      activeIcon: Icons.dashboard,
    ),
    NavItem(label: 'Horses', icon: Icons.pets_outlined, activeIcon: Icons.pets),
    NavItem(
      label: 'Invoices',
      icon: Icons.receipt_long_outlined,
      activeIcon: Icons.receipt_long,
    ),
    NavItem(
      label: 'Calendar',
      icon: Icons.calendar_today_outlined,
      activeIcon: Icons.calendar_today,
    ),
    NavItem(
      label: 'Manage Yard',
      icon: Icons.business_outlined,
      activeIcon: Icons.business,
    ),
  ];

  // Mobile nav - key pages only (max 4-5 items)
  static const _mobileNavItems = [
    NavItem(
      label: 'Home',
      icon: Icons.dashboard_outlined,
      activeIcon: Icons.dashboard,
    ),
    NavItem(label: 'Horses', icon: Icons.pets_outlined, activeIcon: Icons.pets),
    NavItem(
      label: 'Calendar',
      icon: Icons.calendar_today_outlined,
      activeIcon: Icons.calendar_today,
    ),
    NavItem(
      label: 'Invoices',
      icon: Icons.receipt_long_outlined,
      activeIcon: Icons.receipt_long,
    ),
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
        child: SafeArea(
          child: Stack(
            children: [
              // Main content
              Padding(
                padding: EdgeInsets.only(
                  top: isDesktop ? 80 : 24,
                  left: isDesktop && _selectedNavIndex == 4 ? 0 : 24,
                  right: isDesktop && _selectedNavIndex == 4 ? 0 : 24,
                  bottom: isDesktop ? 24 : 100,
                ),
                child: isDesktop && _selectedNavIndex == 4
                    ? YardManagementPage(yardId: widget.yardId)
                    : _buildPageContent(),
              ),
              // Desktop: Top nav bar
              if (isDesktop)
                Positioned(
                  top: 16,
                  left: 0,
                  right: 0,
                  child: _buildDesktopHeader(),
                ),
              // Mobile: Bottom nav bar
              if (!isDesktop)
                Positioned(
                  bottom: 0,
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
      ),
    );
  }

  Widget _buildDesktopHeader() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          // Logo
          Text(
            'STALLIO',
            style: theme.textTheme.labelSmall?.copyWith(
              letterSpacing: 4,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
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

  Widget _buildPageContent() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Show different content based on selected nav item
    final isDesktop = MediaQuery.of(context).size.width > 600;
    final titles = isDesktop
        ? ['Dashboard', 'Horses', 'Invoices', 'Calendar', 'Manage Yard']
        : ['Home', 'Horses', 'Calendar', 'Invoices'];
    final title = _selectedNavIndex < titles.length
        ? titles[_selectedNavIndex]
        : titles[0];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Mobile header
        if (MediaQuery.of(context).size.width <= 600) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'STALLIO',
                style: theme.textTheme.labelSmall?.copyWith(
                  letterSpacing: 4,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.notifications_outlined),
                    style: IconButton.styleFrom(
                      foregroundColor: isDark ? Colors.white70 : Colors.black54,
                    ),
                  ),
                  _buildMobileMenu(),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],
        // Page title
        Text(
          title,
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _getSubtitle(),
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: 24),
        // Placeholder content
        Expanded(
          child: Center(
            child: Text(
              '$title content coming soon...',
              style: const TextStyle(color: Colors.black38),
            ),
          ),
        ),
      ],
    );
  }

  String _getSubtitle() {
    final isDesktop = MediaQuery.of(context).size.width > 600;

    if (isDesktop) {
      // Desktop: Dashboard, Horses, Invoices, Calendar, Manage Yard
      switch (_selectedNavIndex) {
        case 0:
          return 'Welcome back! Your yard overview will appear here.';
        case 1:
          return 'Manage all horses in your yard.';
        case 2:
          return 'View and manage invoices.';
        case 3:
          return 'Schedule and manage appointments.';
        case 4:
          return 'Configure your yard services and billing.';
        default:
          return '';
      }
    } else {
      // Mobile: Home, Horses, Calendar, Invoices
      switch (_selectedNavIndex) {
        case 0:
          return 'Welcome back! Your yard overview will appear here.';
        case 1:
          return 'Manage all horses in your yard.';
        case 2:
          return 'Schedule and manage appointments.';
        case 3:
          return 'View and manage invoices.';
        default:
          return '';
      }
    }
  }
}
