import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/supabase/supabase_client.dart';

/// Measurement type for consumables
enum MeasurementType {
  slices('Slices per bale'),
  weight('Weight (kg)'),
  whole('Whole unit (not divisible)');

  const MeasurementType(this.displayName);
  final String displayName;
}

/// Preset consumable types
enum ConsumablePreset {
  hay('Hay'),
  haylage('Haylage'),
  straw('Straw'),
  shavings('Shavings');

  const ConsumablePreset(this.displayName);
  final String displayName;

  /// Default measurement type for this preset
  MeasurementType get defaultMeasurementType {
    switch (this) {
      case ConsumablePreset.shavings:
        return MeasurementType.whole;
      default:
        return MeasurementType.slices;
    }
  }

  /// Whether this type supports slice measurement (divisible into portions)
  bool get supportsSlices => this != ConsumablePreset.shavings;
}

/// Data models for settings
class ConsumableType {
  final String id;
  final String yardId;
  final String name;
  final String stockUnit;
  final String usageUnit;
  final int ratio;
  final double pricePerUsageUnit;
  final String? brand;
  final String? description;
  final bool trackInventory;
  final double currentStock;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ConsumableType({
    required this.id,
    required this.yardId,
    required this.name,
    required this.stockUnit,
    required this.usageUnit,
    required this.ratio,
    required this.pricePerUsageUnit,
    this.brand,
    this.description,
    this.trackInventory = false,
    this.currentStock = 0.0,
    this.createdAt,
    this.updatedAt,
  });

  factory ConsumableType.fromJson(Map<String, dynamic> json) {
    return ConsumableType(
      id: json['id'] as String,
      yardId: json['yard_id'] as String,
      name: json['name'] as String,
      stockUnit: json['stock_unit'] as String,
      usageUnit: json['usage_unit'] as String,
      ratio: json['ratio'] as int,
      pricePerUsageUnit: (json['price_per_usage_unit'] as num).toDouble(),
      brand: json['brand'] as String?,
      description: json['description'] as String?,
      trackInventory: json['track_inventory'] as bool? ?? false,
      currentStock: (json['current_stock'] as num?)?.toDouble() ?? 0.0,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'yard_id': yardId,
    'name': name,
    'stock_unit': stockUnit,
    'usage_unit': usageUnit,
    'ratio': ratio,
    'price_per_usage_unit': pricePerUsageUnit,
    'brand': brand,
    'description': description,
    'track_inventory': trackInventory,
    'current_stock': currentStock,
  };
}

/// Extra services that can be charged (Arena time, Rug changes, Feed, etc.)
class Extra {
  final String id;
  final String yardId;
  final String name;
  final double price;
  final String unit; // per session, per change, per feed, etc.
  final bool isRecurring; // Can be added to monthly bill
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Extra({
    required this.id,
    required this.yardId,
    required this.name,
    required this.price,
    required this.unit,
    this.isRecurring = true,
    this.createdAt,
    this.updatedAt,
  });

  factory Extra.fromJson(Map<String, dynamic> json) {
    return Extra(
      id: json['id'] as String,
      yardId: json['yard_id'] as String,
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
      unit: json['unit'] as String,
      isRecurring: json['is_recurring'] as bool? ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'yard_id': yardId,
    'name': name,
    'price': price,
    'unit': unit,
    'is_recurring': isRecurring,
  };
}

/// Preset extra services
enum ExtraPreset {
  arena('Arena', 'per session'),
  rugChange('Rug Change', 'per change'),
  feed('Feed', 'per feed'),
  turnout('Turnout', 'per day'),
  grooming('Grooming', 'per session'),
  exercise('Exercise', 'per session'),
  medicationAdmin('Medication Admin', 'per dose'),
  holdForFarrier('Hold for Farrier', 'per visit'),
  holdForVet('Hold for Vet', 'per visit');

  const ExtraPreset(this.displayName, this.defaultUnit);

  final String displayName;
  final String defaultUnit;
}

class LiveryPackage {
  final String id;
  final String yardId;
  final String name;
  final int version;
  final double basePrice;
  final List<Map<String, dynamic>> includedItems;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  LiveryPackage({
    required this.id,
    required this.yardId,
    required this.name,
    this.version = 1,
    required this.basePrice,
    this.includedItems = const [],
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  factory LiveryPackage.fromJson(Map<String, dynamic> json) {
    return LiveryPackage(
      id: json['id'] as String,
      yardId: json['yard_id'] as String,
      name: json['name'] as String,
      version: json['version'] as int? ?? 1,
      basePrice: (json['base_price'] as num).toDouble(),
      includedItems:
          (json['included_items'] as List<dynamic>?)
              ?.map((e) => e as Map<String, dynamic>)
              .toList() ??
          [],
      isActive: json['is_active'] as bool? ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'yard_id': yardId,
    'name': name,
    'version': version,
    'base_price': basePrice,
    'included_items': includedItems,
    'is_active': isActive,
  };
}

class InvoiceSettings {
  final int? id;
  final String yardId;
  final String? logoUrl;
  final String? bankDetails;
  final String? paymentTerms;
  final int? billingDay;
  final int cutoffBuffer;
  final String? primaryColor;
  final String? secondaryColor;

  InvoiceSettings({
    this.id,
    required this.yardId,
    this.logoUrl,
    this.bankDetails,
    this.paymentTerms,
    this.billingDay,
    this.cutoffBuffer = 5,
    this.primaryColor,
    this.secondaryColor,
  });

  factory InvoiceSettings.fromJson(Map<String, dynamic> json) {
    return InvoiceSettings(
      id: json['id'] as int?,
      yardId: json['yard_id'] as String,
      logoUrl: json['logo_url'] as String?,
      bankDetails: json['bank_details'] as String?,
      paymentTerms: json['payment_terms'] as String?,
      billingDay: json['billing_day'] as int?,
      cutoffBuffer: json['cutoff_buffer'] as int? ?? 5,
      primaryColor: json['primary_color'] as String?,
      secondaryColor: json['secondary_color'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'yard_id': yardId,
    'logo_url': logoUrl,
    'bank_details': bankDetails,
    'payment_terms': paymentTerms,
    'billing_day': billingDay,
    'cutoff_buffer': cutoffBuffer,
    'primary_color': primaryColor,
    'secondary_color': secondaryColor,
  };
}

/// Repository for yard settings (consumables, packages, invoice settings)
class SettingsRepository {
  final SupabaseClient _client = SupabaseManager.client;

  // ============ Consumable Types ============

  Future<List<ConsumableType>> getConsumables(String yardId) async {
    final response = await _client
        .from('consumable_types')
        .select()
        .eq('yard_id', yardId)
        .order('name');

    return (response as List)
        .map((e) => ConsumableType.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<ConsumableType> createConsumable(ConsumableType item) async {
    final response = await _client
        .from('consumable_types')
        .insert(item.toJson())
        .select()
        .single();

    return ConsumableType.fromJson(response);
  }

  Future<ConsumableType> updateConsumable(ConsumableType item) async {
    final response = await _client
        .from('consumable_types')
        .update({
          'name': item.name,
          'stock_unit': item.stockUnit,
          'usage_unit': item.usageUnit,
          'ratio': item.ratio,
          'price_per_usage_unit': item.pricePerUsageUnit,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', item.id)
        .select()
        .single();

    return ConsumableType.fromJson(response);
  }

  Future<void> deleteConsumable(String id) async {
    await _client.from('consumable_types').delete().eq('id', id);
  }

  // ============ Livery Packages ============

  Future<List<LiveryPackage>> getPackages(String yardId) async {
    final response = await _client
        .from('livery_packages')
        .select()
        .eq('yard_id', yardId)
        .eq('is_active', true)
        .order('name');

    return (response as List)
        .map((e) => LiveryPackage.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<LiveryPackage> createPackage(LiveryPackage pkg) async {
    final response = await _client
        .from('livery_packages')
        .insert(pkg.toJson())
        .select()
        .single();

    return LiveryPackage.fromJson(response);
  }

  Future<LiveryPackage> updatePackage(LiveryPackage pkg) async {
    final response = await _client
        .from('livery_packages')
        .update({
          'name': pkg.name,
          'base_price': pkg.basePrice,
          'included_items': pkg.includedItems,
          'is_active': pkg.isActive,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', pkg.id)
        .select()
        .single();

    return LiveryPackage.fromJson(response);
  }

  Future<void> deletePackage(String id) async {
    // Soft delete - set is_active to false
    await _client
        .from('livery_packages')
        .update({'is_active': false})
        .eq('id', id);
  }

  // ============ Invoice Settings ============

  Future<InvoiceSettings?> getInvoiceSettings(String yardId) async {
    final response = await _client
        .from('invoice_settings')
        .select()
        .eq('yard_id', yardId)
        .maybeSingle();

    if (response == null) return null;
    return InvoiceSettings.fromJson(response);
  }

  Future<InvoiceSettings> upsertInvoiceSettings(
    InvoiceSettings settings,
  ) async {
    final response = await _client
        .from('invoice_settings')
        .upsert(settings.toJson(), onConflict: 'yard_id')
        .select()
        .single();

    return InvoiceSettings.fromJson(response);
  }

  // ============ Extras (Services) ============

  Future<List<Extra>> getExtras(String yardId) async {
    final response = await _client
        .from('extras')
        .select()
        .eq('yard_id', yardId)
        .order('name');

    return (response as List)
        .map((e) => Extra.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Extra> createExtra(Extra extra) async {
    final response = await _client
        .from('extras')
        .insert(extra.toJson())
        .select()
        .single();

    return Extra.fromJson(response);
  }

  Future<Extra> updateExtra(Extra extra) async {
    final response = await _client
        .from('extras')
        .update({
          'name': extra.name,
          'price': extra.price,
          'unit': extra.unit,
          'is_recurring': extra.isRecurring,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', extra.id)
        .select()
        .single();

    return Extra.fromJson(response);
  }

  Future<void> deleteExtra(String id) async {
    await _client.from('extras').delete().eq('id', id);
  }
}
