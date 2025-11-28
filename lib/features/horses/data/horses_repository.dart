import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import 'horse_model.dart';

/// Repository for horse management.
/// Horses are tied to their owner (created_by), not directly to a yard.
/// When a user joins/leaves a yard, their horses automatically appear/disappear.
class HorsesRepository {
  final _supabase = Supabase.instance.client;
  static const _uuid = Uuid();

  /// Get all horses owned by the current user
  Future<List<Horse>> getMyHorses() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('Not authenticated');

    final response = await _supabase
        .from('horses')
        .select()
        .eq('created_by', userId)
        .order('name', ascending: true);

    return (response as List).map((json) => Horse.fromJson(json)).toList();
  }

  /// Get all horses visible in a yard (horses owned by yard members)
  /// Used by staff/owners to see all horses in their yard
  Future<List<Horse>> getHorsesInYard(String yardId) async {
    final response = await _supabase
        .from('horses')
        .select()
        .eq('current_yard_id', yardId)
        .order('name', ascending: true);

    return (response as List).map((json) => Horse.fromJson(json)).toList();
  }

  /// Get a single horse by ID
  Future<Horse?> getHorse(String horseId) async {
    final response = await _supabase
        .from('horses')
        .select()
        .eq('id', horseId)
        .maybeSingle();

    if (response == null) return null;
    return Horse.fromJson(response);
  }

  /// Create a new horse
  Future<Horse> createHorse({
    required String name,
    String? color,
    DateTime? dateOfBirth,
    String? notes,
  }) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('Not authenticated');

    // Get user's current yard
    final profile = await _supabase
        .from('profiles')
        .select('yard_id')
        .eq('user_id', userId)
        .maybeSingle();

    final yardId = profile?['yard_id'] as String?;

    final id = _uuid.v4();

    final horseData = {
      'id': id,
      'created_by': userId,
      'current_yard_id': yardId,
      'name': name,
      'colour': color,
      'date_of_birth': dateOfBirth?.toIso8601String().split('T').first,
      'notes': notes,
    };

    final response = await _supabase
        .from('horses')
        .insert(horseData)
        .select()
        .single();

    return Horse.fromJson(response);
  }

  /// Update a horse's basic info
  Future<Horse> updateHorse(
    String horseId,
    Map<String, dynamic> updates,
  ) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('Not authenticated');

    // Add updated timestamp
    updates['updated_at'] = DateTime.now().toUtc().toIso8601String();

    final response = await _supabase
        .from('horses')
        .update(updates)
        .eq('id', horseId)
        .eq('created_by', userId) // Ensure only owner can update
        .select()
        .single();

    return Horse.fromJson(response);
  }

  /// Update care information (diet, medical, behaviour notes)
  /// Per spec: Only the owner can update sensitive care information
  Future<Horse> updateCareInfo(
    String horseId, {
    String? dietNotes,
    String? medicalNotes,
    String? behaviourNotes,
  }) async {
    final updates = <String, dynamic>{};
    if (dietNotes != null) updates['diet_notes'] = dietNotes;
    if (medicalNotes != null) updates['medical_notes'] = medicalNotes;
    if (behaviourNotes != null) updates['behaviour_notes'] = behaviourNotes;

    return updateHorse(horseId, updates);
  }

  /// Delete a horse
  Future<void> deleteHorse(String horseId) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('Not authenticated');

    await _supabase
        .from('horses')
        .delete()
        .eq('id', horseId)
        .eq('created_by', userId); // Ensure only owner can delete
  }

  /// Get horse count for current user
  Future<int> getMyHorseCount() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return 0;

    final response = await _supabase
        .from('horses')
        .select()
        .eq('created_by', userId)
        .count(CountOption.exact);

    return response.count;
  }

  /// Upload a photo for a horse and update the horse record
  Future<String> uploadHorsePhoto(String horseId, File imageFile) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('Not authenticated');

    // Generate unique filename
    final extension = imageFile.path.split('.').last.toLowerCase();
    final fileName = '$userId/$horseId.$extension';

    // Upload to storage
    await _supabase.storage
        .from('horse-photos')
        .upload(
          fileName,
          imageFile,
          fileOptions: const FileOptions(upsert: true),
        );

    // Get public URL
    final photoUrl = _supabase.storage
        .from('horse-photos')
        .getPublicUrl(fileName);

    // Update horse record with photo URL
    await updateHorse(horseId, {'photo_url': photoUrl});

    return photoUrl;
  }

  /// Delete a horse's photo
  Future<void> deleteHorsePhoto(String horseId) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('Not authenticated');

    // Try to delete from storage (ignore errors if file doesn't exist)
    try {
      await _supabase.storage.from('horse-photos').remove(['$userId/$horseId']);
    } catch (_) {
      // File may not exist, continue
    }

    // Clear photo URL in database
    await updateHorse(horseId, {'photo_url': null});
  }
}
