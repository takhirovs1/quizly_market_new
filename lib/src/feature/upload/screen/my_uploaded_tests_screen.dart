import 'package:ui/ui.dart';

import '../../../common/extension/context_extension.dart';
import '../../../common/extension/number_extension.dart';
import '../state/my_uploaded_tests_state.dart';
import '../widget/uploaded_test_shimmer.dart';

class MyUploadedTestsScreen extends StatefulWidget {
  const MyUploadedTestsScreen({super.key});

  @override
  State<MyUploadedTestsScreen> createState() => _MyUploadedTestsScreenState();
}

class _MyUploadedTestsScreenState extends MyUploadedTestsState {
  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const UploadedTestShimmer();
    }

    if (tests.isEmpty) {
      return Padding(
        padding: const .all(16),
        child: EmptyTestWidget(
          title: context.x.l10n.youDontHaveAnyTestsYet,
          description: context.x.l10n.thereAreTestsOnaVarietyOfTopicsAvailableOnTheMarket,
        ),
      );
    }

    return RefreshIndicator.adaptive(
      onRefresh: onRefresh,
      child: ListView.separated(
        padding: const .symmetric(horizontal: 16, vertical: 8),
        itemCount: tests.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final test = tests[index];
          return TestCardWidget(
            title: test.title,
            companyName: test.category,
            description: test.subtitle,
            price: test.price != null ? test.price!.formatUzs : '',
            questionAmount: context.x.l10n.questionAmountText(test.questionCount),
            showPrice: test.isPublished && test.price != null,
            secondaryButtonText: test.isPublished ? context.x.l10n.shareAction : context.x.l10n.editAction,
            onSecondaryButtonPressed: () => test.isPublished ? onShare(test) : onEdit(test),
            buyButtonText: test.isPublished ? context.x.l10n.enterTest : context.x.l10n.publish,
            onBuyButtonPressed: () => test.isPublished ? onEnterTest(test) : onPublish(test),
          );
        },
      ),
    );
  }
}
