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
  Widget build(BuildContext context) => DefaultTabController(
    length: 2,
    child: Scaffold(
      backgroundColor: context.x.colors.scaffoldBackground,
      appBar: QuizAppBar(
        title: context.x.l10n.documents,
        telegramWebAppSafeAreaInsetTop: context.telegramWebApp.safeAreaInset.top.toDouble(),
      ),
      body: Column(
        children: [
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
                Padding(
                  padding: .only(bottom: context.telegramWebApp.safeAreaInset.bottom.toDouble()),
                  child: MarkdownTab(data: kTermsOfUseMarkdown, styleSheet: markdownStyle(context)),
                ),
                Padding(
                  padding: .only(bottom: context.telegramWebApp.safeAreaInset.bottom.toDouble()),
                  child: MarkdownTab(data: kPrivacyPolicyMarkdown, styleSheet: markdownStyle(context)),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class MarkdownTab extends StatelessWidget {
  const MarkdownTab({required this.data, required this.styleSheet, super.key});

  final String data;
  final MarkdownStyleSheet styleSheet;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: const .all(16),
    child: MarkdownBody(data: data, selectable: true, styleSheet: styleSheet),
  );
}
