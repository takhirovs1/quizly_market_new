import 'dart:convert';

import 'package:archive/archive.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quizly_market/src/feature/upload/bloc/import_mapping_cubit.dart';
import 'package:quizly_market/src/feature/upload/model/import_mapping_models.dart';
import 'package:quizly_market/src/feature/upload/util/spreadsheet_codec.dart';

/// Builds a minimal single-sheet xlsx (zip + XML) in memory.
List<int> buildXlsx(List<List<String>> rows, {String sheetName = 'Sheet1'}) {
  final shared = <String>[];
  int sharedIndex(String s) {
    final existing = shared.indexOf(s);
    if (existing >= 0) return existing;
    shared.add(s);
    return shared.length - 1;
  }

  String cellRef(int row, int column) {
    var c = column;
    var letters = '';
    do {
      letters = String.fromCharCode(0x41 + (c % 26)) + letters;
      c = c ~/ 26 - 1;
    } while (c >= 0);
    return '$letters${row + 1}';
  }

  final rowsXml = StringBuffer();
  for (var r = 0; r < rows.length; r++) {
    rowsXml.write('<row r="${r + 1}">');
    for (var c = 0; c < rows[r].length; c++) {
      final value = rows[r][c];
      if (value.isEmpty) continue;
      final asNum = num.tryParse(value);
      if (asNum != null) {
        rowsXml.write('<c r="${cellRef(r, c)}"><v>$value</v></c>');
      } else {
        rowsXml.write('<c r="${cellRef(r, c)}" t="s"><v>${sharedIndex(value)}</v></c>');
      }
    }
    rowsXml.write('</row>');
  }

  final sheetXml =
      '<?xml version="1.0"?><worksheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main">'
      '<sheetData>$rowsXml</sheetData></worksheet>';
  final sstXml =
      '<?xml version="1.0"?><sst xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main">'
      '${shared.map((s) => '<si><t>$s</t></si>').join()}</sst>';
  final workbookXml =
      '<?xml version="1.0"?><workbook xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main" '
      'xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships">'
      '<sheets><sheet name="$sheetName" sheetId="1" r:id="rId1"/></sheets></workbook>';
  final relsXml =
      '<?xml version="1.0"?><Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">'
      '<Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/worksheet" '
      'Target="worksheets/sheet1.xml"/></Relationships>';

  final archive = Archive()
    ..add(ArchiveFile.string('xl/workbook.xml', workbookXml))
    ..add(ArchiveFile.string('xl/_rels/workbook.xml.rels', relsXml))
    ..add(ArchiveFile.string('xl/sharedStrings.xml', sstXml))
    ..add(ArchiveFile.string('xl/worksheets/sheet1.xml', sheetXml));
  return ZipEncoder().encode(archive);
}

void main() {
  group('SpreadsheetCodec', () {
    test('decodes xlsx with shared strings and numbers', () {
      final bytes = buildXlsx([
        ['question', 'A', 'B', 'C', 'correct'],
        ['2+2=?', '3', '4', '5', '2'],
        ['Capital of UZ?', 'Tashkent', 'Samarkand', '', 'Tashkent'],
      ]);
      final sheets = SpreadsheetCodec.decode(bytes, 'test.xlsx');
      expect(sheets, hasLength(1));
      expect(sheets.first.rows[0], ['question', 'A', 'B', 'C', 'correct']);
      expect(sheets.first.rows[1][1], '3');
      expect(sheets.first.rows[2][1], 'Tashkent');
    });

    test('decodes csv with semicolon delimiter', () {
      final bytes = utf8.encode('savol;javob a;javob b;togri\nQ1;x;y;1\nQ2;m;n;2\n');
      final sheets = SpreadsheetCodec.decode(bytes, 'test.csv');
      expect(sheets.first.rows, hasLength(3));
      expect(sheets.first.rows[1], ['Q1', 'x', 'y', '1']);
    });
  });

  group('ImportMappingCubit', () {
    test('auto-maps template-shaped xlsx and resolves numeric index keys', () async {
      final cubit = ImportMappingCubit();
      await cubit.parseFile(
        bytes: buildXlsx([
          ['question', 'A', 'B', 'C', 'correct'],
          ['2+2=?', '3', '4', '5', '2'],
          ['1+1=?', '2', '7', '', '1'],
        ]),
        fileName: 'test.xlsx',
      );

      final state = cubit.state;
      expect(state.hasFile, isTrue);
      expect(state.headerRow, 0);
      expect(state.questionColumn, 0);
      expect(state.answerColumns, [1, 2, 3]);
      expect(state.correctColumn, 4);
      expect(state.drafts, hasLength(2));
      expect(state.drafts[0].correctFlags, [false, true, false]); // key "2" → B
      expect(state.drafts[1].options, hasLength(2)); // empty C dropped
      expect(state.drafts[1].correctFlags, [true, false]);
      expect(state.canConfirm, isTrue);
      await cubit.close();
    });

    test('resolves letter, label and text keys in auto mode', () async {
      final cubit = ImportMappingCubit();
      await cubit.parseFile(
        bytes: utf8.encode(
          'savol,javob a,javob b,togri javob\n'
          'Q1,alpha,beta,B\n'
          'Q2,gamma,delta,Variant 1\n'
          'Q3,epsilon,zeta,zeta\n',
        ),
        fileName: 'test.csv',
      );

      final drafts = cubit.state.drafts;
      expect(drafts, hasLength(3));
      expect(drafts[0].correctFlags, [false, true]); // letter B
      expect(drafts[1].correctFlags, [true, false]); // label "Variant 1"
      expect(drafts[2].correctFlags, [false, true]); // exact text
      await cubit.close();
    });

    test('fixed answer column convention marks that column correct', () async {
      final cubit = ImportMappingCubit();
      await cubit.parseFile(
        bytes: utf8.encode('savol,javob a,javob b\nQ1,right,wrong\nQ2,right2,wrong2\n'),
        fileName: 'test.csv',
      );
      // No correct column exists → configure the fixed-column convention.
      cubit
        ..setCorrectSource(CorrectSource.fixedAnswerColumn)
        ..setAlwaysCorrectColumn(1);

      final state = cubit.state;
      expect(state.drafts, hasLength(2));
      expect(state.drafts[0].correctFlags, [true, false]);
      expect(state.canConfirm, isTrue);
      await cubit.close();
    });

    test('flags invalid rows and honors skipInvalid gate', () async {
      final cubit = ImportMappingCubit();
      await cubit.parseFile(
        bytes: utf8.encode(
          'savol,javob a,javob b,togri\n'
          'Q1,x,y,1\n'
          ',x,y,1\n' // no question
          'Q3,only,,1\n' // one option
          'Q4,x,y,9\n', // unresolvable key
        ),
        fileName: 'test.csv',
      );

      final state = cubit.state;
      expect(state.drafts, hasLength(1));
      expect(state.issues.map((i) => i.kind), [
        MappingIssueKind.noQuestion,
        MappingIssueKind.tooFewOptions,
        MappingIssueKind.noCorrect,
      ]);
      expect(state.canConfirm, isTrue); // skipInvalid defaults to true

      cubit.toggleSkipInvalid(false);
      expect(cubit.state.canConfirm, isFalse);
      await cubit.close();
    });

    test('multi-correct keys like "1,3" set several flags', () async {
      final cubit = ImportMappingCubit();
      await cubit.parseFile(
        bytes: utf8.encode('savol,javob a,javob b,javob c,togri\nQ1,x,y,z,"1,3"\n'),
        fileName: 'test.csv',
      );
      expect(cubit.state.drafts.single.correctFlags, [true, false, true]);
      await cubit.close();
    });

    test('header row change re-maps data window', () async {
      final cubit = ImportMappingCubit();
      await cubit.parseFile(
        bytes: utf8.encode('junk,,,\nsavol,javob a,javob b,togri\nQ1,x,y,1\n'),
        fileName: 'test.csv',
      );
      // Auto-guess should already have found row 1 (0-based) as header.
      expect(cubit.state.headerRow, 1);
      expect(cubit.state.drafts, hasLength(1));
      await cubit.close();
    });
  });
}
