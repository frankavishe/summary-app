import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:path/path.dart' as path;
import 'package:summaread/features/home/presentation/home_page.dart';
import 'package:summaread/features/home/providers/home_providers.dart';
import 'package:summaread/models/summary_record.dart';
import 'package:summaread/services/isar_service.dart';
import 'package:summaread/services/providers.dart';

void main() {
  late Directory tempDir;
  late Isar isar;
  late IsarService isarService;
  late StreamController<List<SummaryRecord>> summariesController;

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
    summariesController = StreamController<List<SummaryRecord>>();
  });

  tearDown(() async {
    await summariesController.close();
    await isar.close(deleteFromDisk: true);
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

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

  // Real Isar writes (saveSummary/toggleFavorite) resolve fine inside a
  // pumped widget test, but Isar's *watch* mechanism relies on a persistent
  // native ReceivePort that never delivers its message inside
  // TestWidgetsFlutterBinding's fake-async zone - it hangs for real minutes
  // instead of failing fast. So `summariesStreamProvider` is overridden here
  // with a controller the test drives directly (standard Riverpod testing
  // practice), rather than going through the real `watchAllSummaries()`.
  // This still exercises the actual UI/live-update logic; it just doesn't
  // exercise Isar's own watch plumbing, which is covered by Isar's own
  // tests - see the note in issues.md.
  Future<void> pumpHomePage(
    WidgetTester tester, {
    List<SummaryRecord> initialSummaries = const [],
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          isarServiceProvider.overrideWith((ref) async => isarService),
          summariesStreamProvider.overrideWith(
            (ref) => summariesController.stream,
          ),
        ],
        child: const MaterialApp(home: HomePage()),
      ),
    );
    summariesController.add(initialSummaries);
    await tester.pump();
    await tester.pump();
  }

  testWidgets('shows the empty state when there are no summaries', (tester) async {
    await pumpHomePage(tester);

    expect(find.text('No summaries yet'), findsOneWidget);
  });

  testWidgets('lists saved summaries newest first with read time', (tester) async {
    final older = buildRecord(title: 'Older Report');
    final newer = buildRecord(title: 'Newer Report');
    await tester.runAsync(() async {
      await isarService.saveSummary(older);
      await isarService.saveSummary(newer);
    });

    await pumpHomePage(tester, initialSummaries: [newer, older]);

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
    final record = buildRecord(title: 'Toggle Me');
    final id = await tester.runAsync(() => isarService.saveSummary(record));
    record.id = id!;

    await pumpHomePage(tester, initialSummaries: [record]);

    expect(find.byIcon(Icons.star_border), findsOneWidget);
    expect(find.byIcon(Icons.star), findsNothing);

    // The star button's onPressed is `void Function()`, so it fires the
    // toggle write without the widget tree ever awaiting it - plain pump()
    // calls only advance fake time and don't drive that real Isar write to
    // completion. Tap and poll for it inside runAsync's real event loop
    // rather than guessing a fixed delay (flaky under load otherwise).
    final reloaded = (await tester.runAsync(() async {
      await tester.tap(find.byIcon(Icons.star_border));
      var record = await isarService.getSummaryById(id);
      final deadline = DateTime.now().add(const Duration(seconds: 5));
      while (record?.isFavorite != true && DateTime.now().isBefore(deadline)) {
        await Future<void>.delayed(const Duration(milliseconds: 20));
        record = await isarService.getSummaryById(id);
      }
      return record;
    }))!;
    await tester.pump();

    expect(reloaded.isFavorite, isTrue);

    // Simulate the live watcher pushing the updated record, as it would in
    // the real app.
    summariesController.add([reloaded]);
    await tester.pump();

    expect(find.byIcon(Icons.star), findsOneWidget);
    expect(find.byIcon(Icons.star_border), findsNothing);
  });

  testWidgets('tapping a summary card navigates to its detail view', (tester) async {
    final record = buildRecord(title: 'Deep Dive Report');
    final id = await tester.runAsync(() => isarService.saveSummary(record));
    record.id = id!;

    await pumpHomePage(tester, initialSummaries: [record]);
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
