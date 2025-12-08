import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

/// Work item type - either a routine Task or an ad-hoc Issue
enum WorkItemType {
  task('task', 'Task', 'Routine'),
  issue('issue', 'Issue', 'Ad-hoc');

  const WorkItemType(this.value, this.displayName, this.subtitle);
  final String value;
  final String displayName;
  final String subtitle;
}

/// Work item status
enum WorkItemStatus {
  open('open', 'Open'),
  inProgress('in_progress', 'In Progress'),
  completed(
    'completed',
    'Done',
  ); // 'completed' for tasks, 'resolved' for issues

  const WorkItemStatus(this.value, this.displayName);
  final String value;
  final String displayName;

  static WorkItemStatus fromString(String value) {
    // Map 'resolved' to completed for issues
    if (value == 'resolved') return WorkItemStatus.completed;
    return WorkItemStatus.values.firstWhere(
      (s) => s.value == value,
      orElse: () => WorkItemStatus.open,
    );
  }
}

/// Work item priority
enum WorkItemPriority {
  low('low', 'Low', 0),
  medium('medium', 'Medium', 1),
  high('high', 'High', 2),
  urgent('urgent', 'Urgent', 3);

  const WorkItemPriority(this.value, this.displayName, this.sortOrder);
  final String value;
  final String displayName;
  final int sortOrder; // Higher = more urgent

  static WorkItemPriority fromString(String value) {
    return WorkItemPriority.values.firstWhere(
      (p) => p.value == value,
      orElse: () => WorkItemPriority.medium,
    );
  }
}

/// Unified work item model - abstracts both Tasks and Issues
class WorkItem {
  final String id;
  final String yardId;
  final WorkItemType type;
  final String title;
  final String? description;
  final WorkItemStatus status;
  final WorkItemPriority priority;
  final String? assignedToUserId;
  final String? assignedToName;
  final String createdBy;
  final String? createdByName;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? dueDate;
  final DateTime? completedAt;
  final String? completedByUserId;
  final String? completedByName;

  // Issue-specific fields
  final String? location;
  final String? photoUrl;

  WorkItem({
    required this.id,
    required this.yardId,
    required this.type,
    required this.title,
    this.description,
    required this.status,
    required this.priority,
    this.assignedToUserId,
    this.assignedToName,
    required this.createdBy,
    this.createdByName,
    required this.createdAt,
    required this.updatedAt,
    this.dueDate,
    this.completedAt,
    this.completedByUserId,
    this.completedByName,
    this.location,
    this.photoUrl,
  });

  bool get isTask => type == WorkItemType.task;
  bool get isIssue => type == WorkItemType.issue;
  bool get isCompleted => status == WorkItemStatus.completed;
  bool get isAssigned => assignedToUserId != null;

  bool get isOverdue =>
      dueDate != null &&
      dueDate!.isBefore(DateTime.now()) &&
      status != WorkItemStatus.completed;

  bool get isDueToday {
    if (dueDate == null) return false;
    final now = DateTime.now();
    return dueDate!.year == now.year &&
        dueDate!.month == now.month &&
        dueDate!.day == now.day;
  }

  /// Create a copy with updated fields
  WorkItem copyWith({
    String? createdByName,
    String? assignedToName,
    String? completedByName,
  }) {
    return WorkItem(
      id: id,
      yardId: yardId,
      type: type,
      title: title,
      description: description,
      status: status,
      priority: priority,
      assignedToUserId: assignedToUserId,
      assignedToName: assignedToName ?? this.assignedToName,
      createdBy: createdBy,
      createdByName: createdByName ?? this.createdByName,
      createdAt: createdAt,
      updatedAt: updatedAt,
      dueDate: dueDate,
      completedAt: completedAt,
      completedByUserId: completedByUserId,
      completedByName: completedByName ?? this.completedByName,
      location: location,
      photoUrl: photoUrl,
    );
  }

  /// Factory to create WorkItem from a task JSON
  factory WorkItem.fromTask(Map<String, dynamic> json) {
    return WorkItem(
      id: json['id'] as String,
      yardId: json['yard_id'] as String,
      type: WorkItemType.task,
      title: json['title'] as String,
      description: json['description'] as String?,
      status: WorkItemStatus.fromString(json['status'] as String? ?? 'open'),
      priority: WorkItemPriority.fromString(
        json['priority'] as String? ?? 'medium',
      ),
      assignedToUserId: json['assigned_to_user_id'] as String?,
      createdBy: json['created_by'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      dueDate: json['due_date'] != null
          ? DateTime.parse(json['due_date'] as String)
          : null,
    );
  }

  /// Factory to create WorkItem from an issue JSON
  factory WorkItem.fromIssue(Map<String, dynamic> json) {
    return WorkItem(
      id: json['id'] as String,
      yardId: json['yard_id'] as String,
      type: WorkItemType.issue,
      title: json['title'] as String,
      description: json['description'] as String?,
      status: WorkItemStatus.fromString(json['status'] as String? ?? 'open'),
      priority: WorkItemPriority.fromString(
        json['priority'] as String? ?? 'medium',
      ),
      assignedToUserId: json['assigned_to'] as String?,
      createdBy: json['reporter_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      completedAt: json['resolved_at'] != null
          ? DateTime.parse(json['resolved_at'] as String)
          : null,
      completedByUserId: json['resolved_by'] as String?,
      location: json['location'] as String?,
      photoUrl: json['photo_url'] as String?,
    );
  }
}

/// Repository for the unified work list
class WorkListRepository {
  final _supabase = Supabase.instance.client;
  static const _uuid = Uuid();

  /// Fetch profile names for a list of user IDs
  Future<Map<String, String>> _getProfileNames(Set<String> userIds) async {
    if (userIds.isEmpty) return {};

    final response = await _supabase
        .from('profiles')
        .select('user_id, full_name')
        .inFilter('user_id', userIds.toList());

    final names = <String, String>{};
    for (final profile in response as List) {
      final userId = profile['user_id'] as String?;
      final name = profile['full_name'] as String?;
      if (userId != null && name != null) {
        names[userId] = name;
      }
    }
    return names;
  }

  /// Get all work items (tasks + issues) for a yard, sorted by priority
  Future<List<WorkItem>> getWorkItems(
    String yardId, {
    WorkItemType? typeFilter,
    WorkItemStatus? statusFilter,
    String? assignedToUserId,
    bool includeCompleted = false,
  }) async {
    final items = <WorkItem>[];

    // Fetch tasks if not filtered to issues only
    if (typeFilter == null || typeFilter == WorkItemType.task) {
      var taskQuery = _supabase.from('tasks').select().eq('yard_id', yardId);

      if (statusFilter != null) {
        taskQuery = taskQuery.eq('status', statusFilter.value);
      } else if (!includeCompleted) {
        taskQuery = taskQuery.neq('status', 'completed');
      }

      if (assignedToUserId != null) {
        taskQuery = taskQuery.eq('assigned_to_user_id', assignedToUserId);
      }

      final taskResponse = await taskQuery.order(
        'created_at',
        ascending: false,
      );
      for (final task in taskResponse as List) {
        items.add(WorkItem.fromTask(task));
      }
    }

    // Fetch issues if not filtered to tasks only
    if (typeFilter == null || typeFilter == WorkItemType.issue) {
      var issueQuery = _supabase.from('issues').select().eq('yard_id', yardId);

      if (statusFilter != null) {
        final issueStatus = statusFilter == WorkItemStatus.completed
            ? 'resolved'
            : statusFilter.value;
        issueQuery = issueQuery.eq('status', issueStatus);
      } else if (!includeCompleted) {
        issueQuery = issueQuery.neq('status', 'resolved');
      }

      if (assignedToUserId != null) {
        issueQuery = issueQuery.eq('assigned_to', assignedToUserId);
      }

      final issueResponse = await issueQuery.order(
        'created_at',
        ascending: false,
      );
      for (final issue in issueResponse as List) {
        items.add(WorkItem.fromIssue(issue));
      }
    }

    // Fetch profile names for all users involved
    final userIds = <String>{};
    for (final item in items) {
      userIds.add(item.createdBy);
      if (item.assignedToUserId != null) userIds.add(item.assignedToUserId!);
      if (item.completedByUserId != null) userIds.add(item.completedByUserId!);
    }
    final names = await _getProfileNames(userIds);

    // Update items with profile names
    final enrichedItems = items
        .map(
          (item) => item.copyWith(
            createdByName: names[item.createdBy],
            assignedToName: item.assignedToUserId != null
                ? names[item.assignedToUserId]
                : null,
            completedByName: item.completedByUserId != null
                ? names[item.completedByUserId]
                : null,
          ),
        )
        .toList();

    // Sort by priority (urgent first) then by created date
    enrichedItems.sort((a, b) {
      // First by priority (higher = more urgent)
      final priorityCompare = b.priority.sortOrder.compareTo(
        a.priority.sortOrder,
      );
      if (priorityCompare != 0) return priorityCompare;

      // Then by status (open > inProgress > completed)
      if (a.status != b.status) {
        if (a.status == WorkItemStatus.open) return -1;
        if (b.status == WorkItemStatus.open) return 1;
        if (a.status == WorkItemStatus.inProgress) return -1;
        if (b.status == WorkItemStatus.inProgress) return 1;
      }

      // Finally by created date (newest first)
      return b.createdAt.compareTo(a.createdAt);
    });

    return enrichedItems;
  }

  /// Get work items assigned to current user
  Future<List<WorkItem>> getMyWorkItems(String yardId) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return [];

    return getWorkItems(yardId, assignedToUserId: userId);
  }

  /// Get unassigned work items
  Future<List<WorkItem>> getUnassignedWorkItems(String yardId) async {
    final items = <WorkItem>[];

    // Unassigned tasks
    final taskResponse = await _supabase
        .from('tasks')
        .select()
        .eq('yard_id', yardId)
        .isFilter('assigned_to_user_id', null)
        .neq('status', 'completed');

    for (final task in taskResponse as List) {
      items.add(WorkItem.fromTask(task));
    }

    // Unassigned issues
    final issueResponse = await _supabase
        .from('issues')
        .select()
        .eq('yard_id', yardId)
        .isFilter('assigned_to', null)
        .neq('status', 'resolved');

    for (final issue in issueResponse as List) {
      items.add(WorkItem.fromIssue(issue));
    }

    // Fetch profile names
    final userIds = <String>{};
    for (final item in items) {
      userIds.add(item.createdBy);
    }
    final names = await _getProfileNames(userIds);

    // Enrich with names and sort by priority
    final enrichedItems = items
        .map((item) => item.copyWith(createdByName: names[item.createdBy]))
        .toList();
    enrichedItems.sort(
      (a, b) => b.priority.sortOrder.compareTo(a.priority.sortOrder),
    );

    return enrichedItems;
  }

  /// Assign work item to current user (self-assign)
  Future<void> assignToSelf(WorkItem item) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('Not authenticated');

    if (item.isTask) {
      await _supabase
          .from('tasks')
          .update({
            'assigned_to_user_id': userId,
            'status': 'in_progress',
            'updated_at': DateTime.now().toUtc().toIso8601String(),
          })
          .eq('id', item.id);
    } else {
      await _supabase
          .from('issues')
          .update({
            'assigned_to': userId,
            'status': 'in_progress',
            'updated_at': DateTime.now().toUtc().toIso8601String(),
          })
          .eq('id', item.id);
    }
  }

  /// Assign work item to a specific user (manager/owner capability)
  /// Validates that the target user is in the same yard
  Future<void> assignToUser(WorkItem item, String targetUserId) async {
    // Verify target user is in the same yard
    final targetProfile = await _supabase
        .from('profiles')
        .select('yard_id')
        .eq('user_id', targetUserId)
        .maybeSingle();

    if (targetProfile == null || targetProfile['yard_id'] != item.yardId) {
      throw Exception('Cannot assign to user outside this yard');
    }

    if (item.isTask) {
      await _supabase
          .from('tasks')
          .update({
            'assigned_to_user_id': targetUserId,
            'status': 'in_progress',
            'updated_at': DateTime.now().toUtc().toIso8601String(),
          })
          .eq('id', item.id);
    } else {
      await _supabase
          .from('issues')
          .update({
            'assigned_to': targetUserId,
            'status': 'in_progress',
            'updated_at': DateTime.now().toUtc().toIso8601String(),
          })
          .eq('id', item.id);
    }
  }

  /// Get assignable staff members for the yard
  /// Automatically determines caller's role to filter assignable users
  Future<List<Map<String, dynamic>>> getAssignableStaff(String yardId) async {
    final currentUserId = _supabase.auth.currentUser?.id;
    if (currentUserId == null) return [];

    // Get current user's role in this yard
    final myProfile = await _supabase
        .from('profiles')
        .select('role')
        .eq('user_id', currentUserId)
        .eq('yard_id', yardId)
        .maybeSingle();

    if (myProfile == null) return [];

    final myRole = myProfile['role'] as String?;
    final isOwner = myRole == 'owner';

    // Staff can be assigned by managers and owners
    // Managers can be assigned by owners only
    final roles = isOwner ? ['staff', 'manager'] : ['staff'];

    final response = await _supabase
        .from('profiles')
        .select('user_id, full_name, role')
        .eq('yard_id', yardId)
        .inFilter('role', roles)
        .order('full_name');

    return (response as List).cast<Map<String, dynamic>>();
  }

  /// Update work item status
  Future<void> updateStatus(WorkItem item, WorkItemStatus status) async {
    final userId = _supabase.auth.currentUser?.id;

    if (item.isTask) {
      await _supabase
          .from('tasks')
          .update({
            'status': status.value,
            'updated_at': DateTime.now().toUtc().toIso8601String(),
          })
          .eq('id', item.id);
    } else {
      final updates = <String, dynamic>{
        'status': status == WorkItemStatus.completed
            ? 'resolved'
            : status.value,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      };

      // Track who resolved the issue
      if (status == WorkItemStatus.completed && userId != null) {
        updates['resolved_at'] = DateTime.now().toUtc().toIso8601String();
        updates['resolved_by'] = userId;
      }

      await _supabase.from('issues').update(updates).eq('id', item.id);
    }
  }

  /// Update work item priority
  Future<void> updatePriority(WorkItem item, WorkItemPriority priority) async {
    final table = item.isTask ? 'tasks' : 'issues';
    await _supabase
        .from(table)
        .update({
          'priority': priority.value,
          'updated_at': DateTime.now().toUtc().toIso8601String(),
        })
        .eq('id', item.id);
  }

  /// Create a new task
  Future<WorkItem> createTask({
    required String yardId,
    required String title,
    String? description,
    WorkItemPriority priority = WorkItemPriority.medium,
    String? assignToUserId,
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
          'assigned_to_user_id': assignToUserId,
          'due_date': dueDate?.toIso8601String(),
          'created_by': userId,
        })
        .select()
        .single();

    return WorkItem.fromTask(response);
  }

  /// Create a new issue (report an issue)
  Future<WorkItem> createIssue({
    required String yardId,
    required String title,
    String? description,
    String? location,
    String? photoUrl,
    WorkItemPriority priority = WorkItemPriority.medium,
    String? assignToUserId,
  }) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('Not authenticated');

    final id = _uuid.v4();

    final response = await _supabase
        .from('issues')
        .insert({
          'id': id,
          'yard_id': yardId,
          'reporter_id': userId,
          'title': title,
          'description': description,
          'location': location,
          'photo_url': photoUrl,
          'priority': priority.value,
          'assigned_to': assignToUserId,
        })
        .select()
        .single();

    return WorkItem.fromIssue(response);
  }

  /// Get counts for dashboard stats
  Future<Map<String, int>> getCounts(String yardId) async {
    // Open tasks
    final openTasksResponse = await _supabase
        .from('tasks')
        .select()
        .eq('yard_id', yardId)
        .neq('status', 'completed')
        .count(CountOption.exact);

    // Open issues
    final openIssuesResponse = await _supabase
        .from('issues')
        .select()
        .eq('yard_id', yardId)
        .neq('status', 'resolved')
        .count(CountOption.exact);

    // Urgent items (both)
    final urgentTasksResponse = await _supabase
        .from('tasks')
        .select()
        .eq('yard_id', yardId)
        .eq('priority', 'urgent')
        .neq('status', 'completed')
        .count(CountOption.exact);

    final urgentIssuesResponse = await _supabase
        .from('issues')
        .select()
        .eq('yard_id', yardId)
        .eq('priority', 'urgent')
        .neq('status', 'resolved')
        .count(CountOption.exact);

    return {
      'tasks': openTasksResponse.count,
      'issues': openIssuesResponse.count,
      'total': openTasksResponse.count + openIssuesResponse.count,
      'urgent': urgentTasksResponse.count + urgentIssuesResponse.count,
    };
  }
}
