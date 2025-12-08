import 'package:supabase_flutter/supabase_flutter.dart';

/// Model for a consumable type (for display in quick log)
class ConsumableTypeInfo {
  final String id;
  final String name;
  final String usageUnit;
  final double pricePerUsageUnit;
  final String? brand;

  ConsumableTypeInfo({
    required this.id,
    required this.name,
    required this.usageUnit,
    required this.pricePerUsageUnit,
    this.brand,
  });

  factory ConsumableTypeInfo.fromJson(Map<String, dynamic> json) {
    return ConsumableTypeInfo(
      id: json['id'] as String,
      name: json['name'] as String,
      usageUnit: json['usage_unit'] as String,
      pricePerUsageUnit: (json['price_per_usage_unit'] as num).toDouble(),
      brand: json['brand'] as String?,
    );
  }
}

/// Model for a consumable log entry
class ConsumableLog {
  final String id;
  final String yardId;
  final String horseId;
  final String userId;
  final String consumableTypeId;
  final double quantityUsage;
  final DateTime logAt;
  final bool isBillable;
  final bool isDeleted;
  final DateTime createdAt;

  // Joined fields
  final String? horseName;
  final String? consumableName;
  final String? loggedByName;
  final double? pricePerUnit;

  ConsumableLog({
    required this.id,
    required this.yardId,
    required this.horseId,
    required this.userId,
    required this.consumableTypeId,
    required this.quantityUsage,
    required this.logAt,
    this.isBillable = true,
    this.isDeleted = false,
    required this.createdAt,
    this.horseName,
    this.consumableName,
    this.loggedByName,
    this.pricePerUnit,
  });

  double get totalPrice => (pricePerUnit ?? 0) * quantityUsage;

  factory ConsumableLog.fromJson(Map<String, dynamic> json) {
    // Handle joined data
    final horse = json['horses'] as Map<String, dynamic>?;
    final consumable = json['consumable_types'] as Map<String, dynamic>?;
    final profile = json['profiles'] as Map<String, dynamic>?;

    return ConsumableLog(
      id: json['id'] as String,
      yardId: json['yard_id'] as String,
      horseId: json['horse_id'] as String,
      userId: json['user_id'] as String,
      consumableTypeId: json['consumable_type_id'] as String,
      quantityUsage: (json['quantity_usage'] as num).toDouble(),
      logAt: DateTime.parse(json['log_at'] as String),
      isBillable: json['is_billable'] as bool? ?? true,
      isDeleted: json['is_deleted'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      horseName: horse?['name'] as String?,
      consumableName: consumable?['name'] as String?,
      loggedByName: profile?['full_name'] as String?,
      pricePerUnit: consumable != null
          ? (consumable['price_per_usage_unit'] as num?)?.toDouble()
          : null,
    );
  }
}

/// Model for bulk log entry (used in quick log)
class BulkLogEntry {
  final String horseId;
  final String horseName;
  double quantity;

  BulkLogEntry({
    required this.horseId,
    required this.horseName,
    this.quantity = 1,
  });
}

/// Repository for consumable logging operations
class ConsumableLogsRepository {
  final _supabase = Supabase.instance.client;

  /// Get all consumable types for a yard
  Future<List<ConsumableTypeInfo>> getConsumableTypes(String yardId) async {
    final response = await _supabase
        .from('consumable_types')
        .select('id, name, usage_unit, price_per_usage_unit, brand')
        .eq('yard_id', yardId)
        .order('name');

    return (response as List)
        .map((json) => ConsumableTypeInfo.fromJson(json))
        .toList();
  }

  /// Get recent logs for a yard (for staff dashboard)
  Future<List<ConsumableLog>> getRecentLogs(
    String yardId, {
    int limit = 20,
  }) async {
    final response = await _supabase
        .from('consumable_logs')
        .select('''
          *,
          horses!inner(name),
          consumable_types!inner(name, price_per_usage_unit),
          profiles!consumable_logs_user_id_fkey(full_name)
        ''')
        .eq('yard_id', yardId)
        .eq('is_deleted', false)
        .order('log_at', ascending: false)
        .limit(limit);

    return (response as List)
        .map((json) => ConsumableLog.fromJson(json))
        .toList();
  }

  /// Get logs for a specific horse (for horse profile)
  Future<List<ConsumableLog>> getLogsForHorse(
    String horseId, {
    int limit = 50,
  }) async {
    final response = await _supabase
        .from('consumable_logs')
        .select('''
          *,
          horses!inner(name),
          consumable_types!inner(name, price_per_usage_unit),
          profiles!consumable_logs_user_id_fkey(full_name)
        ''')
        .eq('horse_id', horseId)
        .eq('is_deleted', false)
        .order('log_at', ascending: false)
        .limit(limit);

    return (response as List)
        .map((json) => ConsumableLog.fromJson(json))
        .toList();
  }

  /// Get the last quantity logged for each horse by the current user
  /// Used for "memory" feature - showing previous quantities
  Future<Map<String, double>> getLastQuantities(
    String yardId,
    String consumableTypeId,
  ) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return {};

    // Get the most recent log for each horse by this user for this consumable
    final response = await _supabase
        .from('consumable_logs')
        .select('horse_id, quantity_usage')
        .eq('yard_id', yardId)
        .eq('user_id', userId)
        .eq('consumable_type_id', consumableTypeId)
        .eq('is_deleted', false)
        .order('log_at', ascending: false);

    final Map<String, double> lastQuantities = {};
    for (final row in response as List) {
      final horseId = row['horse_id'] as String;
      // Only keep the first (most recent) entry for each horse
      if (!lastQuantities.containsKey(horseId)) {
        lastQuantities[horseId] = (row['quantity_usage'] as num).toDouble();
      }
    }

    return lastQuantities;
  }

  /// Create multiple log entries (bulk logging)
  Future<void> createBulkLogs({
    required String yardId,
    required String consumableTypeId,
    required List<BulkLogEntry> entries,
  }) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('Not authenticated');

    // Filter out entries with 0 quantity
    final validEntries = entries.where((e) => e.quantity > 0).toList();
    if (validEntries.isEmpty) return;

    // Create log entries
    // Note: is_billable is automatically set by database trigger
    // based on whether consumable is included in horse's package
    final logs = validEntries
        .map(
          (entry) => {
            'yard_id': yardId,
            'horse_id': entry.horseId,
            'user_id': userId,
            'consumable_type_id': consumableTypeId,
            'quantity_usage': entry.quantity,
          },
        )
        .toList();

    await _supabase.from('consumable_logs').insert(logs);
  }

  /// Delete a log entry (soft delete)
  Future<void> deleteLog(String logId) async {
    await _supabase
        .from('consumable_logs')
        .update({
          'is_deleted': true,
          'updated_at': DateTime.now().toUtc().toIso8601String(),
        })
        .eq('id', logId);
  }

  /// Get today's log count for the current user
  Future<int> getTodayLogCount(String yardId) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return 0;

    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);

    final response = await _supabase
        .from('consumable_logs')
        .select()
        .eq('yard_id', yardId)
        .eq('user_id', userId)
        .eq('is_deleted', false)
        .gte('log_at', startOfDay.toIso8601String())
        .count(CountOption.exact);

    return response.count;
  }
}
