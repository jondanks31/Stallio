import 'package:flutter/material.dart';

import 'app_nav_bar.dart';

/// Floating pill-shaped vertical sidebar for operations navigation.
/// Icon-only with tooltips on hover.
class OperationsSidebar extends StatelessWidget {
  const OperationsSidebar({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onItemTapped,
    this.bottomItems,
    this.onBottomItemTapped,
    this.selectedBottomIndex,
  });

  final List<NavItem> items;
  final int selectedIndex;
  final ValueChanged<int> onItemTapped;

  final List<NavItem>? bottomItems;
  final ValueChanged<int>? onBottomItemTapped;
  final int? selectedBottomIndex;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(4, 0),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Main nav items
          for (int i = 0; i < items.length; i++) ...[
            _buildNavItem(context, items[i], i, selectedIndex, onItemTapped),
            if (i < items.length - 1) const SizedBox(height: 4),
          ],
          if (bottomItems != null && bottomItems!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(width: 32, height: 1, color: Colors.black12),
            const SizedBox(height: 8),
            for (int i = 0; i < bottomItems!.length; i++) ...[
              _buildNavItem(
                context,
                bottomItems![i],
                i,
                selectedBottomIndex ?? -1,
                onBottomItemTapped ?? (_) {},
              ),
              if (i < bottomItems!.length - 1) const SizedBox(height: 4),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    NavItem item,
    int index,
    int selectedIndex,
    ValueChanged<int> onTap,
  ) {
    final isSelected = index == selectedIndex;
    final icon = isSelected ? (item.activeIcon ?? item.icon) : item.icon;

    return Material(
      color: Colors.transparent,
      child: Tooltip(
        message: item.label,
        preferBelow: false,
        waitDuration: const Duration(milliseconds: 500),
        child: InkWell(
          onTap: () => onTap(index),
          borderRadius: BorderRadius.circular(16),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF1A1A1A) : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              icon,
              size: 22,
              color: isSelected ? Colors.white : Colors.black54,
            ),
          ),
        ),
      ),
    );
  }
}

/// Legacy: Expanded sidebar with labels (non-collapsible)
class OperationsSidebarExpanded extends StatelessWidget {
  const OperationsSidebarExpanded({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onItemTapped,
    this.bottomItems,
    this.onBottomItemTapped,
    this.selectedBottomIndex,
  });

  final List<NavItem> items;
  final int selectedIndex;
  final ValueChanged<int> onItemTapped;

  final List<NavItem>? bottomItems;
  final ValueChanged<int>? onBottomItemTapped;
  final int? selectedBottomIndex;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(4, 0),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Main nav items
          for (int i = 0; i < items.length; i++) ...[
            _buildNavItem(context, items[i], i, selectedIndex, onItemTapped),
            if (i < items.length - 1) const SizedBox(height: 4),
          ],
          if (bottomItems != null && bottomItems!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              height: 1,
              margin: const EdgeInsets.symmetric(horizontal: 8),
              color: Colors.black12,
            ),
            const SizedBox(height: 12),
            for (int i = 0; i < bottomItems!.length; i++) ...[
              _buildNavItem(
                context,
                bottomItems![i],
                i,
                selectedBottomIndex ?? -1,
                onBottomItemTapped ?? (_) {},
              ),
              if (i < bottomItems!.length - 1) const SizedBox(height: 4),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    NavItem item,
    int index,
    int selectedIndex,
    ValueChanged<int> onTap,
  ) {
    final isSelected = index == selectedIndex;
    final icon = isSelected ? (item.activeIcon ?? item.icon) : item.icon;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onTap(index),
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF1A1A1A) : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: isSelected ? Colors.white : Colors.black54,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  item.label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected ? Colors.white : Colors.black87,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
