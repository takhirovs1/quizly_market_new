import 'package:flutter/cupertino.dart';
import 'package:meta/meta.dart';

import '../../ui.dart';

/// {@template list_tile_button}
/// ActionListTile widget.
/// {@endtemplate}
class ActionListTile extends StatefulWidget {
  /// {@macro list_tile_button}
  const ActionListTile({
    required this.leading,
    required this.onPressed,
    this.icon,
    this.iconColor,
    this.textColor,
    super.key, // ignore: unused_element
  });

  final String leading;
  final VoidCallback onPressed;
  final Widget? icon;
  final Color? iconColor;
  final Color? textColor;

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
  Widget build(BuildContext context) => CupertinoButton(
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
                decoration: BoxDecoration(shape: BoxShape.circle, color: ThemeColors.of(context).white),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: widget.icon ?? Icon(Icons.person, color: widget.iconColor, size: 20),
                ),
              ),

              AppText.w600s16(widget.leading, color: widget.textColor),
            ],
          ),

          Icon(Icons.keyboard_arrow_right_rounded, color: ThemeColors.of(context).onSecondary),
        ],
      ),
    ),
  );
}
