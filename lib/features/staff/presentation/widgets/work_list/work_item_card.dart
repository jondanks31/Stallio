import 'package:flutter/material.dart';

import '../../../data/work_list_repository.dart';

// ─────────────────────────────────────────────────────────────────────────────
// WORK ITEM CARD - Display card for tasks and issues
// ─────────────────────────────────────────────────────────────────────────────

/// Returns the color associated with a priority level
Color getPriorityColor(WorkItemPriority priority) {
  return switch (priority) {
    WorkItemPriority.urgent => Colors.red,
    WorkItemPriority.high => Colors.orange,
    WorkItemPriority.medium => Colors.blue,
    WorkItemPriority.low => Colors.grey,
  };
}

/// Card displaying a work item (task or issue)
class WorkItemCard extends StatelessWidget {
  const WorkItemCard({
    super.key,
    required this.item,
    required this.onTap,
    required this.onAssignToSelf,
    required this.onComplete,
    this.onAssign,
    this.canAssign = false,
  });

  final WorkItem item;
  final VoidCallback onTap;
  final VoidCallback onAssignToSelf;
  final VoidCallback onComplete;
  final VoidCallback? onAssign;
  final bool canAssign;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final priorityColor = getPriorityColor(item.priority);
    final isUrgent =
        item.priority == WorkItemPriority.urgent ||
        item.priority == WorkItemPriority.high;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isUrgent
              ? priorityColor.withValues(alpha: 0.3)
              : (isDark
                    ? Colors.white12
                    : Colors.black.withValues(alpha: 0.08)),
          width: isUrgent ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(isDark, priorityColor),
              if (item.description != null) ...[
                const SizedBox(height: 8),
                Text(
                  item.description!,
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? Colors.white60 : Colors.black54,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 12),
              _buildFooter(isDark),
              if (item.isCompleted && item.completedByName != null) ...[
                const SizedBox(height: 8),
                _buildCompletedBy(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark, Color priorityColor) {
    return Row(
      children: [
        // Type icon
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: item.isTask
                ? Colors.blue.withValues(alpha: 0.15)
                : Colors.orange.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            item.isTask
                ? Icons.check_circle_outline
                : Icons.report_problem_outlined,
            size: 20,
            color: item.isTask ? Colors.blue : Colors.orange,
          ),
        ),
        const SizedBox(width: 12),
        // Title and type label
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.title,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  color: isDark ? Colors.white : Colors.black87,
                  decoration: item.isCompleted
                      ? TextDecoration.lineThrough
                      : null,
                ),
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  Text(
                    item.type.displayName,
                    style: TextStyle(
                      fontSize: 12,
                      color: item.isTask ? Colors.blue : Colors.orange,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (item.location != null) ...[
                    Text(
                      ' • ',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.white38 : Colors.black26,
                      ),
                    ),
                    Icon(
                      Icons.location_on_outlined,
                      size: 12,
                      color: isDark ? Colors.white38 : Colors.black38,
                    ),
                    const SizedBox(width: 2),
                    Flexible(
                      child: Text(
                        item.location!,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.white38 : Colors.black38,
                        ),
                        overflow: TextOverflow.ellipsis,
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
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: priorityColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            item.priority.displayName,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: priorityColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFooter(bool isDark) {
    return Row(
      children: [
        // Assigned to / Unassigned badge
        if (item.assignedToName != null) ...[
          Icon(
            Icons.person,
            size: 14,
            color: isDark ? Colors.white38 : Colors.black38,
          ),
          const SizedBox(width: 4),
          Text(
            item.assignedToName!,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.white54 : Colors.black45,
            ),
          ),
        ] else ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text(
              'Unassigned',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: Colors.amber,
              ),
            ),
          ),
        ],
        // Due date
        if (item.dueDate != null) ...[
          const SizedBox(width: 12),
          Icon(
            Icons.calendar_today,
            size: 12,
            color: item.isOverdue
                ? Colors.red
                : (isDark ? Colors.white38 : Colors.black38),
          ),
          const SizedBox(width: 4),
          Text(
            item.isOverdue
                ? 'Overdue'
                : item.isDueToday
                ? 'Due today'
                : '${item.dueDate!.day}/${item.dueDate!.month}',
            style: TextStyle(
              fontSize: 12,
              color: item.isOverdue
                  ? Colors.red
                  : (isDark ? Colors.white38 : Colors.black38),
            ),
          ),
        ],
        const Spacer(),
        // Actions
        if (!item.isAssigned && !item.isCompleted)
          TextButton.icon(
            onPressed: onAssignToSelf,
            icon: const Icon(Icons.person_add, size: 16),
            label: const Text('Take'),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFFFD66B),
              padding: const EdgeInsets.symmetric(horizontal: 8),
              visualDensity: VisualDensity.compact,
            ),
          ),
        // Assign button for managers/owners
        if (canAssign && !item.isCompleted && onAssign != null)
          IconButton(
            onPressed: onAssign,
            icon: Icon(
              item.isAssigned
                  ? Icons.assignment_ind
                  : Icons.assignment_ind_outlined,
            ),
            color: item.isAssigned
                ? Colors.green
                : (isDark ? Colors.white54 : Colors.black45),
            iconSize: 22,
            visualDensity: VisualDensity.compact,
            tooltip: item.isAssigned ? 'Reassign' : 'Assign to staff',
          ),
        if (!item.isCompleted)
          IconButton(
            onPressed: onComplete,
            icon: const Icon(Icons.check_circle_outline),
            color: Colors.green,
            iconSize: 22,
            visualDensity: VisualDensity.compact,
            tooltip: item.isTask ? 'Complete' : 'Resolve',
          ),
      ],
    );
  }

  Widget _buildCompletedBy() {
    return Row(
      children: [
        const Icon(Icons.verified, size: 14, color: Colors.green),
        const SizedBox(width: 4),
        Text(
          '${item.isTask ? 'Completed' : 'Resolved'} by ${item.completedByName}',
          style: const TextStyle(
            fontSize: 12,
            color: Colors.green,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
