import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:path/path.dart' as path;
import 'package:summaread/models/summary_record.dart';
import 'package:summaread/services/isar_service.dart';

void main() {
  late Directory tempDir;
  late Isar isar;
  late IsarService service;

  setUpAll(() async {
    await Isar.initializeIsarCore(download: true);
  });

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('isar_service_test_');
    isar = await Isar.open(
      [SummaryRecordSchema],
      directory: tempDir.path,
      name: path.basename(tempDir.path),
    );
    service = IsarService.forTesting(isar);
  });

  tearDown(() async {
    await isar.close(deleteFromDisk: true);
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  SummaryRecord buildSample() {
    return SummaryRecord()
      ..title = 'Sample Report'
      ..sourcePathOrUrl = '/tmp/sample.pdf'
      ..docType = DocumentType.pdf
      ..executiveSummary = 'A short executive summary.'
      ..sections = [
        SectionSummary()
          ..sectionTitle = 'Chapter 1'
          ..summaryText = 'Chapter 1 summary text.'
          ..keyPoints = ['Point A', 'Point B'],
      ]
      ..createdAt = DateTime(2026, 1, 1)
      ..estimatedReadTimeMinutes = 5;
  }

  test('saveSummary + getSummaryById round-trips all fields', () async {
    final id = await service.saveSummary(buildSample());

    final fetched = await service.getSummaryById(id);

    expect(fetched, isNotNull);
    expect(fetched!.title, 'Sample Report');
    expect(fetched.docType, DocumentType.pdf);
    expect(fetched.executiveSummary, 'A short executive summary.');
    expect(fetched.sections, hasLength(1));
    expect(fetched.sections!.first.sectionTitle, 'Chapter 1');
    expect(fetched.sections!.first.keyPoints, ['Point A', 'Point B']);
    expect(fetched.isFavorite, isFalse);
  });

  test('getAllSummaries returns newest first', () async {
    final older = buildSample()..createdAt = DateTime(2026, 1, 1);
    final newer = buildSample()
      ..title = 'Newer Report'
      ..createdAt = DateTime(2026, 2, 1);

    await service.saveSummary(older);
    await service.saveSummary(newer);

    final all = await service.getAllSummaries();

    expect(all, hasLength(2));
    expect(all.first.title, 'Newer Report');
  });

  test('deleteSummary removes the record', () async {
    final id = await service.saveSummary(buildSample());

    final deleted = await service.deleteSummary(id);
    final fetched = await service.getSummaryById(id);
    final all = await service.getAllSummaries();

    expect(deleted, isTrue);
    expect(fetched, isNull);
    expect(all, isEmpty);
  });

  test('toggleFavorite flips isFavorite and persists', () async {
    final id = await service.saveSummary(buildSample());

    await service.toggleFavorite(id);
    final afterFirstToggle = await service.getSummaryById(id);

    await service.toggleFavorite(id);
    final afterSecondToggle = await service.getSummaryById(id);

    expect(afterFirstToggle!.isFavorite, isTrue);
    expect(afterSecondToggle!.isFavorite, isFalse);
  });
}
