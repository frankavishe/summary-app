import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:summaread/features/home/providers/home_providers.dart';
import 'package:summaread/features/upload/logic/summary_pipeline_provider.dart';
import 'package:summaread/features/upload/logic/upload_source.dart';
import 'package:summaread/features/upload/presentation/upload_page.dart';
import 'package:summaread/models/summary_record.dart';

/// A [SummaryPipelineController] driven directly by the test instead of a
/// real extractor/AI/Isar chain - `testWidgets` fakes all HTTP requests to
/// return 400 (see the flutter_test warning), and Isar's native watch stream
/// hangs inside the fake-time test zone (documented in issues.md), so
/// exercising the real pipeline isn't practical here. The real chain is
/// already covered by summary_pipeline_test.dart /
/// summary_pipeline_provider_test.dart; this suite verifies the widget's own
/// wiring: dialog validation, loading UI, and reacting to success/error.
class _FakePipelineController extends SummaryPipelineController {
  _FakePipelineController(this._runImpl);

  final Future<SummaryRecord> Function(UploadSource source) _runImpl;

  @override
  Future<void> run(UploadSource source) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _runImpl(source));
  }
}

SummaryRecord buildRecord({required int id, required String title}) {
  return SummaryRecord()
    ..id = id
    ..title = title
    ..sourcePathOrUrl = title
    ..docType = DocumentType.webArticle
    ..executiveSummary = 'Summary of $title'
    ..sections = []
    ..createdAt = DateTime.now()
    ..isFavorite = false
    ..estimatedReadTimeMinutes = 3;
}

void main() {
  Future<void> pumpUploadPage(
    WidgetTester tester, {
    required Future<SummaryRecord> Function(UploadSource source) runImpl,
    List<SummaryRecord> knownSummaries = const [],
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          summaryPipelineControllerProvider.overrideWith(
            () => _FakePipelineController(runImpl),
          ),
          summariesStreamProvider.overrideWith((ref) => Stream.value(knownSummaries)),
        ],
        child: const MaterialApp(home: UploadPage()),
      ),
    );
    await tester.pump();
  }

  test('only pdf/docx/xlsx extensions are offered to the file picker', () {
    expect(kAllowedUploadExtensions, ['pdf', 'docx', 'xlsx']);
  });

  testWidgets('URL dialog rejects invalid input and stays open', (tester) async {
    await pumpUploadPage(tester, runImpl: (_) async => buildRecord(id: 1, title: 'Unused'));

    await tester.tap(find.text('Paste a web article URL'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'not a url');
    await tester.tap(find.text('Summarize'));
    await tester.pump();

    expect(find.text('Enter a valid http(s) URL'), findsOneWidget);
    expect(find.byType(AlertDialog), findsOneWidget);
  });

  testWidgets('URL dialog accepts a valid http(s) URL and closes', (tester) async {
    UploadSource? received;
    await pumpUploadPage(
      tester,
      runImpl: (source) async {
        received = source;
        return buildRecord(id: 1, title: 'Result');
      },
    );

    await tester.tap(find.text('Paste a web article URL'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'https://example.com/article');
    await tester.tap(find.text('Summarize'));
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsNothing);
    expect(received, isA<UrlUploadSource>());
    expect((received! as UrlUploadSource).url, 'https://example.com/article');
  });

  testWidgets('shows a loading state while the pipeline runs, then navigates on success', (
    tester,
  ) async {
    final completer = Completer<SummaryRecord>();
    await pumpUploadPage(
      tester,
      runImpl: (_) => completer.future,
      knownSummaries: [buildRecord(id: 7, title: 'Finished Report')],
    );

    await tester.tap(find.text('Paste a web article URL'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'https://example.com/article');
    await tester.tap(find.text('Summarize'));
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Summarizing...'), findsOneWidget);

    completer.complete(buildRecord(id: 7, title: 'Finished Report'));
    await tester.pumpAndSettle();

    expect(find.text('Finished Report'), findsOneWidget);
    expect(find.text('New Summary'), findsNothing);
  });

  testWidgets('a pipeline failure shows an error snackbar instead of navigating', (tester) async {
    await pumpUploadPage(
      tester,
      runImpl: (_) async => throw Exception('boom'),
    );

    await tester.tap(find.text('Paste a web article URL'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'https://example.com/article');
    await tester.tap(find.text('Summarize'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Could not generate summary'), findsOneWidget);
    expect(find.text('New Summary'), findsOneWidget);
  });
}
