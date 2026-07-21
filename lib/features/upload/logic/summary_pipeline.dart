import '../../../models/summary_record.dart';
import '../../../services/ai_service.dart';
import '../../../services/extractors/docx_extractor.dart';
import '../../../services/extractors/excel_extractor.dart';
import '../../../services/extractors/pdf_extractor.dart';
import '../../../services/extractors/web_extractor.dart';
import '../../../services/isar_service.dart';
import 'upload_source.dart';

class _ExtractedContent {
  const _ExtractedContent({required this.text, this.title});

  final String text;
  final String? title;
}

/// Runs the full pipeline for one [UploadSource]: extract -> summarize (AI)
/// -> persist. Kept UI-agnostic so it can be driven from a headless test
/// today and a real Upload screen in Phase 6.
class SummaryPipeline {
  const SummaryPipeline({required this.isarService, required this.aiService});

  final IsarService isarService;
  final GeminiSummarizerService aiService;

  Future<SummaryRecord> run(UploadSource source) async {
    final extracted = await _extract(source);

    final generated = await aiService.summarizeDocument(
      content: extracted.text,
      docType: source.docType.name,
    );

    final record = SummaryRecord()
      ..title = extracted.title ?? source.suggestedTitle
      ..sourcePathOrUrl = _sourcePathOrUrl(source)
      ..docType = source.docType
      ..executiveSummary = generated.executiveSummary
      ..sections = generated.sections
          .map(
            (s) => SectionSummary()
              ..sectionTitle = s.sectionTitle
              ..summaryText = s.summaryText
              ..keyPoints = s.keyPoints,
          )
          .toList()
      ..createdAt = DateTime.now()
      ..estimatedReadTimeMinutes = _estimateReadTimeMinutes(extracted.text);

    final id = await isarService.saveSummary(record);
    return (await isarService.getSummaryById(id))!;
  }

  String _sourcePathOrUrl(UploadSource source) {
    if (source is FileUploadSource) return source.filePath;
    if (source is UrlUploadSource) return source.url;
    throw StateError('Unknown UploadSource type: ${source.runtimeType}');
  }

  Future<_ExtractedContent> _extract(UploadSource source) async {
    if (source is FileUploadSource) {
      switch (source.docType) {
        case DocumentType.pdf:
          final result = await PdfExtractorService.extractFromFile(source.filePath);
          return _ExtractedContent(text: result.toSourceText());
        case DocumentType.docx:
          final text = await DocxExtractorService.extractFromFile(source.filePath);
          return _ExtractedContent(text: text);
        case DocumentType.excel:
          final text = await ExcelExtractorService.extractFromFile(source.filePath);
          return _ExtractedContent(text: text);
        case DocumentType.webArticle:
          throw StateError('FileUploadSource cannot have docType webArticle');
      }
    }
    if (source is UrlUploadSource) {
      final result = await WebExtractorService.extractFromUrl(source.url);
      return _ExtractedContent(text: result.markdown, title: result.title);
    }
    throw StateError('Unknown UploadSource type: ${source.runtimeType}');
  }

  int _estimateReadTimeMinutes(String text) {
    const wordsPerMinute = 200;
    final trimmed = text.trim();
    final wordCount = trimmed.isEmpty ? 0 : trimmed.split(RegExp(r'\s+')).length;
    final minutes = (wordCount / wordsPerMinute).ceil();
    return minutes < 1 ? 1 : minutes;
  }
}
