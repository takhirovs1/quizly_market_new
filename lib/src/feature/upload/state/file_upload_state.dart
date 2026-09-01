import 'dart:io' as io;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:octopus/octopus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../common/extension/context_extension.dart';
import '../../../common/router/pages.dart';
import '../bloc/file_upload_cubit.dart';
import '../bloc/upload_pricing_cubit.dart';
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

  bool showAuthorship = true;

  late final FileUploadCubit fileUploadCubit;
  late final UploadPricingCubit pricingCubit;

  @override
  void initState() {
    super.initState();
    final repo = context.x.dependencies.repository.uploadRepository;
    fileUploadCubit = FileUploadCubit(uploadRepository: repo);
    pricingCubit = UploadPricingCubit(uploadRepository: repo)..fetchPricing();
  }

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

    fileUploadCubit.close();
    pricingCubit.close();
    super.dispose();
  }

  Future<void> onDownloadExampleFile() async {
    try {
      List<int> bytes;
      try {
        bytes = await context.x.dependencies.repository.uploadRepository.downloadTemplate();
      } on Object catch (_) {
        final byteData = await rootBundle.load('packages/ui/lib/file/test_upload_example.xlsx');
        bytes = byteData.buffer.asUint8List();
      }

      final tempDir = await getTemporaryDirectory();
      final filePath = '${tempDir.path}/quizly-test-shabloni.xlsx';
      final file = io.File(filePath);
      await file.writeAsBytes(bytes, flush: true);

      // ignore: deprecated_member_use
      await Share.shareXFiles([
        XFile(
          filePath,
          mimeType: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
          name: 'quizly-test-shabloni.xlsx',
        ),
      ], text: 'quizly-test-shabloni.xlsx');
    } on Object catch (e) {
      debugPrint('onDownloadExampleFile error: $e');
    }
  }

  Future<void> onAttachFile() async {
    try {
      FilePickerResult? result;
      try {
        result = await FilePicker.pickFiles(type: .custom, allowedExtensions: ['xlsx', 'xls'], withData: true);
      } on Object catch (_) {
        result = await FilePicker.pickFiles(type: .any, withData: true);
      }

      if (result != null && result.files.isNotEmpty) {
        final pickedFile = result.files.first;
        List<int>? bytes = pickedFile.bytes;
        if (bytes == null && pickedFile.path != null) {
          bytes = await io.File(pickedFile.path!).readAsBytes();
        }

        if (bytes != null) {
          final rawPrice = priceController.text.replaceAll(RegExp(r'\D'), '');
          final price = int.tryParse(rawPrice);

          await fileUploadCubit.validateFile(
            fileBytes: bytes,
            fileName: pickedFile.name,
            testName: testNameController.text.trim(),
            description: descriptionController.text.trim(),
            price: price,
            isFree: price == null || price == 0,
          );
        }
      }
    } on Object catch (e) {
      debugPrint('onAttachFile error: $e');
    }
  }

  void onRemoveUploadedFile() {
    fileUploadCubit.clearFile();
  }

  void onToggleAuthorship(bool value) {
    setState(() => showAuthorship = value);
  }

  void onReportError() {
    context.octopus.push(Routes.supportChat);
  }

  Future<void> onSubmitUpload() async {
    final rawPrice = priceController.text.replaceAll(RegExp(r'\D'), '');
    final price = int.tryParse(rawPrice);

    await fileUploadCubit.submitImport(
      testName: testNameController.text.trim(),
      description: descriptionController.text.trim(),
      price: price,
      isFree: price == null || price == 0,
    );

    final importResult = fileUploadCubit.state.importResult;
    if (importResult != null && mounted) {
      context.octopus.push(
        Routes.uploadConfirm,
        arguments: {
          'testId': importResult.testId,
          'testName': testNameController.text.trim(),
          'university': universityController.text.trim(),
          'description': descriptionController.text.trim(),
          'price': priceController.text.trim(),
          'questionCount': fileUploadCubit.state.questionCount.toString(),
        },
      );
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
