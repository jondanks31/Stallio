import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

/// Booking status enum
enum BookingStatus {
  confirmed('confirmed', 'Confirmed'),
  cancelled('cancelled', 'Cancelled');

  const BookingStatus(this.value, this.displayName);
  final String value;
  final String displayName;

  static BookingStatus fromString(String value) {
    return BookingStatus.values.firstWhere(
      (s) => s.value == value,
      orElse: () => BookingStatus.confirmed,
    );
  }
}

/// Facility model
class Facility {
  final String id;
  final String yardId;
  final String name;
  final String type;
  final String? description;
  final int slotDurationMinutes;
  final int? maxDailyBookingsPerUser;
  final int advanceBookingDays;
  final bool isActive;

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
  });

  factory Facility.fromJson(Map<String, dynamic> json) {
    return Facility(
      id: json['id'] as String,
      yardId: json['yard_id'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
      description: json['description'] as String?,
      slotDurationMinutes: json['slot_duration_minutes'] as int? ?? 30,
      maxDailyBookingsPerUser: json['max_daily_bookings_per_user'] as int?,
      advanceBookingDays: json['advance_booking_days'] as int? ?? 14,
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  String get typeDisplayName {
    switch (type) {
      case 'indoor_arena':
        return 'Indoor Arena';
      case 'outdoor_arena':
        return 'Outdoor Arena';
      case 'round_pen':
        return 'Round Pen';
      case 'walker':
        return 'Walker';
      case 'wash_bay':
        return 'Wash Bay';
      case 'tack_room':
        return 'Tack Room';
      default:
        return type;
    }
  }
}

/// Facility booking model
class FacilityBooking {
  final String id;
  final String facilityId;
  final String userId;
  final DateTime startTime;
  final DateTime endTime;
  final BookingStatus status;
  final double? priceCharged;
  final String? notes;
  final DateTime createdAt;

  // Joined fields
  final String? facilityName;
  final String? userName;

  FacilityBooking({
    required this.id,
    required this.facilityId,
    required this.userId,
    required this.startTime,
    required this.endTime,
    required this.status,
    this.priceCharged,
    this.notes,
    required this.createdAt,
    this.facilityName,
    this.userName,
  });

  factory FacilityBooking.fromJson(Map<String, dynamic> json) {
    final facility = json['facility'] as Map<String, dynamic>?;
    final profile = json['profile'] as Map<String, dynamic>?;

    return FacilityBooking(
      id: json['id'] as String,
      facilityId: json['facility_id'] as String,
      userId: json['user_id'] as String,
      startTime: DateTime.parse(json['start_time'] as String),
      endTime: DateTime.parse(json['end_time'] as String),
      status: BookingStatus.fromString(
        json['status'] as String? ?? 'confirmed',
      ),
      priceCharged: (json['price_charged'] as num?)?.toDouble(),
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      facilityName: facility?['name'] as String?,
      userName: profile?['full_name'] as String?,
    );
  }

  /// Duration in minutes
  int get durationMinutes => endTime.difference(startTime).inMinutes;

  /// Formatted time range (e.g., "10:00 - 10:30")
  String get timeRange {
    final startHour = startTime.hour.toString().padLeft(2, '0');
    final startMin = startTime.minute.toString().padLeft(2, '0');
    final endHour = endTime.hour.toString().padLeft(2, '0');
    final endMin = endTime.minute.toString().padLeft(2, '0');
    return '$startHour:$startMin - $endHour:$endMin';
  }

  /// Whether booking is in the past
  bool get isPast => endTime.isBefore(DateTime.now());
}

/// Repository for facility bookings
class BookingsRepository {
  final _supabase = Supabase.instance.client;
  static const _uuid = Uuid();

  /// Get all active facilities for a yard
  Future<List<Facility>> getFacilities(String yardId) async {
    final response = await _supabase
        .from('facilities')
        .select()
        .eq('yard_id', yardId)
        .eq('is_active', true)
        .order('name');

    return (response as List).map((json) => Facility.fromJson(json)).toList();
  }

  /// Get bookings for a specific date and facility
  Future<List<FacilityBooking>> getBookingsForDate(
    String facilityId,
    DateTime date,
  ) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final response = await _supabase
        .from('facility_bookings')
        .select('''
          *,
          facility:facility_id(name),
          profile:user_id(full_name)
        ''')
        .eq('facility_id', facilityId)
        .gte('start_time', startOfDay.toIso8601String())
        .lt('start_time', endOfDay.toIso8601String())
        .eq('status', 'confirmed')
        .order('start_time');

    return (response as List)
        .map((json) => FacilityBooking.fromJson(json))
        .toList();
  }

  /// Get all bookings for a yard on a specific date (for calendar view)
  Future<List<FacilityBooking>> getYardBookingsForDate(
    String yardId,
    DateTime date,
  ) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    // First get all facilities for the yard
    final facilities = await getFacilities(yardId);
    if (facilities.isEmpty) return [];

    final facilityIds = facilities.map((f) => f.id).toList();

    final response = await _supabase
        .from('facility_bookings')
        .select('''
          *,
          facility:facility_id(name),
          profile:user_id(full_name)
        ''')
        .inFilter('facility_id', facilityIds)
        .gte('start_time', startOfDay.toIso8601String())
        .lt('start_time', endOfDay.toIso8601String())
        .eq('status', 'confirmed')
        .order('start_time');

    return (response as List)
        .map((json) => FacilityBooking.fromJson(json))
        .toList();
  }

  /// Get bookings for the current user
  Future<List<FacilityBooking>> getMyBookings({
    bool includePast = false,
    int limit = 20,
  }) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return [];

    var query = _supabase
        .from('facility_bookings')
        .select('''
          *,
          facility:facility_id(name),
          profile:user_id(full_name)
        ''')
        .eq('user_id', userId)
        .eq('status', 'confirmed');

    if (!includePast) {
      query = query.gte('end_time', DateTime.now().toIso8601String());
    }

    final response = await query.order('start_time').limit(limit);

    return (response as List)
        .map((json) => FacilityBooking.fromJson(json))
        .toList();
  }

  /// Create a booking
  Future<FacilityBooking> createBooking({
    required String facilityId,
    required DateTime startTime,
    required DateTime endTime,
    String? notes,
  }) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('Not authenticated');

    // Check for conflicts
    final conflicts = await _supabase
        .from('facility_bookings')
        .select('id')
        .eq('facility_id', facilityId)
        .eq('status', 'confirmed')
        .lt('start_time', endTime.toIso8601String())
        .gt('end_time', startTime.toIso8601String());

    if ((conflicts as List).isNotEmpty) {
      throw Exception('This time slot is already booked');
    }

    final id = _uuid.v4();

    final response = await _supabase
        .from('facility_bookings')
        .insert({
          'id': id,
          'facility_id': facilityId,
          'user_id': userId,
          'start_time': startTime.toIso8601String(),
          'end_time': endTime.toIso8601String(),
          'notes': notes,
        })
        .select('''
          *,
          facility:facility_id(name),
          profile:user_id(full_name)
        ''')
        .single();

    return FacilityBooking.fromJson(response);
  }

  /// Cancel a booking
  Future<void> cancelBooking(String bookingId) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('Not authenticated');

    await _supabase
        .from('facility_bookings')
        .update({'status': 'cancelled'})
        .eq('id', bookingId)
        .eq('user_id', userId);
  }

  /// Get available time slots for a facility on a date
  Future<List<DateTime>> getAvailableSlots(
    String facilityId,
    DateTime date,
    int slotDurationMinutes,
  ) async {
    // Get facility operating hours (default 6am-10pm)
    const startHour = 6;
    const endHour = 22;

    final startOfDay = DateTime(date.year, date.month, date.day, startHour);
    final endOfDay = DateTime(date.year, date.month, date.day, endHour);

    // Get existing bookings
    final bookings = await getBookingsForDate(facilityId, date);

    // Generate all possible slots
    final slots = <DateTime>[];
    var current = startOfDay;

    while (current
            .add(Duration(minutes: slotDurationMinutes))
            .isBefore(endOfDay) ||
        current
            .add(Duration(minutes: slotDurationMinutes))
            .isAtSameMomentAs(endOfDay)) {
      // Check if this slot is free
      final slotEnd = current.add(Duration(minutes: slotDurationMinutes));
      final isBooked = bookings.any(
        (b) => (b.startTime.isBefore(slotEnd) && b.endTime.isAfter(current)),
      );

      // Skip past slots
      if (!current.isBefore(DateTime.now()) && !isBooked) {
        slots.add(current);
      }

      current = current.add(Duration(minutes: slotDurationMinutes));
    }

    return slots;
  }
}
