import 'package:supabase_flutter/supabase_flutter.dart';

/// Status of a person in the yard
enum PersonStatus {
  active('Active'),
  invited('Invited');

  const PersonStatus(this.displayName);
  final String displayName;
}

/// Role in the yard
enum YardRole {
  owner('Owner', 4),
  manager('Manager', 3),
  staff('Staff', 2),
  user('User', 1);

  const YardRole(this.displayName, this.level);
  final String displayName;
  final int level;

  static YardRole fromString(String value) {
    return YardRole.values.firstWhere(
      (r) => r.name == value.toLowerCase(),
      orElse: () => YardRole.user,
    );
  }
}

/// Represents a person (user) in the yard
class YardPerson {
  final String id;
  final String? odId;
  final String? fullName;
  final String? email;
  final YardRole role;
  final String? packageId;
  final String? packageName;
  final String? phone;
  final String? stableNumber;
  final String? vetName;
  final String? vetPhone;
  final String? emergencyContactName;
  final String? emergencyContactPhone;
  final String? avatarUrl;
  final PersonStatus status;
  final DateTime? joinedAt;
  final List<HorseSummary> horses;

  YardPerson({
    required this.id,
    this.odId,
    this.fullName,
    this.email,
    required this.role,
    this.packageId,
    this.packageName,
    this.phone,
    this.stableNumber,
    this.vetName,
    this.vetPhone,
    this.emergencyContactName,
    this.emergencyContactPhone,
    this.avatarUrl,
    required this.status,
    this.joinedAt,
    this.horses = const [],
  });

  factory YardPerson.fromProfile(
    Map<String, dynamic> json, {
    List<HorseSummary>? horses,
  }) {
    return YardPerson(
      id: json['user_id'] as String,
      fullName: json['full_name'] as String?,
      email: json['email'] as String?,
      role: YardRole.fromString(json['role'] as String? ?? 'user'),
      packageId: json['package_id'] as String?,
      packageName: json['package_name'] as String?,
      phone: json['phone'] as String?,
      stableNumber: json['stable_number'] as String?,
      vetName: json['vet_name'] as String?,
      vetPhone: json['vet_phone'] as String?,
      emergencyContactName: json['emergency_contact_name'] as String?,
      emergencyContactPhone: json['emergency_contact_phone'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      status: PersonStatus.active,
      joinedAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      horses: horses ?? [],
    );
  }

  factory YardPerson.fromInvite(Map<String, dynamic> json) {
    final usedAt = json['used_at'];
    return YardPerson(
      id: json['id'] as String,
      email: json['email'] as String?,
      role: YardRole.fromString(json['role'] as String? ?? 'user'),
      packageId: json['package_id'] as String?,
      packageName: json['package_name'] as String?,
      status: usedAt != null ? PersonStatus.active : PersonStatus.invited,
      joinedAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }
}

/// Summary of a horse for display in people list
class HorseSummary {
  final String id;
  final String name;
  final String? stableNumber;

  HorseSummary({required this.id, required this.name, this.stableNumber});

  factory HorseSummary.fromJson(Map<String, dynamic> json) {
    return HorseSummary(
      id: json['id'] as String,
      name: json['name'] as String,
      stableNumber: json['stable_number'] as String?,
    );
  }
}

/// Invite model
class Invite {
  final String id;
  final String yardId;
  final String email;
  final YardRole role;
  final String? packageId;
  final String token;
  final String? inviteCode;
  final DateTime expiresAt;
  final DateTime? usedAt;
  final String createdBy;
  final DateTime createdAt;

  Invite({
    required this.id,
    required this.yardId,
    required this.email,
    required this.role,
    this.packageId,
    required this.token,
    this.inviteCode,
    required this.expiresAt,
    this.usedAt,
    required this.createdBy,
    required this.createdAt,
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);
  bool get isUsed => usedAt != null;
  bool get isValid => !isExpired && !isUsed;

  factory Invite.fromJson(Map<String, dynamic> json) {
    return Invite(
      id: json['id'] as String,
      yardId: json['yard_id'] as String,
      email: json['email'] as String,
      role: YardRole.fromString(json['role'] as String),
      packageId: json['package_id'] as String?,
      token: json['token'] as String,
      inviteCode: json['invite_code'] as String?,
      expiresAt: DateTime.parse(json['expires_at'] as String),
      usedAt: json['used_at'] != null
          ? DateTime.parse(json['used_at'] as String)
          : null,
      createdBy: json['created_by'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}

/// Repository for people/invites management
class PeopleRepository {
  final _supabase = Supabase.instance.client;

  /// Get all people in a yard (active members + pending invites)
  Future<List<YardPerson>> getPeopleInYard(String yardId) async {
    final List<YardPerson> people = [];

    // Get active profiles
    final profilesResponse = await _supabase
        .from('profiles')
        .select('''
          user_id,
          full_name,
          role,
          phone,
          stable_number,
          vet_name,
          vet_phone,
          emergency_contact_name,
          emergency_contact_phone,
          avatar_url,
          created_at
        ''')
        .eq('yard_id', yardId)
        .order('created_at', ascending: true);

    // Fetch horses for this yard to match with owners
    final horsesResponse = await _supabase
        .from('horses')
        .select('id, name, created_by')
        .eq('current_yard_id', yardId);

    print(
      'DEBUG: Fetched ${(horsesResponse as List).length} horses for yard $yardId',
    );

    // Group horses by owner
    final horsesByOwner = <String, List<HorseSummary>>{};
    for (final horse in horsesResponse) {
      final ownerId = horse['created_by'] as String;
      print('DEBUG: Horse ${horse['name']} owned by $ownerId');
      horsesByOwner.putIfAbsent(ownerId, () => []);
      horsesByOwner[ownerId]!.add(
        HorseSummary(id: horse['id'] as String, name: horse['name'] as String),
      );
    }
    print('DEBUG: horsesByOwner keys: ${horsesByOwner.keys.toList()}');

    // Build people list with their horses
    for (final profile in (profilesResponse as List)) {
      final userId = profile['user_id'] as String;

      people.add(
        YardPerson(
          id: userId,
          fullName: profile['full_name'] as String?,
          role: YardRole.fromString(profile['role'] as String? ?? 'user'),
          phone: profile['phone'] as String?,
          stableNumber: profile['stable_number'] as String?,
          vetName: profile['vet_name'] as String?,
          vetPhone: profile['vet_phone'] as String?,
          emergencyContactName: profile['emergency_contact_name'] as String?,
          emergencyContactPhone: profile['emergency_contact_phone'] as String?,
          avatarUrl: profile['avatar_url'] as String?,
          status: PersonStatus.active,
          joinedAt: profile['created_at'] != null
              ? DateTime.parse(profile['created_at'] as String)
              : null,
          horses: horsesByOwner[userId] ?? [],
        ),
      );
    }

    // Get pending invites (not used, not expired)
    final invitesResponse = await _supabase
        .from('invites')
        .select('''
          id,
          email,
          role,
          package_id,
          invite_code,
          expires_at,
          created_at,
          livery_packages!left(name)
        ''')
        .eq('yard_id', yardId)
        .isFilter('used_at', null)
        .gt('expires_at', DateTime.now().toIso8601String());

    // Add pending invites to the list
    // Note: The invite should have used_at set when accepted, but as a fallback
    // we're showing all pending invites. The real fix is in the database.
    for (final invite in invitesResponse as List) {
      final liveryPkg = invite['livery_packages'];
      people.add(
        YardPerson(
          id: invite['id'] as String,
          email: invite['email'] as String?,
          role: YardRole.fromString(invite['role'] as String? ?? 'user'),
          packageId: invite['package_id'] as String?,
          packageName: liveryPkg != null ? liveryPkg['name'] as String? : null,
          status: PersonStatus.invited,
          joinedAt: invite['created_at'] != null
              ? DateTime.parse(invite['created_at'] as String)
              : null,
        ),
      );
    }

    return people;
  }

  /// Get counts for stats bar
  Future<Map<String, int>> getPeopleCounts(String yardId) async {
    final activeCount = await _supabase
        .from('profiles')
        .select()
        .eq('yard_id', yardId)
        .count(CountOption.exact);

    final invitedCount = await _supabase
        .from('invites')
        .select()
        .eq('yard_id', yardId)
        .isFilter('used_at', null)
        .gt('expires_at', DateTime.now().toIso8601String())
        .count(CountOption.exact);

    return {'active': activeCount.count, 'invited': invitedCount.count};
  }

  /// Create a new invite
  Future<Invite> createInvite({
    required String yardId,
    required String email,
    required YardRole role,
    String? packageId,
  }) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('Not authenticated');

    // Generate a secure token
    final token = _generateToken();

    final response = await _supabase
        .from('invites')
        .insert({
          'yard_id': yardId,
          'email': email.toLowerCase().trim(),
          'role': role.name,
          'package_id': packageId,
          'token': token,
          'created_by': userId,
        })
        .select()
        .single();

    return Invite.fromJson(response);
  }

  /// Resend an invite (creates new code, extends expiry)
  Future<Invite> resendInvite(String inviteId) async {
    final token = _generateToken();

    final response = await _supabase
        .from('invites')
        .update({
          'token': token,
          'invite_code': null, // Will be regenerated by trigger
          'expires_at': DateTime.now()
              .add(const Duration(hours: 24))
              .toIso8601String(),
        })
        .eq('id', inviteId)
        .select()
        .single();

    return Invite.fromJson(response);
  }

  /// Revoke an invite
  Future<void> revokeInvite(String inviteId) async {
    await _supabase.from('invites').delete().eq('id', inviteId);
  }

  /// Accept an invite by code (for existing users)
  Future<void> acceptInviteByCode(String code) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('Not authenticated');

    final cleanCode = code.toUpperCase().trim();
    final nowUtc = DateTime.now().toUtc().toIso8601String();

    // Debug: First check if invite exists at all
    final anyInvite = await _supabase
        .from('invites')
        .select('invite_code, expires_at, used_at')
        .eq('invite_code', cleanCode)
        .maybeSingle();

    if (anyInvite != null) {
      print(
        'Found invite: code=${anyInvite['invite_code']}, expires=${anyInvite['expires_at']}, used=${anyInvite['used_at']}',
      );
      print('Current UTC time: $nowUtc');
    } else {
      print('No invite found with code: $cleanCode');
    }

    // Find the invite - use UTC for comparison with database timestamps
    final invite = await _supabase
        .from('invites')
        .select()
        .eq('invite_code', cleanCode)
        .isFilter('used_at', null)
        .gt('expires_at', nowUtc)
        .maybeSingle();

    if (invite == null) {
      throw Exception('Invalid or expired invite code');
    }

    // Update user's profile with yard and role
    await _supabase
        .from('profiles')
        .update({'yard_id': invite['yard_id'], 'role': invite['role']})
        .eq('user_id', userId);

    // If there's a package, assign it
    if (invite['package_id'] != null) {
      await _supabase.from('user_packages').insert({
        'user_id': userId,
        'package_id': invite['package_id'],
      });
    }

    // Mark invite as used
    await _supabase
        .from('invites')
        .update({'used_at': DateTime.now().toUtc().toIso8601String()})
        .eq('id', invite['id']);
  }

  /// Accept an invite by token (from deep link)
  Future<void> acceptInviteByToken(String token) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('Not authenticated');

    // Find the invite by token - use UTC for comparison
    final invite = await _supabase
        .from('invites')
        .select()
        .eq('token', token.trim())
        .isFilter('used_at', null)
        .gt('expires_at', DateTime.now().toUtc().toIso8601String())
        .maybeSingle();

    if (invite == null) {
      throw Exception('Invalid or expired invite link');
    }

    // Update user's profile with yard and role
    await _supabase
        .from('profiles')
        .update({'yard_id': invite['yard_id'], 'role': invite['role']})
        .eq('user_id', userId);

    // If there's a package, assign it
    if (invite['package_id'] != null) {
      await _supabase.from('user_packages').insert({
        'user_id': userId,
        'package_id': invite['package_id'],
      });
    }

    // Mark invite as used
    await _supabase
        .from('invites')
        .update({'used_at': DateTime.now().toUtc().toIso8601String()})
        .eq('id', invite['id']);
  }

  /// Update a person's profile
  Future<void> updatePerson(String odId, Map<String, dynamic> updates) async {
    await _supabase.from('profiles').update(updates).eq('user_id', odId);
  }

  /// Remove a person from the yard
  Future<void> removePerson(String odId) async {
    await _supabase
        .from('profiles')
        .update({'yard_id': null, 'role': 'user'})
        .eq('user_id', odId);
  }

  String _generateToken() {
    const chars =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = DateTime.now().millisecondsSinceEpoch;
    final buffer = StringBuffer();
    for (var i = 0; i < 32; i++) {
      buffer.write(chars[(random + i * 7) % chars.length]);
    }
    return buffer.toString();
  }
}
