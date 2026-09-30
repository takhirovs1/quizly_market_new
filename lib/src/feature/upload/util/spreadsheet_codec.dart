import 'dart:convert';

import 'package:archive/archive.dart';
import 'package:csv/csv.dart';
import 'package:xml/xml.dart';

/// One decoded worksheet: a name and a dense rectangular grid of cell strings.
class SheetData {
  const SheetData({required this.name, required this.rows});

  final String name;

  /// Row-major cell values; every row is padded to the same column count.
  final List<List<String>> rows;

  int get rowCount => rows.length;
  int get columnCount => rows.isEmpty ? 0 : rows.first.length;
  bool get isEmpty => rows.isEmpty || columnCount == 0;
}

/// Thrown when the picked file cannot be decoded as xlsx or csv.
class SpreadsheetDecodeException implements Exception {
  const SpreadsheetDecodeException(this.message);

  final String message;

  @override
  String toString() => 'SpreadsheetDecodeException: $message';
}

/// Client-side spreadsheet decoding for the import mapping wizard
/// (docs/upload_backend_integration.md §2 — files are parsed locally and the
/// backend template importer is never called).
///
/// xlsx is decoded directly (zip + XML) on top of `archive`/`xml`, because the
/// pub xlsx packages pin `archive ^3` which conflicts with the app's `lottie`.
abstract final class SpreadsheetCodec {
  /// Decodes [bytes] by file extension. Returns non-empty sheets.
  static List<SheetData> decode(List<int> bytes, String fileName) {
    final lower = fileName.toLowerCase();
    if (lower.endsWith('.csv') || lower.endsWith('.txt')) return _decodeCsv(bytes, fileName);
    if (lower.endsWith('.xlsx') || lower.endsWith('.xlsm')) return _decodeXlsx(bytes);
    // Unknown extension: sniff — zip magic means xlsx, otherwise try csv.
    if (bytes.length > 4 && bytes[0] == 0x50 && bytes[1] == 0x4B) return _decodeXlsx(bytes);
    return _decodeCsv(bytes, fileName);
  }

  // ─── CSV ──────────────────────────────────────────────────────────────────

  static List<SheetData> _decodeCsv(List<int> bytes, String fileName) {
    var text = utf8.decode(bytes, allowMalformed: true);
    if (text.startsWith('﻿')) text = text.substring(1); // strip BOM

    List<List<String>> parse(String delimiter) {
      final rows = CsvToListConverter(
        fieldDelimiter: delimiter,
        shouldParseNumbers: false,
        eol: '\n',
        allowInvalid: true,
      ).convert(text.replaceAll('\r\n', '\n').replaceAll('\r', '\n'));
      return [
        for (final row in rows) [for (final cell in row) cell.toString().trim()],
      ];
    }

    // Delimiter heuristic: prefer the one yielding more columns.
    var rows = parse(',');
    final semicolon = parse(';');
    int width(List<List<String>> r) => r.isEmpty ? 0 : r.map((e) => e.length).reduce((a, b) => a > b ? a : b);
    if (width(semicolon) > width(rows)) rows = semicolon;
    final tab = parse('\t');
    if (width(tab) > width(rows)) rows = tab;

    final normalized = _normalize(rows);
    if (normalized.isEmpty) throw const SpreadsheetDecodeException('empty csv');
    return [SheetData(name: fileName, rows: normalized)];
  }

  // ─── XLSX ─────────────────────────────────────────────────────────────────

  static List<SheetData> _decodeXlsx(List<int> bytes) {
    final Archive archive;
    try {
      archive = ZipDecoder().decodeBytes(bytes);
    } on Object {
      throw const SpreadsheetDecodeException('not a valid xlsx (zip) file');
    }

    String? readEntry(String name) {
      for (final file in archive) {
        if (file.name == name && file.isFile) return utf8.decode(file.content as List<int>, allowMalformed: true);
      }
      return null;
    }

    final workbookXml = readEntry('xl/workbook.xml');
    if (workbookXml == null) throw const SpreadsheetDecodeException('xl/workbook.xml missing');

    // Relationship id → worksheet path.
    final relsXml = readEntry('xl/_rels/workbook.xml.rels') ?? '';
    final relTargets = <String, String>{};
    if (relsXml.isNotEmpty) {
      for (final rel in XmlDocument.parse(relsXml).findAllElements('Relationship')) {
        final id = rel.getAttribute('Id');
        var target = rel.getAttribute('Target') ?? '';
        if (id == null || target.isEmpty) continue;
        if (target.startsWith('/')) target = target.substring(1);
        if (!target.startsWith('xl/')) target = 'xl/$target';
        relTargets[id] = target;
      }
    }

    final sharedStrings = _readSharedStrings(readEntry('xl/sharedStrings.xml'));

    final sheets = <SheetData>[];
    var fallbackIndex = 1;
    for (final sheet in XmlDocument.parse(workbookXml).findAllElements('sheet')) {
      final name = sheet.getAttribute('name') ?? 'Sheet$fallbackIndex';
      final relId =
          sheet.getAttribute('r:id') ??
          sheet.attributes
              .where((a) => a.name.local == 'id')
              .map((a) => a.value)
              .cast<String?>()
              .firstWhere((_) => true, orElse: () => null);
      final path = (relId != null ? relTargets[relId] : null) ?? 'xl/worksheets/sheet$fallbackIndex.xml';
      fallbackIndex++;

      final sheetXml = readEntry(path);
      if (sheetXml == null) continue;
      final rows = _normalize(_readSheetRows(sheetXml, sharedStrings));
      if (rows.isNotEmpty) sheets.add(SheetData(name: name, rows: rows));
    }

    if (sheets.isEmpty) throw const SpreadsheetDecodeException('workbook has no non-empty sheets');
    return sheets;
  }

  static List<String> _readSharedStrings(String? xml) {
    if (xml == null || xml.isEmpty) return const [];
    final strings = <String>[];
    for (final si in XmlDocument.parse(xml).findAllElements('si')) {
      // Plain <t> or rich-text runs <r><t>…</t></r> — concatenate all <t>.
      strings.add(si.findAllElements('t').map((t) => t.innerText).join());
    }
    return strings;
  }

  static List<List<String>> _readSheetRows(String sheetXml, List<String> sharedStrings) {
    final rows = <List<String>>[];
    for (final row in XmlDocument.parse(sheetXml).findAllElements('row')) {
      final rowIndex = (int.tryParse(row.getAttribute('r') ?? '') ?? rows.length + 1) - 1;
      while (rows.length <= rowIndex) {
        rows.add(<String>[]);
      }
      final cells = rows[rowIndex];
      var implicitColumn = 0;
      for (final cell in row.findElements('c')) {
        final ref = cell.getAttribute('r');
        final column = ref != null ? _columnIndexFromRef(ref) : implicitColumn;
        implicitColumn = column + 1;
        final value = _cellValue(cell, sharedStrings);
        while (cells.length <= column) {
          cells.add('');
        }
        cells[column] = value;
      }
    }
    return rows;
  }

  static String _cellValue(XmlElement cell, List<String> sharedStrings) {
    final type = cell.getAttribute('t') ?? 'n';
    switch (type) {
      case 's':
        final index = int.tryParse(cell.getElement('v')?.innerText ?? '');
        return (index != null && index >= 0 && index < sharedStrings.length) ? sharedStrings[index].trim() : '';
      case 'inlineStr':
        return cell.getElement('is')?.findAllElements('t').map((t) => t.innerText).join().trim() ?? '';
      case 'b':
        return (cell.getElement('v')?.innerText == '1') ? 'TRUE' : 'FALSE';
      default: // 'n', 'str', 'e'
        final raw = cell.getElement('v')?.innerText.trim() ?? '';
        // Render integral doubles ("3.0") as "3" so answer keys match cleanly.
        final asNum = num.tryParse(raw);
        if (asNum != null && asNum == asNum.truncateToDouble()) return asNum.toInt().toString();
        return raw;
    }
  }

  /// "BC12" → zero-based column index (54).
  static int _columnIndexFromRef(String ref) {
    var column = 0;
    for (final code in ref.codeUnits) {
      if (code >= 0x41 && code <= 0x5A) {
        column = column * 26 + (code - 0x40);
      } else if (code >= 0x61 && code <= 0x7A) {
        column = column * 26 + (code - 0x60);
      } else {
        break;
      }
    }
    return column > 0 ? column - 1 : 0;
  }

  /// Pads rows to equal width, trims fully-empty trailing rows/columns.
  static List<List<String>> _normalize(List<List<String>> rows) {
    var lastRow = -1;
    var width = 0;
    for (var i = 0; i < rows.length; i++) {
      if (rows[i].any((c) => c.isNotEmpty)) lastRow = i;
      if (rows[i].length > width) width = rows[i].length;
    }
    if (lastRow < 0 || width == 0) return const [];

    var lastColumn = -1;
    for (final row in rows.take(lastRow + 1)) {
      for (var c = 0; c < row.length; c++) {
        if (row[c].isNotEmpty && c > lastColumn) lastColumn = c;
      }
    }

    return [
      for (final row in rows.take(lastRow + 1)) [for (var c = 0; c <= lastColumn; c++) c < row.length ? row[c] : ''],
    ];
  }
}
