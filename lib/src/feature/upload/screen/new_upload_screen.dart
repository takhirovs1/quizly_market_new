import 'package:ui/ui.dart';

import '../../../common/extension/context_extension.dart';
import '../state/new_upload_state.dart';
import '../widget/upload_type_tile.dart';

class NewUploadScreen extends StatefulWidget {
  const NewUploadScreen({super.key});

  @override
  State<NewUploadScreen> createState() => _NewUploadScreenState();
}

class _NewUploadScreenState extends NewUploadState {
  @override
  Widget build(BuildContext context) {
    final colors = context.x.colors;
    final textStyle = context.x.textStyle;
    final l10n = context.x.l10n;

    return ListView(
      padding: const .symmetric(horizontal: 16, vertical: 8),
      children: [
        Padding(
          padding: const .only(bottom: 12),
          child: Text(
            l10n.selectUploadType,
            style: textStyle.sfW700s18.copyWith(color: colors.text, fontWeight: .w700),
          ),
        ),
        UploadTypeTile(
          title: l10n.uploadAsFile,
          icon: Assets.lib.vectors.fileIcon.svg(
            package: 'ui',
            width: 22,
            height: 22,
            colorFilter: ColorFilter.mode(colors.text, .srcIn),
          ),
          onTap: onUploadAsFile,
        ),
        const SizedBox(height: 10),
        UploadTypeTile(
          title: l10n.createTestManually,
          icon: Assets.lib.vectors.writeIcon.svg(
            package: 'ui',
            width: 22,
            height: 22,
            colorFilter: ColorFilter.mode(colors.text, .srcIn),
          ),
          onTap: onCreateTestManually,
        ),
        const SizedBox(height: 10),
        UploadTypeTile(
          title: l10n.createAiTest,
          icon: Assets.lib.vectors.aIIcon.svg(
            package: 'ui',
            width: 22,
            height: 22,
            colorFilter: ColorFilter.mode(colors.text, .srcIn),
          ),
          isComingSoon: true,
          onTap: onCreateAiTest,
        ),
      ],
    );
  }
}
