import 'package:flutter/material.dart';

import '../extension/context_extension.dart';

/// A tappable card that displays an icon, title, and optional subtitle.
/// Supports an optional "coming soon" badge — pass [comingSoonLabel] to enable it.
class LinkCard extends StatelessWidget {
  const LinkCard({
    required this.leading,
    required this.title,
    required this.onTap,
    this.subtitle,
    this.comingSoonLabel,
    super.key,
  });

  final Widget leading;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  /// When non-null, shows a badge with this text and disables [onTap].
  final String? comingSoonLabel;

  bool get _isComingSoon => comingSoonLabel != null;

  @override
  Widget build(BuildContext context) {
    final colors = context.x.colors;
    final textStyle = context.x.textStyle;
    return Material(
      color: colors.scaffoldBackground,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: _isComingSoon ? null : onTap,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colors.divider),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            child: Row(
              children: [
                SizedBox(width: 28, height: 28, child: Center(child: leading)),
                const SizedBox(width: 12),
                Expanded(
                  child: RichText(
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    text: subtitle != null
                        ? TextSpan(
                            style: textStyle.sfW400s16.copyWith(color: colors.text),
                            children: [
                              TextSpan(
                                text: title,
                                style: textStyle.sfW700s16.copyWith(color: colors.text),
                              ),
                              TextSpan(text: subtitle ?? ''),
                            ],
                          )
                        : TextSpan(
                            text: title,
                            style: textStyle.sfW700s16.copyWith(color: colors.text),
                          ),
                  ),
                ),
                if (_isComingSoon) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: colors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: colors.primary.withValues(alpha: 0.2)),
                    ),
                    child: Text(
                      comingSoonLabel!,
                      style: textStyle.sfW500s11.copyWith(color: colors.primary, fontSize: 10),
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
