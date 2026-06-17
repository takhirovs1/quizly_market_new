import 'package:ui/ui.dart';

import '../../../common/extension/context_extension.dart';

class HeaderWidget extends StatelessWidget {
  const HeaderWidget({required this.title, required this.subtitle, super.key});

  final String title;
  final String subtitle;
  @override
  Widget build(BuildContext context) => Column(
    spacing: 4,
    children: [
      Center(
        child: DecoratedBox(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(color: context.x.colors.primary.withValues(alpha: .3), blurRadius: 35, offset: .zero),
            ],
          ),
          child: DecoratedBox(
            decoration: BoxDecoration(color: context.x.colors.primary, borderRadius: .circular(24)),
            child: Padding(
              padding: const .all(20),
              child: Assets.lib.images.logo.image(package: 'ui', width: 56, height: 56),
            ),
          ),
        ),
      ),
      Text(
        title,
        style: context.x.textStyle.sfW700s28.copyWith(color: context.x.colors.black),
        textAlign: .center,
      ),
      Text(
        subtitle,
        style: context.x.textStyle.sfW400s14.copyWith(color: context.x.colors.gray),
        maxLines: 2,
        overflow: .ellipsis,
        textAlign: .center,
      ),
    ],
  );
}
