import '../../ui.dart';
import '../extension/context_extension.dart';

class EmptyTestWidget extends StatelessWidget {
  const EmptyTestWidget({required this.title, required this.description, super.key});

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) => ConstrainedBox(
    constraints: const BoxConstraints(maxWidth: 400, minWidth: 300),
    child: Column(
      spacing: 12,
      children: [
        switch (Theme.of(context).brightness) {
          Brightness.light => Assets.lib.vectors.emptyTestLight.svg(package: 'ui'),
          Brightness.dark => Assets.lib.vectors.emptyTestDark.svg(package: 'ui'),
        },
        Column(
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.x.textStyle.sfW700s16.copyWith(fontSize: 22, color: context.x.colors.bannerText),
            ),
            Text(
              description,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: context.x.textStyle.sfW400s16.copyWith(fontSize: 16, color: context.x.colors.bannerSecondaryText),
            ),
          ],
        ),
      ],
    ),
  );
}
