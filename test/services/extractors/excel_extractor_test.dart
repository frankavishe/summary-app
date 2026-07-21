import 'dart:typed_data';

import 'package:excel/excel.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:summaread/services/extractors/excel_extractor.dart';

void main() {
  test('extractFromBytes converts a worksheet into a Markdown table, skipping empty rows', () async {
    final workbook = Excel.createExcel();
    final defaultSheetName = workbook.getDefaultSheet()!;
    workbook.rename(defaultSheetName, 'Q3 Sales Data');
    final sheet = workbook['Q3 Sales Data'];

    sheet.appendRow([TextCellValue('Region'), TextCellValue('Revenue')]);
    // A fully empty row that must be skipped entirely.
    sheet.appendRow([null, null]);
    sheet.appendRow([TextCellValue('East'), IntCellValue(1000)]);
    sheet.appendRow([TextCellValue('West'), IntCellValue(2000)]);

    final bytes = Uint8List.fromList(workbook.encode()!);

    final markdown = await ExcelExtractorService.extractFromBytes(bytes);

    expect(markdown, contains('## Sheet: Q3 Sales Data'));
    expect(markdown, contains('| Region | Revenue |'));
    expect(markdown, contains('| --- | --- |'));
    expect(markdown, contains('| East | 1000 |'));
    expect(markdown, contains('| West | 2000 |'));
    // The blank row must not produce an empty `|  |` line.
    expect(markdown, isNot(contains('|  |')));
  });

  test('extractFromBytes skips sheets with no rows', () async {
    final workbook = Excel.createExcel();
    final defaultSheetName = workbook.getDefaultSheet()!;
    workbook.rename(defaultSheetName, 'Empty Sheet');

    final bytes = Uint8List.fromList(workbook.encode()!);
    final markdown = await ExcelExtractorService.extractFromBytes(bytes);

    expect(markdown, isNot(contains('## Sheet: Empty Sheet')));
  });
}
