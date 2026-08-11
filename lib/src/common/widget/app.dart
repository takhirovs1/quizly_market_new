import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';
import 'package:localization/localization.dart';
import 'package:logbook/logbook.dart';
import 'package:octopus/octopus.dart';
import 'package:thunder/thunder.dart';
import 'package:ui/ui.dart';
import 'package:universal_html/html.dart' as html;

import '../../core/di/service_locator.dart';
import '../../core/services/web_update_notifier.dart';
import '../../feature/authentication/screen/authentication_scope.dart';
import '../../feature/authentication/state/authentication_controller.dart';
import '../../feature/settings/screen/settings_scope.dart';
import '../constant/config.dart';
import '../dependency/model/debug_config.dart';
import '../extension/context_extension.dart';
import '../localization/app_localizations_config.dart';
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
    localizationsDelegates: appLocalizationsDelegates,
    supportedLocales: AppLocalization.supportedLocales,
    localeResolutionCallback: appLocaleResolution,
    locale: SettingsScope.settingsOf(context).localization,

    // Theme
    themeMode: SettingsScope.settingsOf(context, listen: true).themeMode,
    darkTheme: AppThemeData.dark(),
    theme: AppThemeData.light(),

    // Scopes
    builder: (context, child) {
      final appWidget = MediaQuery(
        key: _appKey,
        data: MediaQuery.of(context).copyWith(textScaler: .noScaling),
        child: KeyboardDismisser(
          child: Logbook(
            config: _logbookConfig,
            child: Thunder(
              enabled: debugConfig.debuggerEnabled,
              color: context.x.theme.colorScheme.primary,

              /// This scope [Overlay] is used to handle the overlay entries
              child: Overlay(
                key: _overlayKey,
                clipBehavior: .none,
                initialEntries: <OverlayEntry>[
                  _scopes,

                  // You can any other overlay entries here for debugging
                  // Important: this list is immutable
                ],
              ),
            ),
          ),
        ),
      );

      if (!kIsWeb) return appWidget;

      return ListenableBuilder(
        listenable: getIt<WebUpdateNotifier>(),
        builder: (context, _) {
          if (!getIt<WebUpdateNotifier>().hasUpdate) return appWidget;
          return Stack(
            children: [
              appWidget,
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: ColoredBox(
                  color: const Color(0xFF1C59F2),
                  child: SafeArea(
                    child: Padding(
                      padding: const .symmetric(horizontal: 16, vertical: 10),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              context.x.l10n.newVersionAvailable,
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          TextButton(
                            onPressed: () => html.window.location.reload(),
                            child: Text(
                              context.x.l10n.updateButton,
                              style: const TextStyle(color: Color(0xFF41D6FF)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      );
    },
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
