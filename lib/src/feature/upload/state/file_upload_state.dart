import 'dart:io' as io;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:octopus/octopus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../common/router/pages.dart';
import '../screen/file_upload_screen.dart';

abstract class FileUploadState extends State<FileUploadScreen> {
  final universityController = TextEditingController();
  final testNameController = TextEditingController();
  final descriptionController = TextEditingController();
  final priceController = TextEditingController();

  final universityFocus = FocusNode();
  final testNameFocus = FocusNode();
  final descriptionFocus = FocusNode();
  final priceFocus = FocusNode();

  String? uploadedFileName;
  List<String> fileIssues = [];
  bool showAuthorship = true;
  bool isUploading = false;

  @override
  void dispose() {
    universityController.dispose();
    testNameController.dispose();
    descriptionController.dispose();
    priceController.dispose();

    universityFocus.dispose();
    testNameFocus.dispose();
    descriptionFocus.dispose();
    priceFocus.dispose();
    super.dispose();
  }

  Future<void> onDownloadExampleFile() async {
    try {
      final byteData = await rootBundle.load('packages/ui/lib/file/test_upload_example.xlsx');
      final bytes = byteData.buffer.asUint8List();

      final tempDir = await getTemporaryDirectory();
      final filePath = '${tempDir.path}/test_upload_example.xlsx';
      final file = io.File(filePath);
      await file.writeAsBytes(bytes, flush: true);

      // ignore: deprecated_member_use
      await Share.shareXFiles([
        XFile(
          filePath,
          mimeType: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
          name: 'test_upload_example.xlsx',
        ),
      ], text: 'test_upload_example.xlsx');
    } on Object catch (e) {
      debugPrint('onDownloadExampleFile error: $e');
    }
  }

  Future<void> onAttachFile() async {
    try {
      FilePickerResult? result;
      try {
        result = await FilePicker.pickFiles(
          type: .custom,
          allowedExtensions: ['xlsx', 'xls', 'csv', 'pdf', 'docx', 'doc'],
        );
      } on Object catch (_) {
        result = await FilePicker.pickFiles(type: .any);
      }

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        setState(() {
          uploadedFileName = file.name;
          fileIssues = [
            '25-savol: To\'g\'ri javob yo\'q.',
            '28-savol: Javoblar yozilmagan.',
          ];
        });
      }
    } on Object catch (_) {
      // Handle file pick error
    }
  }

  void onRemoveUploadedFile() {
    setState(() {
      uploadedFileName = null;
      fileIssues = [];
    });
  }

  void onToggleAuthorship(bool value) {
    setState(() => showAuthorship = value);
  }

  void onReportError() {
    context.octopus.push(Routes.supportChat);
  }

  Future<void> onSubmitUpload() async {
    if (isUploading) return;
    setState(() => isUploading = true);
    await Future<void>.delayed(const Duration(milliseconds: 1200));
    if (mounted) {
      setState(() => isUploading = false);
      context.octopus.pop();
    }
  }
}

class UZSFormatter extends TextInputFormatter {
  final f = NumberFormat('#,###', 'uz');

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return TextEditingValue.empty;

    final text = "${f.format(int.parse(digits)).replaceAll(',', ' ')} so'm";

    return TextEditingValue(
      text: text,
      selection: .collapsed(offset: text.length - 5),
    );
  }
}
