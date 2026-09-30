import 'package:octopus/octopus.dart';
import 'package:ui/ui.dart';

import '../../../common/extension/context_extension.dart';
import '../../../common/router/pages.dart';
import '../../../common/util/error_util.dart';
import '../bloc/my_uploaded_tests_cubit.dart';
import '../model/uploaded_test_model.dart';
import '../screen/my_uploaded_tests_screen.dart';

abstract class MyUploadedTestsState extends State<MyUploadedTestsScreen> {
  late final MyUploadedTestsCubit cubit;

  @override
  void initState() {
    super.initState();
    cubit = MyUploadedTestsCubit(uploadRepository: context.x.dependencies.repository.uploadRepository)..fetchTests();
  }

  @override
  void dispose() {
    cubit.close();
    super.dispose();
  }

  Future<void> onRefresh() => cubit.refresh();

  void onEdit(UploadedTestModel test) {
    context.telegramWebApp.hapticImpact(.light);
    context.octopus.push(
      Routes.createTestQuestions,
      arguments: {'testId': test.id, 'testName': test.title, 'university': test.category, 'description': test.subtitle},
    );
  }

  void onPublish(UploadedTestModel test) {
    context.telegramWebApp.hapticImpact(.light);
    context.octopus.push(
      Routes.uploadConfirm,
      arguments: {
        'testId': test.id,
        'testName': test.title,
        'university': test.category,
        'description': test.subtitle,
        'questionCount': test.questionCount.toString(),
        if (test.price != null) 'price': test.price.toString(),
      },
    );
  }

  void onShare(UploadedTestModel test) {
    context.telegramWebApp.hapticImpact(.light);
    context.shareTest(
      test.title,
      test.category,
      test.subtitle,
      test.price?.toString() ?? '0',
      test.questionCount.toString(),
      code: test.code,
    );
  }

  void onEnterTest(UploadedTestModel test) {
    context.telegramWebApp.hapticImpact(.light);
    context.octopus.push(Routes.testMode, arguments: {'id': test.id});
  }

  /// Deletes a draft after confirming with the user (docs §5 — soft delete).
  Future<void> onDelete(UploadedTestModel test) async {
    context.telegramWebApp.hapticImpact(.medium);
    final screenContext = context;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => Dialog(
        backgroundColor: dialogContext.x.colors.transparent,
        child: Center(
          child: LogoutDialog(
            title: dialogContext.x.l10n.deleteTestTitle,
            description: dialogContext.x.l10n.deleteTestDescription,
            cancelButtonText: dialogContext.x.l10n.cancel,
            successButtonText: dialogContext.x.l10n.delete,
            onCancelButtonPressed: () {
              screenContext.telegramWebApp.hapticImpact(.light);
              dialogContext.bottomSheetPop();
            },
            onSuccessButtonPressed: () async {
              dialogContext.bottomSheetPop();
              screenContext.telegramWebApp.hapticImpact(.heavy);
              try {
                await cubit.deleteTest(test.id);
              } on Object catch (e) {
                if (!screenContext.mounted) return;
                screenContext.x.showNotification(
                  message: ErrorUtil.localizeError(screenContext, ErrorUtil.toUserFriendlyMessage(e)),
                  isError: true,
                );
              }
            },
          ),
        ),
      ),
    );
  }
}
