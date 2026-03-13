part of 'app.dart';

/// AppDebugConfigInitialization mixin
mixin AppDebugConfigInitialization on State<App> {
  final GlobalKey<OverlayState> _overlayKey = GlobalKey<OverlayState>();

  OverlayEntry? _themeToggleOverlay;
  OverlayEntry? _debugButtonOverlay;

  late LogbookConfig _logbookConfig;

  DebugConfig get debugConfig => context.x.dependencies.appDebugSettings.value;

  void _setThemeMode(bool isDarkMode) => SettingsScope.of(context).add(
    SettingsEvent.updateSettings(
      settings: SettingsScope.settingsOf(context).copyWith(themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light),
    ),
  );

  void _appSettingsListener() => WidgetsBinding.instance.addPostFrameCallback((_) {
    if (!mounted) return;

    if (debugConfig.debuggerEnabled) {
      _themeToggleOverlay ??= OverlayEntry(builder: (context) => ThemeToggleOverlay(setThemeMode: _setThemeMode));

      _debugButtonOverlay ??= OverlayEntry(
        builder: (context) => Positioned(
          bottom: 8,
          left: 8,
          child: IconButton(
            onPressed: () =>
                context.x.dependencies.appDebugSettings.value = debugConfig.copyWith(debuggerEnabled: false),
            icon: const Icon(Icons.bug_report_rounded),
          ),
        ),
      );

      _overlayKey.currentState?.insert(_themeToggleOverlay!);
      _overlayKey.currentState?.insert(_debugButtonOverlay!);
    } else {
      _themeToggleOverlay?.remove();
      _debugButtonOverlay?.remove();
    }

    _logbookConfig = LogbookConfig(
      debugFileName: _logbookConfig.debugFileName,
      multipartFileFields: _logbookConfig.multipartFileFields,
      uri: _logbookConfig.uri,
      fontFamily: _logbookConfig.fontFamily,
      enabled: debugConfig.debuggerEnabled,
    );

    // For enabling/disabling [Thunder, Logbook]
    setState(() {});
  });

  // #region lifecycle
  @override
  void initState() {
    super.initState();

    context.x.dependencies.appDebugSettings.addListener(_appSettingsListener);

    _logbookConfig = LogbookConfig(
      enabled: debugConfig.debuggerEnabled,
      debugFileName: '${context.x.dependencies.authenticationController.state.user.id ?? 'unauthenticated'}.csv',
      multipartFileFields: {'chat_id': debugConfig.telegramChatId ?? '', 'caption': '#quizly_market'},
      uri: Uri.parse('${Config.telegramApiBaseUrl}/bot${debugConfig.telegramBotToken ?? ''}/sendDocument'),
    );
  }

  @override
  void dispose() {
    _themeToggleOverlay?.remove();
    _debugButtonOverlay?.remove();

    context.x.dependencies.appDebugSettings.removeListener(_appSettingsListener);

    super.dispose();
  }

  // #endregion lifecycle
}
