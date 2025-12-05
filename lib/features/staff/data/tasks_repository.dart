import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

/// Task status enum
enum TaskStatus {
  open('open', 'Open'),
  inProgress('in_progress', 'In Progress'),
  completed('completed', 'Completed');

  const TaskStatus(this.value, this.displayName);
  final String value;
  final String displayName;

  static TaskStatus fromString(String value) {
    return TaskStatus.values.firstWhere(
      (s) => s.value == value,
      orElse: () => TaskStatus.open,
    );
  }
}

/// Task priority enum
enum TaskPriority {
  low('low', 'Low'),
  medium('medium', 'Medium'),
  high('high', 'High'),
  urgent('urgent', 'Urgent');

  const TaskPriority(this.value, this.displayName);
  final String value;
  final String displayName;

  static TaskPriority fromString(String value) {
    return TaskPriority.values.firstWhere(
      (p) => p.value == value,
      orElse: () => TaskPriority.medium,
    );
  }
}

/// Task model
class Task {
  final String id;
  final String yardId;
  final String title;
  final String? description;
  final TaskStatus status;
  final TaskPriority priority;
  final String? assignedToUserId;
  final String? relatedIssueId;
  final DateTime? dueDate;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Joined fields
  final String? assignedToName;
  final String? createdByName;

  Task({
    required this.id,
    required this.yardId,
    required this.title,
    this.description,
    required this.status,
    required this.priority,
    this.assignedToUserId,
    this.relatedIssueId,
    this.dueDate,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    this.assignedToName,
    this.createdByName,
  });

  bool get isOverdue =>
      dueDate != null &&
      dueDate!.isBefore(DateTime.now()) &&
      status != TaskStatus.completed;

  bool get isDueToday {
    if (dueDate == null) return false;
    final now = DateTime.now();
    return dueDate!.year == now.year &&
        dueDate!.month == now.month &&
        dueDate!.day == now.day;
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    final assignedTo = json['assigned_to'] as Map<String, dynamic>?;
    final createdByProfile =
        json['created_by_profile'] as Map<String, dynamic>?;

    return Task(
      id: json['id'] as String,
      yardId: json['yard_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      status: TaskStatus.fromString(json['status'] as String? ?? 'open'),
      priority: TaskPriority.fromString(
        json['priority'] as String? ?? 'medium',
      ),
      assignedToUserId: json['assigned_to_user_id'] as String?,
      relatedIssueId: json['related_issue_id'] as String?,
      dueDate: json['due_date'] != null
          ? DateTime.parse(json['due_date'] as String)
          : null,
      createdBy: json['created_by'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      assignedToName: assignedTo?['full_name'] as String?,
      createdByName: createdByProfile?['full_name'] as String?,
    );
  }
}

/// Repository for task management
class TasksRepository {
  final _supabase = Supabase.instance.client;
  static const _uuid = Uuid();

  /// Get tasks for a yard
  Future<List<Task>> getTasks(
    String yardId, {
    TaskStatus? status,
    String? assignedToUserId,
    bool includeCompleted = false,
  }) async {
    var query = _supabase
        .from('tasks')
        .select('''
          *,
          assigned_to:profiles!tasks_assigned_to_user_id_fkey(full_name),
          created_by_profile:profiles!tasks_created_by_fkey(full_name)
        ''')
        .eq('yard_id', yardId);

    if (status != null) {
      query = query.eq('status', status.value);
    } else if (!includeCompleted) {
      query = query.neq('status', 'completed');
    }

    if (assignedToUserId != null) {
      query = query.eq('assigned_to_user_id', assignedToUserId);
    }

    final response = await query.order(
      'due_date',
      ascending: true,
      nullsFirst: false,
    );

    return (response as List).map((json) => Task.fromJson(json)).toList();
  }

  /// Get tasks assigned to current user
  Future<List<Task>> getMyTasks(String yardId) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return [];

    return getTasks(yardId, assignedToUserId: userId);
  }

  /// Get task counts for dashboard
  Future<Map<String, int>> getTaskCounts(String yardId) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return {'total': 0, 'mine': 0, 'overdue': 0};

    // Total open tasks
    final totalResponse = await _supabase
        .from('tasks')
        .select()
        .eq('yard_id', yardId)
        .neq('status', 'completed')
        .count(CountOption.exact);

    // My tasks
    final myResponse = await _supabase
        .from('tasks')
        .select()
        .eq('yard_id', yardId)
        .eq('assigned_to_user_id', userId)
        .neq('status', 'completed')
        .count(CountOption.exact);

    // Overdue tasks
    final overdueResponse = await _supabase
        .from('tasks')
        .select()
        .eq('yard_id', yardId)
        .neq('status', 'completed')
        .lt('due_date', DateTime.now().toIso8601String().split('T').first)
        .count(CountOption.exact);

    return {
      'total': totalResponse.count,
      'mine': myResponse.count,
      'overdue': overdueResponse.count,
    };
  }

  /// Create a new task
  Future<Task> createTask({
    required String yardId,
    required String title,
    String? description,
    TaskPriority priority = TaskPriority.medium,
    String? assignedToUserId,
    DateTime? dueDate,
  }) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('Not authenticated');

    final id = _uuid.v4();

    final response = await _supabase
        .from('tasks')
        .insert({
          'id': id,
          'yard_id': yardId,
          'title': title,
          'description': description,
          'priority': priority.value,
          'assigned_to_user_id': assignedToUserId,
          'due_date': dueDate?.toIso8601String().split('T').first,
          'created_by': userId,
        })
        .select('''
          *,
          assigned_to:profiles!tasks_assigned_to_user_id_fkey(full_name),
          created_by_profile:profiles!tasks_created_by_fkey(full_name)
        ''')
        .single();

    return Task.fromJson(response);
  }

  /// Update task status
  Future<void> updateTaskStatus(String taskId, TaskStatus status) async {
    await _supabase
        .from('tasks')
        .update({
          'status': status.value,
          'updated_at': DateTime.now().toUtc().toIso8601String(),
        })
        .eq('id', taskId);
  }

  /// Update task
  Future<void> updateTask(String taskId, Map<String, dynamic> updates) async {
    updates['updated_at'] = DateTime.now().toUtc().toIso8601String();
    await _supabase.from('tasks').update(updates).eq('id', taskId);
  }

  /// Delete task
  Future<void> deleteTask(String taskId) async {
    await _supabase.from('tasks').delete().eq('id', taskId);
  }

  /// Assign task to self
  Future<void> assignToSelf(String taskId) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('Not authenticated');

    await updateTask(taskId, {'assigned_to_user_id': userId});
  }
}
