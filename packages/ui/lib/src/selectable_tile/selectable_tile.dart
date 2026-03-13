import '../../ui.dart';
import '../check_box/check_box.dart';

//
/// {@template selectable_tile}
/// SelectableTile widget.
/// {@endtemplate}
class SelectableTile extends StatelessWidget {
  const SelectableTile({required this.title, this.onTap, this.subtitle, this.isActive = false, super.key});

  /// {@macro selectable_tile}
  final String title;
  final String? subtitle;
  final bool isActive;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: DecoratedBox(
      decoration: BoxDecoration(color: ThemeColors.light.white, borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsetsGeometry.symmetric(horizontal: 24, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText.w400s18(title),
                if (subtitle != null) AppText.w400s14(subtitle!, color: ThemeColors.of(context).gray),
              ],
            ),
            const Spacer(),
            if (isActive) const CheckBox(),
          ],
        ),
      ),
    ),
  );
}
