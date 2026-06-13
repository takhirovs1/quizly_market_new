import 'package:flutter/cupertino.dart';
import 'package:meta/meta.dart';

import '../../ui.dart';
import '../extension/context_extension.dart';

/// {@template list_tile_button}
/// ActionListTile widget.
/// {@endtemplate}
class ActionListTile extends StatefulWidget {
  /// {@macro list_tile_button}
  const ActionListTile({
    required this.leading,
    required this.onPressed,
    required this.comingSoonText,
    required this.connectedText,
    this.icon,
    this.iconColor,
    this.textColor,
    this.isComingSoon = false,
    this.isConnected = false,
    this.isLogout = false,
    super.key, // ignore: unused_element
  });

  final String leading;
  final VoidCallback onPressed;
  final Widget? icon;
  final Color? iconColor;
  final Color? textColor;
  final bool isComingSoon;
  final bool isConnected;
  final bool isLogout;
  final String comingSoonText;
  final String connectedText;

  /// The state from the closest instance of this class
  /// that encloses the given context, if any.
  @internal
  static ActionListTileState? maybeOf(BuildContext context) => context.findAncestorStateOfType<_ActionListTileState>();

  @override
  State<ActionListTile> createState() => _ActionListTileState();
}

/// State for widget ActionListTile.
abstract class ActionListTileState extends State<ActionListTile> {
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

class _ActionListTileState extends ActionListTileState {
  @override
  Widget build(BuildContext context) {
    final colors = context.x.colors;
    final textStyle = context.x.textStyle;

    Widget? trailingWidget;
    if (widget.isComingSoon || widget.comingSoonText.isNotEmpty) {
      trailingWidget = Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: colors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: colors.primary.withValues(alpha: 0.2)),
        ),
        child: Text(widget.comingSoonText, style: textStyle.sfW500s11.copyWith(color: colors.primary, fontSize: 10)),
      );
    } else if (widget.isConnected || widget.connectedText.isNotEmpty) {
      trailingWidget = Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: context.x.colors.success.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: context.x.colors.success.withValues(alpha: 0.2)),
        ),
        child: Text(
          widget.connectedText,
          style: textStyle.sfW500s11.copyWith(color: context.x.colors.success, fontSize: 10),
        ),
      );
    }

    final showArrow =
        !widget.isLogout &&
        !widget.isComingSoon &&
        !widget.isConnected &&
        widget.comingSoonText.isEmpty &&
        widget.connectedText.isEmpty;

    return CupertinoButton(
      onPressed: widget.onPressed,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      color: ThemeColors.of(context).buttonFill,
      child: Material(
        color: ThemeColors.of(context).transparent,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              spacing: 6,
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(shape: BoxShape.circle, color: context.x.colors.scaffoldBackground),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: widget.icon ?? Icon(Icons.person, color: widget.iconColor, size: 20),
                  ),
                ),
                Text(widget.leading, style: context.x.textStyle.sfW600s16.copyWith(color: widget.textColor)),
              ],
            ),
            Row(
              spacing: 8,
              children: [
                ?trailingWidget,
                if (showArrow) Icon(Icons.keyboard_arrow_right_rounded, color: ThemeColors.of(context).onSecondary),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
