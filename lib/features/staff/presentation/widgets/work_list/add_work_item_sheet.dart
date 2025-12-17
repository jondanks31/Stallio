import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../../core/ui/snackbar_service.dart';
import '../../../data/work_list_repository.dart';
import 'work_item_card.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ADD WORK ITEM SHEET - Form to create new tasks or issues
// ─────────────────────────────────────────────────────────────────────────────

/// Bottom sheet for adding new work items (tasks or issues)
class AddWorkItemSheet extends StatefulWidget {
  const AddWorkItemSheet({
    super.key,
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
  State<AddWorkItemSheet> createState() => _AddWorkItemSheetState();
}

class _AddWorkItemSheetState extends State<AddWorkItemSheet> {
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
                  child: WorkItemTypeOption(
                    type: WorkItemType.task,
                    isSelected: _selectedType == WorkItemType.task,
                    onSelected: () =>
                        setState(() => _selectedType = WorkItemType.task),
                    isDark: isDark,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: WorkItemTypeOption(
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
            _buildAssignmentDropdown(isDark),
            const SizedBox(height: 16),

            // Priority selector
            _buildPrioritySelector(isDark),

            // Due date (tasks only)
            if (_selectedType == WorkItemType.task) ...[
              const SizedBox(height: 16),
              _buildDueDateSelector(isDark),
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

  Widget _buildAssignmentDropdown(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
              dropdownColor: isDark ? const Color(0xFF2A2A2A) : Colors.white,
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
                    final name = member['full_name'] as String? ?? 'Unknown';
                    final role = member['role'] as String? ?? 'staff';
                    return DropdownMenuItem<String?>(
                      value: userId,
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              name,
                              style: TextStyle(
                                color: isDark ? Colors.white70 : Colors.black87,
                              ),
                            ),
                          ),
                          Text(
                            role[0].toUpperCase() + role.substring(1),
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? Colors.white38 : Colors.black38,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
              ],
              onChanged: (value) => setState(() => _selectedAssignee = value),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPrioritySelector(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
            final color = getPriorityColor(priority);
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
      ],
    );
  }

  Widget _buildDueDateSelector(bool isDark) {
    return InkWell(
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
                onPressed: () => setState(() => _selectedDueDate = null),
                icon: Icon(
                  Icons.clear,
                  size: 18,
                  color: isDark ? Colors.white38 : Colors.black38,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Type option selector (Task / Issue)
class WorkItemTypeOption extends StatelessWidget {
  const WorkItemTypeOption({
    super.key,
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
