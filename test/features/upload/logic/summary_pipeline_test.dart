import 'dart:io';
import 'dart:typed_data';

import 'package:excel/excel.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:path/path.dart' as path;
import 'package:summaread/features/upload/logic/summary_pipeline.dart';
import 'package:summaread/features/upload/logic/upload_source.dart';
import 'package:summaread/models/summary_record.dart';
import 'package:summaread/services/ai_service.dart';
import 'package:summaread/services/isar_service.dart';

const _samplePage = '''
<!DOCTYPE html>
<html>
<head><title>Sample Article Title</title></head>
<body>
  <nav><a href="/">Home</a></nav>
  <article>
    <h1>Main Article Heading</h1>
    <p>This is the first paragraph of the real article content for the pipeline test.</p>
  </article>
  <footer>Copyright 2026.</footer>
</body>
</html>
''';

void main() {
  late Directory tempDir;
  late Isar isar;
  late IsarService isarService;

  setUpAll(() async {
    await Isar.initializeIsarCore(download: true);
  });

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('summary_pipeline_test_');
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

  GeminiSummarizerService fakeAiService({String docType = ''}) {
    return GeminiSummarizerService.withGenerator((prompt) async {
      return '''
      {
        "executiveSummary": "- Key point one\\n- Key point two",
        "sections": [
          {"sectionTitle": "Overview", "summaryText": "An overview.", "keyPoints": ["A", "B"]}
        ]
      }
      ''';
    });
  }

  test('runs the full pipeline for a file source (xlsx) and persists the result', () async {
    final workbook = Excel.createExcel();
    final defaultSheetName = workbook.getDefaultSheet()!;
    workbook.rename(defaultSheetName, 'Q3 Sales Data');
    final sheet = workbook['Q3 Sales Data'];
    sheet.appendRow([TextCellValue('Region'), TextCellValue('Revenue')]);
    sheet.appendRow([TextCellValue('East'), IntCellValue(1000)]);

    final filePath = path.join(tempDir.path, 'report.xlsx');
    await File(filePath).writeAsBytes(Uint8List.fromList(workbook.encode()!));

    final pipeline = SummaryPipeline(isarService: isarService, aiService: fakeAiService());
    final record = await pipeline.run(FileUploadSource(filePath));

    expect(record.id, greaterThan(0));
    expect(record.title, 'report');
    expect(record.sourcePathOrUrl, filePath);
    expect(record.docType, DocumentType.excel);
    expect(record.executiveSummary, '- Key point one\n- Key point two');
    expect(record.sections, hasLength(1));
    expect(record.sections!.single.sectionTitle, 'Overview');
    expect(record.estimatedReadTimeMinutes, greaterThanOrEqualTo(1));
    expect(record.createdAt, isNotNull);

    // Actually persisted, not just returned in memory.
    final reloaded = await isarService.getSummaryById(record.id);
    expect(reloaded, isNotNull);
    expect(reloaded!.title, 'report');
  });

  test('runs the full pipeline for a URL source and uses the page title', () async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    server.listen((request) {
      request.response
        ..headers.contentType = ContentType.html
        ..write(_samplePage);
      request.response.close();
    });
    addTearDown(() => server.close(force: true));

    final url = 'http://127.0.0.1:${server.port}/';
    final pipeline = SummaryPipeline(isarService: isarService, aiService: fakeAiService());

    final record = await pipeline.run(UrlUploadSource(url));

    expect(record.title, 'Sample Article Title');
    expect(record.sourcePathOrUrl, url);
    expect(record.docType, DocumentType.webArticle);
    expect(record.executiveSummary, '- Key point one\n- Key point two');
  });

  test('throws when the AI service fails, without persisting a partial record', () async {
    final failingAiService = GeminiSummarizerService.withGenerator((prompt) async {
      throw Exception('simulated failure');
    });

    final workbook = Excel.createExcel();
    final defaultSheetName = workbook.getDefaultSheet()!;
    workbook.rename(defaultSheetName, 'Sheet1');
    workbook['Sheet1'].appendRow([TextCellValue('A')]);
    final filePath = path.join(tempDir.path, 'broken.xlsx');
    await File(filePath).writeAsBytes(Uint8List.fromList(workbook.encode()!));

    final pipeline = SummaryPipeline(isarService: isarService, aiService: failingAiService);

    await expectLater(
      () => pipeline.run(FileUploadSource(filePath)),
      throwsA(isA<AiSummarizationException>()),
    );

    final all = await isarService.getAllSummaries();
    expect(all, isEmpty);
  });
}
