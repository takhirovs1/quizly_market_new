import 'package:ui/ui.dart';
import '../../../common/extension/context_extension.dart';
import '../screen/profile_screen.dart';

abstract class ProfileScreenState extends State<ProfileScreen> {
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

  Future<void> onRefresh() async {}

  // String _languageLabel(LanguageEnum languageCode) => switch (languageCode) {
  //   // .ru => context.x.l10n.languageRu,
  //   // .en => context.x.l10n.languageEn,
  //   // .uz => context.x.l10n.languageUz,
  // };

  // String get currentLanguageLabel =>
  //     _languageLabel(.values.firstWhere((e) => e.name == context.localSource.localization.languageCode));

  void selectLanguage(Locale locale) {
    // final current = context.localSource.localization.languageCode;
    // if (current == locale.languageCode) {
    //   context.x.p();
    //   return;
    // }
    // context
    //   ..setLocale(locale)
    //   ..bottomSheetPop();

    // profileBloc.add(SelectLanguageEvent(appLanguage: locale.languageCode));
  }

  String themeLabel(ThemeMode mode) => switch (mode) {
    .system => 'System',
    .dark => 'Dark',
    .light => 'Light',
  };

  ThemeMode get currentThemeMode => context.x.dependencies.localSource.theme;

  // void _selectThemeMode(ThemeMode mode) => context
  //   ..setThemeMode(mode)
  //   ..bottomSheetPop();

  void onWalletCardPressed() {}

  void onSubscriptionCardPressed() {}

  void onMyInformationPressed() {}

  void onMyCardsPressed() {}

  void onPaymentHistoryPressed() {}

  void onPromoCodesPressed() {}

  void onTransferHistoryPressed() {}

  Future<void> onLanguagePressed() async {
    // final selected = context.x.dependencies.localSource.localization.languageCode;
    // await showModalBottomSheet<void>(
    //   backgroundColor: context.x.colors.transparent,
    //   context: context,
    //   builder: (context) => CustomBottomSheet(
    //     initialChildSize: .7,
    //     maxChildSize: .7,
    //     isScrollable: false,
    //     header: Row(
    //       mainAxisAlignment: .spaceBetween,
    //       children: [
    //         Text(
    //           context.l10n.selectLanguage,
    //           style: context.textTheme.rfdW600s18.copyWith(color: context.color.buttonWhite),
    //         ),
    //         IconButton(
    //           style: IconButton.styleFrom(padding: Dimension.pZero),
    //           onPressed: context.bottomSheetPop,
    //           icon: Icon(Icons.close, color: context.color.buttonWhite),
    //         ),
    //       ],
    //     ),
    //     children: [
    //       Padding(
    //         padding: Dimension.pV16,
    //         child: Column(
    //           spacing: 8,
    //           children: LanguageEnum.values
    //               .map(
    //                 (e) => LanguageButton(
    //                   label: _languageLabel(e),
    //                   isSelected: selected == e.name,
    //                   onPressed: () => _selectLanguage(Locale(e.name)),
    //                 ),
    //               )
    //               .toList(),
    //         ),
    //       ),
    //     ],
    //   ),
    // );
  }

  Future<void> onThemePressed() async {
    // final selected = currentThemeMode;
    // await showModalBottomSheet<void>(
    //   backgroundColor: context.color.transparent,
    //   context: context,
    //   builder: (context) => CustomBottomSheet(
    //     initialChildSize: .7,
    //     maxChildSize: .7,
    //     isScrollable: false,
    //     header: Row(
    //       mainAxisAlignment: .spaceBetween,
    //       children: [
    //         Text(
    //           context.l10n.selectTheme,
    //           style: context.textTheme.rfdW600s18.copyWith(color: context.color.buttonWhite),
    //         ),
    //         IconButton(
    //           style: IconButton.styleFrom(padding: Dimension.pZero),
    //           onPressed: context.bottomSheetPop,
    //           icon: Icon(Icons.close, color: context.color.buttonWhite),
    //         ),
    //       ],
    //     ),
    //     children: [
    //       Padding(
    //         padding: Dimension.pV16,
    //         child: Column(
    //           spacing: 8,
    //           children: ThemeModeEnum.values
    //               .map(
    //                 (e) => LanguageButton(
    //                   label: _themeLabel(.values.firstWhere((element) => element.name == e.name)),
    //                   isSelected: selected == .values.firstWhere((element) => element.name == e.name),
    //                   onPressed: () => _selectThemeMode(.values.firstWhere((element) => element.name == e.name)),
    //                 ),
    //               )
    //               .toList(),
    //         ),
    //       ),
    //     ],
    //   ),
    // );
  }

  void onHelpPressed() {}

  void onFrequentlyAskedQuestionsPressed() {}

  void onDocumentsPressed() {}

  void onAboutTheAppPressed() {}

  void onTopUpBalancePressed() {}
  void onReferralPressed() {}
  void onArchivedTestsPressed() {}
  void onTeacherPressed() {}
  void onGoogleConnectPressed() {}
  void onAppleConnectPressed() {}
  void onTelegramConnectPressed() {}
  void onSetHomePressed() {}
  void onTermsPressed() {}

  List<ProfileListRow> get menuRows => [
    ProfileListRow.header((c) => 'Asosiy'),
    ProfileListRow.item(
      (c) => "Balansni to'ldirish",
      onTopUpBalancePressed,
      Assets.lib.vectors.topUpBalance.svg(package: 'ui'),
    ),
    ProfileListRow.item((c) => 'Referral', onReferralPressed, Assets.lib.vectors.referral.svg(package: 'ui')),
    ProfileListRow.item(
      (c) => "To'lovlar tarixi",
      onPaymentHistoryPressed,
      Assets.lib.vectors.historyTransaction.svg(package: 'ui'),
    ),
    ProfileListRow.item(
      (c) => "Arxivlangan testlar",
      onArchivedTestsPressed,
      Assets.lib.vectors.documents.svg(package: 'ui'),
    ),
    ProfileListRow.item((c) => 'Teacher', onTeacherPressed, Assets.lib.vectors.teacherSwap.svg(package: 'ui')),
    ProfileListRow.spacer(16),
    ProfileListRow.header((c) => "Integratsiyalar"),
    ProfileListRow.item((c) => 'Google ulash', onGoogleConnectPressed, Assets.lib.vectors.google.svg(package: 'ui')),
    ProfileListRow.item((c) => 'Apple ID ulash', onAppleConnectPressed, Assets.lib.vectors.apple.svg(package: 'ui')),
    ProfileListRow.item(
      (c) => 'Telegram ulash',
      onTelegramConnectPressed,
      Assets.lib.images.telegramLogo.image(package: 'ui', width: 20, height: 20),
    ),
    ProfileListRow.spacer(16),
    ProfileListRow.header((c) => "Ko'rinish"),
    ProfileListRow.item((c) => 'Til', onLanguagePressed, Assets.lib.vectors.language.svg(package: 'ui')),
    ProfileListRow.item((c) => 'Mavzu', onThemePressed, Assets.lib.vectors.themeIcon.svg(package: 'ui')),
    ProfileListRow.item(
      (c) => "Asosiy ekranga o'rnatish",
      onSetHomePressed,
      Assets.lib.vectors.setHome.svg(package: 'ui'),
    ),
    ProfileListRow.spacer(16),
    ProfileListRow.header((c) => 'Boshqa'),
    ProfileListRow.item((c) => 'Yordam', onHelpPressed, Assets.lib.vectors.support.svg(package: 'ui')),
    ProfileListRow.item(
      (c) => "Foydalanish shartlari",
      onTermsPressed,
      Assets.lib.vectors.documents.svg(package: 'ui'),
    ),
    ProfileListRow.item(
      (c) => 'Chiqish',
      onLogoutPressed,
      Assets.lib.vectors.logout.svg(package: 'ui'),
      isLogout: true,
    ),
    ProfileListRow.spacer(16),
  ];

  // Actions
  Future<void> onLogoutPressed() async {}

  Future<void> onLogoutAccountPressed() async {}

  // Header sizing
  // Slightly taller to fit the status badge on small devices.
  double expandedHeaderHeight(BuildContext context) => (MediaQuery.sizeOf(context).height * 0.32).clamp(220.0, 320.0);

  double collapsedHeaderHeight(BuildContext context) => MediaQuery.paddingOf(context).top + kToolbarHeight;

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
    return EdgeInsets.fromLTRB(16, 0, 16, bottom + 32);
  }

  @override
  void initState() {
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
