import 'package:isar/isar.dart';

part 'summary_record.g.dart';

enum DocumentType { pdf, docx, excel, webArticle }

@collection
class SummaryRecord {
  Id id = Isar.autoIncrement;

  late String title;
  late String sourcePathOrUrl;

  @enumerated
  late DocumentType docType;

  late String executiveSummary;

  /// Section or Chapter breakdowns (or Sheet-by-Sheet analysis for Excel).
  List<SectionSummary>? sections;

  late DateTime createdAt;
  bool isFavorite = false;
  int estimatedReadTimeMinutes = 0;
}

@embedded
class SectionSummary {
  String? sectionTitle; // e.g. "Chapter 1" or "Sheet: Q3 Sales Data"
  String? summaryText;
  List<String>? keyPoints;
}
