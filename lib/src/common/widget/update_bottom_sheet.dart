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
        padding: const .fromLTRB(24, 16, 24, 36),
        decoration: BoxDecoration(
          color: colors.dialogBackground,
          borderRadius: const .vertical(top: .circular(24)),
        ),
        child: Column(
          mainAxisSize: .min,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(color: colors.gray.withValues(alpha: 0.3), borderRadius: .circular(2)),
              ),
            ),
            const SizedBox(height: 24),
            Center(
              child: ClipRRect(
                borderRadius: .circular(12),
                child: Assets.lib.images.logo.image(package: Constant.packageUi, width: 80, height: 80, fit: .contain),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              l10n.newVersionAvailable,
              textAlign: .center,
              style: context.x.textStyle.sfW700s18.copyWith(fontSize: 20, color: colors.dialogText),
            ),
            const SizedBox(height: 10),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 300),
              child: Text(
                l10n.appVersionOutdatedDescription,
                textAlign: .center,
                style: context.x.textStyle.sfW400s14.copyWith(color: colors.gray, height: 1.4),
              ),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: .infinity,
              child: CustomButton(
                title: l10n.updateButton,
                color: colors.primary,
                textColor: colors.white,
                onTap: () async {
                  final uri = Uri.parse(updateInfo.storeUrl);
                  if (await url_launcher.canLaunchUrl(uri)) {
                    await url_launcher.launchUrl(uri, mode: .externalApplication);
                  } else {
                    await url_launcher.launchUrl(uri);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  },
);
