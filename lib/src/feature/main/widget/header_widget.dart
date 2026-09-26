import 'package:ui/ui.dart';

import '../../../common/extension/context_extension.dart';

class HeaderWidget extends StatelessWidget {
  const HeaderWidget({
    required this.title,
    required this.subtitle,
    this.onTitlePointerDown,
    this.onTitlePointerUp,
    this.onTitlePointerCancel,
    super.key,
  });

  final String title;
  final String subtitle;

  /// Hold gestures on the title — used to unlock the hidden dev/debug mode
  /// (same pattern as the app bar title on the "Mening testlarim" screen).
  final void Function(PointerDownEvent event)? onTitlePointerDown;
  final void Function(PointerUpEvent event)? onTitlePointerUp;
  final void Function(PointerCancelEvent event)? onTitlePointerCancel;

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
      Listener(
        onPointerDown: onTitlePointerDown,
        onPointerUp: onTitlePointerUp,
        onPointerCancel: onTitlePointerCancel,
        behavior: .opaque,
        child: Text(
          title,
          style: context.x.textStyle.sfW700s28.copyWith(color: context.x.colors.black),
          textAlign: .center,
        ),
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
