import 'package:drift/drift.dart';

import 'app_database.dart';

class YardsRepository {
  YardsRepository(this._db);

  final AppDatabase _db;

  Future<List<Yard>> getAllYards() {
    return _db.select(_db.yards).get();
  }

  Future<void> upsertYard(YardsCompanion yard) {
    return _db.into(_db.yards).insertOnConflictUpdate(yard);
  }
}

class ProfilesRepository {
  ProfilesRepository(this._db);

  final AppDatabase _db;

  Future<Profile?> getProfile(String userId) {
    return (_db.select(
      _db.profiles,
    )..where((tbl) => tbl.userId.equals(userId))).getSingleOrNull();
  }

  Future<void> upsertProfile(ProfilesCompanion profile) {
    return _db.into(_db.profiles).insertOnConflictUpdate(profile);
  }
}

class ConsumableTypesRepository {
  ConsumableTypesRepository(this._db);

  final AppDatabase _db;

  Future<List<ConsumableType>> getConsumablesForYard(String yardId) {
    return (_db.select(
      _db.consumableTypes,
    )..where((tbl) => tbl.yardId.equals(yardId))).get();
  }

  Future<void> upsertConsumable(ConsumableTypesCompanion consumable) {
    return _db.into(_db.consumableTypes).insertOnConflictUpdate(consumable);
  }
}

class LiveryPackagesRepository {
  LiveryPackagesRepository(this._db);

  final AppDatabase _db;

  Future<List<LiveryPackage>> getPackagesForYard(String yardId) {
    return (_db.select(
      _db.liveryPackages,
    )..where((tbl) => tbl.yardId.equals(yardId))).get();
  }

  Future<void> upsertPackage(LiveryPackagesCompanion packageCompanion) {
    return _db
        .into(_db.liveryPackages)
        .insertOnConflictUpdate(packageCompanion);
  }
}

class InvoiceSettingsRepository {
  InvoiceSettingsRepository(this._db);

  final AppDatabase _db;

  Future<InvoiceSetting?> getSettingsForYard(String yardId) {
    return (_db.select(
      _db.invoiceSettings,
    )..where((tbl) => tbl.yardId.equals(yardId))).getSingleOrNull();
  }

  Future<void> upsertSettings(InvoiceSettingsCompanion settings) {
    return _db.into(_db.invoiceSettings).insertOnConflictUpdate(settings);
  }
}

class SyncQueueRepository {
  SyncQueueRepository(this._db);

  final AppDatabase _db;

  Future<void> enqueue(SyncQueueCompanion entry) {
    return _db.into(_db.syncQueue).insert(entry);
  }

  Future<List<SyncQueueData>> pendingEntries() {
    return (_db.select(_db.syncQueue)
          ..where((tbl) => tbl.status.equals('pending'))
          ..orderBy([(tbl) => OrderingTerm(expression: tbl.createdAt)]))
        .get();
  }

  Future<void> markSucceeded(String id) {
    return (_db.update(_db.syncQueue)..where((tbl) => tbl.id.equals(id))).write(
      const SyncQueueCompanion(status: Value('succeeded')),
    );
  }

  Future<void> markFailed(String id, String errorMessage) {
    return (_db.update(_db.syncQueue)..where((tbl) => tbl.id.equals(id))).write(
      SyncQueueCompanion(
        status: const Value('failed'),
        lastError: Value(errorMessage),
        retryCount: const Value(1),
      ),
    );
  }
}
