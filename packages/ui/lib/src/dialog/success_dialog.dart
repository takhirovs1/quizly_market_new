import '../../ui.dart';
import '../extension/context_extension.dart';

class SuccessDialog extends StatelessWidget {
  const SuccessDialog({
    required this.title,
    required this.description,
    required this.successButtonText,
    required this.onSuccessButtonPressed,
    this.cancelButtonText,
    this.onCancelButtonPressed,
    this.isError = false,
    super.key,
  });

  final String title;
  final String description;
  final String? cancelButtonText;
  final String successButtonText;
  final VoidCallback? onCancelButtonPressed;
  final VoidCallback onSuccessButtonPressed;
  final bool isError;

  @override
  Widget build(BuildContext context) => ConstrainedBox(
    constraints: const BoxConstraints(maxWidth: 400),
    child: Stack(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 62),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: context.x.colors.dialogBackground,
              borderRadius: const BorderRadius.all(Radius.circular(16)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 70),
                  Text(
                    title,
                    style: context.x.textStyle.sfW700s28.copyWith(
                      fontSize: 24,
                      color: isError ? context.x.colors.error : context.x.colors.primary,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    description,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: context.x.textStyle.sfW400s16.copyWith(color: context.x.colors.dialogText),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    spacing: 12,
                    children: [
                      if (cancelButtonText != null && onCancelButtonPressed != null)
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              elevation: 0,
                              shadowColor: context.x.colors.transparent,
                              overlayColor: context.x.colors.primary,
                              backgroundColor: context.x.colors.dialogCancelButton,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              padding: const EdgeInsets.all(14),
                              fixedSize: const Size(double.infinity, 50),
                            ),
                            onPressed: onCancelButtonPressed,
                            child: Text(
                              cancelButtonText!,
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: context.x.textStyle.sfW500s16.copyWith(
                                fontSize: 17,
                                color: context.x.colors.bannerPriceText,
                              ),
                            ),
                          ),
                        ),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            shadowColor: context.x.colors.transparent,
                            surfaceTintColor: context.x.colors.transparent,
                            backgroundColor: context.x.colors.bannerButton,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.all(14),
                            fixedSize: const Size(double.infinity, 50),
                          ),
                          onPressed: onSuccessButtonPressed,
                          child: Text(
                            successButtonText,
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: context.x.textStyle.sfW500s16.copyWith(fontSize: 17, color: context.x.colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: isError
              ? Assets.lib.vectors.errorDialog.svg(width: 124, height: 124, package: 'ui')
              : Assets.lib.images.successDialog.image(width: 124, height: 124, package: 'ui'),
        ),
      ],
    ),
  );
}
