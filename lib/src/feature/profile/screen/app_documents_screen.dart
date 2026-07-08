import 'package:flutter/cupertino.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:ui/ui.dart';

import '../../../common/extension/context_extension.dart';
import '../state/app_documents_state.dart';

class AppDocumentsScreen extends StatefulWidget {
  const AppDocumentsScreen({super.key});

  @override
  State<AppDocumentsScreen> createState() => _AppDocumentsScreenState();
}

class _AppDocumentsScreenState extends AppDocumentsState {
  @override
  Widget build(BuildContext context) {
    final isMobile = context.x.isMobile || context.x.isTablet;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: context.x.colors.scaffoldBackground,
        appBar: QuizAppBar(
          title: context.x.l10n.documents,
          telegramWebAppSafeAreaInsetTop: context.telegramWebApp.safeAreaInset.top.toDouble(),
        ),
        body: isMobile
            ? Column(children: _buildContent(context, isMobile: true))
            : Center(
                child: Padding(
                  padding: const .symmetric(vertical: 24, horizontal: 16),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 800),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: context.x.colors.cardBackground2,
                        borderRadius: .circular(20),
                        border: Border.all(color: context.x.colors.divider),
                      ),
                      child: Column(children: _buildContent(context, isMobile: false)),
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  List<Widget> _buildContent(BuildContext context, {required bool isMobile}) => [
    Padding(
      padding: const .all(16),
      child: DecoratedBox(
        decoration: BoxDecoration(color: context.x.colors.bannerBackground, borderRadius: .circular(10)),
        child: SizedBox(
          height: 45,
          child: TabBar(
            padding: const .all(4),
            indicatorSize: .tab,
            splashFactory: NoSplash.splashFactory,
            dividerColor: context.x.colors.transparent,
            isScrollable: false,
            physics: const NeverScrollableScrollPhysics(),
            labelPadding: EdgeInsets.zero,
            indicatorPadding: EdgeInsets.zero,
            overlayColor: WidgetStatePropertyAll(context.x.colors.transparent),
            indicator: BoxDecoration(
              color: context.x.colors.white,
              borderRadius: .circular(8),
              boxShadow: [
                BoxShadow(
                  color: context.x.colors.black.withValues(alpha: .06),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            labelColor: context.x.colors.black,
            labelStyle: context.x.textStyle.sfW600s16,
            unselectedLabelStyle: context.x.textStyle.sfW400s16,
            tabs: [
              Tab(text: context.x.l10n.termsOfUse),
              Tab(text: context.x.l10n.privacyPolicy),
            ],
          ),
        ),
      ),
    ),
    Expanded(
      child: TabBarView(
        physics: const NeverScrollableScrollPhysics(),
        children: [
          _buildTabContent(
            isLoading: isLoadingTerms,
            error: termsError,
            data: termsOfUseMarkdown,
            onRetry: loadDocuments,
            isMobile: isMobile,
            context: context,
          ),
          _buildTabContent(
            isLoading: isLoadingPrivacy,
            error: privacyError,
            data: privacyPolicyMarkdown,
            onRetry: loadDocuments,
            isMobile: isMobile,
            context: context,
          ),
        ],
      ),
    ),
  ];

  Widget _buildTabContent({
    required bool isLoading,
    required String? error,
    required String data,
    required VoidCallback onRetry,
    required bool isMobile,
    required BuildContext context,
  }) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator.adaptive());
    }
    if (error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              EmptyTestWidget(title: context.x.l10n.errorOccurred, description: context.x.l10n.somethingWentWrong),
              // const SizedBox(height: 16),
              // CupertinoButton(
              //   color: context.x.colors.primary,
              //   padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              //   borderRadius: BorderRadius.circular(10),
              //   onPressed: onRetry,
              //   child: Text(
              //     context.x.l10n.retry,
              //     style: context.x.textStyle.sfW600s16.copyWith(color: context.x.colors.white),
              //   ),
              // ),
            ],
          ),
        ),
      );
    }
    return Padding(
      padding: EdgeInsets.only(bottom: isMobile ? context.telegramWebApp.safeAreaInset.bottom.toDouble() : 0),
      child: MarkdownTab(data: data, styleSheet: markdownStyle(context)),
    );
  }
}

class MarkdownTab extends StatelessWidget {
  const MarkdownTab({required this.data, required this.styleSheet, super.key});

  final String data;
  final MarkdownStyleSheet styleSheet;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: const EdgeInsets.all(16),
    child: MarkdownBody(data: data, selectable: true, styleSheet: styleSheet),
  );
}
