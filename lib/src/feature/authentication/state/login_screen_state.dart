import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:octopus/octopus.dart';
import 'package:ui/ui.dart';

import '../../../common/extension/context_extension.dart';
import '../../../common/router/pages.dart';
import '../../../common/service/update_service.dart';
import '../../../common/util/error_util.dart';
import '../../../common/widget/update_bottom_sheet.dart';
import '../../settings/screen/settings_scope.dart';
import '../cubit/auth_cubit.dart';
import '../screen/login_screen.dart';

abstract class LoginScreenState extends State<LoginScreen> {
  late final AuthCubit authCubit;
  late final TextEditingController pinController;
  late final FocusNode pinFocusNode;

  SocialLoginType? loadingType;
  final isLanguageSheetOpen = ValueNotifier<bool>(false);

  /// Fires after holding the title for 5s to open the dev-mode password prompt.
  Timer? _holdTimer;

  Locale get currentLocale {
    final saved = SettingsScope.settingsOf(context, listen: true).localization;
    if (saved != null) return saved;
    return Localizations.localeOf(context);
  }

  void selectLanguage(Locale locale) {
    if (_isCurrentLocale(locale)) return;
    context.x.setLocalization(locale);
  }

  bool _isCurrentLocale(Locale locale) =>
      currentLocale.languageCode == locale.languageCode && currentLocale.scriptCode == locale.scriptCode;

  String get currentLanguageLabel {
    final locale = currentLocale;
    if (locale.languageCode == 'uz') {
      if (locale.scriptCode == 'Cyrl') {
        return context.x.l10n.uzbekKril;
      }
      return context.x.l10n.uzbekLatin;
    }
    if (locale.languageCode == 'kk') return context.x.l10n.kazakh;
    if (locale.languageCode == 'kaa') return context.x.l10n.karakalpak;
    if (locale.languageCode == 'ky') return context.x.l10n.kyrgyz;
    if (locale.languageCode == 'tg') return context.x.l10n.tajik;
    if (locale.languageCode == 'ru') return context.x.l10n.russian;
    if (locale.languageCode == 'en') return context.x.l10n.english;
    return 'O\'zbekcha';
  }

  static const _uzbekLatin = Locale('uz');
  static const _uzbekCyrillic = Locale.fromSubtags(languageCode: 'uz', scriptCode: 'Cyrl');
  static const _kazakh = Locale('kk');
  static const _karakalpak = Locale('kaa');
  static const _kyrgyz = Locale('ky');
  static const _tajik = Locale('tg');
  static const _russian = Locale('ru');
  static const _english = Locale('en');

  Future<void> onLanguagePressed() async {
    final textColor = context.x.colors.text;

    final options = <({String label, Locale locale})>[
      (label: context.x.l10n.uzbekLatin, locale: _uzbekLatin),
      (label: context.x.l10n.uzbekKril, locale: _uzbekCyrillic),
      (label: context.x.l10n.kazakh, locale: _kazakh),
      (label: context.x.l10n.karakalpak, locale: _karakalpak),
      (label: context.x.l10n.kyrgyz, locale: _kyrgyz),
      (label: context.x.l10n.tajik, locale: _tajik),
      (label: context.x.l10n.russian, locale: _russian),
      (label: context.x.l10n.english, locale: _english),
    ];

    isLanguageSheetOpen.value = true;

    await showModalBottomSheet<void>(
      backgroundColor: context.x.colors.transparent,
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => CustomBottomSheet(
        maxHeightFactor: .75,
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
          for (final option in options) ...[
            SelectionPillButton(
              label: option.label,
              isSelected: _isCurrentLocale(option.locale),
              onTap: () => _onLanguageSelected(option.locale),
            ),
            const SizedBox(height: 8),
          ],
          const SizedBox(height: 4),
        ],
      ),
    );

    if (mounted) isLanguageSheetOpen.value = false;
  }

  void _onLanguageSelected(Locale locale) {
    context.telegramWebApp.hapticImpact(.light);
    selectLanguage(locale);
    context.bottomSheetPop();
  }

  @override
  void initState() {
    super.initState();
    authCubit = context.read<AuthCubit>();
    pinController = TextEditingController();
    pinFocusNode = FocusNode();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkUpdate();
    });
  }

  Future<void> _checkUpdate() async {
    final updateInfo = await UpdateService().checkUpdate();
    if (!mounted) return;
    if (updateInfo != null && (updateInfo.hasUpdate || updateInfo.isForced)) {
      showUpdateBottomSheet(context, updateInfo);
    }
  }

  Future<void> signInWithGoogle() async {
    setState(() => loadingType = .google);
    try {
      await authCubit.signInWithGoogle();
    } finally {
      if (mounted) setState(() => loadingType = null);
    }
  }

  Future<void> signInWithApple() async {
    setState(() => loadingType = .apple);
    try {
      await authCubit.signInWithApple();
    } finally {
      if (mounted) setState(() => loadingType = null);
    }
  }

  Future<void> signInWithTelegram() async {
    setState(() => loadingType = .telegram);
    try {
      await authCubit.signInWithTelegram();
      if (mounted) pinFocusNode.requestFocus();
    } finally {
      if (mounted) setState(() => loadingType = null);
    }
  }

  Future<void> verifyTelegramOtp(String code) => authCubit.verifyTelegramOtp(code);

  Future<void> cancelTelegramLogin() async {
    pinController.clear();
    await authCubit.cancelTelegramLogin();
  }

  void onAuthSuccess() => context.octopus.navigate(Routes.home.name);

  void onAuthError(String? errorMessage) => context.x.showNotification(
    message: context.x.l10n.somethingWentWrong,
    isError: true,
    top: switch (context.telegramWebApp.isSupported) {
      true => context.telegramWebApp.safeAreaInset.top.toDouble() + 56,
      false => MediaQuery.paddingOf(context).top + 56,
    },
  );

  // ── Hidden dev-mode unlock (hold the title 5s → password) ──────────────
  // Mirrors the app bar title gesture on the "Mening testlarim" screen.

  void onTitlePointerDown(PointerDownEvent event) {
    _holdTimer?.cancel();
    _holdTimer = Timer(const Duration(seconds: 5), () {
      if (!mounted) return;
      _showPasswordDialog();
    });
  }

  void onTitlePointerUp(PointerUpEvent event) {
    _holdTimer?.cancel();
    _holdTimer = null;
  }

  void onTitlePointerCancel(PointerCancelEvent event) {
    _holdTimer?.cancel();
    _holdTimer = null;
  }

  void _showPasswordDialog() {
    final passwordController = TextEditingController();
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => Dialog(
        backgroundColor: context.x.colors.dialogBackground,
        shape: const RoundedRectangleBorder(borderRadius: .all(.circular(16))),
        child: Padding(
          padding: const .all(20),
          child: Column(
            mainAxisSize: .min,
            crossAxisAlignment: .stretch,
            children: [
              Text(
                'Password',
                textAlign: .center,
                style: context.x.textStyle.sfW700s28.copyWith(fontSize: 20, color: context.x.colors.dialogText),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: passwordController,
                obscureText: true,
                autofocus: true,
                keyboardType: .number,
                cursorColor: context.x.colors.primary,
                style: context.x.textStyle.sfW500s16.copyWith(color: context.x.colors.dialogText),
                decoration: InputDecoration(
                  hintText: 'Enter password',
                  hintStyle: context.x.textStyle.sfW400s16.copyWith(color: context.x.colors.bannerSecondaryText),
                  filled: true,
                  fillColor: context.x.colors.textFieldBackground,
                  contentPadding: const .symmetric(horizontal: 16, vertical: 14),
                  border: const OutlineInputBorder(borderRadius: .all(.circular(12)), borderSide: .none),
                  enabledBorder: const OutlineInputBorder(borderRadius: .all(.circular(12)), borderSide: .none),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: const .all(.circular(12)),
                    borderSide: BorderSide(color: context.x.colors.primary, width: 1.5),
                  ),
                ),
                onSubmitted: (_) => _submitPassword(dialogContext, passwordController.text),
              ),
              const SizedBox(height: 20),
              Row(
                spacing: 12,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        shadowColor: context.x.colors.transparent,
                        surfaceTintColor: context.x.colors.transparent,
                        backgroundColor: context.x.colors.dialogCancelButton,
                        shape: const RoundedRectangleBorder(borderRadius: .all(.circular(10))),
                        padding: const .symmetric(vertical: 14),
                      ),
                      onPressed: () => Navigator.of(dialogContext).pop(),
                      child: Text(
                        context.x.l10n.cancel,
                        style: context.x.textStyle.sfW600s16.copyWith(color: context.x.colors.bannerPriceText),
                      ),
                    ),
                  ),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        shadowColor: context.x.colors.transparent,
                        surfaceTintColor: context.x.colors.transparent,
                        backgroundColor: context.x.colors.primary,
                        shape: const RoundedRectangleBorder(borderRadius: .all(.circular(10))),
                        padding: const .symmetric(vertical: 14),
                      ),
                      onPressed: () => _submitPassword(dialogContext, passwordController.text),
                      child: Text('OK', style: context.x.textStyle.sfW600s16.copyWith(color: context.x.colors.white)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submitPassword(BuildContext dialogContext, String rawPassword) {
    final password = rawPassword.trim();
    Navigator.of(dialogContext).pop();
    if (password == '0510') {
      context.x.dependencies.appDebugSettings.value = context.x.dependencies.appDebugSettings.value.copyWith(
        debuggerEnabled: true,
        thunderEnabled: true,
      );
    } else {
      context.x.dependencies.appDebugSettings.value = context.x.dependencies.appDebugSettings.value.copyWith(
        debuggerEnabled: false,
        thunderEnabled: false,
      );
      ErrorUtil.showSnackBar(context, 'Xato parol!');
    }
  }

  @override
  void dispose() {
    _holdTimer?.cancel();
    isLanguageSheetOpen.dispose();
    pinController.dispose();
    pinFocusNode.dispose();
    authCubit.close();
    super.dispose();
  }
}
