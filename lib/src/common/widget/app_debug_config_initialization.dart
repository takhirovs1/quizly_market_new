part of 'app.dart';

/// AppDebugConfigInitialization mixin
mixin AppDebugConfigInitialization on State<App> {
  final GlobalKey<OverlayState> _overlayKey = GlobalKey<OverlayState>();

  OverlayEntry? _themeToggleOverlay;
  OverlayEntry? _debugButtonOverlay;

  /// Whether the debug overlays are currently inserted — re-inserting an
  /// already-present [OverlayEntry] (or removing a never-inserted one) throws.
  bool _debugOverlaysInserted = false;

  late LogbookConfig _logbookConfig;

  /// Captured in [initState] so [dispose] never looks up an ancestor scope.
  late final ValueNotifier<DebugConfig> _appDebugSettings;

  DebugConfig get debugConfig => _appDebugSettings.value;

  void _setThemeMode(bool isDarkMode) => SettingsScope.of(context).add(
    .updateSettings(
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
            onPressed: () => context.x.dependencies.appDebugSettings.value = debugConfig.copyWith(
              debuggerEnabled: false,
              thunderEnabled: false,
            ),
            icon: const Icon(Icons.bug_report_rounded),
          ),
        ),
      );

      final overlay = _overlayKey.currentState;
      if (!_debugOverlaysInserted && overlay != null) {
        overlay
          ..insert(_themeToggleOverlay!)
          ..insert(_debugButtonOverlay!);
        _debugOverlaysInserted = true;
      }
    } else if (_debugOverlaysInserted) {
      _themeToggleOverlay?.remove();
      _debugButtonOverlay?.remove();
      _debugOverlaysInserted = false;
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

    _appDebugSettings = context.x.dependencies.appDebugSettings;
    _appDebugSettings.addListener(_appSettingsListener);
    _appSettingsListener();

    _logbookConfig = LogbookConfig(
      enabled: debugConfig.debuggerEnabled,
      debugFileName: '${context.x.dependencies.authenticationController.state.user.id ?? 'unauthenticated'}.csv',
      multipartFileFields: {'chat_id': debugConfig.telegramChatId ?? '', 'caption': '#quizly_market'},
      uri: .parse('${Config.telegramApiBaseUrl}/bot${debugConfig.telegramBotToken ?? ''}/sendDocument'),
    );
  }

  @override
  void dispose() {
    if (_debugOverlaysInserted) {
      _themeToggleOverlay?.remove();
      _debugButtonOverlay?.remove();
      _debugOverlaysInserted = false;
    }

    _appDebugSettings.removeListener(_appSettingsListener);

    super.dispose();
  }

  // #endregion lifecycle
}
