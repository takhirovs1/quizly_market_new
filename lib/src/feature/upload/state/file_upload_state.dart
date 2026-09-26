import 'dart:io' as io;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:octopus/octopus.dart';

import '../../../common/extension/context_extension.dart';
import '../../../common/router/pages.dart';
import '../bloc/import_mapping_cubit.dart';
import '../bloc/upload_pricing_cubit.dart';
import '../model/import_mapping_models.dart';
import '../screen/file_upload_screen.dart';

/// File-import flow: meta form → pick ANY xlsx/csv → client-side column
/// mapping wizard → review/edit. The backend template importer is never
/// called — the mapped questions go through the same `POST /api/tests` path
/// as the manual builder (docs/upload_backend_integration.md §2).
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

  /// 0 = meta form + file pick, 1 = column mapping wizard.
  int step = 0;

  late final ImportMappingCubit mappingCubit;
  late final UploadPricingCubit pricingCubit;

  @override
  void initState() {
    super.initState();
    context.setupTelegramBackButton(onTelegramBack);
    final repo = context.x.dependencies.repository.uploadRepository;
    mappingCubit = ImportMappingCubit();
    pricingCubit = UploadPricingCubit(uploadRepository: repo)..fetchPricing();

    universityController.addListener(_onMetaChanged);
    testNameController.addListener(_onMetaChanged);
  }

  @override
  void dispose() {
    context.teardownTelegramBackButton(onTelegramBack);
    universityController.dispose();
    testNameController.dispose();
    descriptionController.dispose();
    priceController.dispose();

    universityFocus.dispose();
    testNameFocus.dispose();
    descriptionFocus.dispose();
    priceFocus.dispose();

    mappingCubit.close();
    pricingCubit.close();
    super.dispose();
  }

  void _onMetaChanged() => setState(() {});

  // ─── Guards ────────────────────────────────────────────────────────────────

  bool get isMetaValid => universityController.text.trim().isNotEmpty && testNameController.text.trim().isNotEmpty;

  int? get priceSum {
    final raw = priceController.text.replaceAll(RegExp(r'\D'), '');
    return int.tryParse(raw);
  }

  // ─── Navigation ────────────────────────────────────────────────────────────

  void onTelegramBack() {
    if (step == 1) {
      onBackFromMapping();
    } else if (mounted) {
      context.octopus.pop();
    }
  }

  /// Hardware/system back: step 2 returns to the meta step instead of popping.
  bool get canPopScreen => step == 0;

  void onBackFromMapping() {
    mappingCubit.reset();
    setState(() => step = 0);
  }

  void goToMappingStep() {
    if (!mounted) return;
    setState(() => step = 1);
  }

  // ─── File picking / parsing ────────────────────────────────────────────────

  Future<void> onAttachFile() async {
    if (!isMetaValid) return;
    context.telegramWebApp.hapticImpact(.light);
    try {
      FilePickerResult? result;
      try {
        result = await FilePicker.pickFiles(type: .custom, allowedExtensions: ['xlsx', 'xlsm', 'csv'], withData: true);
      } on Object catch (_) {
        result = await FilePicker.pickFiles(type: .any, withData: true);
      }

      if (result == null || result.files.isEmpty) return;
      final pickedFile = result.files.first;
      List<int>? bytes = pickedFile.bytes;
      if (bytes == null && pickedFile.path != null) {
        bytes = await io.File(pickedFile.path!).readAsBytes();
      }
      if (bytes == null) return;

      await mappingCubit.parseFile(bytes: bytes, fileName: pickedFile.name);
      // The screen's BlocListener flips to the mapping step on parse success.
    } on Object catch (e) {
      debugPrint('onAttachFile error: $e');
    }
  }

  // ─── Meta actions ──────────────────────────────────────────────────────────

  void onToggleAuthorship(bool value) {
    context.telegramWebApp.hapticImpact(.soft);
    setState(() => showAuthorship = value);
  }

  void onReportError() => context.octopus.push(Routes.supportChat);

  // ─── Confirm mapping → review/edit ─────────────────────────────────────────

  void onConfirmMapping() {
    final mappingState = mappingCubit.state;
    if (!mappingState.canConfirm || !isMetaValid) return;
    context.telegramWebApp.hapticImpact(.medium);

    ImportHandoff.put([for (final draft in mappingState.drafts) draft.toQuestionModel()]);

    final price = priceSum;
    context.octopus.push(
      Routes.createTestQuestions,
      arguments: {
        'testName': testNameController.text.trim(),
        'university': universityController.text.trim(),
        if (descriptionController.text.trim().isNotEmpty) 'description': descriptionController.text.trim(),
        if (price != null && price > 0) 'price': price.toString(),
      },
    );
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
