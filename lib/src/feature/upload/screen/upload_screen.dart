import 'package:ui/ui.dart';

import '../../../common/extension/context_extension.dart';
import 'my_uploaded_tests_screen.dart';
import 'new_upload_screen.dart';

class UploadScreen extends StatelessWidget {
  const UploadScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.x.colors;
    final textStyle = context.x.textStyle;
    final l10n = context.x.l10n;
    final isMobile = context.x.isMobile;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: colors.scaffoldBackground,
        appBar: QuizAppBar(
          title: l10n.upload,
          telegramWebAppSafeAreaInsetTop: context.telegramWebApp.safeAreaInset.top.toDouble(),
        ),
        body: SafeArea(
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 680),
              child: Padding(
                padding: .only(bottom: isMobile ? 0 : 24),
                child: Column(
                  crossAxisAlignment: .stretch,
                  children: [
                    // Segmented Tab Switcher
                    Padding(
                      padding: .fromLTRB(isMobile ? 16 : 24, 16, isMobile ? 16 : 24, 12),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: colors.bannerBackground,
                          borderRadius: .circular(10),
                        ),
                        child: SizedBox(
                          height: 45,
                          child: TabBar(
                            padding: const .all(4),
                            indicatorSize: .tab,
                            splashFactory: NoSplash.splashFactory,
                            dividerColor: colors.transparent,
                            isScrollable: false,
                            physics: const NeverScrollableScrollPhysics(),
                            labelPadding: .zero,
                            indicatorPadding: .zero,
                            overlayColor: WidgetStatePropertyAll(colors.transparent),
                            indicator: BoxDecoration(
                              color: colors.white,
                              borderRadius: .circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: colors.black.withValues(alpha: .06),
                                  blurRadius: 10,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            labelColor: colors.black,
                            labelStyle: textStyle.sfW600s16,
                            unselectedLabelColor: colors.bannerSecondaryText,
                            unselectedLabelStyle: textStyle.sfW400s16,
                            tabs: [
                              Tab(text: l10n.uploadedMyTests),
                              Tab(text: l10n.newUpload),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // TabBar Views
                    const Expanded(
                      child: TabBarView(
                        physics: NeverScrollableScrollPhysics(),
                        children: [
                          MyUploadedTestsScreen(),
                          NewUploadScreen(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
