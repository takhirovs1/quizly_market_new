import 'package:flutter/cupertino.dart';
import 'package:ui/ui.dart';

import '../../../common/extension/context_extension.dart';
import '../../../common/extension/number_extension.dart';
import '../model/uploaded_test_model.dart';

class UploadedTestCard extends StatelessWidget {
  const UploadedTestCard({required this.test, this.onEdit, this.onPublish, this.onShare, this.onEnterTest, super.key});

  final UploadedTestModel test;
  final VoidCallback? onEdit;
  final VoidCallback? onPublish;
  final VoidCallback? onShare;
  final VoidCallback? onEnterTest;

  @override
  Widget build(BuildContext context) {
    final colors = context.x.colors;
    final textStyle = context.x.textStyle;

    return Container(
      decoration: BoxDecoration(color: colors.buttonFill, borderRadius: .circular(16)),
      padding: const .all(16),
      child: Column(
        crossAxisAlignment: .stretch,
        mainAxisSize: .min,
        children: [
          // Header: Title and Category
          Row(
            crossAxisAlignment: .start,
            children: [
              Expanded(
                child: Text(
                  test.title,
                  style: textStyle.sfW700s18.copyWith(color: colors.text, fontWeight: .w600),
                  maxLines: 2,
                  overflow: .ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Text(test.category, style: textStyle.sfW400s14.copyWith(color: colors.bannerSecondaryText)),
            ],
          ),
          const SizedBox(height: 4),

          // Subtitle
          Text(
            test.subtitle,
            style: textStyle.sfW400s14.copyWith(color: colors.bannerSecondaryText),
            maxLines: 2,
            overflow: .ellipsis,
          ),
          const SizedBox(height: 6),

          // Questions count
          Row(
            children: [
              Assets.lib.images.memo.image(width: 16, height: 16, package: 'ui'),
              const SizedBox(width: 4),
              Text(
                context.x.l10n.questionAmountText(test.questionCount),
                style: textStyle.sfW400s14.copyWith(color: colors.bannerSecondaryText),
              ),
            ],
          ),

          // Price row if published
          if (test.isPublished && test.price != null) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                Assets.lib.images.money.image(width: 16, height: 16, package: 'ui'),
                const SizedBox(width: 4),
                Text(
                  test.price!.formatUzs,
                  style: textStyle.sfW500s14.copyWith(color: colors.primary, fontWeight: .w600),
                ),
              ],
            ),
          ],
          const SizedBox(height: 10),

          // Action buttons row (aligned to right)
          Row(
            mainAxisAlignment: .end,
            children: [
              if (!test.isPublished) ...[
                _ActionPillButton(text: context.x.l10n.editAction, isPrimary: false, onPressed: onEdit),
                const SizedBox(width: 8),
                _ActionPillButton(text: context.x.l10n.publish, isPrimary: true, onPressed: onPublish),
              ] else ...[
                _ActionPillButton(text: context.x.l10n.shareAction, isPrimary: false, onPressed: onShare),
                const SizedBox(width: 8),
                _ActionPillButton(text: context.x.l10n.enterTest, isPrimary: true, onPressed: onEnterTest),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionPillButton extends StatelessWidget {
  const _ActionPillButton({required this.text, required this.isPrimary, this.onPressed});

  final String text;
  final bool isPrimary;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = context.x.colors;
    final textStyle = context.x.textStyle;

    final backgroundColor = isPrimary ? colors.primary : (context.x.isDarkMode ? colors.cardBackground2 : colors.white);

    final textColor = isPrimary ? colors.white : colors.text;

    return CupertinoButton(
      onPressed: onPressed ?? () {},
      padding: .zero,
      child: Container(
        padding: const .symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: .circular(10),
          boxShadow: isPrimary
              ? null
              : [BoxShadow(color: colors.black.withValues(alpha: .04), blurRadius: 4, offset: const Offset(0, 2))],
        ),
        child: Text(
          text,
          style: textStyle.sfW500s14.copyWith(color: textColor, fontWeight: .w600),
        ),
      ),
    );
  }
}
