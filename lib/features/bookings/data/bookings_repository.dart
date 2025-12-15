import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

/// Personal event type enum
enum PersonalEventType {
  farrier('farrier', 'Farrier', Icons.content_cut),
  vet('vet', 'Vet', Icons.medical_services),
  physio('physio', 'Physio', Icons.spa),
  dentist('dentist', 'Dentist', Icons.mood),
  saddleFitter('saddle_fitter', 'Saddle Fitter', Icons.chair),
  lesson('lesson', 'Lesson', Icons.school),
  competition('competition', 'Competition', Icons.emoji_events),
  other('other', 'Other', Icons.event);

  const PersonalEventType(this.value, this.displayName, this.icon);
  final String value;
  final String displayName;
  final IconData icon;

  static PersonalEventType fromString(String value) {
    return PersonalEventType.values.firstWhere(
      (t) => t.value == value,
      orElse: () => PersonalEventType.other,
    );
  }
}

/// Personal event model (for farrier, vet, etc.)
class PersonalEvent {
  final String id;
  final String userId;
  final String? horseId;
  final PersonalEventType eventType;
  final String? title;
  final String? notes;
  final DateTime eventDate;
  final TimeOfDay? eventTime;
  final int? reminderDays;
  final DateTime createdAt;

  // Joined fields
  final String? horseName;

  PersonalEvent({
    required this.id,
    required this.userId,
    this.horseId,
    required this.eventType,
    this.title,
    this.notes,
    required this.eventDate,
    this.eventTime,
    this.reminderDays,
    required this.createdAt,
    this.horseName,
  });

  factory PersonalEvent.fromJson(Map<String, dynamic> json) {
    final horse = json['horse'] as Map<String, dynamic>?;
    TimeOfDay? time;
    if (json['event_time'] != null) {
      final parts = (json['event_time'] as String).split(':');
      time = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    }

    return PersonalEvent(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      horseId: json['horse_id'] as String?,
      eventType: PersonalEventType.fromString(json['event_type'] as String),
      title: json['title'] as String?,
      notes: json['notes'] as String?,
      eventDate: DateTime.parse(json['event_date'] as String),
      eventTime: time,
      reminderDays: json['reminder_days'] as int?,
      createdAt: DateTime.parse(json['created_at'] as String),
      horseName: horse?['name'] as String?,
    );
  }

  /// Display name for the event (title or type name)
  String get displayTitle => title ?? eventType.displayName;

  /// Formatted time string
  String get timeString {
    if (eventTime == null) return 'All day';
    final hour = eventTime!.hour.toString().padLeft(2, '0');
    final minute = eventTime!.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}

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

  /// Create a copy with updated fields
  FacilityBooking copyWith({String? userName, String? facilityName}) {
    return FacilityBooking(
      id: id,
      facilityId: facilityId,
      userId: userId,
      startTime: startTime,
      endTime: endTime,
      status: status,
      priceCharged: priceCharged,
      notes: notes,
      createdAt: createdAt,
      facilityName: facilityName ?? this.facilityName,
      userName: userName ?? this.userName,
    );
  }
}

/// Repository for facility bookings
class BookingsRepository {
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
          facility:facility_id(name)
        ''')
        .eq('facility_id', facilityId)
        .gte('start_time', startOfDay.toIso8601String())
        .lt('start_time', endOfDay.toIso8601String())
        .eq('status', 'confirmed')
        .order('start_time');

    final bookings = (response as List)
        .map((json) => FacilityBooking.fromJson(json))
        .toList();

    // Fetch user names separately
    final userIds = bookings.map((b) => b.userId).toSet();
    final names = await _getProfileNames(userIds);

    return bookings.map((b) => b.copyWith(userName: names[b.userId])).toList();
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
          facility:facility_id(name)
        ''')
        .inFilter('facility_id', facilityIds)
        .gte('start_time', startOfDay.toIso8601String())
        .lt('start_time', endOfDay.toIso8601String())
        .eq('status', 'confirmed')
        .order('start_time');

    final bookings = (response as List)
        .map((json) => FacilityBooking.fromJson(json))
        .toList();

    // Fetch user names separately
    final userIds = bookings.map((b) => b.userId).toSet();
    final names = await _getProfileNames(userIds);

    return bookings.map((b) => b.copyWith(userName: names[b.userId])).toList();
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
          facility:facility_id(name)
        ''')
        .eq('user_id', userId)
        .eq('status', 'confirmed');

    if (!includePast) {
      query = query.gte('end_time', DateTime.now().toIso8601String());
    }

    final response = await query.order('start_time').limit(limit);

    final bookings = (response as List)
        .map((json) => FacilityBooking.fromJson(json))
        .toList();

    // Fetch user names separately
    final userIds = bookings.map((b) => b.userId).toSet();
    final names = await _getProfileNames(userIds);

    return bookings.map((b) => b.copyWith(userName: names[b.userId])).toList();
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
          facility:facility_id(name)
        ''')
        .single();

    final booking = FacilityBooking.fromJson(response);

    // Fetch user name
    final names = await _getProfileNames({userId});
    return booking.copyWith(userName: names[userId]);
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

  // ========== Personal Events ==========

  /// Get personal events for the current user on a specific date
  Future<List<PersonalEvent>> getPersonalEventsForDate(DateTime date) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return [];

    final dateStr =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

    final response = await _supabase
        .from('horse_events')
        .select('''
          *,
          horse:horse_id(name)
        ''')
        .eq('user_id', userId)
        .eq('event_date', dateStr)
        .order('event_time', nullsFirst: false);

    return (response as List)
        .map((json) => PersonalEvent.fromJson(json))
        .toList();
  }

  /// Get all personal events for the current user
  Future<List<PersonalEvent>> getMyPersonalEvents({
    bool includePast = false,
    int limit = 50,
  }) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return [];

    var query = _supabase
        .from('horse_events')
        .select('''
          *,
          horse:horse_id(name)
        ''')
        .eq('user_id', userId);

    if (!includePast) {
      final today =
          '${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')}';
      query = query.gte('event_date', today);
    }

    final response = await query.order('event_date').limit(limit);

    return (response as List)
        .map((json) => PersonalEvent.fromJson(json))
        .toList();
  }

  /// Create a personal event
  Future<PersonalEvent> createPersonalEvent({
    required PersonalEventType eventType,
    required DateTime eventDate,
    TimeOfDay? eventTime,
    String? horseId,
    String? title,
    String? notes,
    int? reminderDays,
  }) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('Not authenticated');

    final id = _uuid.v4();
    final dateStr =
        '${eventDate.year}-${eventDate.month.toString().padLeft(2, '0')}-${eventDate.day.toString().padLeft(2, '0')}';
    String? timeStr;
    if (eventTime != null) {
      timeStr =
          '${eventTime.hour.toString().padLeft(2, '0')}:${eventTime.minute.toString().padLeft(2, '0')}:00';
    }

    final response = await _supabase
        .from('horse_events')
        .insert({
          'id': id,
          'user_id': userId,
          'horse_id': horseId,
          'event_type': eventType.value,
          'title': title,
          'notes': notes,
          'event_date': dateStr,
          'event_time': timeStr,
          'reminder_days': reminderDays ?? 1,
        })
        .select('''
          *,
          horse:horse_id(name)
        ''')
        .single();

    return PersonalEvent.fromJson(response);
  }

  /// Delete a personal event
  Future<void> deletePersonalEvent(String eventId) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('Not authenticated');

    await _supabase
        .from('horse_events')
        .delete()
        .eq('id', eventId)
        .eq('user_id', userId);
  }

  /// Update a personal event
  Future<PersonalEvent> updatePersonalEvent({
    required String eventId,
    PersonalEventType? eventType,
    DateTime? eventDate,
    TimeOfDay? eventTime,
    String? horseId,
    String? title,
    String? notes,
    int? reminderDays,
  }) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('Not authenticated');

    final updates = <String, dynamic>{};
    if (eventType != null) updates['event_type'] = eventType.value;
    if (eventDate != null) {
      updates['event_date'] =
          '${eventDate.year}-${eventDate.month.toString().padLeft(2, '0')}-${eventDate.day.toString().padLeft(2, '0')}';
    }
    if (eventTime != null) {
      updates['event_time'] =
          '${eventTime.hour.toString().padLeft(2, '0')}:${eventTime.minute.toString().padLeft(2, '0')}:00';
    }
    if (horseId != null) updates['horse_id'] = horseId;
    if (title != null) updates['title'] = title;
    if (notes != null) updates['notes'] = notes;
    if (reminderDays != null) updates['reminder_days'] = reminderDays;
    updates['updated_at'] = DateTime.now().toIso8601String();

    final response = await _supabase
        .from('horse_events')
        .update(updates)
        .eq('id', eventId)
        .eq('user_id', userId)
        .select('''
          *,
          horse:horse_id(name)
        ''')
        .single();

    return PersonalEvent.fromJson(response);
  }
}
