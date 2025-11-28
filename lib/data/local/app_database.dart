import 'package:drift/drift.dart';

import 'connection/connection.dart';

part 'app_database.g.dart';

class Yards extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get address => text().nullable()();
  TextColumn get createdBy => text()();
  TextColumn get inviteCode => text().nullable()();
  DateTimeColumn get inviteCodeExpiresAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class Profiles extends Table {
  TextColumn get userId => text()();
  TextColumn get yardId => text().nullable()();
  TextColumn get role => text()();
  TextColumn get fullName => text().nullable()();
  BoolColumn get onboardingCompleted =>
      boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column<Object>> get primaryKey => {userId};
}

class ConsumableTypes extends Table {
  TextColumn get id => text()();
  TextColumn get yardId => text()();
  TextColumn get name => text()();
  TextColumn get stockUnit => text()();
  TextColumn get usageUnit => text()();
  IntColumn get ratio => integer()();
  RealColumn get pricePerUsageUnit => real()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class LiveryPackages extends Table {
  TextColumn get id => text()();
  TextColumn get yardId => text()();
  TextColumn get name => text()();
  IntColumn get version => integer().withDefault(const Constant(1))();
  RealColumn get basePrice => real()();
  TextColumn get includedItemsJson =>
      text().withDefault(const Constant('[]'))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class InvoiceSettings extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get yardId => text().unique()();
  TextColumn get logoUrl => text().nullable()();
  TextColumn get bankDetails => text().nullable()();
  TextColumn get paymentTerms => text().nullable()();
  IntColumn get billingDay => integer().nullable()();
  IntColumn get cutoffBuffer => integer().withDefault(const Constant(5))();
  TextColumn get primaryColor => text().nullable()();
  TextColumn get secondaryColor => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

class SyncQueue extends Table {
  TextColumn get id => text()();
  TextColumn get targetTable => text()();
  TextColumn get operation => text()();
  TextColumn get recordId => text().nullable()();
  TextColumn get payloadJson => text()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  TextColumn get status => text().withDefault(const Constant('pending'))();
  IntColumn get retryCount => integer().withDefault(const Constant(0))();
  TextColumn get lastError => text().nullable()();
  TextColumn get groupId => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class YardAccessRequests extends Table {
  TextColumn get id => text()();
  TextColumn get yardId => text()();
  TextColumn get userId => text()();
  TextColumn get status => text().withDefault(const Constant('pending'))();
  TextColumn get message => text().nullable()();
  TextColumn get reviewedBy => text().nullable()();
  DateTimeColumn get reviewedAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// Horses table - tied to owner (user), not yard directly.
/// When user joins/leaves a yard, their horses come with them.
class Horses extends Table {
  TextColumn get id => text()();
  TextColumn get ownerId => text()(); // The user who owns this horse
  TextColumn get name => text()();
  TextColumn get breed => text().nullable()();
  TextColumn get color => text().nullable()();
  IntColumn get age => integer().nullable()();
  TextColumn get gender => text().nullable()(); // mare, gelding, stallion
  TextColumn get stableNumber => text().nullable()();
  TextColumn get photoUrl => text().nullable()();

  // Care information (only owner can edit)
  TextColumn get dietNotes => text().nullable()();
  TextColumn get careInstructions => text().nullable()();
  TextColumn get feedInstructions => text().nullable()();
  TextColumn get medicalNotes => text().nullable()();

  // Emergency contacts
  TextColumn get vetName => text().nullable()();
  TextColumn get vetPhone => text().nullable()();
  TextColumn get farrierName => text().nullable()();
  TextColumn get farrierPhone => text().nullable()();

  // Soft delete support
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DriftDatabase(
  tables: [
    Yards,
    Profiles,
    ConsumableTypes,
    LiveryPackages,
    InvoiceSettings,
    SyncQueue,
    YardAccessRequests,
    Horses,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(openConnection());

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) => m.createAll(),
    onUpgrade: (Migrator m, int from, int to) async {
      if (from < 2) {
        // Schema v2: Added onboarding fields and yard access requests
        await m.createAll();
      }
      if (from < 3) {
        // Schema v3: Added horses table
        await m.createTable(horses);
      }
    },
  );
}
