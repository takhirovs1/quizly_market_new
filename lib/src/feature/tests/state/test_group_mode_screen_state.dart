import 'package:flutter/material.dart';

import '../../../common/extension/context_extension.dart';
import '../../my_tests/models/test_mode.dart';
import '../screens/test_group_mode_screen.dart';

abstract class TestGroupModeScreenState extends State<TestGroupModeScreen> {
  final TestModel test = TestModel(
    id: 1,
    name: 'O’zbekistonning eng yangi tarixi fanidan testlar',
    createdBy: 123123,
    description: 'Example test description, Example test description, Example test description',
    price: 20000,
  );

  void onPressLike() {}
  void onPressShare() {
    context.shareTest(
      'Example test',
      'QuizlyMarket',
      'Example test description, Example test description, Example test description',
      '100000',
      '100',
    );
  }

  @override
  void initState() {
    super.initState();
    context.setupTelegramBackButton();
  }

  @override
  void dispose() {
    context.teardownTelegramBackButton();
    super.dispose();
  }
}
