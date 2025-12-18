import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Horse info for staff quick log
class HorseForLog {
  final String id;
  final String name;
  final String? colour;
  final String? photoUrl;
  final String ownerName;
  final bool isAssigned; // Whether this horse is assigned to the current staff

  HorseForLog({
    required this.id,
    required this.name,
    this.colour,
    this.photoUrl,
    required this.ownerName,
    this.isAssigned = false,
  });

  factory HorseForLog.fromJson(
    Map<String, dynamic> json, {
    bool isAssigned = false,
    String? ownerNameOverride,
  }) {
    final owner = json['owner'] as Map<String, dynamic>?;
    return HorseForLog(
      id: json['id'] as String,
      name: json['name'] as String,
      colour: json['colour'] as String?,
      photoUrl: json['photo_url'] as String?,
      ownerName:
          ownerNameOverride ?? owner?['full_name'] as String? ?? 'Unknown',
      isAssigned: isAssigned,
    );
  }
}

/// Staff assignment model
class StaffAssignment {
  final String id;
  final String yardId;
  final String staffUserId;
  final String horseId;
  final String assignedBy;
  final DateTime assignedAt;
  final String? notes;

  // Joined fields
  final String? staffName;
  final String? horseName;

  StaffAssignment({
    required this.id,
    required this.yardId,
    required this.staffUserId,
    required this.horseId,
    required this.assignedBy,
    required this.assignedAt,
    this.notes,
    this.staffName,
    this.horseName,
  });

  factory StaffAssignment.fromJson(Map<String, dynamic> json) {
    final staff = json['staff'] as Map<String, dynamic>?;
    final horse = json['horse'] as Map<String, dynamic>?;

    return StaffAssignment(
      id: json['id'] as String,
      yardId: json['yard_id'] as String,
      staffUserId: json['staff_user_id'] as String,
      horseId: json['horse_id'] as String,
      assignedBy: json['assigned_by'] as String,
      assignedAt: DateTime.parse(json['assigned_at'] as String),
      notes: json['notes'] as String?,
      staffName: staff?['full_name'] as String?,
      horseName: horse?['name'] as String?,
    );
  }
}

/// Repository for staff-specific operations
class StaffRepository {
  final _supabase = Supabase.instance.client;

  /// Get horses for logging - assigned horses first, then all others
  Future<List<HorseForLog>> getHorsesForLogging(String yardId) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('Not authenticated');

    // Get assigned horse IDs for current user
    final assignmentsResponse = await _supabase
        .from('staff_horse_assignments')
        .select('horse_id')
        .eq('yard_id', yardId)
        .eq('staff_user_id', userId);

    final assignedHorseIds = (assignmentsResponse as List)
        .map((a) => a['horse_id'] as String)
        .toSet();

    // Get all horses in the yard with owner info
    debugPrint('StaffRepository: Fetching horses for yard $yardId');
    final horsesResponse = await _supabase
        .from('horses')
        .select('''
          id, name, colour, photo_url, created_by
        ''')
        .eq('current_yard_id', yardId)
        .order('name');

    debugPrint(
      'StaffRepository: Got ${(horsesResponse as List).length} horses',
    );

    // Fetch owner names and leaving status to filter out departed users
    final ownerIds = (horsesResponse as List)
        .map((h) => h['created_by'] as String)
        .toSet()
        .toList();

    Map<String, String> ownerNames = {};
    Set<String> departedOwnerIds = {};
    if (ownerIds.isNotEmpty) {
      final profilesResponse = await _supabase
          .from('profiles')
          .select('user_id, full_name, leaving_status')
          .inFilter('user_id', ownerIds);

      for (final p in profilesResponse as List) {
        final userId = p['user_id'] as String;
        ownerNames[userId] = p['full_name'] as String? ?? 'Unknown';

        // Track departed owners to filter out their horses
        if (p['leaving_status'] == 'departed') {
          departedOwnerIds.add(userId);
        }
      }
    }

    // Filter out horses owned by departed users
    final horses = (horsesResponse as List)
        .where(
          (json) => !departedOwnerIds.contains(json['created_by'] as String),
        )
        .map((json) {
          final horseId = json['id'] as String;
          final createdBy = json['created_by'] as String;
          return HorseForLog.fromJson(
            json,
            isAssigned: assignedHorseIds.contains(horseId),
            ownerNameOverride: ownerNames[createdBy],
          );
        })
        .toList();

    // Sort: assigned horses first, then alphabetically
    horses.sort((a, b) {
      if (a.isAssigned && !b.isAssigned) return -1;
      if (!a.isAssigned && b.isAssigned) return 1;
      return a.name.compareTo(b.name);
    });

    return horses;
  }

  /// Get only assigned horses for current user
  /// Excludes horses owned by departed users
  Future<List<HorseForLog>> getAssignedHorses(String yardId) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('Not authenticated');

    final response = await _supabase
        .from('staff_horse_assignments')
        .select('''
          horse:horses!inner(
            id, name, colour, photo_url, created_by,
            owner:profiles!horses_created_by_fkey(full_name, leaving_status)
          )
        ''')
        .eq('yard_id', yardId)
        .eq('staff_user_id', userId);

    // Filter out horses owned by departed users
    final horses = <HorseForLog>[];
    for (final json in response as List) {
      final horse = json['horse'] as Map<String, dynamic>;
      final owner = horse['owner'] as Map<String, dynamic>?;
      final leavingStatus = owner?['leaving_status'] as String?;

      if (leavingStatus != 'departed') {
        horses.add(HorseForLog.fromJson(horse, isAssigned: true));
      }
    }
    return horses;
  }

  /// Get all staff assignments for a yard (for managers)
  Future<List<StaffAssignment>> getYardAssignments(String yardId) async {
    final response = await _supabase
        .from('staff_horse_assignments')
        .select('''
          *,
          staff:profiles!staff_horse_assignments_staff_user_id_fkey(full_name),
          horse:horses!inner(name)
        ''')
        .eq('yard_id', yardId)
        .order('assigned_at', ascending: false);

    return (response as List)
        .map((json) => StaffAssignment.fromJson(json))
        .toList();
  }

  /// Assign a horse to a staff member (manager/owner only)
  Future<void> assignHorseToStaff({
    required String yardId,
    required String staffUserId,
    required String horseId,
    String? notes,
  }) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('Not authenticated');

    await _supabase.from('staff_horse_assignments').upsert({
      'yard_id': yardId,
      'staff_user_id': staffUserId,
      'horse_id': horseId,
      'assigned_by': userId,
      'notes': notes,
    }, onConflict: 'staff_user_id,horse_id');
  }

  /// Remove a horse assignment
  Future<void> removeAssignment(String assignmentId) async {
    await _supabase
        .from('staff_horse_assignments')
        .delete()
        .eq('id', assignmentId);
  }

  /// Remove assignment by staff and horse
  Future<void> unassignHorse({
    required String staffUserId,
    required String horseId,
  }) async {
    await _supabase
        .from('staff_horse_assignments')
        .delete()
        .eq('staff_user_id', staffUserId)
        .eq('horse_id', horseId);
  }

  /// Get assignment count for a staff member
  Future<int> getAssignmentCount(String staffUserId) async {
    final response = await _supabase
        .from('staff_horse_assignments')
        .select()
        .eq('staff_user_id', staffUserId)
        .count(CountOption.exact);

    return response.count;
  }
}
