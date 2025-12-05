import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Represents a consumable charge for billing
class ConsumableCharge {
  final String id;
  final String horseId;
  final String horseName;
  final String consumableName;
  final double quantity;
  final String unit;
  final double pricePerUnit;
  final double totalCost;
  final DateTime loggedAt;
  final String? loggedByName;

  ConsumableCharge({
    required this.id,
    required this.horseId,
    required this.horseName,
    required this.consumableName,
    required this.quantity,
    required this.unit,
    required this.pricePerUnit,
    required this.totalCost,
    required this.loggedAt,
    this.loggedByName,
  });

  factory ConsumableCharge.fromJson(Map<String, dynamic> json) {
    final consumable = json['consumable_type'] as Map<String, dynamic>?;
    final horse = json['horse'] as Map<String, dynamic>?;
    final profile = json['profile'] as Map<String, dynamic>?;
    final quantity = (json['quantity_usage'] as num?)?.toDouble() ?? 0;
    final pricePerUnit =
        (consumable?['price_per_usage_unit'] as num?)?.toDouble() ?? 0;

    return ConsumableCharge(
      id: json['id'] as String,
      horseId: json['horse_id'] as String? ?? '',
      horseName: horse?['name'] as String? ?? 'Unknown',
      consumableName: consumable?['name'] as String? ?? 'Unknown',
      quantity: quantity,
      unit: consumable?['usage_unit'] as String? ?? 'unit',
      pricePerUnit: pricePerUnit,
      totalCost: quantity * pricePerUnit,
      loggedAt: DateTime.parse(json['log_at'] as String),
      loggedByName: profile?['full_name'] as String?,
    );
  }
}

/// Represents a horse's billing summary
class HorseBillingSummary {
  final String horseId;
  final String horseName;
  final double consumablesCost;
  final double packageCost;
  final String? packageName;
  final List<ConsumableCharge> charges;

  HorseBillingSummary({
    required this.horseId,
    required this.horseName,
    required this.consumablesCost,
    this.packageCost = 0,
    this.packageName,
    required this.charges,
  });

  double get totalCost => packageCost + consumablesCost;
}

/// Represents a user's billing summary (for owner view)
class UserBillingSummary {
  final String oderId;
  final String ownerName;
  final double packageCost;
  final String? packageName;
  final double consumablesCost;
  final double extrasCost;
  final double totalCost;
  final List<HorseBillingSummary> horseBreakdowns;
  final List<ExtraCharge> extras;

  UserBillingSummary({
    required this.oderId,
    required this.ownerName,
    required this.packageCost,
    this.packageName,
    required this.consumablesCost,
    this.extrasCost = 0,
    required this.totalCost,
    required this.horseBreakdowns,
    this.extras = const [],
  });
}

/// Represents an extra charge for a user
class ExtraCharge {
  final String name;
  final double price;
  final String unit;
  final double monthlyPrice;

  ExtraCharge({
    required this.name,
    required this.price,
    required this.unit,
    required this.monthlyPrice,
  });
}

/// Represents a billing summary for a user
class BillingSummary {
  final double packageCost;
  final String? packageName;
  final double consumablesCost;
  final double extrasCost;
  final double totalCost;
  final List<ConsumableCharge> consumableCharges;
  final DateTime cycleStart;
  final DateTime cycleEnd;

  BillingSummary({
    required this.packageCost,
    this.packageName,
    required this.consumablesCost,
    required this.extrasCost,
    required this.totalCost,
    required this.consumableCharges,
    required this.cycleStart,
    required this.cycleEnd,
  });
}

class BillingRepository {
  final _supabase = Supabase.instance.client;

  /// Get the current billing cycle dates (1st to last day of current month)
  (DateTime, DateTime) getCurrentBillingCycle() {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, 1);
    final end = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
    return (start, end);
  }

  /// Get billing summary for the current user
  Future<BillingSummary> getBillingSummary(String yardId) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('Not authenticated');

    final (cycleStart, cycleEnd) = getCurrentBillingCycle();

    // Get user's horses
    final horsesResponse = await _supabase
        .from('horses')
        .select('id')
        .eq('current_yard_id', yardId)
        .eq('created_by', userId);

    final horseIds = (horsesResponse as List)
        .map((h) => h['id'] as String)
        .toList();

    if (horseIds.isEmpty) {
      return BillingSummary(
        packageCost: 0,
        consumablesCost: 0,
        extrasCost: 0,
        totalCost: 0,
        consumableCharges: [],
        cycleStart: cycleStart,
        cycleEnd: cycleEnd,
      );
    }

    // Get consumable logs for user's horses in current cycle
    final logsResponse = await _supabase
        .from('consumable_logs')
        .select('''
          id, quantity_usage, log_at, is_billable,
          consumable_type:consumable_type_id(name, usage_unit, price_per_usage_unit),
          horse:horse_id(name)
        ''')
        .eq('yard_id', yardId)
        .inFilter('horse_id', horseIds)
        .gte('log_at', cycleStart.toIso8601String())
        .lte('log_at', cycleEnd.toIso8601String())
        .eq('is_billable', true)
        .eq('is_deleted', false)
        .order('log_at', ascending: false);

    final charges = (logsResponse as List)
        .map((json) => ConsumableCharge.fromJson(json))
        .toList();

    final consumablesCost = charges.fold<double>(
      0,
      (sum, c) => sum + c.totalCost,
    );

    // Get package costs for user's horses
    double packageCost = 0;
    String? packageName;
    final now = DateTime.now();

    if (horseIds.isNotEmpty) {
      final packageResponse = await _supabase
          .from('user_packages')
          .select('''
            horse_id,
            livery_package:package_id(name, base_price)
          ''')
          .eq('yard_id', yardId)
          .inFilter('horse_id', horseIds)
          .lte('effective_from', now.toIso8601String())
          .or('effective_to.is.null,effective_to.gte.${now.toIso8601String()}');

      for (final pkg in packageResponse as List) {
        final liveryPkg = pkg['livery_package'] as Map<String, dynamic>?;
        if (liveryPkg != null) {
          packageCost += (liveryPkg['base_price'] as num?)?.toDouble() ?? 0;
          packageName ??= liveryPkg['name'] as String?;
        }
      }
    }

    // Calculate extras cost for this user
    double extrasCost = 0;
    final extrasResponse = await _supabase
        .from('user_extras')
        .select('extra:extra_id(price, unit)')
        .eq('yard_id', yardId)
        .eq('user_id', userId)
        .lte('effective_from', now.toIso8601String())
        .or('effective_to.is.null,effective_to.gte.${now.toIso8601String()}');

    for (final e in extrasResponse as List) {
      final extra = e['extra'] as Map<String, dynamic>?;
      if (extra != null) {
        final price = (extra['price'] as num?)?.toDouble() ?? 0;
        final unit = extra['unit'] as String? ?? '';
        // Convert to monthly
        if (unit.toLowerCase().contains('week')) {
          extrasCost += price * 4.33;
        } else if (unit.toLowerCase().contains('day')) {
          extrasCost += price * 30.44;
        } else {
          extrasCost += price;
        }
      }
    }

    return BillingSummary(
      packageCost: packageCost,
      packageName: packageName,
      consumablesCost: consumablesCost,
      extrasCost: extrasCost,
      totalCost: packageCost + consumablesCost + extrasCost,
      consumableCharges: charges,
      cycleStart: cycleStart,
      cycleEnd: cycleEnd,
    );
  }

  /// Get consumable charges grouped by horse
  Map<String, List<ConsumableCharge>> groupChargesByHorse(
    List<ConsumableCharge> charges,
  ) {
    final grouped = <String, List<ConsumableCharge>>{};
    for (final charge in charges) {
      grouped.putIfAbsent(charge.horseName, () => []).add(charge);
    }
    return grouped;
  }

  /// Get consumable charges grouped by type
  Map<String, double> groupChargesByType(List<ConsumableCharge> charges) {
    final grouped = <String, double>{};
    for (final charge in charges) {
      grouped.update(
        charge.consumableName,
        (value) => value + charge.totalCost,
        ifAbsent: () => charge.totalCost,
      );
    }
    return grouped;
  }

  /// Get recent activity for the yard (for owner dashboard)
  Future<List<ConsumableCharge>> getRecentActivity(
    String yardId, {
    int limit = 20,
  }) async {
    debugPrint('getRecentActivity: yardId=$yardId');
    try {
      final response = await _supabase
          .from('consumable_logs')
          .select('''
            id, horse_id, quantity_usage, log_at, is_billable, user_id,
            consumable_type:consumable_type_id(name, usage_unit, price_per_usage_unit),
            horse:horse_id(name)
          ''')
          .eq('yard_id', yardId)
          .eq('is_deleted', false)
          .order('log_at', ascending: false)
          .limit(limit);

      final logs = response as List;
      debugPrint('getRecentActivity: got ${logs.length} items');

      // Fetch user names separately
      final userIds = logs
          .map((l) => l['user_id'] as String?)
          .whereType<String>()
          .toSet()
          .toList();
      final userNames = <String, String>{};
      if (userIds.isNotEmpty) {
        final profiles = await _supabase
            .from('profiles')
            .select('user_id, full_name')
            .inFilter('user_id', userIds);
        for (final p in profiles as List) {
          userNames[p['user_id'] as String] =
              p['full_name'] as String? ?? 'Unknown';
        }
      }

      return logs.map((json) {
        final userId = json['user_id'] as String?;
        json['profile'] = {'full_name': userNames[userId] ?? 'Staff'};
        return ConsumableCharge.fromJson(json);
      }).toList();
    } catch (e) {
      debugPrint('getRecentActivity error: $e');
      rethrow;
    }
  }

  /// Get activity for a specific horse (for user's horse profile)
  Future<List<ConsumableCharge>> getHorseActivity(
    String horseId, {
    int limit = 50,
  }) async {
    final response = await _supabase
        .from('consumable_logs')
        .select('''
          id, horse_id, quantity_usage, log_at, is_billable, user_id,
          consumable_type:consumable_type_id(name, usage_unit, price_per_usage_unit),
          horse:horse_id(name)
        ''')
        .eq('horse_id', horseId)
        .eq('is_deleted', false)
        .order('log_at', ascending: false)
        .limit(limit);

    final logs = response as List;

    // Fetch user names separately
    final userIds = logs
        .map((l) => l['user_id'] as String?)
        .whereType<String>()
        .toSet()
        .toList();
    final userNames = <String, String>{};
    if (userIds.isNotEmpty) {
      final profiles = await _supabase
          .from('profiles')
          .select('user_id, full_name')
          .inFilter('user_id', userIds);
      for (final p in profiles as List) {
        userNames[p['user_id'] as String] =
            p['full_name'] as String? ?? 'Unknown';
      }
    }

    return logs.map((json) {
      final userId = json['user_id'] as String?;
      json['profile'] = {'full_name': userNames[userId] ?? 'Staff'};
      return ConsumableCharge.fromJson(json);
    }).toList();
  }

  /// Get all users' billing summaries for the yard (for owner invoicing view)
  Future<List<UserBillingSummary>> getAllUsersBilling(String yardId) async {
    debugPrint('getAllUsersBilling: yardId=$yardId');
    final (cycleStart, cycleEnd) = getCurrentBillingCycle();

    // Get all users with horses in the yard
    final usersWithHorses = await _supabase
        .from('horses')
        .select('created_by, id, name')
        .eq('current_yard_id', yardId);

    final horsesList = usersWithHorses as List;
    debugPrint('getAllUsersBilling: found ${horsesList.length} horses');

    // Group horses by owner
    final horsesByOwner = <String, List<Map<String, dynamic>>>{};
    for (final horse in horsesList) {
      final ownerId = horse['created_by'] as String;
      horsesByOwner.putIfAbsent(ownerId, () => []).add(horse);
    }

    if (horsesByOwner.isEmpty) return [];

    // Get owner names
    final ownerIds = horsesByOwner.keys.toList();
    final profilesResponse = await _supabase
        .from('profiles')
        .select('user_id, full_name')
        .inFilter('user_id', ownerIds);

    final ownerNames = <String, String>{};
    for (final profile in profilesResponse as List) {
      ownerNames[profile['user_id'] as String] =
          profile['full_name'] as String? ?? 'Unknown';
    }

    // Get all consumable logs for the cycle
    final allHorseIds = horsesByOwner.values
        .expand((h) => h.map((x) => x['id']))
        .toList();

    final logsResponse = await _supabase
        .from('consumable_logs')
        .select('''
          id, horse_id, quantity_usage, log_at, is_billable,
          consumable_type:consumable_type_id(name, usage_unit, price_per_usage_unit),
          horse:horse_id(name)
        ''')
        .eq('yard_id', yardId)
        .inFilter('horse_id', allHorseIds)
        .gte('log_at', cycleStart.toIso8601String())
        .lte('log_at', cycleEnd.toIso8601String())
        .eq('is_billable', true)
        .eq('is_deleted', false);

    // Group logs by horse
    final logsByHorse = <String, List<ConsumableCharge>>{};
    for (final log in logsResponse as List) {
      final charge = ConsumableCharge.fromJson(log);
      logsByHorse.putIfAbsent(charge.horseId, () => []).add(charge);
    }

    // Get packages for all horses (packages are per-horse, not per-user)
    final now = DateTime.now();
    final packagesResponse = await _supabase
        .from('user_packages')
        .select('horse_id, livery_package:package_id(name, base_price)')
        .eq('yard_id', yardId)
        .inFilter('horse_id', allHorseIds)
        .lte('effective_from', now.toIso8601String())
        .or('effective_to.is.null,effective_to.gte.${now.toIso8601String()}');

    final packagesByHorse = <String, Map<String, dynamic>>{};
    for (final pkg in packagesResponse as List) {
      final horseId = pkg['horse_id'] as String;
      packagesByHorse[horseId] =
          pkg['livery_package'] as Map<String, dynamic>? ?? {};
    }

    // Build user billing summaries
    final summaries = <UserBillingSummary>[];
    for (final entry in horsesByOwner.entries) {
      final ownerId = entry.key;
      final horses = entry.value;

      final horseBreakdowns = <HorseBillingSummary>[];
      double totalConsumables = 0;
      double totalPackageCost = 0;
      String? firstPackageName;

      for (final horse in horses) {
        final horseId = horse['id'] as String;
        final horseName = horse['name'] as String;
        final charges = logsByHorse[horseId] ?? [];
        final horseCost = charges.fold<double>(
          0,
          (sum, c) => sum + c.totalCost,
        );

        // Get package for this horse
        final pkg = packagesByHorse[horseId];
        final horsePackageCost = (pkg?['base_price'] as num?)?.toDouble() ?? 0;
        final horsePackageName = pkg?['name'] as String?;

        totalPackageCost += horsePackageCost;
        firstPackageName ??= horsePackageName;

        horseBreakdowns.add(
          HorseBillingSummary(
            horseId: horseId,
            horseName: horseName,
            consumablesCost: horseCost,
            charges: charges,
            packageCost: horsePackageCost,
            packageName: horsePackageName,
          ),
        );

        totalConsumables += horseCost;
      }

      final packageCost = totalPackageCost;
      final packageName = firstPackageName;

      // Get extras for this user
      final userExtrasResponse = await _supabase
          .from('user_extras')
          .select('extra:extra_id(name, price, unit)')
          .eq('yard_id', yardId)
          .eq('user_id', ownerId)
          .lte('effective_from', now.toIso8601String())
          .or('effective_to.is.null,effective_to.gte.${now.toIso8601String()}');

      double totalExtras = 0;
      final extraCharges = <ExtraCharge>[];
      for (final e in userExtrasResponse as List) {
        final extra = e['extra'] as Map<String, dynamic>?;
        if (extra != null) {
          final price = (extra['price'] as num?)?.toDouble() ?? 0;
          final unit = extra['unit'] as String? ?? '';
          final name = extra['name'] as String? ?? '';

          // Convert to monthly
          double monthlyPrice = price;
          if (unit.toLowerCase().contains('week')) {
            monthlyPrice = price * 4.33;
          } else if (unit.toLowerCase().contains('day')) {
            monthlyPrice = price * 30.44;
          }

          totalExtras += monthlyPrice;
          extraCharges.add(
            ExtraCharge(
              name: name,
              price: price,
              unit: unit,
              monthlyPrice: monthlyPrice,
            ),
          );
        }
      }

      summaries.add(
        UserBillingSummary(
          oderId: ownerId,
          ownerName: ownerNames[ownerId] ?? 'Unknown',
          packageCost: packageCost,
          packageName: packageName,
          consumablesCost: totalConsumables,
          extrasCost: totalExtras,
          totalCost: packageCost + totalConsumables + totalExtras,
          horseBreakdowns: horseBreakdowns,
          extras: extraCharges,
        ),
      );
    }

    // Sort by total cost descending
    summaries.sort((a, b) => b.totalCost.compareTo(a.totalCost));

    return summaries;
  }
}
