import 'package:ui/ui.dart';
import 'package:url_launcher/url_launcher.dart' as url_launcher;

import '../constant/constant.dart';
import '../extension/context_extension.dart';
import '../service/update_service.dart';

Future<void> showUpdateBottomSheet(BuildContext context, UpdateInfo updateInfo) => showModalBottomSheet<void>(
      context: context,
      isDismissible: false,
      enableDrag: false,
      isScrollControlled: true,
      backgroundColor: context.x.colors.transparent,
      barrierColor: context.x.colors.black.withValues(alpha: 0.7),
      builder: (context) {
        final colors = context.x.colors;
        final l10n = context.x.l10n;

        return PopScope(
          canPop: false,
          child: Container(
            padding: const EdgeInsets.fromLTRB(24, 32, 24, 40),
            decoration: BoxDecoration(
              color: colors.dialogBackground,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD4FF00),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Assets.lib.images.logo.image(
                        package: Constant.packageUi,
                        width: 44,
                        height: 44,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  l10n.newVersionAvailable,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                    color: colors.dialogText,
                  ),
                ),
                const SizedBox(height: 10),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 300),
                  child: Text(
                    l10n.appVersionOutdatedDescription,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: colors.gray,
                      height: 1.4,
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD4FF00),
                      foregroundColor: colors.black,
                      elevation: 0,
                      shape: const StadiumBorder(),
                    ),
                    onPressed: () async {
                      final uri = Uri.parse(updateInfo.storeUrl);
                      if (await url_launcher.canLaunchUrl(uri)) {
                        await url_launcher.launchUrl(
                          uri,
                          mode: url_launcher.LaunchMode.externalApplication,
                        );
                      } else {
                        await url_launcher.launchUrl(uri);
                      }
                    },
                    child: Text(
                      l10n.updateButton,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: colors.black,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
