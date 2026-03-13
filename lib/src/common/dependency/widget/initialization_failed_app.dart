import 'dart:async' show FutureOr;

import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:ui/ui.dart';

import '../../constant/config.dart';

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
      home: Scaffold(
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
                    AppText.w500s22('Initialization Failed', color: theme.appColors.error, textAlign: TextAlign.center),
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
                        AppText.w500s16('Error Details:'),
                        AppText.w400s14('${widget.error}', color: theme.appColors.error),
                        const SizedBox(height: 4),
                        AppText.w500s11(
                          'Occurred at: ${DateFormat('dd.MM.yyyy HH:mm:ss:SS').format(DateTime.now())}',
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
                              const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator.adaptive(backgroundColor: Colors.white),
                              ),
                              const SizedBox(width: 4),
                            ],
                            AppText.w700s16(inProgress ? 'Retrying...' : 'Retry'),
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
                    decoration: const ShapeDecoration(
                      color: Colors.white,
                      shape: SmoothRectangleBorders(
                        smoothness: 1,
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        side: BorderSide(color: Color.fromARGB(118, 102, 112, 133), width: 1.3),
                      ),
                    ),
                    child: CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () => setState(() => _showStackTrace = !_showStackTrace),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(_showStackTrace ? Icons.expand_less : Icons.expand_more, color: const Color(0xFF1D2939)),
                          const SizedBox(width: 4),
                          Text(
                            _showStackTrace ? 'Hide Stack Trace' : 'Show Stack Trace',
                            style: const TextStyle(color: Color(0xFF1D2939), fontWeight: FontWeight.w500),
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
                      color: Colors.white,
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
    );
  }
}
