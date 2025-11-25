import 'package:drift/drift.dart';

import 'connection/connection.dart';

part 'app_database.g.dart';

class Yards extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get address => text().nullable()();
  TextColumn get createdBy => text()();
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

@DriftDatabase(
  tables: [
    Yards,
    Profiles,
    ConsumableTypes,
    LiveryPackages,
    InvoiceSettings,
    SyncQueue,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(openConnection());

  @override
  int get schemaVersion => 1;
}
