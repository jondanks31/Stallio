import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../../core/supabase/supabase_client.dart';

/// Repository for onboarding-related operations.
/// Handles profile setup, yard creation, and initial configuration.
class OnboardingRepository {
  final SupabaseClient _client = SupabaseManager.client;
  final _uuid = const Uuid();

  /// Gets the current user's profile from Supabase.
  Future<Map<String, dynamic>?> getProfile() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return null;

    final response = await _client
        .from('profiles')
        .select()
        .eq('user_id', userId)
        .maybeSingle();

    return response;
  }

  /// Updates the user's profile with their full name.
  Future<void> updateProfileName(String fullName) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    await _client.from('profiles').upsert({
      'user_id': userId,
      'full_name': fullName,
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  /// Creates a new yard and sets the user as owner.
  /// Returns the created yard's ID.
  Future<String> createYard({required String name, String? address}) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    final yardId = _uuid.v4();
    final inviteCode = _generateInviteCode();

    // Use RPC to create yard and update profile atomically
    // This avoids RLS issues where profile needs yard_id to see yard
    await _client.rpc(
      'create_yard_with_owner',
      params: {
        'p_yard_id': yardId,
        'p_yard_name': name,
        'p_yard_address': address,
        'p_user_id': userId,
        'p_invite_code': inviteCode,
        'p_invite_expires': DateTime.now()
            .add(const Duration(days: 30))
            .toIso8601String(),
      },
    );

    return yardId;
  }

  /// Marks onboarding as complete for the current user.
  Future<void> completeOnboarding() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    await _client.from('profiles').upsert({
      'user_id': userId,
      'onboarding_completed': true,
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  /// Generates a random 6-character invite code.
  String _generateInviteCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789'; // No I, O, 0, 1
    final random = DateTime.now().millisecondsSinceEpoch;
    var code = '';
    var seed = random;
    for (var i = 0; i < 6; i++) {
      code += chars[seed % chars.length];
      seed = (seed * 31 + 17) % 1000000007;
    }
    return code;
  }
}
