import 'package:ui/ui.dart';

import '../../../common/extension/context_extension.dart';

class SectionHeaderWidget extends StatelessWidget {
  const SectionHeaderWidget({required this.title, required this.onTap, super.key});

  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: .spaceBetween,
    children: [
      Text(title, style: context.x.textStyle.sfW700s16.copyWith(fontSize: 22)),
      GestureDetector(
        onTap: () {
          context.telegramWebApp.hapticImpact(.light);
          onTap();
        },
        child: Padding(
          padding: const .all(4),
          child: Assets.lib.vectors.chevronRight.svg(package: 'ui', width: 24, height: 24),
        ),
      ),
    ],
  );
}
