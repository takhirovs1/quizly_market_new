import 'package:octopus/octopus.dart';
import 'package:ui/ui.dart';

import '../../../common/extension/context_extension.dart';
import '../../../common/router/pages.dart';
import '../screen/my_tests_screen.dart';

abstract class MyTestsScreenState extends State<MyTestsScreen> {
  void onBuyTestPressed() => context.octopus.push(Routes.purchaseTest);
  Future<void> onRefresh() async {
    context.telegramWebApp.hapticFeedback.impactOccurred(.light);
  }

  void onShareTestPressed() {
    context.telegramWebApp.hapticFeedback.impactOccurred(.light);
  }
}
