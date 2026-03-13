import 'package:octopus/octopus.dart';
import 'package:ui/ui.dart';

import '../../../common/router/pages.dart';
import '../screen/my_tests_screen.dart';

abstract class MyTestsScreenState extends State<MyTestsScreen> {
  void onBuyTestPressed() => context.octopus.navigate(Routes.purchaseTest.name);
}
