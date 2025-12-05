import 'package:flutter/material.dart';

import '../../../../core/ui/snackbar_service.dart';
import '../../data/tasks_repository.dart';

/// Tasks page for staff - shows assigned tasks and allows status updates.
class TasksPage extends StatefulWidget {
  const TasksPage({super.key, required this.yardId});

  final String yardId;

  @override
  State<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> {
  final _repository = TasksRepository();

  List<Task> _tasks = [];
  bool _isLoading = true;
  bool _showAllTasks = false;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    setState(() => _isLoading = true);
    try {
      final tasks = _showAllTasks
          ? await _repository.getTasks(widget.yardId)
          : await _repository.getMyTasks(widget.yardId);

      if (mounted) {
        setState(() {
          _tasks = tasks;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        SnackbarService.showError(context, 'Failed to load tasks');
      }
    }
  }

  Future<void> _toggleTaskStatus(Task task) async {
    final newStatus = task.status == TaskStatus.completed
        ? TaskStatus.open
        : task.status == TaskStatus.open
        ? TaskStatus.inProgress
        : TaskStatus.completed;

    try {
      await _repository.updateTaskStatus(task.id, newStatus);
      await _loadTasks();
      if (mounted) {
        SnackbarService.showSuccess(
          context,
          'Task marked as ${newStatus.displayName}',
        );
      }
    } catch (e) {
      if (mounted) {
        SnackbarService.showError(context, 'Failed to update task');
      }
    }
  }

  Future<void> _assignToSelf(Task task) async {
    try {
      await _repository.assignToSelf(task.id);
      await _loadTasks();
      if (mounted) {
        SnackbarService.showSuccess(context, 'Task assigned to you');
      }
    } catch (e) {
      if (mounted) {
        SnackbarService.showError(context, 'Failed to assign task');
      }
    }
  }

  void _showAddTaskDialog() {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    TaskPriority selectedPriority = TaskPriority.medium;
    DateTime? selectedDueDate;

    showDialog(
      context: context,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Add Task',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: Icon(
                              Icons.close,
                              color: isDark ? Colors.white54 : Colors.black45,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: titleController,
                        decoration: InputDecoration(
                          labelText: 'Task title',
                          filled: true,
                          fillColor: isDark
                              ? Colors.white.withValues(alpha: 0.05)
                              : Colors.grey[100],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: descriptionController,
                        maxLines: 3,
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
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 16),
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
                        children: TaskPriority.values.map((priority) {
                          final isSelected = priority == selectedPriority;
                          final color = _getPriorityColor(priority);
                          return ChoiceChip(
                            label: Text(priority.displayName),
                            selected: isSelected,
                            onSelected: (selected) {
                              if (selected) {
                                setDialogState(
                                  () => selectedPriority = priority,
                                );
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
                      const SizedBox(height: 16),
                      InkWell(
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: selectedDueDate ?? DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(
                              const Duration(days: 365),
                            ),
                          );
                          if (date != null) {
                            setDialogState(() => selectedDueDate = date);
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
                                selectedDueDate != null
                                    ? '${selectedDueDate!.day}/${selectedDueDate!.month}/${selectedDueDate!.year}'
                                    : 'Set due date (optional)',
                                style: TextStyle(
                                  color: selectedDueDate != null
                                      ? (isDark ? Colors.white : Colors.black87)
                                      : (isDark
                                            ? Colors.white38
                                            : Colors.black38),
                                ),
                              ),
                              const Spacer(),
                              if (selectedDueDate != null)
                                IconButton(
                                  onPressed: () {
                                    setDialogState(
                                      () => selectedDueDate = null,
                                    );
                                  },
                                  icon: Icon(
                                    Icons.clear,
                                    size: 18,
                                    color: isDark
                                        ? Colors.white38
                                        : Colors.black38,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(context),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                side: BorderSide(
                                  color: isDark
                                      ? Colors.white24
                                      : Colors.black12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                'Cancel',
                                style: TextStyle(
                                  color: isDark
                                      ? Colors.white70
                                      : Colors.black54,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () async {
                                if (titleController.text.trim().isEmpty) {
                                  SnackbarService.showError(
                                    context,
                                    'Please enter a task title',
                                  );
                                  return;
                                }

                                Navigator.pop(context);
                                try {
                                  await _repository.createTask(
                                    yardId: widget.yardId,
                                    title: titleController.text.trim(),
                                    description:
                                        descriptionController.text
                                            .trim()
                                            .isEmpty
                                        ? null
                                        : descriptionController.text.trim(),
                                    priority: selectedPriority,
                                    dueDate: selectedDueDate,
                                  );
                                  await _loadTasks();
                                  if (mounted) {
                                    SnackbarService.showSuccess(
                                      context,
                                      'Task created',
                                    );
                                  }
                                } catch (e) {
                                  if (mounted) {
                                    SnackbarService.showError(
                                      context,
                                      'Failed to create task',
                                    );
                                  }
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFFD66B),
                                foregroundColor: Colors.black87,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text('Create'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Color _getPriorityColor(TaskPriority priority) {
    return switch (priority) {
      TaskPriority.urgent => Colors.red,
      TaskPriority.high => Colors.orange,
      TaskPriority.medium => Colors.blue,
      TaskPriority.low => Colors.grey,
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          children: [
            Expanded(
              child: Text(
                'Tasks',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ),
            // Toggle between my tasks and all tasks
            Flexible(
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : Colors.grey[100],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildToggleButton('Mine', !_showAllTasks, () {
                      setState(() => _showAllTasks = false);
                      _loadTasks();
                    }, isDark),
                    _buildToggleButton('All', _showAllTasks, () {
                      setState(() => _showAllTasks = true);
                      _loadTasks();
                    }, isDark),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: _showAddTaskDialog,
              icon: const Icon(Icons.add_circle, size: 28),
              color: const Color(0xFFFFD66B),
              tooltip: 'Add Task',
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Task list
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _tasks.isEmpty
              ? _buildEmptyState(isDark)
              : RefreshIndicator(
                  onRefresh: _loadTasks,
                  child: ListView.separated(
                    itemCount: _tasks.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      return _buildTaskCard(_tasks[index], isDark);
                    },
                  ),
                ),
        ),
      ],
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
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFFD66B) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            color: isSelected
                ? Colors.black87
                : (isDark ? Colors.white54 : Colors.black45),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
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
            _showAllTasks ? 'No tasks yet' : 'No tasks assigned to you',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white54 : Colors.black45,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create a task to get started',
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.white38 : Colors.black26,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskCard(Task task, bool isDark) {
    final priorityColor = _getPriorityColor(task.priority);

    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.white12 : Colors.black.withValues(alpha: 0.08),
        ),
      ),
      child: InkWell(
        onTap: () => _toggleTaskStatus(task),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Status checkbox
              GestureDetector(
                onTap: () => _toggleTaskStatus(task),
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: task.status == TaskStatus.completed
                        ? const Color(0xFF10B981)
                        : Colors.transparent,
                    border: Border.all(
                      color: task.status == TaskStatus.completed
                          ? const Color(0xFF10B981)
                          : (isDark ? Colors.white38 : Colors.black26),
                      width: 2,
                    ),
                  ),
                  child: task.status == TaskStatus.completed
                      ? const Icon(Icons.check, size: 16, color: Colors.white)
                      : null,
                ),
              ),
              const SizedBox(width: 12),
              // Priority indicator
              Container(
                width: 4,
                height: 40,
                decoration: BoxDecoration(
                  color: priorityColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              // Task content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: isDark ? Colors.white : Colors.black87,
                        decoration: task.status == TaskStatus.completed
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        if (task.dueDate != null) ...[
                          Icon(
                            Icons.calendar_today,
                            size: 12,
                            color: task.isOverdue
                                ? Colors.red
                                : (isDark ? Colors.white38 : Colors.black38),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            task.isOverdue
                                ? 'Overdue'
                                : task.isDueToday
                                ? 'Due today'
                                : '${task.dueDate!.day}/${task.dueDate!.month}',
                            style: TextStyle(
                              fontSize: 12,
                              color: task.isOverdue
                                  ? Colors.red
                                  : (isDark ? Colors.white38 : Colors.black38),
                            ),
                          ),
                          const SizedBox(width: 12),
                        ],
                        if (task.assignedToName != null) ...[
                          Icon(
                            Icons.person_outline,
                            size: 12,
                            color: isDark ? Colors.white38 : Colors.black38,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            task.assignedToName!,
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? Colors.white38 : Colors.black38,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              // Actions
              if (task.assignedToUserId == null)
                TextButton(
                  onPressed: () => _assignToSelf(task),
                  child: const Text('Assign to me'),
                ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: priorityColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  task.priority.displayName,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: priorityColor,
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
