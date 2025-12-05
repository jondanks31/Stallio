import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

/// Issue status enum
enum IssueStatus {
  open('open', 'Open'),
  inProgress('in_progress', 'In Progress'),
  resolved('resolved', 'Resolved');

  const IssueStatus(this.value, this.displayName);
  final String value;
  final String displayName;

  static IssueStatus fromString(String value) {
    return IssueStatus.values.firstWhere(
      (s) => s.value == value,
      orElse: () => IssueStatus.open,
    );
  }
}

/// Issue model
class Issue {
  final String id;
  final String yardId;
  final String reporterId;
  final String title;
  final String? description;
  final String? location;
  final String? photoUrl;
  final IssueStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? resolvedAt;

  // Joined fields
  final String? reporterName;

  Issue({
    required this.id,
    required this.yardId,
    required this.reporterId,
    required this.title,
    this.description,
    this.location,
    this.photoUrl,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.resolvedAt,
    this.reporterName,
  });

  bool get isOpen => status == IssueStatus.open;
  bool get isResolved => status == IssueStatus.resolved;

  factory Issue.fromJson(Map<String, dynamic> json) {
    final reporter = json['reporter'] as Map<String, dynamic>?;

    return Issue(
      id: json['id'] as String,
      yardId: json['yard_id'] as String,
      reporterId: json['reporter_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      location: json['location'] as String?,
      photoUrl: json['photo_url'] as String?,
      status: IssueStatus.fromString(json['status'] as String? ?? 'open'),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      resolvedAt: json['resolved_at'] != null
          ? DateTime.parse(json['resolved_at'] as String)
          : null,
      reporterName: reporter?['full_name'] as String?,
    );
  }
}

/// Repository for issue management
class IssuesRepository {
  final _supabase = Supabase.instance.client;
  static const _uuid = Uuid();

  /// Get issues for a yard
  Future<List<Issue>> getIssues(
    String yardId, {
    IssueStatus? status,
    bool includeResolved = false,
  }) async {
    var query = _supabase
        .from('issues')
        .select('''
          *,
          reporter:profiles!issues_reporter_id_fkey(full_name)
        ''')
        .eq('yard_id', yardId);

    if (status != null) {
      query = query.eq('status', status.value);
    } else if (!includeResolved) {
      query = query.neq('status', 'resolved');
    }

    final response = await query.order('created_at', ascending: false);

    return (response as List).map((json) => Issue.fromJson(json)).toList();
  }

  /// Get issue counts for dashboard
  Future<Map<String, int>> getIssueCounts(String yardId) async {
    // Open issues
    final openResponse = await _supabase
        .from('issues')
        .select()
        .eq('yard_id', yardId)
        .eq('status', 'open')
        .count(CountOption.exact);

    // In progress issues
    final inProgressResponse = await _supabase
        .from('issues')
        .select()
        .eq('yard_id', yardId)
        .eq('status', 'in_progress')
        .count(CountOption.exact);

    return {
      'open': openResponse.count,
      'inProgress': inProgressResponse.count,
      'total': openResponse.count + inProgressResponse.count,
    };
  }

  /// Create a new issue
  Future<Issue> createIssue({
    required String yardId,
    required String title,
    String? description,
    String? location,
    String? photoUrl,
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
        })
        .select('''
          *,
          reporter:profiles!issues_reporter_id_fkey(full_name)
        ''')
        .single();

    return Issue.fromJson(response);
  }

  /// Update issue status
  Future<void> updateIssueStatus(String issueId, IssueStatus status) async {
    final updates = <String, dynamic>{
      'status': status.value,
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    };

    if (status == IssueStatus.resolved) {
      updates['resolved_at'] = DateTime.now().toUtc().toIso8601String();
    }

    await _supabase.from('issues').update(updates).eq('id', issueId);
  }

  /// Update issue
  Future<void> updateIssue(String issueId, Map<String, dynamic> updates) async {
    updates['updated_at'] = DateTime.now().toUtc().toIso8601String();
    await _supabase.from('issues').update(updates).eq('id', issueId);
  }

  /// Delete issue
  Future<void> deleteIssue(String issueId) async {
    await _supabase.from('issues').delete().eq('id', issueId);
  }
}
