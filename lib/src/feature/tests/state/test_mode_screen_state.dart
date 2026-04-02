import 'package:ui/ui.dart';

import '../../my_tests/models/test_mode.dart';
import '../screens/test_mode_screen.dart';

abstract class TestModeScreenState extends State<TestModeScreen> {
  final TestModel test = TestModel(id: 1, name: 'Test 1', description: 'Description 1', price: 10000, createdBy: 1);
  void onPressLike() {}
  void onPressShare() {}
}
