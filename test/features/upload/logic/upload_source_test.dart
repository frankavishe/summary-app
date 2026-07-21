import 'package:flutter_test/flutter_test.dart';
import 'package:summaread/features/upload/logic/upload_source.dart';
import 'package:summaread/models/summary_record.dart';

void main() {
  group('FileUploadSource', () {
    test('derives DocumentType from the file extension', () {
      expect(FileUploadSource('C:/docs/report.pdf').docType, DocumentType.pdf);
      expect(FileUploadSource('C:/docs/report.PDF').docType, DocumentType.pdf);
      expect(FileUploadSource('C:/docs/report.docx').docType, DocumentType.docx);
      expect(FileUploadSource('C:/docs/report.xlsx').docType, DocumentType.excel);
    });

    test('suggestedTitle strips the directory and extension', () {
      expect(FileUploadSource(r'C:\docs\Quarterly Report.pdf').suggestedTitle, 'Quarterly Report');
      expect(FileUploadSource('/home/user/notes.docx').suggestedTitle, 'notes');
    });

    test('throws ArgumentError for an unsupported extension', () {
      expect(() => FileUploadSource('C:/docs/report.txt'), throwsArgumentError);
    });
  });

  group('UrlUploadSource', () {
    test('always has docType webArticle and uses the url as the suggested title', () {
      const source = UrlUploadSource('https://example.com/article');
      expect(source.docType, DocumentType.webArticle);
      expect(source.suggestedTitle, 'https://example.com/article');
    });
  });
}
