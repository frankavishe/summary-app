import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:summaread/features/home/providers/home_providers.dart';
import 'package:summaread/features/summary_viewer/presentation/summary_detail_page.dart';
import 'package:summaread/models/summary_record.dart';
import 'package:summaread/services/providers.dart';
import 'package:summaread/services/tts_service.dart';

class FakeTtsEngine implements TtsEngine {
  final List<String> spokenTexts = [];
  int pauseCalls = 0;
  int stopCalls = 0;

  VoidCallback? _onStart;
  VoidCallback? _onPause;
  VoidCallback? _onContinue;

  @override
  Future<void> speak(String text) async {
    spokenTexts.add(text);
  }

  @override
  Future<void> pause() async {
    pauseCalls++;
  }

  @override
  Future<void> stop() async {
    stopCalls++;
  }

  @override
  void setStartHandler(VoidCallback handler) => _onStart = handler;

  @override
  void setCompletionHandler(VoidCallback handler) {}

  @override
  void setPauseHandler(VoidCallback handler) => _onPause = handler;

  @override
  void setContinueHandler(VoidCallback handler) => _onContinue = handler;

  @override
  void setCancelHandler(VoidCallback handler) {}

  @override
  void setErrorHandler(void Function(dynamic message) handler) {}

  void simulateStart() => _onStart?.call();
  void simulatePause() => _onPause?.call();
  void simulateContinue() => _onContinue?.call();
}

void main() {
  late FakeTtsEngine fakeEngine;
  late TtsService ttsService;
  late StreamController<List<SummaryRecord>> summariesController;

  setUp(() {
    fakeEngine = FakeTtsEngine();
    ttsService = TtsService.withEngine(fakeEngine);
    summariesController = StreamController<List<SummaryRecord>>();
  });

  tearDown(() async {
    await summariesController.close();
  });

  SummaryRecord buildRecord() {
    return SummaryRecord()
      ..id = 1
      ..title = 'Deep Dive Report'
      ..sourcePathOrUrl = '/tmp/report.pdf'
      ..docType = DocumentType.pdf
      ..executiveSummary = '- **Key** finding one\n- Key finding two'
      ..sections = [
        SectionSummary()
          ..sectionTitle = 'Chapter 1'
          ..summaryText = 'Chapter 1 body text.'
          ..keyPoints = ['First point', 'Second point'],
      ]
      ..createdAt = DateTime.now()
      ..isFavorite = false
      ..estimatedReadTimeMinutes = 5;
  }

  testWidgets('renders the executive summary and section content as Markdown', (tester) async {
    final record = buildRecord();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          ttsServiceProvider.overrideWithValue(ttsService),
          summariesStreamProvider.overrideWith((ref) => summariesController.stream),
        ],
        child: const MaterialApp(home: SummaryDetailPage(summaryId: 1)),
      ),
    );
    summariesController.add([record]);
    await tester.pump();
    await tester.pump();

    expect(find.text('Deep Dive Report'), findsOneWidget);

    final markdownBodies = tester.widgetList<MarkdownBody>(find.byType(MarkdownBody)).toList();
    final renderedData = markdownBodies.map((w) => w.data).toList();

    expect(renderedData, contains(record.executiveSummary));
    expect(renderedData, contains('Chapter 1 body text.'));
    expect(renderedData, contains('- First point'));
    expect(renderedData, contains('- Second point'));
  });

  testWidgets('play/pause/stop bar drives TtsService and reflects playback state', (tester) async {
    final record = buildRecord();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          ttsServiceProvider.overrideWithValue(ttsService),
          summariesStreamProvider.overrideWith((ref) => summariesController.stream),
        ],
        child: const MaterialApp(home: SummaryDetailPage(summaryId: 1)),
      ),
    );
    summariesController.add([record]);
    await tester.pump();
    await tester.pump();

    expect(find.text('Listen to this summary'), findsOneWidget);
    expect(find.byIcon(Icons.play_circle), findsOneWidget);

    await tester.tap(find.byIcon(Icons.play_circle));
    await tester.pump();

    expect(fakeEngine.spokenTexts, hasLength(1));
    expect(fakeEngine.spokenTexts.single, contains('Key finding one'));
    expect(fakeEngine.spokenTexts.single, contains('Chapter 1'));
    expect(fakeEngine.spokenTexts.single, isNot(contains('**')));

    fakeEngine.simulateStart();
    await tester.pump();

    expect(find.text('Reading summary...'), findsOneWidget);
    expect(find.byIcon(Icons.pause_circle), findsOneWidget);

    await tester.tap(find.byIcon(Icons.pause_circle));
    await tester.pump();
    expect(fakeEngine.pauseCalls, 1);

    fakeEngine.simulatePause();
    await tester.pump();
    expect(find.text('Paused'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.play_circle));
    await tester.pump();
    expect(fakeEngine.spokenTexts, hasLength(2), reason: 'resume() re-speaks the last text');

    fakeEngine.simulateContinue();
    await tester.pump();
    expect(find.text('Reading summary...'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.stop_circle_outlined));
    await tester.pump();

    expect(fakeEngine.stopCalls, 1);
    expect(find.text('Listen to this summary'), findsOneWidget);
  });
}
