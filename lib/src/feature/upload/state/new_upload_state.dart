import 'package:flutter/material.dart';

import '../screen/new_upload_screen.dart';

abstract class NewUploadState extends State<NewUploadScreen> {
  void onUploadAsFile() {
    // File upload action
  }

  void onCreateTestManually() {
    // Create test manually action
  }

  void onCreateAiTest() {
    // AI Test action
  }
}
