import 'dart:async' show FutureOr;

import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:localization/localization.dart';
import 'package:ui/ui.dart';

import '../../constant/config.dart';
import '../../localization/app_localizations_config.dart';

/// {@template initialization_failed_screen}
/// An enhanced screen that is shown when the initialization of the app fails.
/// Provides a user-friendly error display with retry functionality.
/// {@endtemplate}
class InitializationFailedApp extends StatefulWidget {
  /// {@macro initialization_failed_screen}
  const InitializationFailedApp({required this.error, required this.stackTrace, this.onRetryInitialization, super.key});

  final Object error;
  final StackTrace stackTrace;
  final FutureOr<void> Function()? onRetryInitialization;

  @override
  State<InitializationFailedApp> createState() => _InitializationFailedAppState();
}

class _InitializationFailedAppState extends State<InitializationFailedApp> {
  final _inProgress = ValueNotifier<bool>(false);
  bool _showStackTrace = false;

  @override
  void dispose() {
    _inProgress.dispose();
    super.dispose();
  }

  Future<void> _retryInitialization() async {
    if (_inProgress.value) return;

    _inProgress.value = true;

    try {
      await widget.onRetryInitialization?.call();
    } finally {
      _inProgress.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = View.of(context).platformDispatcher.platformBrightness == Brightness.dark;
    final theme = isDarkMode ? AppThemeData.dark() : AppThemeData.light();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: theme,
      localizationsDelegates: appLocalizationsDelegates,
      supportedLocales: AppLocalization.supportedLocales,
      localeResolutionCallback: appLocaleResolution,
      home: Builder(
        builder: (context) => Scaffold(
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  //TODO(Miracle): Add logo
                  const SizedBox(height: 24),

                  // Initialization failed text
                  Row(
                    spacing: 4,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline_rounded, size: 32, color: theme.appColors.error),
                      AppText.w500s22(
                        AppLocalization.of(context).initializationFailed,
                        color: theme.appColors.error,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Error details
                  Card(
                    color: theme.appColors.black,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppText.w500s16(AppLocalization.of(context).initializationErrorDetails),
                          AppText.w400s14('${widget.error}', color: theme.appColors.error),
                          const SizedBox(height: 4),
                          AppText.w500s11(
                            AppLocalization.of(context).initializationErrorOccurredAt(
                              DateFormat('dd.MM.yyyy HH:mm:ss:SS').format(DateTime.now()),
                            ),
                            color: theme.appColors.text,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Retry button
                  if (widget.onRetryInitialization != null)
                    ValueListenableBuilder<bool>(
                      valueListenable: _inProgress,
                      builder: (context, inProgress, _) => Container(
                        height: 45,
                        decoration: ShapeDecoration(
                          color: theme.appColors.primary,
                          shape: SmoothRectangleBorders(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: CupertinoButton(
                          padding: EdgeInsets.zero,
                          onPressed: inProgress ? null : _retryInitialization,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (_inProgress.value) ...[
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator.adaptive(backgroundColor: theme.appColors.pureWhite),
                                ),
                                const SizedBox(width: 4),
                              ],
                              AppText.w700s16(
                                inProgress ? AppLocalization.of(context).retrying : AppLocalization.of(context).retry,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 12),

                  // Stack trace show toggle
                  if (!Config.environment.isProduction)
                    Container(
                      height: 45,
                      decoration: ShapeDecoration(
                        color: theme.appColors.pureWhite,
                        shape: SmoothRectangleBorders(
                          smoothness: 1,
                          borderRadius: const BorderRadius.all(Radius.circular(10)),
                          side: BorderSide(color: theme.appColors.initErrorToggleBorder, width: 1.3),
                        ),
                      ),
                      child: CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: () => setState(() => _showStackTrace = !_showStackTrace),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _showStackTrace ? Icons.expand_less : Icons.expand_more,
                              color: theme.appColors.initErrorToggleText,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _showStackTrace
                                  ? AppLocalization.of(context).hideStackTrace
                                  : AppLocalization.of(context).showStackTrace,
                              style: TextStyle(color: theme.appColors.initErrorToggleText, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // Stack trace
                  if (_showStackTrace) ...[
                    const SizedBox(height: 12),
                    Expanded(
                      child: Card(
                        color: theme.appColors.pureWhite,
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(16),
                          child: SelectableText(
                            '${widget.stackTrace}${widget.stackTrace}${widget.stackTrace}${widget.stackTrace}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
