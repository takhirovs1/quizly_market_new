import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:math_keyboard/src/custom_key_icons/custom_key_icons.dart';
import 'package:math_keyboard/src/foundation/keyboard_button.dart';
import 'package:math_keyboard/src/widgets/decimal_separator.dart';
import 'package:math_keyboard/src/widgets/keyboard_button.dart';
import 'package:math_keyboard/src/widgets/math_field.dart';
import 'package:math_keyboard/src/widgets/math_keyboard_theme.dart';
import 'package:math_keyboard/src/widgets/view_insets.dart';

/// Enumeration for the types of keyboard that a math keyboard can adopt.
///
/// This way we allow different button configurations. The user may only need to
/// input a number.
enum MathKeyboardType {
  /// Keyboard for entering complete math expressions.
  ///
  /// This shows numbers + operators and a toggle button to switch to another
  /// page with extended functions.
  expression,

  /// Keyboard for number input only.
  numberOnly,
}

/// Widget displaying the math keyboard.
class MathKeyboard extends StatelessWidget {
  /// Constructs a [MathKeyboard].
  const MathKeyboard({
    Key? key,
    required this.controller,
    this.type = MathKeyboardType.expression,
    this.variables = const [],
    this.onSubmit,
    this.insetsState,
    this.slideAnimation,
    this.style,
    this.semantics,
    this.padding = const EdgeInsets.only(bottom: 4, left: 4, right: 4),
  }) : super(key: key);

  /// The controller for editing the math field.
  ///
  /// Must not be `null`.
  final MathFieldEditingController controller;

  /// The state for reporting the keyboard insets.
  ///
  /// If `null`, the math keyboard will not report about its bottom inset.
  final MathKeyboardViewInsetsState? insetsState;

  /// Animation that indicates the current slide progress of the keyboard.
  ///
  /// If `null`, the keyboard is always fully slided out.
  final Animation<double>? slideAnimation;

  /// The Variables a user can use.
  final List<String> variables;

  /// The Type of the Keyboard.
  final MathKeyboardType type;

  /// Visual style. Falls back to [MathKeyboardStyle.dark] when null.
  final MathKeyboardStyle? style;

  /// Localized labels + a11y. Falls back to [MathKeyboardSemantics.fallback].
  final MathKeyboardSemantics? semantics;

  /// Function that is called when the enter / submit button is tapped.
  ///
  /// Can be `null`.
  final VoidCallback? onSubmit;

  /// Insets of the keyboard.
  ///
  /// Defaults to `const EdgeInsets.only(bottom: 4, left: 4, right: 4),`.
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final style = this.style ?? MathKeyboardStyle.dark();
    final semantics = this.semantics ?? MathKeyboardSemantics.fallback;

    final curvedSlideAnimation = CurvedAnimation(
      parent: slideAnimation ?? AlwaysStoppedAnimation(1),
      curve: Curves.ease,
    );

    return SlideTransition(
      position: Tween<Offset>(begin: const Offset(0, 1), end: const Offset(0, 0)).animate(curvedSlideAnimation),
      child: Stack(
        children: [
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Material(
              type: MaterialType.transparency,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: style.backgroundColor,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(style.topBorderRadius)),
                ),
                child: SafeArea(
                  top: false,
                  child: _KeyboardBody(
                    insetsState: insetsState,
                    slideAnimation: slideAnimation == null ? null : curvedSlideAnimation,
                    child: Padding(
                      padding: padding,
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 5e2),
                          child: Column(
                            children: [
                              if (type != MathKeyboardType.numberOnly)
                                _Variables(controller: controller, variables: variables, style: style),
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: _Buttons(
                                  controller: controller,
                                  page1: type == MathKeyboardType.numberOnly ? numberKeyboard : standardKeyboard,
                                  page2: type == MathKeyboardType.numberOnly ? null : functionKeyboard,
                                  onSubmit: onSubmit,
                                  style: style,
                                  semantics: semantics,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Widget that reports about the math keyboard body's bottom inset.
class _KeyboardBody extends StatefulWidget {
  const _KeyboardBody({Key? key, this.insetsState, this.slideAnimation, required this.child}) : super(key: key);

  final MathKeyboardViewInsetsState? insetsState;

  /// The animation for sliding the keyboard.
  ///
  /// This is used in the body for reporting fractional sliding progress, i.e.
  /// reporting a smaller size while sliding.
  final Animation<double>? slideAnimation;

  final Widget child;

  @override
  _KeyboardBodyState createState() => _KeyboardBodyState();
}

class _KeyboardBodyState extends State<_KeyboardBody> {
  @override
  void initState() {
    super.initState();

    widget.slideAnimation?.addListener(_handleAnimation);
  }

  @override
  void didUpdateWidget(_KeyboardBody oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.insetsState != widget.insetsState) {
      _removeInsets(oldWidget.insetsState);
      _reportInsets(widget.insetsState);
    }

    if (oldWidget.slideAnimation != widget.slideAnimation) {
      oldWidget.slideAnimation?.removeListener(_handleAnimation);
      widget.slideAnimation?.addListener(_handleAnimation);
    }
  }

  @override
  void dispose() {
    _removeInsets(widget.insetsState);
    widget.slideAnimation?.removeListener(_handleAnimation);

    super.dispose();
  }

  void _handleAnimation() {
    _reportInsets(widget.insetsState);
  }

  void _removeInsets(MathKeyboardViewInsetsState? insetsState) {
    if (insetsState == null) return;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      widget.insetsState![ObjectKey(this)] = null;
    });
  }

  void _reportInsets(MathKeyboardViewInsetsState? insetsState) {
    if (insetsState == null) return;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final renderBox = context.findRenderObject() as RenderBox;
      insetsState[ObjectKey(this)] = renderBox.size.height * (widget.slideAnimation?.value ?? 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    _reportInsets(widget.insetsState);
    return widget.child;
  }
}

/// Widget showing the variables a user can use.
class _Variables extends StatelessWidget {
  /// Constructs a [_Variables] Widget.
  const _Variables({Key? key, required this.controller, required this.variables, required this.style})
    : super(key: key);

  /// The editing controller for the math field that the variables are connected
  /// to.
  final MathFieldEditingController controller;

  /// The variables to show.
  final List<String> variables;

  final MathKeyboardStyle style;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 54,
      color: style.variableRowColor,
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, child) {
          return ListView.separated(
            itemCount: variables.length,
            scrollDirection: Axis.horizontal,
            separatorBuilder: (context, index) {
              return Center(child: Container(height: 24, width: 1, color: style.keyTextColor.withValues(alpha: 0.3)));
            },
            itemBuilder: (context, index) {
              return SizedBox(
                width: 56,
                child: _VariableButton(
                  name: variables[index],
                  style: style,
                  onTap: () => controller.addLeaf('{${variables[index]}}'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

/// Widget displaying the buttons.
class _Buttons extends StatefulWidget {
  /// Constructs a [_Buttons] Widget.
  const _Buttons({
    Key? key,
    required this.controller,
    required this.style,
    required this.semantics,
    this.page1,
    this.page2,
    this.onSubmit,
  }) : super(key: key);

  /// The editing controller for the math field that the variables are connected
  /// to.
  final MathFieldEditingController controller;

  /// The buttons to display.
  final List<List<KeyboardButtonConfig>>? page1;

  /// The buttons to display.
  final List<List<KeyboardButtonConfig>>? page2;

  /// Function that is called when the enter / submit button is tapped.
  ///
  /// Can be `null`.
  final VoidCallback? onSubmit;

  final MathKeyboardStyle style;
  final MathKeyboardSemantics semantics;

  @override
  State<_Buttons> createState() => _ButtonsState();
}

class _ButtonsState extends State<_Buttons> {
  bool _showSymbols = false;

  /// Symbols are only available on the full expression keyboard.
  bool get _symbolsAvailable => widget.page2 != null;

  void _toggleSymbols() => setState(() => _showSymbols = !_showSymbols);

  @override
  Widget build(BuildContext context) {
    final style = widget.style;
    final semantics = widget.semantics;

    return SizedBox(
      height: 268,
      child: Column(
        children: [
          if (_symbolsAvailable)
            _SymbolsToggle(
              active: _showSymbols,
              style: style,
              label: semantics.showSymbolsKeyboardLabel,
              onTap: _toggleSymbols,
            ),
          Expanded(
            child: AnimatedBuilder(
              animation: widget.controller,
              builder: (context, child) {
                if (_showSymbols && _symbolsAvailable) {
                  return _SymbolsPage(
                    controller: widget.controller,
                    style: style,
                    semantics: semantics,
                    onSubmit: widget.onSubmit,
                  );
                }
                final layout = widget.controller.secondPage ? widget.page2! : widget.page1 ?? numberKeyboard;
                return Column(
                  children: [
                    for (final row in layout)
                      Expanded(
                        child: Row(
                          children: [
                            for (final config in row)
                              if (config is BasicKeyboardButtonConfig)
                                _BasicButton(
                                  flex: config.flex,
                                  label: config.label,
                                  onTap: config.args != null
                                      ? () => widget.controller.addFunction(config.value, config.args!)
                                      : () => widget.controller.addLeaf(config.value),
                                  asTex: config.asTex,
                                  highlightLevel: config.highlighted ? 1 : 0,
                                  style: style,
                                )
                              else if (config is DeleteButtonConfig)
                                _NavigationButton(
                                  flex: config.flex,
                                  icon: Icons.backspace,
                                  iconSize: 22,
                                  semanticLabel: semantics.deleteLabel,
                                  color: style.utilityKeyColor,
                                  iconColor: style.keyTextColor,
                                  onTap: () => widget.controller.goBack(deleteMode: true),
                                )
                              else if (config is PageButtonConfig)
                                _BasicButton(
                                  flex: config.flex,
                                  icon: widget.controller.secondPage ? null : CustomKeyIcons.key_symbols,
                                  label: widget.controller.secondPage ? '123' : null,
                                  onTap: widget.controller.togglePage,
                                  highlightLevel: 3,
                                  style: style,
                                )
                              else if (config is PreviousButtonConfig)
                                _NavigationButton(
                                  flex: config.flex,
                                  icon: Icons.chevron_left_rounded,
                                  semanticLabel: semantics.previousLabel,
                                  color: style.neutralKeyColor,
                                  iconColor: style.keyTextColor,
                                  onTap: widget.controller.goBack,
                                )
                              else if (config is NextButtonConfig)
                                _NavigationButton(
                                  flex: config.flex,
                                  icon: Icons.chevron_right_rounded,
                                  semanticLabel: semantics.nextLabel,
                                  color: style.neutralKeyColor,
                                  iconColor: style.keyTextColor,
                                  onTap: widget.controller.goNext,
                                )
                              else if (config is SubmitButtonConfig)
                                _BasicButton(
                                  flex: config.flex,
                                  icon: Icons.keyboard_return,
                                  onTap: widget.onSubmit,
                                  highlightLevel: 2,
                                  style: style,
                                ),
                          ],
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Small header toggle that reveals the scrollable symbols page.
class _SymbolsToggle extends StatelessWidget {
  const _SymbolsToggle({required this.active, required this.style, required this.label, required this.onTap});

  final bool active;
  final MathKeyboardStyle style;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: Semantics(
            button: true,
            selected: active,
            label: label,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: active ? style.primaryKeyColor : style.neutralKeyColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    active ? Icons.close_rounded : Icons.functions_rounded,
                    size: 16,
                    color: active ? style.primaryKeyTextColor : style.keyTextColor,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    label,
                    style: TextStyle(fontSize: 13, color: active ? style.primaryKeyTextColor : style.keyTextColor),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Vertical, scrollable 14-category symbols page with a fixed control row.
class _SymbolsPage extends StatelessWidget {
  const _SymbolsPage({required this.controller, required this.style, required this.semantics, this.onSubmit});

  final MathFieldEditingController controller;
  final MathKeyboardStyle style;
  final MathKeyboardSemantics semantics;
  final VoidCallback? onSubmit;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            itemCount: symbolCategories.length,
            itemBuilder: (context, index) {
              final category = symbolCategories[index];
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(4, 10, 4, 6),
                    child: Text(
                      semantics.categoryLabel(category.id, category.titleFallback),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: style.keyTextColor.withValues(alpha: 0.6),
                      ),
                    ),
                  ),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      for (final config in category.buttons)
                        _SymbolButton(
                          config: config,
                          style: style,
                          onTap: config.args != null
                              ? () => controller.addFunction(config.value, config.args!)
                              : () => controller.addLeaf(config.value),
                        ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
        // Fixed control row: ◄ ► ⌫ ✓
        SizedBox(
          height: 52,
          child: Row(
            children: [
              _NavigationButton(
                flex: 2,
                icon: Icons.chevron_left_rounded,
                semanticLabel: semantics.previousLabel,
                color: style.neutralKeyColor,
                iconColor: style.keyTextColor,
                onTap: controller.goBack,
              ),
              _NavigationButton(
                flex: 2,
                icon: Icons.chevron_right_rounded,
                semanticLabel: semantics.nextLabel,
                color: style.neutralKeyColor,
                iconColor: style.keyTextColor,
                onTap: controller.goNext,
              ),
              _NavigationButton(
                flex: 2,
                icon: Icons.backspace,
                iconSize: 22,
                semanticLabel: semantics.deleteLabel,
                color: style.utilityKeyColor,
                iconColor: style.keyTextColor,
                onTap: () => controller.goBack(deleteMode: true),
              ),
              _BasicButton(flex: 2, icon: Icons.keyboard_return, onTap: onSubmit, highlightLevel: 2, style: style),
            ],
          ),
        ),
      ],
    );
  }
}

/// A single tappable symbol on the symbols page.
class _SymbolButton extends StatelessWidget {
  const _SymbolButton({required this.config, required this.style, required this.onTap});

  final BasicKeyboardButtonConfig config;
  final MathKeyboardStyle style;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 52,
      height: 44,
      child: KeyboardButton(
        onTap: onTap,
        color: style.functionKeyColor,
        pressedOverlayColor: style.pressedOverlayColor,
        child: config.asTex
            ? Math.tex(config.label, options: MathOptions(fontSize: 18, color: style.keyTextColor))
            : Text(config.label, style: TextStyle(fontSize: 18, color: style.keyTextColor)),
      ),
    );
  }
}

/// Widget displaying a single keyboard button.
class _BasicButton extends StatelessWidget {
  /// Constructs a [_BasicButton].
  const _BasicButton({
    Key? key,
    required this.flex,
    required this.style,
    this.label,
    this.icon,
    this.onTap,
    this.asTex = false,
    this.highlightLevel = 0,
  }) : assert(label != null || icon != null),
       super(key: key);

  /// The flexible flex value.
  final int? flex;

  /// The label for this button.
  final String? label;

  /// Icon for this button.
  final IconData? icon;

  /// Function to be called on tap.
  final VoidCallback? onTap;

  /// Show label as tex.
  final bool asTex;

  /// 0 = function key, 1 = neutral (operators), 2 = primary (submit),
  /// 3 = utility (page toggle).
  final int highlightLevel;

  final MathKeyboardStyle style;

  @override
  Widget build(BuildContext context) {
    final isPrimary = highlightLevel == 2;
    final textColor = isPrimary ? style.primaryKeyTextColor : style.keyTextColor;
    final Color keyColor = switch (highlightLevel) {
      2 => style.primaryKeyColor,
      1 => style.neutralKeyColor,
      3 => style.utilityKeyColor,
      _ => style.functionKeyColor,
    };

    Widget result;
    if (label == null) {
      result = Icon(icon, color: textColor);
    } else if (asTex) {
      result = Math.tex(
        label!,
        options: MathOptions(fontSize: style.baseFontSize + 2, color: textColor),
      );
    } else {
      var symbol = label;
      if (label == '.') {
        // We want to display the decimal separator differently depending
        // on the current locale.
        symbol = decimalSeparator(context);
      }

      result = Text(
        symbol!,
        style: TextStyle(fontSize: style.baseFontSize + 2, color: textColor),
      );
    }

    result = KeyboardButton(
      onTap: onTap,
      color: keyColor,
      pressedOverlayColor: style.pressedOverlayColor,
      child: result,
    );

    return Expanded(flex: flex ?? 2, child: result);
  }
}

/// Keyboard button for navigation actions.
class _NavigationButton extends StatelessWidget {
  /// Constructs a [_NavigationButton].
  const _NavigationButton({
    Key? key,
    required this.flex,
    required this.color,
    required this.iconColor,
    this.icon,
    this.iconSize = 36,
    this.semanticLabel,
    this.onTap,
  }) : super(key: key);

  /// The flexible flex value.
  final int? flex;

  /// Icon to be shown.
  final IconData? icon;

  /// The size for the icon.
  final double iconSize;

  final Color color;
  final Color iconColor;
  final String? semanticLabel;

  /// Function used when user holds the button down.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex ?? 2,
      child: KeyboardButton(
        onTap: onTap,
        onHold: onTap,
        color: color,
        child: Icon(icon, color: iconColor, size: iconSize, semanticLabel: semanticLabel),
      ),
    );
  }
}

/// Widget for variable keyboard buttons.
class _VariableButton extends StatelessWidget {
  /// Constructs a [_VariableButton] widget.
  const _VariableButton({Key? key, required this.name, required this.style, this.onTap}) : super(key: key);

  /// The variable name.
  final String name;

  final MathKeyboardStyle style;

  /// Called when the button is tapped.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return KeyboardButton(
      onTap: onTap,
      pressedOverlayColor: style.pressedOverlayColor,
      child: Math.tex(
        name,
        options: MathOptions(fontSize: style.baseFontSize + 2, color: style.keyTextColor),
      ),
    );
  }
}
