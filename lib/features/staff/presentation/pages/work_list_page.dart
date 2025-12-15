import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/ui/snackbar_service.dart';
import '../../data/work_list_repository.dart';

/// Unified Work List page showing both Tasks and Issues.
/// Staff see everything they need to do in one place.
/// Managers/Owners can also assign work to staff members.
class WorkListPage extends StatefulWidget {
  const WorkListPage({
    super.key,
    required this.yardId,
    this.canAssign = false, // true for managers/owners
  });

  final String yardId;
  final bool canAssign;

  @override
  State<WorkListPage> createState() => _WorkListPageState();
}

class _WorkListPageState extends State<WorkListPage> {
  final _repository = WorkListRepository();

  List<WorkItem> _items = [];
  bool _isLoading = true;

  // Filters
  WorkItemType? _typeFilter; // null = All
  int _assignmentFilter = 0; // 0 = Mine, 1 = Unassigned, 2 = All

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    setState(() => _isLoading = true);
    try {
      List<WorkItem> items;

      if (_assignmentFilter == 0) {
        // My items
        items = await _repository.getMyWorkItems(widget.yardId);
        if (_typeFilter != null) {
          items = items.where((i) => i.type == _typeFilter).toList();
        }
      } else if (_assignmentFilter == 1) {
        // Unassigned
        items = await _repository.getUnassignedWorkItems(widget.yardId);
        if (_typeFilter != null) {
          items = items.where((i) => i.type == _typeFilter).toList();
        }
      } else {
        // All
        items = await _repository.getWorkItems(
          widget.yardId,
          typeFilter: _typeFilter,
        );
      }

      if (mounted) {
        setState(() {
          _items = items;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        SnackbarService.showError(context, 'Failed to load work items');
      }
    }
  }

  Future<void> _assignToSelf(WorkItem item) async {
    try {
      await _repository.assignToSelf(item);
      await _loadItems();
      if (mounted) {
        SnackbarService.showSuccess(
          context,
          '${item.isTask ? 'Task' : 'Issue'} assigned to you',
        );
      }
    } catch (e) {
      if (mounted) {
        SnackbarService.showError(context, 'Failed to assign');
      }
    }
  }

  Future<void> _updateStatus(WorkItem item, WorkItemStatus status) async {
    try {
      await _repository.updateStatus(item, status);
      await _loadItems();
      if (mounted) {
        final action = status == WorkItemStatus.completed
            ? (item.isTask ? 'completed' : 'resolved')
            : status.displayName.toLowerCase();
        SnackbarService.showSuccess(
          context,
          '${item.isTask ? 'Task' : 'Issue'} marked as $action',
        );
      }
    } catch (e) {
      if (mounted) {
        SnackbarService.showError(context, 'Failed to update status');
      }
    }
  }

  Future<void> _showAssignDialog(WorkItem item) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Get assignable staff (role check happens server-side)
    final staff = await _repository.getAssignableStaff(widget.yardId);

    if (staff.isEmpty) {
      if (mounted) {
        SnackbarService.showError(context, 'No staff members to assign to');
      }
      return;
    }

    if (!mounted) return;

    showModalBottomSheet(
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
            ...staff.map((member) {
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
                        try {
                          await _repository.assignToUser(item, userId);
                          await _loadItems();
                        } catch (e) {
                          debugPrint('Failed to assign: $e');
                        }
                      },
              );
            }),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showAddDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true, // Allows sheet to resize for keyboard
      builder: (context) => _AddWorkItemSheet(
        yardId: widget.yardId,
        repository: _repository,
        onCreated: _loadItems,
        canAssign: widget.canAssign,
      ),
    );
  }

  Color _getPriorityColor(WorkItemPriority priority) {
    return switch (priority) {
      WorkItemPriority.urgent => Colors.red,
      WorkItemPriority.high => Colors.orange,
      WorkItemPriority.medium => Colors.blue,
      WorkItemPriority.low => Colors.grey,
    };
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row with title and assignment toggle
            Row(
              children: [
                Text(
                  'Work List',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const Spacer(),
                _buildAssignmentToggle(isDark),
              ],
            ),
            const SizedBox(height: 12),

            // Type filter chips (All / Tasks / Issues)
            _buildFilterChips(isDark),
            const SizedBox(height: 16),

            // Work items list
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _items.isEmpty
                  ? _buildEmptyState(isDark)
                  : RefreshIndicator(
                      onRefresh: _loadItems,
                      child: ListView.separated(
                        padding: const EdgeInsets.only(bottom: 80),
                        itemCount: _items.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          return _buildWorkItemCard(_items[index], isDark);
                        },
                      ),
                    ),
            ),
          ],
        ),
        // FAB for adding new work items
        Positioned(
          right: 0,
          bottom: 80, // Above mobile nav bar
          child: FloatingActionButton(
            onPressed: _showAddDialog,
            backgroundColor: Colors.black,
            shape: const CircleBorder(),
            child: const Icon(Icons.add, color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChips(bool isDark) {
    return Row(
      children: [
        _FilterChip(
          label: 'All',
          isSelected: _typeFilter == null,
          onSelected: () {
            setState(() => _typeFilter = null);
            _loadItems();
          },
          isDark: isDark,
        ),
        const SizedBox(width: 8),
        _FilterChip(
          label: 'Tasks',
          icon: Icons.check_circle_outline,
          isSelected: _typeFilter == WorkItemType.task,
          onSelected: () {
            setState(() => _typeFilter = WorkItemType.task);
            _loadItems();
          },
          isDark: isDark,
        ),
        const SizedBox(width: 8),
        _FilterChip(
          label: 'Issues',
          icon: Icons.report_problem_outlined,
          isSelected: _typeFilter == WorkItemType.issue,
          onSelected: () {
            setState(() => _typeFilter = WorkItemType.issue);
            _loadItems();
          },
          isDark: isDark,
        ),
        const Spacer(), // Push to left
      ],
    );
  }

  Widget _buildAssignmentToggle(bool isDark) {
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
          _buildToggleButton('Mine', _assignmentFilter == 0, () {
            setState(() => _assignmentFilter = 0);
            _loadItems();
          }, isDark),
          _buildToggleButton('Unassigned', _assignmentFilter == 1, () {
            setState(() => _assignmentFilter = 1);
            _loadItems();
          }, isDark),
          // Show "All" option for managers/owners
          if (widget.canAssign)
            _buildToggleButton('All', _assignmentFilter == 2, () {
              setState(() => _assignmentFilter = 2);
              _loadItems();
            }, isDark),
        ],
      ),
    );
  }

  Widget _buildToggleButton(
    String label,
    bool isSelected,
    VoidCallback onTap,
    bool isDark,
  ) {
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

  Widget _buildEmptyState(bool isDark) {
    final message = switch (_assignmentFilter) {
      0 => 'No work assigned to you',
      1 => 'No unassigned work items',
      _ => 'No work items',
    };
    final subtitle = switch (_assignmentFilter) {
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

  Widget _buildWorkItemCard(WorkItem item, bool isDark) {
    final priorityColor = _getPriorityColor(item.priority);
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
        onTap: () => _showItemDetails(item),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
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
                                color: item.isTask
                                    ? Colors.blue
                                    : Colors.orange,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            if (item.location != null) ...[
                              Text(
                                ' • ',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark
                                      ? Colors.white38
                                      : Colors.black26,
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
                                    color: isDark
                                        ? Colors.white38
                                        : Colors.black38,
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
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
              ),
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
              // Footer row
              Row(
                children: [
                  // Assigned to / Created by
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
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
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
                      onPressed: () => _assignToSelf(item),
                      icon: const Icon(Icons.person_add, size: 16),
                      label: const Text('Take'),
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFFFFD66B),
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                  // Assign button for managers/owners
                  if (widget.canAssign && !item.isCompleted)
                    IconButton(
                      onPressed: () => _showAssignDialog(item),
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
                      onPressed: () =>
                          _updateStatus(item, WorkItemStatus.completed),
                      icon: const Icon(Icons.check_circle_outline),
                      color: Colors.green,
                      iconSize: 22,
                      visualDensity: VisualDensity.compact,
                      tooltip: item.isTask ? 'Complete' : 'Resolve',
                    ),
                ],
              ),
              // Show who resolved (audit trail)
              if (item.isCompleted && item.completedByName != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.verified, size: 14, color: Colors.green),
                    const SizedBox(width: 4),
                    Text(
                      '${item.isTask ? 'Completed' : 'Resolved'} by ${item.completedByName}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.green,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showItemDetails(WorkItem item) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _ItemDetailsSheet(
        item: item,
        repository: _repository,
        onUpdated: () {
          Navigator.pop(context);
          _loadItems();
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// FILTER CHIP
// ─────────────────────────────────────────────────────────────────────────────

class _FilterChip extends StatelessWidget {
  const _FilterChip({
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

// ─────────────────────────────────────────────────────────────────────────────
// ADD WORK ITEM SHEET
// ─────────────────────────────────────────────────────────────────────────────

class _AddWorkItemSheet extends StatefulWidget {
  const _AddWorkItemSheet({
    required this.yardId,
    required this.repository,
    required this.onCreated,
    this.canAssign = false,
  });

  final String yardId;
  final WorkListRepository repository;
  final VoidCallback onCreated;
  final bool canAssign;

  @override
  State<_AddWorkItemSheet> createState() => _AddWorkItemSheetState();
}

class _AddWorkItemSheetState extends State<_AddWorkItemSheet> {
  WorkItemType _selectedType = WorkItemType.task;
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  WorkItemPriority _selectedPriority = WorkItemPriority.medium;
  DateTime? _selectedDueDate;
  String? _selectedAssignee; // null = unassigned, 'me' = self, or user_id
  bool _isCreating = false;
  List<Map<String, dynamic>> _staffList = [];

  @override
  void initState() {
    super.initState();
    if (widget.canAssign) {
      _loadStaffList();
    }
  }

  Future<void> _loadStaffList() async {
    // Role check now happens server-side in getAssignableStaff
    final staff = await widget.repository.getAssignableStaff(widget.yardId);
    if (mounted) {
      setState(() => _staffList = staff);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    if (_titleController.text.trim().isEmpty) {
      SnackbarService.showError(context, 'Please enter a title');
      return;
    }

    setState(() => _isCreating = true);

    // Determine assignee
    String? assigneeId;
    if (_selectedAssignee == 'me') {
      assigneeId = Supabase.instance.client.auth.currentUser?.id;
    } else if (_selectedAssignee != null) {
      assigneeId = _selectedAssignee;
    }

    try {
      if (_selectedType == WorkItemType.task) {
        await widget.repository.createTask(
          yardId: widget.yardId,
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
          priority: _selectedPriority,
          dueDate: _selectedDueDate,
          assignToUserId: assigneeId,
        );
      } else {
        await widget.repository.createIssue(
          yardId: widget.yardId,
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
          location: _locationController.text.trim().isEmpty
              ? null
              : _locationController.text.trim(),
          priority: _selectedPriority,
          assignToUserId: assigneeId,
        );
      }

      if (mounted) {
        Navigator.pop(context);
        widget.onCreated();
        SnackbarService.showSuccess(
          context,
          '${_selectedType.displayName} created',
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isCreating = false);
        SnackbarService.showError(context, 'Failed to create');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
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

            // Title
            Text(
              'Add Work Item',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 20),

            // Type selector
            Row(
              children: [
                Expanded(
                  child: _TypeOption(
                    type: WorkItemType.task,
                    isSelected: _selectedType == WorkItemType.task,
                    onSelected: () =>
                        setState(() => _selectedType = WorkItemType.task),
                    isDark: isDark,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _TypeOption(
                    type: WorkItemType.issue,
                    isSelected: _selectedType == WorkItemType.issue,
                    onSelected: () =>
                        setState(() => _selectedType = WorkItemType.issue),
                    isDark: isDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Title field
            TextField(
              controller: _titleController,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: _selectedType == WorkItemType.task
                    ? 'Task title'
                    : 'Issue title',
                hintText: _selectedType == WorkItemType.task
                    ? 'e.g., Turn Missy out to paddock 2'
                    : 'e.g., Broken fence in paddock 3',
                filled: true,
                fillColor: isDark
                    ? Colors.white.withValues(alpha: 0.05)
                    : Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              style: TextStyle(color: isDark ? Colors.white : Colors.black87),
            ),
            const SizedBox(height: 12),

            // Location field (issues only)
            if (_selectedType == WorkItemType.issue) ...[
              TextField(
                controller: _locationController,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  labelText: 'Location',
                  hintText: 'e.g., Paddock 3, near the gate',
                  prefixIcon: const Icon(Icons.location_on_outlined),
                  filled: true,
                  fillColor: isDark
                      ? Colors.white.withValues(alpha: 0.05)
                      : Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                style: TextStyle(color: isDark ? Colors.white : Colors.black87),
              ),
              const SizedBox(height: 12),
            ],

            // Description field
            TextField(
              controller: _descriptionController,
              maxLines: 2,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: 'Description (optional)',
                filled: true,
                fillColor: isDark
                    ? Colors.white.withValues(alpha: 0.05)
                    : Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              style: TextStyle(color: isDark ? Colors.white : Colors.black87),
            ),
            const SizedBox(height: 16),

            // Assignment dropdown
            Text(
              'Assign to',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.white70 : Colors.black54,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.05)
                    : Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String?>(
                  value: _selectedAssignee,
                  isExpanded: true,
                  hint: Text(
                    'Unassigned',
                    style: TextStyle(
                      color: isDark ? Colors.white38 : Colors.black38,
                    ),
                  ),
                  dropdownColor: isDark
                      ? const Color(0xFF2A2A2A)
                      : Colors.white,
                  items: [
                    DropdownMenuItem<String?>(
                      value: null,
                      child: Text(
                        'Unassigned',
                        style: TextStyle(
                          color: isDark ? Colors.white70 : Colors.black87,
                        ),
                      ),
                    ),
                    DropdownMenuItem<String?>(
                      value: 'me',
                      child: Text(
                        'Assign to me',
                        style: TextStyle(
                          color: isDark ? Colors.white70 : Colors.black87,
                        ),
                      ),
                    ),
                    // Show staff list for managers/owners
                    if (widget.canAssign)
                      ..._staffList.map((member) {
                        final userId = member['user_id'] as String;
                        final name =
                            member['full_name'] as String? ?? 'Unknown';
                        final role = member['role'] as String? ?? 'staff';
                        return DropdownMenuItem<String?>(
                          value: userId,
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  name,
                                  style: TextStyle(
                                    color: isDark
                                        ? Colors.white70
                                        : Colors.black87,
                                  ),
                                ),
                              ),
                              Text(
                                role[0].toUpperCase() + role.substring(1),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark
                                      ? Colors.white38
                                      : Colors.black38,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                  ],
                  onChanged: (value) =>
                      setState(() => _selectedAssignee = value),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Priority selector
            Text(
              'Priority',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.white70 : Colors.black54,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: WorkItemPriority.values.map((priority) {
                final isSelected = priority == _selectedPriority;
                final color = _getPriorityColor(priority);
                return ChoiceChip(
                  label: Text(priority.displayName),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() => _selectedPriority = priority);
                    }
                  },
                  selectedColor: color.withValues(alpha: 0.2),
                  labelStyle: TextStyle(
                    color: isSelected ? color : null,
                    fontWeight: isSelected ? FontWeight.w600 : null,
                  ),
                );
              }).toList(),
            ),

            // Due date (tasks only)
            if (_selectedType == WorkItemType.task) ...[
              const SizedBox(height: 16),
              InkWell(
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _selectedDueDate ?? DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (date != null) {
                    setState(() => _selectedDueDate = date);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.05)
                        : Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 20,
                        color: isDark ? Colors.white54 : Colors.black45,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        _selectedDueDate != null
                            ? '${_selectedDueDate!.day}/${_selectedDueDate!.month}/${_selectedDueDate!.year}'
                            : 'Set due date (optional)',
                        style: TextStyle(
                          color: _selectedDueDate != null
                              ? (isDark ? Colors.white : Colors.black87)
                              : (isDark ? Colors.white38 : Colors.black38),
                        ),
                      ),
                      const Spacer(),
                      if (_selectedDueDate != null)
                        IconButton(
                          onPressed: () =>
                              setState(() => _selectedDueDate = null),
                          icon: Icon(
                            Icons.clear,
                            size: 18,
                            color: isDark ? Colors.white38 : Colors.black38,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 24),

            // Create button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isCreating ? null : _create,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFD66B),
                  foregroundColor: Colors.black87,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isCreating
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text('Create ${_selectedType.displayName}'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getPriorityColor(WorkItemPriority priority) {
    return switch (priority) {
      WorkItemPriority.urgent => Colors.red,
      WorkItemPriority.high => Colors.orange,
      WorkItemPriority.medium => Colors.blue,
      WorkItemPriority.low => Colors.grey,
    };
  }
}

class _TypeOption extends StatelessWidget {
  const _TypeOption({
    required this.type,
    required this.isSelected,
    required this.onSelected,
    required this.isDark,
  });

  final WorkItemType type;
  final bool isSelected;
  final VoidCallback onSelected;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final color = type == WorkItemType.task ? Colors.blue : Colors.orange;

    return GestureDetector(
      onTap: onSelected,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withValues(alpha: 0.15)
              : (isDark
                    ? Colors.white.withValues(alpha: 0.05)
                    : Colors.grey[100]),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(
              type == WorkItemType.task
                  ? Icons.check_circle_outline
                  : Icons.report_problem_outlined,
              size: 28,
              color: isSelected
                  ? color
                  : (isDark ? Colors.white54 : Colors.black45),
            ),
            const SizedBox(height: 8),
            Text(
              type.displayName,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? color
                    : (isDark ? Colors.white : Colors.black87),
              ),
            ),
            Text(
              type.subtitle,
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.white38 : Colors.black38,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ITEM DETAILS SHEET
// ─────────────────────────────────────────────────────────────────────────────

class _ItemDetailsSheet extends StatelessWidget {
  const _ItemDetailsSheet({
    required this.item,
    required this.repository,
    required this.onUpdated,
  });

  final WorkItem item;
  final WorkListRepository repository;
  final VoidCallback onUpdated;

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

          // Type badge + Title
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
                  color: _getPriorityColor(
                    item.priority,
                  ).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  item.priority.displayName,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _getPriorityColor(item.priority),
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
                        await repository.assignToSelf(item);
                        onUpdated();
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
                      await repository.updateStatus(
                        item,
                        WorkItemStatus.completed,
                      );
                      onUpdated();
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

  Color _getPriorityColor(WorkItemPriority priority) {
    return switch (priority) {
      WorkItemPriority.urgent => Colors.red,
      WorkItemPriority.high => Colors.orange,
      WorkItemPriority.medium => Colors.blue,
      WorkItemPriority.low => Colors.grey,
    };
  }
}
