import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:path/path.dart' as path;
import 'package:summaread/features/home/presentation/home_page.dart';
import 'package:summaread/models/summary_record.dart';
import 'package:summaread/services/isar_service.dart';
import 'package:summaread/services/providers.dart';

void main() {
  late Directory tempDir;
  late Isar isar;
  late IsarService isarService;

  setUpAll(() async {
    await Isar.initializeIsarCore(download: true);
  });

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('home_page_test_');
    isar = await Isar.open(
      [SummaryRecordSchema],
      directory: tempDir.path,
      name: path.basename(tempDir.path),
    );
    isarService = IsarService.forTesting(isar);
  });

  tearDown(() async {
    await isar.close(deleteFromDisk: true);
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  Future<void> pumpHomePage(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          isarServiceProvider.overrideWith((ref) async => isarService),
        ],
        child: const MaterialApp(home: HomePage()),
      ),
    );
    await tester.pumpAndSettle();
  }

  SummaryRecord buildRecord({
    required String title,
    bool isFavorite = false,
    DocumentType docType = DocumentType.pdf,
  }) {
    return SummaryRecord()
      ..title = title
      ..sourcePathOrUrl = '/tmp/$title'
      ..docType = docType
      ..executiveSummary = 'Summary of $title'
      ..sections = []
      ..createdAt = DateTime.now()
      ..isFavorite = isFavorite
      ..estimatedReadTimeMinutes = 5;
  }

  testWidgets('shows the empty state when there are no summaries', (tester) async {
    await pumpHomePage(tester);

    expect(find.text('No summaries yet'), findsOneWidget);
  });

  testWidgets('lists saved summaries newest first with read time', (tester) async {
    await isarService.saveSummary(buildRecord(title: 'Older Report'));
    await Future<void>.delayed(const Duration(milliseconds: 5));
    await isarService.saveSummary(buildRecord(title: 'Newer Report'));

    await pumpHomePage(tester);

    expect(find.text('No summaries yet'), findsNothing);
    expect(find.text('Newer Report'), findsOneWidget);
    expect(find.text('Older Report'), findsOneWidget);
    expect(find.text('5 min read'), findsNWidgets(2));

    final titles = tester
        .widgetList<ListTile>(find.byType(ListTile))
        .map((tile) => (tile.title! as Text).data)
        .toList();
    expect(titles, ['Newer Report', 'Older Report']);
  });

  testWidgets('tapping the favorite star toggles isFavorite and updates live', (tester) async {
    final id = await isarService.saveSummary(buildRecord(title: 'Toggle Me'));

    await pumpHomePage(tester);

    expect(find.byIcon(Icons.star_border), findsOneWidget);
    expect(find.byIcon(Icons.star), findsNothing);

    await tester.tap(find.byIcon(Icons.star_border));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.star), findsOneWidget);
    expect(find.byIcon(Icons.star_border), findsNothing);

    final reloaded = await isarService.getSummaryById(id);
    expect(reloaded!.isFavorite, isTrue);
  });

  testWidgets('tapping a summary card navigates to its detail view', (tester) async {
    await isarService.saveSummary(buildRecord(title: 'Deep Dive Report'));

    await pumpHomePage(tester);
    await tester.tap(find.text('Deep Dive Report'));
    await tester.pumpAndSettle();

    expect(find.text('Deep Dive Report'), findsOneWidget);
    expect(find.text('Summary of Deep Dive Report'), findsOneWidget);
  });

  testWidgets('tapping the FAB navigates to the upload placeholder', (tester) async {
    await pumpHomePage(tester);

    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    expect(find.text('New Summary'), findsOneWidget);
  });
}
