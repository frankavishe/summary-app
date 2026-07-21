import '../../../models/summary_record.dart';

/// Where a summarization pipeline run pulls its content from: either a local
/// file (PDF/DOCX/XLSX) or a web article URL. The [DocumentType] is derived
/// automatically from the source.
abstract class UploadSource {
  const UploadSource();

  DocumentType get docType;

  /// A human-readable label used as the initial [SummaryRecord.title] unless
  /// a better title is available (e.g. a web page's `<title>`).
  String get suggestedTitle;
}

class FileUploadSource extends UploadSource {
  FileUploadSource(this.filePath) : docType = _docTypeForPath(filePath);

  final String filePath;

  @override
  final DocumentType docType;

  @override
  String get suggestedTitle {
    final fileName = filePath.split(RegExp(r'[\\/]')).last;
    final dotIndex = fileName.lastIndexOf('.');
    return dotIndex > 0 ? fileName.substring(0, dotIndex) : fileName;
  }

  static DocumentType _docTypeForPath(String filePath) {
    final dotIndex = filePath.lastIndexOf('.');
    final ext = dotIndex >= 0 ? filePath.substring(dotIndex + 1).toLowerCase() : '';
    switch (ext) {
      case 'pdf':
        return DocumentType.pdf;
      case 'docx':
        return DocumentType.docx;
      case 'xlsx':
        return DocumentType.excel;
      default:
        throw ArgumentError.value(filePath, 'filePath', 'Unsupported file extension: .$ext');
    }
  }
}

class UrlUploadSource extends UploadSource {
  const UrlUploadSource(this.url);

  final String url;

  @override
  DocumentType get docType => DocumentType.webArticle;

  @override
  String get suggestedTitle => url;
}
