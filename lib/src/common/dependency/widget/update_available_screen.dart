import 'package:localization/localization.dart';
import 'package:logbook/logbook.dart';
import 'package:ui/ui.dart';
import 'package:url_launcher/url_launcher.dart' as launcher;

import '../../constant/constant.dart';
import '../../localization/app_localizations_config.dart';

/// {@template update_available_screen}
/// UpdateAvailableScreen widget.
/// {@endtemplate}
class UpdateAvailableScreen extends StatefulWidget {
  /// {@macro update_available}
  const UpdateAvailableScreen({
    super.key, // ignore: unused_element
  });

  @override
  State<UpdateAvailableScreen> createState() => _UpdateAvailableScreenState();
}

abstract class UpdateAvailableController extends State<UpdateAvailableScreen> {
  void launchToStore() {
    try {
      launcher.launchUrl(Uri.parse(Constant.appLink), mode: launcher.LaunchMode.externalApplication);
    } on Object catch (error, stackTrace) {
      l.s(error, stackTrace);
    }
  }

  /* #region Lifecycle */
  @override
  void initState() {
    super.initState();
    // Initial state initialization
  }

  @override
  void dispose() {
    // Permanent removal of a tree stent
    super.dispose();
  }

  /* #endregion */
}

/// State for widget UpdateAvailableScreen.
class _UpdateAvailableScreenState extends UpdateAvailableController {
  @override
  Widget build(BuildContext context) {
    final platformDispatcher = View.of(context).platformDispatcher;
    final theme = platformDispatcher.platformBrightness == Brightness.light
        ? AppThemeData.light()
        : AppThemeData.dark();

    // Rendered above the app's MaterialApp, so provide localizations here.
    return Localizations(
      locale: appLocaleResolution(platformDispatcher.locale, AppLocalization.supportedLocales),
      delegates: appLocalizationsDelegates,
      child: Builder(
        builder: (context) => Material(
          color: theme.appColors.transparent,
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: Scaffold(
              extendBody: true,
              body: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Center(
                  child: Column(
                    spacing: 12,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AppText.w700s28(AppLocalization.of(context).newVersionAvailable, textAlign: TextAlign.center),
                      AppText.w500s16(
                        AppLocalization.of(context).updateAvailableDescription,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              bottomNavigationBar: Padding(
                padding: EdgeInsets.fromLTRB(
                  16,
                  8,
                  16,
                  MediaQuery.viewInsetsOf(context).bottom + MediaQuery.paddingOf(context).bottom + 16,
                ),
                child: SizedBox(
                  height: 48,
                  width: double.infinity,
                  child: FilledButton(
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.all(theme.appColors.primary),
                      elevation: WidgetStateProperty.all(1),
                      shape: WidgetStateProperty.all(
                        SmoothRectangleBorders(borderRadius: BorderRadius.circular(16), smoothness: 1),
                      ),
                    ),
                    onPressed: launchToStore,
                    child: AppText.w700s16(AppLocalization.of(context).updateButton, color: theme.appColors.white),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
