import 'package:flutter/material.dart';
import 'package:octopus/octopus.dart';
import 'package:share_plus/share_plus.dart';

import '../../../common/extension/context_extension.dart';
import '../../../common/router/pages.dart';
import '../bloc/my_uploaded_tests_cubit.dart';
import '../model/uploaded_test_model.dart';
import '../screen/my_uploaded_tests_screen.dart';

abstract class MyUploadedTestsState extends State<MyUploadedTestsScreen> {
  late final MyUploadedTestsCubit cubit;

  @override
  void initState() {
    super.initState();
    cubit = MyUploadedTestsCubit(uploadRepository: context.x.dependencies.repository.uploadRepository)..fetchTests();
  }

  @override
  void dispose() {
    cubit.close();
    super.dispose();
  }

  Future<void> onRefresh() => cubit.refresh();

  void onEdit(UploadedTestModel test) {
    context.octopus.push(
      Routes.createTestQuestions,
      arguments: {'testId': test.id, 'testName': test.title, 'university': test.category, 'description': test.subtitle},
    );
  }

  void onPublish(UploadedTestModel test) {
    context.octopus.push(
      Routes.uploadConfirm,
      arguments: {
        'testId': test.id,
        'testName': test.title,
        'university': test.category,
        'description': test.subtitle,
        'questionCount': test.questionCount.toString(),
        if (test.price != null) 'price': test.price.toString(),
      },
    );
  }

  void onShare(UploadedTestModel test) {
    final code = test.code;
    if (code != null && code.isNotEmpty) {
      SharePlus.instance.share(ShareParams(text: 'https://quizly.uz/tests/code/$code', subject: test.title));
    } else {
      SharePlus.instance.share(ShareParams(text: test.title));
    }
  }

  void onEnterTest(UploadedTestModel test) {
    context.octopus.push(Routes.testMode, arguments: {'testId': test.id});
  }
}
