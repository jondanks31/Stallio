import 'package:flutter/material.dart';

/// Navigation item data
class NavItem {
  final String label;
  final IconData icon;
  final IconData? activeIcon;

  const NavItem({required this.label, required this.icon, this.activeIcon});
}

/// Floating pill-shaped navigation bar.
/// On desktop: horizontal bar at top center.
/// On mobile: floating bottom bar.
class AppNavBar extends StatelessWidget {
  const AppNavBar({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onItemTapped,
    this.trailing,
  });

  final List<NavItem> items;
  final int selectedIndex;
  final ValueChanged<int> onItemTapped;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 600;

    if (isDesktop) {
      return _buildDesktopNav(context);
    } else {
      return _buildMobileNav(context);
    }
  }

  Widget _buildDesktopNav(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (int i = 0; i < items.length; i++) ...[
            _buildDesktopNavItem(context, i),
            if (i < items.length - 1) const SizedBox(width: 4),
          ],
          if (trailing != null) ...[
            const SizedBox(width: 8),
            Container(width: 1, height: 24, color: Colors.black12),
            const SizedBox(width: 8),
            trailing!,
          ],
        ],
      ),
    );
  }

  Widget _buildDesktopNavItem(BuildContext context, int index) {
    final item = items[index];
    final isSelected = index == selectedIndex;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onItemTapped(index),
        borderRadius: BorderRadius.circular(999),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF1A1A1A) : Colors.transparent,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            item.label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              color: isSelected ? Colors.white : Colors.black87,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMobileNav(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          for (int i = 0; i < items.length; i++)
            _buildMobileNavItem(context, i),
        ],
      ),
    );
  }

  Widget _buildMobileNavItem(BuildContext context, int index) {
    final item = items[index];
    final isSelected = index == selectedIndex;
    final icon = isSelected ? (item.activeIcon ?? item.icon) : item.icon;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onItemTapped(index),
        borderRadius: BorderRadius.circular(999),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF1A1A1A) : Colors.transparent,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 20,
                color: isSelected ? Colors.white : Colors.black54,
              ),
              if (isSelected) ...[
                const SizedBox(width: 8),
                Text(
                  item.label,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
