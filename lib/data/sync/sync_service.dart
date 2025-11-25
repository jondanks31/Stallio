import '../local/app_database.dart';
import '../local/local_repositories.dart';

abstract class RemoteApi {
  Future<void> pull(AppDatabase db);
  Future<void> pushEntry(SyncQueueData entry);
}

class NoopRemoteApi implements RemoteApi {
  @override
  Future<void> pull(AppDatabase db) async {}

  @override
  Future<void> pushEntry(SyncQueueData entry) async {}
}

class SyncService {
  SyncService({required AppDatabase database, required RemoteApi remoteApi})
    : _db = database,
      _remoteApi = remoteApi,
      _syncQueueRepository = SyncQueueRepository(database);

  final AppDatabase _db;
  final RemoteApi _remoteApi;
  final SyncQueueRepository _syncQueueRepository;

  Future<void> syncAll() async {
    await _pullFromServer();
    await _pushQueue();
  }

  Future<void> _pullFromServer() async {
    await _remoteApi.pull(_db);
  }

  Future<void> _pushQueue() async {
    final entries = await _syncQueueRepository.pendingEntries();
    for (final entry in entries) {
      await _remoteApi.pushEntry(entry);
    }
  }
}
