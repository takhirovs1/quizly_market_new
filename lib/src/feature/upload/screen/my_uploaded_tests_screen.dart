import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ui/ui.dart';

import '../../../common/extension/context_extension.dart';
import '../../../common/extension/number_extension.dart';
import '../bloc/my_uploaded_tests_cubit.dart';
import '../state/my_uploaded_tests_state.dart';

class MyUploadedTestsScreen extends StatefulWidget {
  const MyUploadedTestsScreen({super.key});

  @override
  State<MyUploadedTestsScreen> createState() => _MyUploadedTestsScreenState();
}

class _MyUploadedTestsScreenState extends MyUploadedTestsState {
  @override
  Widget build(BuildContext context) {
    final l10n = context.x.l10n;

    return BlocBuilder<MyUploadedTestsCubit, MyUploadedTestsCubitState>(
      bloc: cubit,
      builder: (context, state) => RefreshIndicator.adaptive(
        onRefresh: onRefresh,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            if (state.status.isLoading && state.tests.isEmpty)
              SliverPadding(
                padding: const .symmetric(horizontal: 16, vertical: 8),
                sliver: SliverList.separated(
                  itemCount: 4,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (_, _) => const TestCardShimmer(),
                ),
              )
            else if (state.tests.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Padding(
                  padding: const .all(16),
                  child: EmptyTestWidget(
                    title: l10n.youDontHaveAnyTestsYet,
                    description: l10n.thereAreTestsOnaVarietyOfTopicsAvailableOnTheMarket,
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const .symmetric(horizontal: 16, vertical: 8),
                sliver: SliverList.separated(
                  itemCount: state.tests.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final test = state.tests[index];
                    return TestCardWidget(
                      title: test.title,
                      companyName: test.category,
                      description: test.subtitle,
                      price: test.price != null ? test.price!.formatUzs : '',
                      questionAmount: l10n.questionAmountText(test.questionCount),
                      showPrice: test.isPublished && test.price != null,
                      secondaryButtonText: test.isPublished ? l10n.shareAction : l10n.editAction,
                      onSecondaryButtonPressed: () => test.isPublished ? onShare(test) : onEdit(test),
                      buyButtonText: test.isPublished ? l10n.enterTest : l10n.publish,
                      onBuyButtonPressed: () => test.isPublished ? onEnterTest(test) : onPublish(test),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
