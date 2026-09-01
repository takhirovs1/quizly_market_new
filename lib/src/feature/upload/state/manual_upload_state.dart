import 'package:flutter/material.dart';
import 'package:octopus/octopus.dart';

import '../../../common/extension/context_extension.dart';
import '../../../common/router/pages.dart';
import '../screen/manual_upload_screen.dart';

abstract class ManualUploadState extends State<ManualUploadScreen> {
  final universityController = TextEditingController();
  final testNameController = TextEditingController();
  final descriptionController = TextEditingController();

  final universityFocus = FocusNode();
  final testNameFocus = FocusNode();
  final descriptionFocus = FocusNode();

  bool showAuthorship = true;
  bool exitFullScreen = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (context.isTelegramSupported && exitFullScreen) {
        context.exitFullscreen();
      }
    });
  }

  @override
  void dispose() {
    universityController.dispose();
    testNameController.dispose();
    descriptionController.dispose();

    universityFocus.dispose();
    testNameFocus.dispose();
    descriptionFocus.dispose();
    super.dispose();
  }

  void onToggleAuthorship(bool value) {
    setState(() => showAuthorship = value);
  }

  void onToggleExitFullScreen(bool value) {
    setState(() => exitFullScreen = value);
    if (value) {
      context.exitFullscreen();
    } else {
      context.requestFullscreen();
    }
  }

  void onSubmitProceed() {
    final university = universityController.text.trim();
    final testName = testNameController.text.trim();
    final description = descriptionController.text.trim();

    if (university.isEmpty) {
      universityFocus.requestFocus();
      return;
    }

    if (testName.isEmpty) {
      testNameFocus.requestFocus();
      return;
    }

    context.octopus.push(
      Routes.uploadConfirm,
      arguments: {'testName': testName, 'university': university, 'description': description},
    );
  }
}
