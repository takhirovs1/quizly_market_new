import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';
import 'package:localization/localization.dart';
import 'package:logbook/logbook.dart';
import 'package:octopus/octopus.dart';
import 'package:thunder/thunder.dart';
import 'package:ui/ui.dart';

import '../../feature/authentication/screen/authentication_scope.dart';
import '../../feature/settings/bloc/settings_bloc.dart';
import '../../feature/settings/screen/settings_scope.dart';
import '../constant/config.dart';
import '../dependency/model/debug_config.dart';
import '../extension/context_extension.dart';
import '../router/auth_guard.dart';
import '../router/main_guard.dart';
import '../router/pages.dart';

part 'app_debug_config_initialization.dart';
part 'app_route_initialization.dart';
part 'app_state.dart';

/// {@template app}
/// App widget.
/// {@endtemplate}
class App extends StatefulWidget {
  /// {@macro app}
  const App({
    super.key, // ignore: unused_element
  });

  @override
  State<App> createState() => _AppState();
}

/// UI configuration for widget App.
class _AppState extends AppState {
  @override
  void initState() {
    super.initState();
    _configureTelegramShell();
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
    restorationScopeId: 'material_app',
    onGenerateTitle: (context) => context.x.l10n.title,
    debugShowCheckedModeBanner: false,

    // Localizations
    localizationsDelegates: const <LocalizationsDelegate<Object?>>[
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
      AppLocalization.delegate,
    ],
    supportedLocales: AppLocalization.supportedLocales,
    locale: SettingsScope.settingsOf(context).localization,

    // Theme
    themeMode: SettingsScope.settingsOf(context, listen: true).themeMode,
    darkTheme: AppThemeData.dark(),
    theme: AppThemeData.light(),

    // Scopes
    builder: (context, child) =>
        /// This scope [MediaQuery] is used to handle the screen size and orientation
        MediaQuery(
          key: _appKey,
          data: MediaQuery.of(context).copyWith(textScaler: TextScaler.noScaling),
          child: KeyboardDismisser(
            child: Logbook(
              config: _logbookConfig,
              child: Thunder(
                enabled: debugConfig.debuggerEnabled,
                color: context.x.theme.colorScheme.primary,

                /// This scope [Overlay] is used to handle the overlay entries
                child: Overlay(
                  key: _overlayKey,
                  clipBehavior: Clip.none,
                  initialEntries: <OverlayEntry>[
                    _scopes,

                    // You can any other overlay entries here for debugging
                    // Important: this list is immutable
                  ],
                ),
              ),
            ),
          ),
        ),
  );
  void _configureTelegramShell() {
    if (!kIsWeb) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        final telegram = context.telegramWebApp;
        if (!telegram.isSupported) return;

        telegram
          ..ready()
          ..expand()
          ..disableVerticalSwipes();
        if (!kDebugMode) telegram.requestFullscreen();
      } on Object catch (_) {
        log('Telegram Web App configuration failed');
      }
    });
  }
}
