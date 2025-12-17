import 'package:flutter/material.dart';

import '../../../data/work_list_repository.dart';

// ─────────────────────────────────────────────────────────────────────────────
// WORK LIST FILTERS - Toggle and filter widgets for work list
// ─────────────────────────────────────────────────────────────────────────────

/// Assignment toggle (Mine / Unassigned / All)
class WorkListAssignmentToggle extends StatelessWidget {
  const WorkListAssignmentToggle({
    super.key,
    required this.selectedFilter,
    required this.onFilterChanged,
    required this.showAllOption,
  });

  final int selectedFilter; // 0 = Mine, 1 = Unassigned, 2 = All
  final ValueChanged<int> onFilterChanged;
  final bool showAllOption;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ToggleButton(
            label: 'Mine',
            isSelected: selectedFilter == 0,
            onTap: () => onFilterChanged(0),
            isDark: isDark,
          ),
          _ToggleButton(
            label: 'Unassigned',
            isSelected: selectedFilter == 1,
            onTap: () => onFilterChanged(1),
            isDark: isDark,
          ),
          if (showAllOption)
            _ToggleButton(
              label: 'All',
              isSelected: selectedFilter == 2,
              onTap: () => onFilterChanged(2),
              isDark: isDark,
            ),
        ],
      ),
    );
  }
}

class _ToggleButton extends StatelessWidget {
  const _ToggleButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.isDark,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFFD66B) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected
                ? Colors.black87
                : (isDark ? Colors.white70 : Colors.black54),
          ),
        ),
      ),
    );
  }
}

/// Type filter chips (All / Tasks / Issues)
class WorkListTypeFilter extends StatelessWidget {
  const WorkListTypeFilter({
    super.key,
    required this.selectedType,
    required this.onTypeChanged,
  });

  final WorkItemType? selectedType; // null = All
  final ValueChanged<WorkItemType?> onTypeChanged;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        WorkListFilterChip(
          label: 'All',
          isSelected: selectedType == null,
          onSelected: () => onTypeChanged(null),
          isDark: isDark,
        ),
        const SizedBox(width: 8),
        WorkListFilterChip(
          label: 'Tasks',
          icon: Icons.check_circle_outline,
          isSelected: selectedType == WorkItemType.task,
          onSelected: () => onTypeChanged(WorkItemType.task),
          isDark: isDark,
        ),
        const SizedBox(width: 8),
        WorkListFilterChip(
          label: 'Issues',
          icon: Icons.report_problem_outlined,
          isSelected: selectedType == WorkItemType.issue,
          onSelected: () => onTypeChanged(WorkItemType.issue),
          isDark: isDark,
        ),
        const Spacer(),
      ],
    );
  }
}

/// Reusable filter chip for work list
class WorkListFilterChip extends StatelessWidget {
  const WorkListFilterChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onSelected,
    required this.isDark,
    this.icon,
  });

  final String label;
  final IconData? icon;
  final bool isSelected;
  final VoidCallback onSelected;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onSelected,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFFFD66B)
              : (isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : Colors.grey[100]),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 16,
                color: isSelected
                    ? Colors.black87
                    : (isDark ? Colors.white54 : Colors.black45),
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected
                    ? Colors.black87
                    : (isDark ? Colors.white54 : Colors.black45),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Empty state for work list
class WorkListEmptyState extends StatelessWidget {
  const WorkListEmptyState({super.key, required this.assignmentFilter});

  final int assignmentFilter;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final message = switch (assignmentFilter) {
      0 => 'No work assigned to you',
      1 => 'No unassigned work items',
      _ => 'No work items',
    };
    final subtitle = switch (assignmentFilter) {
      0 => 'Check unassigned items to pick up work',
      1 => 'Great! Everything is assigned',
      _ => 'Create a task or report an issue',
    };

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.task_alt,
            size: 64,
            color: isDark ? Colors.white24 : Colors.black12,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white54 : Colors.black45,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.white38 : Colors.black26,
            ),
          ),
        ],
      ),
    );
  }
}
