import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ui/ui.dart';

import '../../../common/extension/context_extension.dart';
import '../../../common/util/error_util.dart';
import '../../../common/util/state_status.dart';
import '../../my_tests/models/test_model.dart';
import '../bloc/profile_cubit.dart';
import '../state/archive_screen_state.dart';

class ArchiveScreen extends StatefulWidget {
  const ArchiveScreen({super.key});

  @override
  State<ArchiveScreen> createState() => _ArchiveScreenState();
}

class _ArchiveScreenState extends ArchiveScreenState {
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: context.x.colors.scaffoldBackground,
    appBar: QuizAppBar(
      title: context.x.l10n.archivedTests,
      telegramWebAppSafeAreaInsetTop: context.telegramWebApp.safeAreaInset.top.toDouble(),
    ),
    body: BlocConsumer<ProfileCubit, ProfileState>(
      listener: (context, state) {
        if (state.archiveStatus == StateStatus.error && state.archiveTests.isNotEmpty) {
          ErrorUtil.showSnackBar(context, state.archiveErrorMessage ?? context.x.l10n.somethingWentWrong);
        }
      },
      builder: (context, state) {
        if (state.archiveStatus == StateStatus.loading || state.archiveStatus == StateStatus.idle) {
          return const _ArchiveShimmer();
        }

        if (state.archiveStatus == StateStatus.error && state.archiveTests.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: .min,
                children: [
                  EmptyTestWidget(
                    title: context.x.l10n.somethingWentWrong,
                    description: state.archiveErrorMessage ?? context.x.l10n.somethingWentWrong,
                  ),
                  const SizedBox(height: 16),
                  FilledButton(onPressed: profileCubit.loadArchiveTests, child: Text(context.x.l10n.retry)),
                ],
              ),
            ),
          );
        }

        if (state.archiveTests.isEmpty) {
          return Center(
            child: EmptyTestWidget(title: context.x.l10n.archivedTests, description: context.x.l10n.noTestsFound),
          );
        }

        return RefreshIndicator.adaptive(
          onRefresh: profileCubit.loadArchiveTests,
          child: ListView.separated(
            controller: scrollController,
            padding: EdgeInsets.only(left: 16, right: 16, top: 16, bottom: context.x.isMobile ? 24 : 80),
            itemCount: state.archiveTests.length + (state.isArchiveLoadingMore ? 1 : 0),
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              if (index >= state.archiveTests.length) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Center(child: CircularProgressIndicator.adaptive()),
                );
              }
              final test = state.archiveTests[index];
              return _ArchiveTestCard(
                test: test,
                onUnarchive: () => onUnarchive(test.id ?? ''),
                onDelete: () => onDelete(test.id ?? ''),
              );
            },
          ),
        );
      },
    ),
  );
}

class _ArchiveTestCard extends StatelessWidget {
  const _ArchiveTestCard({required this.test, required this.onUnarchive, required this.onDelete});

  final TestModel test;
  final VoidCallback onUnarchive;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: context.x.colors.bannerBackground,
      borderRadius: const BorderRadius.all(Radius.circular(16)),
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: .stretch,
        children: [
          Row(
            mainAxisAlignment: .spaceBetween,
            crossAxisAlignment: .start,
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  test.name ?? '',
                  style: context.x.textStyle.sfW400s18.copyWith(
                    color: context.x.colors.bannerText,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: .ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    test.categoryName ?? '',
                    style: context.x.textStyle.sfW500s16.copyWith(color: context.x.colors.bannerSecondaryText),
                    maxLines: 2,
                    overflow: .ellipsis,
                    textAlign: .right,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          if ((test.description ?? '').isNotEmpty) ...[
            Text(
              test.description!,
              style: context.x.textStyle.sfW400s14.copyWith(color: context.x.colors.bannerSecondaryText),
              maxLines: 2,
              overflow: .ellipsis,
            ),
            const SizedBox(height: 2),
          ],
          Row(
            children: [
              Assets.lib.images.memo.image(width: 16, height: 16, package: 'ui'),
              const SizedBox(width: 4),
              Text(
                context.x.l10n.questionAmountText(test.questionCount ?? 0),
                style: context.x.textStyle.sfW400s14.copyWith(color: context.x.colors.bannerSecondaryText),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: .end,
            children: [
              OutlinedButton(
                onPressed: onDelete,
                style: OutlinedButton.styleFrom(
                  shape: const StadiumBorder(),
                  side: BorderSide(color: context.x.colors.divider),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                child: Text(
                  'Delete',
                  style: context.x.textStyle.sfW500s16.copyWith(fontSize: 15, color: context.x.colors.text),
                ),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: onUnarchive,
                style: FilledButton.styleFrom(
                  backgroundColor: context.x.colors.bannerPriceText,
                  shape: const StadiumBorder(),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                child: Text(
                  'Unarchive',
                  style: context.x.textStyle.sfW500s16.copyWith(fontSize: 15, color: context.x.colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

class _ArchiveShimmer extends StatelessWidget {
  const _ArchiveShimmer();

  @override
  Widget build(BuildContext context) => ListView.separated(
    padding: const .all(16),
    itemCount: 6,
    separatorBuilder: (_, _) => const SizedBox(height: 10),
    itemBuilder: (_, _) => const TestCardShimmer(),
  );
}
