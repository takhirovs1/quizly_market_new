import 'package:flutter/material.dart';
import 'package:octopus/octopus.dart';

import '../../../common/router/pages.dart';
import '../screen/new_upload_screen.dart';

abstract class NewUploadState extends State<NewUploadScreen> {
  void onUploadAsFile() {
    context.octopus.push(Routes.fileUpload);
  }

  void onCreateTestManually() {
    // Create test manually action
  }

  void onCreateAiTest() {
    // AI Test action
  }
}
