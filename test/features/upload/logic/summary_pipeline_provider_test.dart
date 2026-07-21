import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:path/path.dart' as path;
import 'package:summaread/features/upload/logic/summary_pipeline_provider.dart';
import 'package:summaread/features/upload/logic/upload_source.dart';
import 'package:summaread/models/summary_record.dart';
import 'package:summaread/services/ai_service.dart';
import 'package:summaread/services/isar_service.dart';
import 'package:summaread/services/providers.dart';

/// Simulates a UI "test button" driving the whole pipeline through Riverpod
/// state, without needing a real Isar path or a real Gemini API key.
void main() {
  late Directory tempDir;
  late Isar isar;

  setUpAll(() async {
    await Isar.initializeIsarCore(download: true);
  });

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('summary_pipeline_provider_test_');
    isar = await Isar.open(
      [SummaryRecordSchema],
      directory: tempDir.path,
      name: path.basename(tempDir.path),
    );
  });

  tearDown(() async {
    await isar.close(deleteFromDisk: true);
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('run() transitions loading -> data and the record is persisted', () async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    server.listen((request) {
      request.response
        ..headers.contentType = ContentType.html
        ..write('<html><head><title>Provider Test Page</title></head>'
            '<body><article><h1>Heading</h1><p>Some article body text.</p></article></body></html>');
      request.response.close();
    });
    addTearDown(() => server.close(force: true));

    final container = ProviderContainer(
      overrides: [
        isarServiceProvider.overrideWith((ref) async => IsarService.forTesting(isar)),
        aiServiceProvider.overrideWithValue(
          GeminiSummarizerService.withGenerator(
            (prompt) async => '{"executiveSummary": "- Point", "sections": []}',
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    // Initial state before running anything.
    final initial = await container.read(summaryPipelineControllerProvider.future);
    expect(initial, isNull);

    final url = 'http://127.0.0.1:${server.port}/';
    final runFuture = container
        .read(summaryPipelineControllerProvider.notifier)
        .run(UrlUploadSource(url));

    // Right after calling run(), state should be loading.
    expect(container.read(summaryPipelineControllerProvider).isLoading, isTrue);

    await runFuture;

    final finalState = container.read(summaryPipelineControllerProvider);
    expect(finalState.hasValue, isTrue);
    expect(finalState.value, isA<SummaryRecord>());
    expect(finalState.value!.title, 'Provider Test Page');
    expect(finalState.value!.executiveSummary, '- Point');

    final isarService = await container.read(isarServiceProvider.future);
    final all = await isarService.getAllSummaries();
    expect(all, hasLength(1));
  });

  test('run() surfaces a pipeline failure as AsyncError instead of throwing', () async {
    // A real (fast) local server, but an AI service that fails deterministically -
    // avoids relying on OS-level TCP timeout behavior for an "unreachable" address,
    // which can hang rather than fail fast.
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    server.listen((request) {
      request.response
        ..headers.contentType = ContentType.html
        ..write('<html><head><title>Doomed Page</title></head>'
            '<body><article><h1>H</h1><p>Body text.</p></article></body></html>');
      request.response.close();
    });
    addTearDown(() => server.close(force: true));

    final container = ProviderContainer(
      overrides: [
        isarServiceProvider.overrideWith((ref) async => IsarService.forTesting(isar)),
        aiServiceProvider.overrideWithValue(
          GeminiSummarizerService.withGenerator((prompt) async => 'not json'),
        ),
      ],
    );
    addTearDown(container.dispose);

    final url = 'http://127.0.0.1:${server.port}/';
    await container.read(summaryPipelineControllerProvider.notifier).run(UrlUploadSource(url));

    final finalState = container.read(summaryPipelineControllerProvider);
    expect(finalState.hasError, isTrue);
  });
}
