import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:octopus/octopus.dart';
import 'package:ui/ui.dart';
import '../../../common/constant/constant.dart';
import '../../../common/extension/context_extension.dart';
import '../../../common/router/pages.dart';
import '../../settings/screen/settings_scope.dart';
import '../bloc/profile_cubit.dart';
import '../screen/profile_screen.dart';

abstract class ProfileScreenState extends State<ProfileScreen> {
  late final ProfileCubit profileCubit;
  String formatProfileName(String? apiName) {
    final raw = (apiName ?? '').trim();
    if (raw.isEmpty) return '';

    final parts = raw.split(RegExp(r'\s+')).where((e) => e.trim().isNotEmpty).toList();
    if (parts.isEmpty) return '';

    final firstTwo = parts.take(2).map(_titleCaseWord).toList();
    return firstTwo.join(' ');
  }

  String _titleCaseWord(String word) {
    final w = word.trim();
    if (w.isEmpty) return '';
    final lower = w.toLowerCase();
    return '${lower[0].toUpperCase()}${lower.substring(1)}';
  }

  Future<void> onRefresh() async {
    context.telegramWebApp.hapticFeedback.impactOccurred(.heavy);
  }

  Locale get currentLocale => SettingsScope.settingsOf(context, listen: true).localization ?? const Locale('en');

  void selectLanguage(Locale locale) {
    if (locale.languageCode == currentLocale.languageCode) return;
    context.x.setLocalization(locale);
  }

  String themeLabel(ThemeMode mode) => switch (mode) {
    .system => 'System',
    .dark => 'Dark',
    .light => 'Light',
  };

  ThemeMode get currentThemeMode => SettingsScope.settingsOf(context, listen: true).themeMode;

  void onCopyCardNumber(String cardNumber) {
    Clipboard.setData(ClipboardData(text: cardNumber));
    context.telegramWebApp.hapticFeedback.impactOccurred(.light);
    context.x.showNotification(message: 'Card number copied to clipboard');
  }

  void selectThemeMode(ThemeMode mode) {
    final current = currentThemeMode;
    if (mode == current) return;

    final settingsValue = SettingsScope.settingsOf(context, listen: false);
    SettingsScope.of(context, listen: false).add(.updateSettings(settings: settingsValue.copyWith(themeMode: mode)));
  }

  void onWalletCardPressed() {}

  void onAppInfoPressed() => context.octopus.push(Routes.appInfo);

  void onSubscriptionCardPressed() {}

  void onMyInformationPressed() {}

  void onMyCardsPressed() {}

  void onPaymentHistoryPressed() => context.octopus.push(Routes.paymentHistory);

  void onPromoCodesPressed() {}

  void onTransferHistoryPressed() {}

  Future<void> onLanguagePressed() async {
    final selected = currentLocale.languageCode;
    final textColor = context.x.colors.text;

    await showModalBottomSheet<void>(
      backgroundColor: context.x.colors.transparent,
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => CustomBottomSheet(
        maxHeightFactor: .45,
        isScrollable: true,
        title: Row(
          children: [
            Expanded(
              child: Text(context.x.l10n.appLanguage, style: context.x.textStyle.sfW700s18.copyWith(color: textColor)),
            ),
            IconButton(
              onPressed: () => context.bottomSheetPop(),
              icon: Icon(Icons.close_rounded, color: textColor),
            ),
          ],
        ),
        children: [
          SelectionPillButton(
            label: context.x.l10n.uzbekLatin,
            isSelected: currentLocale.languageCode == 'uz',
            onTap: () => _onLanguageSelected(const Locale('uz')),
          ),
          const SizedBox(height: 8),
          SelectionPillButton(
            label: context.x.l10n.uzbekKril,
            isSelected: currentLocale.languageCode == 'kk',
            onTap: () => _onLanguageSelected(const Locale('kk')),
          ),
          const SizedBox(height: 8),
          SelectionPillButton(
            label: context.x.l10n.english,
            isSelected: selected == 'en',
            onTap: () => _onLanguageSelected(const Locale('en')),
          ),
          const SizedBox(height: 8),
          SelectionPillButton(
            label: context.x.l10n.russian,
            isSelected: selected == 'ru',
            onTap: () => _onLanguageSelected(const Locale('ru')),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Future<void> onThemePressed() async {
    final selected = currentThemeMode;
    final textColor = context.x.colors.text;

    await showModalBottomSheet<void>(
      backgroundColor: context.x.colors.transparent,
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => CustomBottomSheet(
        maxHeightFactor: .3,
        isScrollable: true,
        title: Row(
          children: [
            Expanded(
              child: Text(context.x.l10n.appTheme, style: context.x.textStyle.sfW700s18.copyWith(color: textColor)),
            ),
            IconButton(
              onPressed: () => context.bottomSheetPop(),
              icon: Icon(Icons.close_rounded, color: textColor),
            ),
          ],
        ),
        children: [
          SelectionPillButton(
            label: context.x.l10n.dark,
            isSelected: selected == .dark,
            onTap: () => onThemeModePressed(.dark),
          ),
          const SizedBox(height: 8),
          SelectionPillButton(
            label: context.x.l10n.light,
            isSelected: selected == .light,
            onTap: () => onThemeModePressed(.light),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  void onThemeModePressed(ThemeMode mode) {
    context.telegramWebApp.hapticFeedback.impactOccurred(.light);
    selectThemeMode(mode);
    context.bottomSheetPop();
  }

  void _onLanguageSelected(Locale locale) {
    context.telegramWebApp.hapticFeedback.impactOccurred(.light);
    selectLanguage(locale);
    context.bottomSheetPop();
  }

  void onHelpPressed() {}

  void onFrequentlyAskedQuestionsPressed() {}

  void onDocumentsPressed() {}

  void onAboutTheAppPressed() {}

  void onTopUpBalancePressed() => context.octopus.push(Routes.payment);

  void onReferralPressed() => context.octopus.push(Routes.referral);

  void onArchivedTestsPressed() {}
  void onTeacherPressed() {}
  void onGoogleConnectPressed() {}
  void onAppleConnectPressed() {}
  void onTelegramConnectPressed() {}

  void onSetHomePressed() {
    context.telegramWebApp.hapticFeedback.impactOccurred(.light);
    context.telegramWebApp.addToHomeScreen();
  }

  void onTermsPressed() {}

  List<ProfileListRow> get menuRows => [
    ProfileListRow.header((c) => context.x.l10n.home),
    ProfileListRow.item(
      (c) => context.x.l10n.topUpBalance,
      onTopUpBalancePressed,
      Assets.lib.vectors.topUpBalance.svg(package: Constant.packageUi),
    ),
    ProfileListRow.item(
      (c) => context.x.l10n.referral,
      onReferralPressed,
      Assets.lib.vectors.referral.svg(package: Constant.packageUi),
    ),
    ProfileListRow.item(
      (c) => context.x.l10n.paymentHistory,
      onPaymentHistoryPressed,
      Assets.lib.vectors.historyTransaction.svg(package: Constant.packageUi),
    ),
    ProfileListRow.item(
      (c) => context.x.l10n.archivedTests,
      onArchivedTestsPressed,
      Assets.lib.vectors.documents.svg(package: Constant.packageUi),
    ),
    ProfileListRow.item(
      (c) => context.x.l10n.teacher,
      onTeacherPressed,
      Assets.lib.vectors.teacherSwap.svg(package: Constant.packageUi),
    ),
    ProfileListRow.spacer(16),
    ProfileListRow.header((c) => context.x.l10n.integrations),
    ProfileListRow.item(
      (c) => context.x.l10n.googleConnect,
      onGoogleConnectPressed,
      Assets.lib.vectors.google.svg(package: Constant.packageUi),
    ),
    ProfileListRow.item(
      (c) => context.x.l10n.appleIdConnect,
      onAppleConnectPressed,
      Assets.lib.vectors.apple.svg(package: Constant.packageUi),
    ),
    ProfileListRow.item(
      (c) => context.x.l10n.telegramConnect,
      onTelegramConnectPressed,
      Assets.lib.images.telegramLogo.image(package: Constant.packageUi, width: 20, height: 20),
    ),
    ProfileListRow.spacer(16),
    ProfileListRow.header((c) => context.x.l10n.appearance),
    ProfileListRow.item(
      (c) => context.x.l10n.language,
      onLanguagePressed,
      Assets.lib.vectors.language.svg(package: Constant.packageUi),
    ),
    ProfileListRow.item(
      (c) => context.x.l10n.theme,
      onThemePressed,
      Assets.lib.vectors.themeIcon.svg(package: Constant.packageUi),
    ),
    if (context.telegramWebApp.isSupported)
      ProfileListRow.item(
        (c) => context.x.l10n.installOnHomeScreen,
        onSetHomePressed,
        Assets.lib.vectors.setHome.svg(package: Constant.packageUi),
      ),
    ProfileListRow.spacer(16),
    ProfileListRow.header((c) => context.x.l10n.other),
    ProfileListRow.item(
      (c) => context.x.l10n.help,
      onHelpPressed,
      Assets.lib.vectors.support.svg(package: Constant.packageUi),
    ),
    ProfileListRow.item(
      (c) => context.x.l10n.termsOfUse,
      onTermsPressed,
      Assets.lib.vectors.documents.svg(package: Constant.packageUi),
    ),
    ProfileListRow.item(
      (c) => context.x.l10n.app_info,
      onAppInfoPressed,
      Assets.lib.vectors.informationApp.svg(package: Constant.packageUi),
    ),
    ProfileListRow.item(
      (c) => context.x.l10n.logout,
      onLogoutPressed,
      Assets.lib.vectors.logout.svg(package: Constant.packageUi),
      isLogout: true,
    ),
  ];

  // Actions
  Future<void> onLogoutPressed() async {}

  Future<void> onLogoutAccountPressed() async {}

  // Header sizing
  double expandedHeaderHeight(BuildContext context) {
    var height = (MediaQuery.sizeOf(context).height * 0.26).clamp(150.0, 200.0);
    if (context.telegramWebApp.isSupported) {
      height += context.telegramWebApp.safeAreaInset.top;
    }
    return height;
  }

  double collapsedHeaderHeight(BuildContext context) {
    if (context.telegramWebApp.isSupported) {
      return context.telegramWebApp.safeAreaInset.top + kToolbarHeight;
    }
    return MediaQuery.paddingOf(context).top + kToolbarHeight;
  }

  // 0 -> expanded, 1 -> collapsed
  double collapseT(BuildContext context, BoxConstraints constraints) {
    final expandedHeight = expandedHeaderHeight(context);
    final collapsedHeight = collapsedHeaderHeight(context);
    final currentHeight = constraints.maxHeight;
    return 1.0 - ((currentHeight - collapsedHeight) / (expandedHeight - collapsedHeight)).clamp(0.0, 1.0);
  }

  // Opacity curves (Telegram-like)
  double headerOpacity(double t) => (1.0 - Curves.easeOut.transform((t * 1.2).clamp(0.0, 1.0))).clamp(0.0, 1.0);

  double titleOpacity(double t) => Curves.easeIn.transform(((t - 0.6) / 0.4).clamp(0.0, 1.0));

  // Responsive sizing
  double avatarMax(double width) => (width * 0.24).clamp(72.0, 110.0);
  double avatarMin(double width) => (width * 0.12).clamp(44.0, 64.0);
  double avatarSize(double width, double t) {
    final max = avatarMax(width);
    final min = avatarMin(width);
    return (max - (max - min) * t).clamp(min, max);
  }

  double nameSizeExpanded(double width) => (width * 0.07).clamp(20.0, 28.0);
  double nameSizeCollapsed(double width) => (width * 0.048).clamp(16.0, 20.0);
  double phoneSize(double width) => (width * 0.038).clamp(12.0, 15.0);

  double nameHorizontalPadding(double width) => (width * 0.08).clamp(16.0, 28.0);
  double phoneHorizontalPadding(double width) => (width * 0.10).clamp(16.0, 32.0);
  double collapsedTitleHorizontalPadding(double width) => (width * 0.12).clamp(20.0, 40.0);

  double headerNameSpacing(double expandedHeight) => (expandedHeight * 0.045).clamp(6.0, 12.0);

  ({double t, double headerAlpha, double titleAlpha, double width, double expandedHeight, double avatar}) headerLayout(
    BuildContext context,
    BoxConstraints constraints,
  ) {
    final t = collapseT(context, constraints);
    final headerAlpha = headerOpacity(t);
    final titleAlpha = titleOpacity(t);
    final width = MediaQuery.sizeOf(context).width;
    final expandedHeight = expandedHeaderHeight(context);
    final avatar = avatarSize(width, t);
    return (
      t: t,
      headerAlpha: headerAlpha,
      titleAlpha: titleAlpha,
      width: width,
      expandedHeight: expandedHeight,
      avatar: avatar,
    );
  }

  EdgeInsets menuSliverPadding(BuildContext context) {
    // Keep the last button visible above bottom navigation bar / home indicator.
    final bottom = MediaQuery.paddingOf(context).bottom;
    // NOTE: We don't have direct access to the app's bottom-nav height here,
    // so we use a conservative extra padding that still keeps the logout visible.
    return EdgeInsets.fromLTRB(16, 0, 16, bottom);
  }

  @override
  void initState() {
    profileCubit = context.read<ProfileCubit>()..loadProfile();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }
}

typedef ProfileTitleBuilder = String Function(BuildContext context);

class ProfileListRow {
  factory ProfileListRow.item(
    ProfileTitleBuilder titleBuilder,
    VoidCallback onTap,
    Widget? leading, {
    bool isLogout = false,
  }) => ProfileListRow._(.item, titleBuilder: titleBuilder, onTap: onTap, leading: leading, isLogout: isLogout);

  factory ProfileListRow.spacer(double height) => ProfileListRow._(.spacer, spacerHeight: height);

  factory ProfileListRow.header(ProfileTitleBuilder titleBuilder) =>
      ProfileListRow._(.header, titleBuilder: titleBuilder);
  const ProfileListRow._(
    this.type, {
    this.titleBuilder,
    this.spacerHeight,
    this.onTap,
    this.leading,
    this.isLogout = false,
  });

  final ProfileListRowType type;
  final ProfileTitleBuilder? titleBuilder;
  final double? spacerHeight;
  final VoidCallback? onTap;
  final Widget? leading;
  final bool isLogout;
}

enum ProfileListRowType { header, item, spacer }
