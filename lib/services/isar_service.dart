import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import '../models/summary_record.dart';

class IsarService {
  IsarService._(this._isar);

  final Isar _isar;

  static Future<IsarService> open() async {
    final dir = await getApplicationDocumentsDirectory();
    final isar = await Isar.open(
      [SummaryRecordSchema],
      directory: dir.path,
    );
    return IsarService._(isar);
  }

  /// Wraps an already-opened [Isar] instance. Used by tests to inject an
  /// isolated in-memory/temp-directory instance instead of the real app
  /// documents directory.
  factory IsarService.forTesting(Isar isar) => IsarService._(isar);

  Future<int> saveSummary(SummaryRecord record) {
    return _isar.writeTxn(() => _isar.summaryRecords.put(record));
  }

  Future<List<SummaryRecord>> getAllSummaries() {
    return _isar.summaryRecords.where().sortByCreatedAtDesc().findAll();
  }

  /// Reactively streams the newest-first summary list, re-emitting whenever
  /// any `SummaryRecord` is added, changed, or removed - so the Home
  /// dashboard updates live without manual refresh calls.
  Stream<List<SummaryRecord>> watchAllSummaries() {
    return _isar.summaryRecords
        .where()
        .sortByCreatedAtDesc()
        .watch(fireImmediately: true);
  }

  Future<SummaryRecord?> getSummaryById(int id) {
    return _isar.summaryRecords.get(id);
  }

  Future<bool> deleteSummary(int id) {
    return _isar.writeTxn(() => _isar.summaryRecords.delete(id));
  }

  Future<void> toggleFavorite(int id) async {
    final record = await _isar.summaryRecords.get(id);
    if (record == null) return;
    record.isFavorite = !record.isFavorite;
    await _isar.writeTxn(() => _isar.summaryRecords.put(record));
  }

  Future<void> close() => _isar.close();
}
