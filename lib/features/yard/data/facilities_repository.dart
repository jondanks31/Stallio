import 'package:supabase_flutter/supabase_flutter.dart';

/// Facility types available in the system
enum FacilityType {
  indoorArena('indoor_arena', 'Indoor Arena', 'Indoor riding arena'),
  outdoorArena('outdoor_arena', 'Outdoor Arena', 'Outdoor riding arena'),
  roundPen('round_pen', 'Round Pen', 'Circular training pen'),
  walker('walker', 'Horse Walker', 'Automated horse exerciser'),
  washBay('wash_bay', 'Wash Bay', 'Horse washing station'),
  tackRoom('tack_room', 'Tack Room', 'Equipment storage'),
  other('other', 'Other', 'Other facility');

  const FacilityType(this.value, this.displayName, this.description);
  final String value;
  final String displayName;
  final String description;

  static FacilityType fromValue(String value) {
    return FacilityType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => FacilityType.other,
    );
  }
}

/// Pricing model for facility access
enum PricingModel {
  included('included', 'Included', 'Included in package'),
  payPerUse('pay_per_use', 'Pay Per Use', 'Charged per booking'),
  notAvailable(
    'not_available',
    'Not Available',
    'Not available for this package',
  );

  const PricingModel(this.value, this.displayName, this.description);
  final String value;
  final String displayName;
  final String description;

  static PricingModel fromValue(String value) {
    return PricingModel.values.firstWhere(
      (e) => e.value == value,
      orElse: () => PricingModel.notAvailable,
    );
  }
}

/// Represents a facility in the yard
class Facility {
  final String id;
  final String yardId;
  final String name;
  final FacilityType type;
  final String? description;
  final int slotDurationMinutes;
  final int? maxDailyBookingsPerUser;
  final int advanceBookingDays;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  Facility({
    required this.id,
    required this.yardId,
    required this.name,
    required this.type,
    this.description,
    required this.slotDurationMinutes,
    this.maxDailyBookingsPerUser,
    required this.advanceBookingDays,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Facility.fromJson(Map<String, dynamic> json) {
    return Facility(
      id: json['id'] as String,
      yardId: json['yard_id'] as String,
      name: json['name'] as String,
      type: FacilityType.fromValue(json['type'] as String),
      description: json['description'] as String?,
      slotDurationMinutes: json['slot_duration_minutes'] as int,
      maxDailyBookingsPerUser: json['max_daily_bookings_per_user'] as int?,
      advanceBookingDays: json['advance_booking_days'] as int,
      isActive: json['is_active'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'yard_id': yardId,
      'name': name,
      'type': type.value,
      'description': description,
      'slot_duration_minutes': slotDurationMinutes,
      'max_daily_bookings_per_user': maxDailyBookingsPerUser,
      'advance_booking_days': advanceBookingDays,
      'is_active': isActive,
    };
  }
}

/// Represents pricing for a facility-package combination
class FacilityPricing {
  final String id;
  final String facilityId;
  final String? packageId;
  final PricingModel pricingModel;
  final double pricePerSlot;

  FacilityPricing({
    required this.id,
    required this.facilityId,
    this.packageId,
    required this.pricingModel,
    required this.pricePerSlot,
  });

  factory FacilityPricing.fromJson(Map<String, dynamic> json) {
    return FacilityPricing(
      id: json['id'] as String,
      facilityId: json['facility_id'] as String,
      packageId: json['package_id'] as String?,
      pricingModel: PricingModel.fromValue(json['pricing_model'] as String),
      pricePerSlot: (json['price_per_slot'] as num).toDouble(),
    );
  }
}

/// Repository for facility operations
class FacilitiesRepository {
  final _supabase = Supabase.instance.client;

  /// Get all facilities for a yard
  Future<List<Facility>> getFacilities(String yardId) async {
    final response = await _supabase
        .from('facilities')
        .select()
        .eq('yard_id', yardId)
        .order('name');

    return (response as List).map((json) => Facility.fromJson(json)).toList();
  }

  /// Get active facilities for a yard
  Future<List<Facility>> getActiveFacilities(String yardId) async {
    final response = await _supabase
        .from('facilities')
        .select()
        .eq('yard_id', yardId)
        .eq('is_active', true)
        .order('name');

    return (response as List).map((json) => Facility.fromJson(json)).toList();
  }

  /// Create a new facility
  Future<Facility> createFacility(Facility facility) async {
    final response = await _supabase
        .from('facilities')
        .insert(facility.toJson())
        .select()
        .single();

    return Facility.fromJson(response);
  }

  /// Update a facility
  Future<Facility> updateFacility(Facility facility) async {
    final response = await _supabase
        .from('facilities')
        .update(facility.toJson())
        .eq('id', facility.id)
        .select()
        .single();

    return Facility.fromJson(response);
  }

  /// Delete a facility
  Future<void> deleteFacility(String facilityId) async {
    await _supabase.from('facilities').delete().eq('id', facilityId);
  }

  /// Get pricing for a facility
  Future<List<FacilityPricing>> getFacilityPricing(String facilityId) async {
    final response = await _supabase
        .from('facility_pricing')
        .select()
        .eq('facility_id', facilityId);

    return (response as List)
        .map((json) => FacilityPricing.fromJson(json))
        .toList();
  }

  /// Set pricing for a facility-package combination
  Future<void> setFacilityPricing({
    required String facilityId,
    String? packageId,
    required PricingModel pricingModel,
    double pricePerSlot = 0,
  }) async {
    await _supabase.from('facility_pricing').upsert({
      'facility_id': facilityId,
      'package_id': packageId,
      'pricing_model': pricingModel.value,
      'price_per_slot': pricePerSlot,
    }, onConflict: 'facility_id,package_id');
  }

  /// Delete pricing for a facility-package combination
  Future<void> deleteFacilityPricing(String pricingId) async {
    await _supabase.from('facility_pricing').delete().eq('id', pricingId);
  }
}
