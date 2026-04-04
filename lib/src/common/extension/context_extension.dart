import 'dart:async';
import 'dart:developer';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:localization/localization.dart';
import 'package:octopus/octopus.dart';
import 'package:telegram_web_app/telegram_web_app.dart';
import 'package:ui/ui.dart';

import '../dependency/model/dependencies.dart';
import '../dependency/widget/dependencies_scope.dart';
import '../util/screen_util.dart';

extension BuildContextX on BuildContext {
  /// [Build] extension
  Build get x => Build(this);
}

extension type Build(BuildContext context) {
  /// [ThemeData] extension
  ThemeData get theme => Theme.of(context);

  /// [ThemeColors] extension
  ThemeColors get colors => theme.appColors;

  /// [AppTypography] extension
  AppTypography get textStyle => theme.appTextStyles;

  /// [isDarkMode] extension
  bool get isDarkMode => theme.brightness == .dark;

  /// [Dependencies] extension
  Dependencies get dependencies => DependenciesScope.of(context);

  /// [Localization] extension
  AppLocalization get l10n => .of(context);

  /// [setLocalization] extension
  void setLocalization(Locale localization) => dependencies.settingsBloc.add(
    .updateSettings(settings: dependencies.settingsBloc.state.settings.copyWith(localization: localization)),
  );

  /// [kSize] extension
  Size get kSize => MediaQuery.sizeOf(context);

  /// [width] extension
  double get width => MediaQuery.sizeOf(context).width;

  /// [height] extension
  double get height => MediaQuery.sizeOf(context).height;

  /// [isMobile] extension
  bool get isMobile => ScreenUtil.screenSizeOf(context).isPhone;

  /// [isTablet] extension
  bool get isTablet => ScreenUtil.screenSizeOf(context).isTablet;

  /// [double] extension.
  double get bottomSheetHeight => (height / 4).clamp(200, 500);

  /// [double] extension.
  double get bottomViewInsets => MediaQuery.viewInsetsOf(context).bottom + MediaQuery.paddingOf(context).bottom;

  dynamic get appMetadata => null;

  /// [showCustomDialog] extension from [showGeneralDialog]
  Future<void> showCustomDialog({required Widget dialog, bool barrierDismissible = true}) => showGeneralDialog(
    context: context,
    pageBuilder: (context, _, _) => dialog,
    barrierLabel: '',
    barrierColor: Colors.black26,
    barrierDismissible: barrierDismissible,
    transitionBuilder: (ctx, anim1, anim2, child) => RepaintBoundary(
      key: const ValueKey('custom_dialog'),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10 * anim1.value, sigmaY: 10 * anim1.value),
        child: FadeTransition(opacity: anim1, child: child),
      ),
    ),
  );

  /// [showLoading] extension from [showDialog]
  void showLoading() => showDialog<void>(
    builder: (context) => PopScope(
      onPopInvokedWithResult: (didPop, result) => false,
      canPop: false,
      child: const Center(
        child: SizedBox.square(
          dimension: 32,
          child: RepaintBoundary(
            key: ValueKey('loading_dialog'),
            child: CircularProgressIndicator(strokeCap: .round),
          ),
        ),
      ),
    ),
    context: context,
  ).ignore();

  /// [hideLoading] extension from [Navigator.of(this).pop<void>()]
  void hideLoading() => Navigator.of(context).pop<void>();

  /// [showNotification] extension from [CustomNotification]
  void showNotification({
    required String message,
    Color? iconBackgroundColor,
    Color? textColor,
    bool isError = false,
    TextStyle? textStyle,
    String? errorStatusCode,
  }) => CustomNotification.show(
    context: context,
    message: message,
    iconBackgroundColor: iconBackgroundColor,
    isError: isError,
    textStyle: textStyle,
  );

  /// Obtain the nearest widget of the given type T,
  /// which must be the type of a concrete [InheritedWidget] subclass,
  /// and register this build context with that widget such that
  /// when that widget changes (or a new widget of that type is introduced,
  /// or the widget goes away), this build context is rebuilt so that it can
  /// obtain new values from that widget.
  T? inhMaybeOf<T extends InheritedWidget>({bool listen = true}) =>
      listen ? context.dependOnInheritedWidgetOfExactType<T>() : context.getInheritedWidgetOfExactType<T>();

  /// Obtain the nearest widget of the given type T,
  /// which must be the type of a concrete [InheritedWidget] subclass,
  /// and register this build context with that widget such that
  /// when that widget changes (or a new widget of that type is introduced,
  /// or the widget goes away), this build context is rebuilt so that it can
  /// obtain new values from that widget.
  T inhOf<T extends InheritedWidget>({bool listen = true}) =>
      inhMaybeOf<T>(listen: listen) ??
      (throw ArgumentError(
        'Out of scope, not found inherited widget '
            'a $T of the exact type',
        'out_of_scope',
      ));

  /// Maybe inherit specific aspect from [InheritedModel].
  T? maybeInheritFrom<A extends Object, T extends InheritedModel<A>>({A? aspect}) =>
      InheritedModel.inheritFrom<T>(context, aspect: aspect);

  /// Inherit specific aspect from [InheritedModel].
  T inheritFrom<A extends Object, T extends InheritedModel<A>>({A? aspect}) =>
      maybeInheritFrom(aspect: aspect) ??
      (throw ArgumentError(
        'Out of scope, not found inherited model '
            'a $T of the exact type',
        'out_of_scope',
      ));
}

/// Octopus navigation shortcuts.
extension OctopusNavigationX on Octopus {
  /// Shorthand for [pop]. So you can call `context.octopus.p()`.
  Future<OctopusNode?> p() => pop();

  /// Replacement-style navigation for Octopus (replaces the last route).
  Future<OctopusNode> pushReplacement(OctopusRoute route, {Map<String, String>? arguments}) =>
      upsertLast(route, arguments: arguments);

  /// Replacement-style navigation for Octopus (replaces the last route).
  Future<OctopusNode> pushReplacementNamed(String name, {Map<String, String>? arguments}) =>
      upsertLastNamed(name, arguments: arguments);
}

extension BottomSheetPopX on BuildContext {
  /// Pop a modal (bottom sheet / dialog) using Flutter's [Navigator].
  void bottomSheetPop<T extends Object?>([T? result]) => Navigator.of(this).pop<T>(result);
}

extension TelegramWebAppX on BuildContext {
  TelegramWebApp get telegramWebApp => .instance;
  // WebAppUser? get telegramUser => telegramWebApp.initDataUnsafe?.user;

  void close() => telegramWebApp.close();
  void ready() => telegramWebApp.ready();
  void expand() => telegramWebApp.expand();
  void disableVerticalSwipes() => telegramWebApp.disableVerticalSwipes();
  void disableClosingConfirmation() => telegramWebApp.disableClosingConfirmation();
  void enableClosingConfirmation() => telegramWebApp.enableClosingConfirmation();

  void setupTelegramBackButton() {
    if (!kIsWeb) return;
    try {
      if (!telegramWebApp.isSupported) return;
      telegramWebApp.backButton
        ..onClick(_handleTelegramBackButtonPressed)
        ..show();
    } on Object catch (_) {
      log('Failed to show Telegram back button');
    }
  }

  void teardownTelegramBackButton() {
    if (!kIsWeb) return;
    try {
      if (!telegramWebApp.isSupported) return;
      telegramWebApp.backButton
        ..offClick(_handleTelegramBackButtonPressed)
        ..hide();
    } on Object catch (_) {
      log('Failed to hide Telegram back button');
    }
  }

  void _handleTelegramBackButtonPressed() {
    telegramWebApp.hapticFeedback.impactOccurred(.light);
    if (!mounted) return;
    octopus.pop();
  }
}
