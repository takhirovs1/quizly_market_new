import 'dart:async';

import 'package:flutter/material.dart';

import '../model/uploaded_test_model.dart';
import '../screen/my_uploaded_tests_screen.dart';

abstract class MyUploadedTestsState extends State<MyUploadedTestsScreen> {
  bool isLoading = true;
  List<UploadedTestModel> tests = [];

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    setState(() => isLoading = true);
    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (mounted) {
      setState(() {
        tests = .of(UploadedTestModel.mockList);
        isLoading = false;
      });
    }
  }

  Future<void> onRefresh() async {
    await Future<void>.delayed(const Duration(milliseconds: 700));
    if (mounted) {
      setState(() {
        tests = .of(UploadedTestModel.mockList);
      });
    }
  }

  void onEdit(UploadedTestModel test) {
    // Edit draft action
  }

  void onPublish(UploadedTestModel test) {
    // Publish draft action
  }

  void onShare(UploadedTestModel test) {
    // Share test action
  }

  void onEnterTest(UploadedTestModel test) {
    // Enter test action
  }
}
