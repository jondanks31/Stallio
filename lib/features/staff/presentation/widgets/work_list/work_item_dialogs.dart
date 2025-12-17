import 'package:flutter/material.dart';

import '../../../data/work_list_repository.dart';
import 'work_item_card.dart';

// ─────────────────────────────────────────────────────────────────────────────
// WORK ITEM DIALOGS - Bottom sheets for work item interactions
// ─────────────────────────────────────────────────────────────────────────────

/// Shows assignment bottom sheet for managers/owners
Future<void> showAssignDialog({
  required BuildContext context,
  required WorkItem item,
  required List<Map<String, dynamic>> staffList,
  required Future<void> Function(String userId) onAssign,
}) async {
  final isDark = Theme.of(context).brightness == Brightness.dark;

  await showModalBottomSheet(
    context: context,
    backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : Colors.black12,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Assign ${item.isTask ? 'Task' : 'Issue'}',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            item.title,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.white60 : Colors.black54,
            ),
          ),
          const SizedBox(height: 20),
          ...staffList.map((member) {
            final userId = member['user_id'] as String;
            final name = member['full_name'] as String? ?? 'Unknown';
            final role = member['role'] as String? ?? 'staff';
            final isCurrentlyAssigned = item.assignedToUserId == userId;

            return ListTile(
              leading: CircleAvatar(
                backgroundColor: isCurrentlyAssigned
                    ? const Color(0xFFFFD66B)
                    : (isDark ? Colors.white12 : Colors.grey[200]),
                child: Icon(
                  Icons.person,
                  color: isCurrentlyAssigned
                      ? Colors.black87
                      : (isDark ? Colors.white54 : Colors.black45),
                ),
              ),
              title: Text(
                name,
                style: TextStyle(
                  fontWeight: isCurrentlyAssigned
                      ? FontWeight.bold
                      : FontWeight.normal,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              subtitle: Text(
                role[0].toUpperCase() + role.substring(1),
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.white38 : Colors.black45,
                ),
              ),
              trailing: isCurrentlyAssigned
                  ? const Icon(Icons.check, color: Color(0xFFFFD66B))
                  : null,
              onTap: isCurrentlyAssigned
                  ? null
                  : () async {
                      Navigator.pop(context);
                      await onAssign(userId);
                    },
            );
          }),
          const SizedBox(height: 16),
        ],
      ),
    ),
  );
}

/// Bottom sheet showing work item details
class WorkItemDetailsSheet extends StatelessWidget {
  const WorkItemDetailsSheet({
    super.key,
    required this.item,
    required this.onAssignToSelf,
    required this.onComplete,
  });

  final WorkItem item;
  final Future<void> Function() onAssignToSelf;
  final Future<void> Function() onComplete;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : Colors.black12,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Type badge + Priority
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: item.isTask
                      ? Colors.blue.withValues(alpha: 0.15)
                      : Colors.orange.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  item.type.displayName,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: item.isTask ? Colors.blue : Colors.orange,
                  ),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: getPriorityColor(
                    item.priority,
                  ).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  item.priority.displayName,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: getPriorityColor(item.priority),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Title
          Text(
            item.title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),

          if (item.description != null) ...[
            const SizedBox(height: 12),
            Text(
              item.description!,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white70 : Colors.black54,
              ),
            ),
          ],

          if (item.location != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.location_on_outlined,
                  size: 16,
                  color: isDark ? Colors.white38 : Colors.black38,
                ),
                const SizedBox(width: 4),
                Text(
                  item.location!,
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? Colors.white54 : Colors.black45,
                  ),
                ),
              ],
            ),
          ],

          const SizedBox(height: 16),

          // Info rows
          _buildInfoRow(
            Icons.person_outline,
            'Created by',
            item.createdByName ?? 'Unknown',
            isDark,
          ),
          if (item.assignedToName != null)
            _buildInfoRow(
              Icons.person,
              'Assigned to',
              item.assignedToName!,
              isDark,
            ),
          if (item.completedByName != null)
            _buildInfoRow(
              Icons.verified,
              item.isTask ? 'Completed by' : 'Resolved by',
              item.completedByName!,
              isDark,
              color: Colors.green,
            ),

          const SizedBox(height: 24),

          // Action buttons
          if (!item.isCompleted)
            Row(
              children: [
                if (!item.isAssigned)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        await onAssignToSelf();
                      },
                      icon: const Icon(Icons.person_add),
                      label: const Text('Assign to me'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                if (!item.isAssigned) const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      await onComplete();
                    },
                    icon: const Icon(Icons.check),
                    label: Text(item.isTask ? 'Complete' : 'Resolve'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value,
    bool isDark, {
    Color? color,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: color ?? (isDark ? Colors.white38 : Colors.black38),
          ),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: 13,
              color: isDark ? Colors.white38 : Colors.black38,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: color ?? (isDark ? Colors.white70 : Colors.black54),
            ),
          ),
        ],
      ),
    );
  }
}
