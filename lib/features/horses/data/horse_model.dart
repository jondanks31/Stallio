/// Horse gender options
enum HorseGender {
  mare('Mare'),
  gelding('Gelding'),
  stallion('Stallion');

  const HorseGender(this.displayName);
  final String displayName;

  static HorseGender? fromString(String? value) {
    if (value == null) return null;
    return HorseGender.values.firstWhere(
      (g) => g.name == value.toLowerCase(),
      orElse: () => HorseGender.gelding,
    );
  }
}

/// Horse model - represents a horse owned by a user.
/// Horses are tied to their owner (created_by), not directly to a yard.
/// When a user joins/leaves a yard, their horses come with them.
class Horse {
  final String id;
  final String createdBy; // The user who owns this horse
  final String?
  currentYardId; // The yard this horse is currently at (via owner's profile)
  final String name;
  final String? color;
  final DateTime? dateOfBirth;
  final String? photoUrl;

  // Notes and care information (only owner can edit per spec)
  final String? notes;
  final String? dietNotes;
  final String? medicalNotes;
  final String? behaviourNotes;

  final DateTime createdAt;
  final DateTime updatedAt;

  Horse({
    required this.id,
    required this.createdBy,
    this.currentYardId,
    required this.name,
    this.color,
    this.dateOfBirth,
    this.photoUrl,
    this.notes,
    this.dietNotes,
    this.medicalNotes,
    this.behaviourNotes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  /// Create from Supabase JSON response
  factory Horse.fromJson(Map<String, dynamic> json) {
    return Horse(
      id: json['id'] as String,
      createdBy: json['created_by'] as String,
      currentYardId: json['current_yard_id'] as String?,
      name: json['name'] as String,
      color: json['colour'] as String?, // Note: DB uses British spelling
      dateOfBirth: json['date_of_birth'] != null
          ? DateTime.parse(json['date_of_birth'] as String)
          : null,
      photoUrl: json['photo_url'] as String?,
      notes: json['notes'] as String?,
      dietNotes: json['diet_notes'] as String?,
      medicalNotes: json['medical_notes'] as String?,
      behaviourNotes: json['behaviour_notes'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  /// Convert to JSON for Supabase insert/update
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_by': createdBy,
      'current_yard_id': currentYardId,
      'name': name,
      'colour': color,
      'date_of_birth': dateOfBirth?.toIso8601String().split('T').first,
      'photo_url': photoUrl,
      'notes': notes,
      'diet_notes': dietNotes,
      'medical_notes': medicalNotes,
      'behaviour_notes': behaviourNotes,
    };
  }

  /// Create a copy with updated fields
  Horse copyWith({
    String? id,
    String? createdBy,
    String? currentYardId,
    String? name,
    String? color,
    DateTime? dateOfBirth,
    String? photoUrl,
    String? notes,
    String? dietNotes,
    String? medicalNotes,
    String? behaviourNotes,
  }) {
    return Horse(
      id: id ?? this.id,
      createdBy: createdBy ?? this.createdBy,
      currentYardId: currentYardId ?? this.currentYardId,
      name: name ?? this.name,
      color: color ?? this.color,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      photoUrl: photoUrl ?? this.photoUrl,
      notes: notes ?? this.notes,
      dietNotes: dietNotes ?? this.dietNotes,
      medicalNotes: medicalNotes ?? this.medicalNotes,
      behaviourNotes: behaviourNotes ?? this.behaviourNotes,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  /// Calculate age from date of birth
  int? get age {
    if (dateOfBirth == null) return null;
    final now = DateTime.now();
    int years = now.year - dateOfBirth!.year;
    if (now.month < dateOfBirth!.month ||
        (now.month == dateOfBirth!.month && now.day < dateOfBirth!.day)) {
      years--;
    }
    return years;
  }

  /// Display string for age
  String get ageDisplay => age != null ? '$age years' : 'Unknown age';
}
