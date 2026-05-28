import 'package:ui/ui.dart';

import '../../../common/extension/context_extension.dart';
import '../screen/more_recommendation_screen.dart';

abstract class MoreRecommendationScreenState extends State<MoreRecommendationScreen> {
  late final TextEditingController searchController;

  void onSortPressed() {
    context.telegramWebApp.hapticFeedback.impactOccurred(.medium);
    showModalBottomSheet<void>(
      context: context,
      builder: (context) => BottomSheetView(
        backgroundColor: context.x.colors.bottomSheetSurface,
        onClose: () => Navigator.pop(context),
        isCenterTitle: false,
        title: context.x.l10n.sort,
        child: Padding(
          padding: const .symmetric(horizontal: 16, vertical: 20),
          child: Column(
            crossAxisAlignment: .stretch,
            spacing: 10,
            children: [
              for (var i = 0; i < 2; i++)
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: context.x.colors.scaffoldBackground,
                    borderRadius: const .all(.circular(16)),
                    boxShadow: [
                      BoxShadow(
                        offset: const Offset(0, 12),
                        blurRadius: 56,
                        color: context.x.colors.black.withValues(alpha: .08),
                      ),
                      BoxShadow(
                        offset: const Offset(0, 3),
                        blurRadius: 3,
                        color: context.x.colors.black.withValues(alpha: .05),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const .symmetric(horizontal: 16, vertical: 24),
                    child: Row(
                      mainAxisAlignment: .spaceBetween,
                      children: [
                        Text(context.x.l10n.recentlyAdded, style: context.x.textStyle.sfW400s14.copyWith(fontSize: 18)),
                        Assets.lib.vectors.checkCircle.svg(package: 'ui', width: 24, height: 24),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 10),
              CustomButton(
                onTap: () {},
                color: context.x.colors.primary,
                textColor: context.x.colors.white,
                title: context.x.l10n.sort,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    searchController = TextEditingController();
    context.setupTelegramBackButton();
  }

  @override
  void dispose() {
    searchController.dispose();
    context.teardownTelegramBackButton();
    super.dispose();
  }
}
