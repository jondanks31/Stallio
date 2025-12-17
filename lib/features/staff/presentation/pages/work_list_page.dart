import 'package:flutter/material.dart';

import '../../../../core/ui/snackbar_service.dart';
import '../../data/work_list_repository.dart';
import '../widgets/work_list/add_work_item_sheet.dart';
import '../widgets/work_list/work_item_card.dart';
import '../widgets/work_list/work_item_dialogs.dart';
import '../widgets/work_list/work_list_filters.dart';

// ─────────────────────────────────────────────────────────────────────────────
// WORK LIST PAGE - Unified view for tasks and issues
// ─────────────────────────────────────────────────────────────────────────────

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
  List<Map<String, dynamic>> _staffList = [];
  bool _isLoading = true;

  // Filters
  WorkItemType? _typeFilter; // null = All
  int _assignmentFilter = 0; // 0 = Mine, 1 = Unassigned, 2 = All

  @override
  void initState() {
    super.initState();
    _loadItems();
    if (widget.canAssign) {
      _loadStaffList();
    }
  }

  Future<void> _loadStaffList() async {
    final staff = await _repository.getAssignableStaff(widget.yardId);
    if (mounted) {
      setState(() => _staffList = staff);
    }
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

  Future<void> _handleAssign(WorkItem item) async {
    if (_staffList.isEmpty) {
      SnackbarService.showError(context, 'No staff members to assign to');
      return;
    }

    await showAssignDialog(
      context: context,
      item: item,
      staffList: _staffList,
      onAssign: (userId) async {
        await _repository.assignToUser(item, userId);
        await _loadItems();
      },
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
      builder: (context) => WorkItemDetailsSheet(
        item: item,
        onAssignToSelf: () async {
          Navigator.pop(context);
          await _assignToSelf(item);
        },
        onComplete: () async {
          Navigator.pop(context);
          await _updateStatus(item, WorkItemStatus.completed);
        },
      ),
    );
  }

  void _showAddDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => AddWorkItemSheet(
        yardId: widget.yardId,
        repository: _repository,
        onCreated: _loadItems,
        canAssign: widget.canAssign,
      ),
    );
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
                WorkListAssignmentToggle(
                  selectedFilter: _assignmentFilter,
                  onFilterChanged: (filter) {
                    setState(() => _assignmentFilter = filter);
                    _loadItems();
                  },
                  showAllOption: widget.canAssign,
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Type filter chips (All / Tasks / Issues)
            WorkListTypeFilter(
              selectedType: _typeFilter,
              onTypeChanged: (type) {
                setState(() => _typeFilter = type);
                _loadItems();
              },
            ),
            const SizedBox(height: 16),

            // Work items list
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _items.isEmpty
                  ? WorkListEmptyState(assignmentFilter: _assignmentFilter)
                  : RefreshIndicator(
                      onRefresh: _loadItems,
                      child: ListView.separated(
                        padding: const EdgeInsets.only(bottom: 80),
                        itemCount: _items.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final item = _items[index];
                          return WorkItemCard(
                            item: item,
                            onTap: () => _showItemDetails(item),
                            onAssignToSelf: () => _assignToSelf(item),
                            onComplete: () =>
                                _updateStatus(item, WorkItemStatus.completed),
                            onAssign: widget.canAssign
                                ? () => _handleAssign(item)
                                : null,
                            canAssign: widget.canAssign,
                          );
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
}
