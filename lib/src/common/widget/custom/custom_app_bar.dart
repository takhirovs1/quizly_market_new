import 'package:ui/ui.dart';

import '../../extension/context_extension.dart';

class CustomAppBar extends StatelessWidget {
  const CustomAppBar({required this.title, this.bottom, super.key});

  final String title;
  final PreferredSizeWidget? bottom;

  @override
  Widget build(BuildContext context) => QuizAppBar(
    telegramWebAppSafeAreaInsetTop: context.telegramWebApp.safeAreaInset.top.toDouble(),
    title: title,
    bottom: bottom,
  );
}
