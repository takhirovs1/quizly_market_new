import 'package:ui/ui.dart';

import '../../../common/extension/context_extension.dart';
import '../screen/app_info_screen.dart';

abstract class AppInfoState extends State<AppInfoScreen> {
  @override
  void initState() {
    super.initState();
    context.setupTelegramBackButton();
  }

  @override
  void dispose() {
    super.dispose();
    context.teardownTelegramBackButton();
  }
}
