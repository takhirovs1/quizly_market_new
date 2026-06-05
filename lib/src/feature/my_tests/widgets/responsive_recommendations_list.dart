import 'package:ui/ui.dart';

import '../models/test_mode.dart';
import 'my_test_card_item.dart';

class ResponsiveRecommendationsList extends StatelessWidget {
  const ResponsiveRecommendationsList({
    required this.tests,
    required this.crossAxisCount,
    required this.onBuyButtonPressed,
    required this.onShareButtonPressed,
    super.key,
  });

  final List<TestModel> tests;
  final int crossAxisCount;
  final VoidCallback onBuyButtonPressed;
  final void Function(TestModel test) onShareButtonPressed;

  @override
  Widget build(BuildContext context) {
    if (crossAxisCount == 1) {
      return Column(
        children: [
          for (final test in tests) ...[
            MyTestCardItem(
              test: test,
              onBuyButtonPressed: onBuyButtonPressed,
              onShareButtonPressed: onShareButtonPressed,
            ),
            const SizedBox(height: 10),
          ],
        ],
      );
    }

    final rows = <Widget>[];
    for (var i = 0; i < tests.length; i += crossAxisCount) {
      final rowEnd = (i + crossAxisCount).clamp(0, tests.length);
      final rowTests = tests.sublist(i, rowEnd);
      rows
        ..add(
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: .stretch,
              children: [
                for (var j = 0; j < crossAxisCount; j++) ...[
                  if (j > 0) const SizedBox(width: 10),
                  Expanded(
                    child: j < rowTests.length
                        ? MyTestCardItem(
                            test: rowTests[j],
                            onBuyButtonPressed: onBuyButtonPressed,
                            onShareButtonPressed: onShareButtonPressed,
                          )
                        : const SizedBox.shrink(),
                  ),
                ],
              ],
            ),
          ),
        )
        ..add(const SizedBox(height: 10));
    }
    return Column(children: rows);
  }
}
