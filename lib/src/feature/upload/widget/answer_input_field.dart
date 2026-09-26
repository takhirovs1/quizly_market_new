import 'package:flutter/material.dart';
import 'package:math_keyboard/math_keyboard.dart';

import '../../../common/extension/context_extension.dart';
import '../../../core/theme/app_math_keyboard_theme.dart';
import 'keyboard_mode_swap_button.dart';

/// A single input that can be edited with the native keyboard (plain text) or
/// the in-app math keyboard (TeX), swapping between the two via an embedded
/// [KeyboardModeSwapButton].
///
/// This is a faithful port of the native↔math swap flow described in
/// docs/math_native_keyboard_flow.md §5–6:
///  * both controllers are cleared on swap,
///  * focus moves to the new field on the next frame,
///  * the keyboard does not open while [interactionEnabled] is false.
///
/// If [mathController]/[isMathMode] are null the field degrades to a plain text
/// field (graceful degrade).
class AnswerInputField extends StatefulWidget {
  const AnswerInputField({
    required this.nativeController,
    required this.onChanged,
    required this.hintText,
    this.mathController,
    this.isMathMode,
    this.isNumeric = false,
    this.interactionEnabled = true,
    this.showWrongFeedback = false,
    this.showSwapButton = true,
    this.onFocusChanged,
    this.borderRadius = 14,
    this.leading,
    super.key,
  });

  final TextEditingController nativeController;
  final MathFieldEditingController? mathController;
  final ValueNotifier<bool>? isMathMode;

  /// Emits the native text OR the TeX value, depending on the active mode.
  final ValueChanged<String> onChanged;
  final String hintText;
  final bool isNumeric;

  /// Disable input while a submit/check is in flight; keyboard won't open.
  final bool interactionEnabled;

  /// Render a red border to flag an invalid field.
  final bool showWrongFeedback;
  final bool showSwapButton;
  final ValueChanged<bool>? onFocusChanged;
  final double borderRadius;

  /// Optional leading widget (e.g. correct-answer toggle) rendered on the left.
  final Widget? leading;

  @override
  State<AnswerInputField> createState() => _AnswerInputFieldState();
}

class _AnswerInputFieldState extends State<AnswerInputField> {
  late final FocusNode _nativeFocus;
  late final FocusNode _mathFocus;
  late final ScrollController _nativeScrollController;

  bool get _mathEnabled => widget.mathController != null && widget.isMathMode != null;
  bool get _isFocused => _nativeFocus.hasFocus || _mathFocus.hasFocus;

  bool get _hasContent {
    final native = widget.nativeController.text.trim();
    final math = widget.mathController?.currentEditingValue(placeholderWhenEmpty: false).trim() ?? '';
    return native.isNotEmpty || math.isNotEmpty;
  }

  String get _mathValue => widget.mathController?.currentEditingValue(placeholderWhenEmpty: false) ?? '';

  @override
  void initState() {
    super.initState();
    _nativeFocus = FocusNode();
    _mathFocus = FocusNode();
    _nativeScrollController = ScrollController();
    _nativeFocus.addListener(_handleFocusChanged);
    _mathFocus.addListener(_handleFocusChanged);
  }

  @override
  void dispose() {
    _nativeFocus.removeListener(_handleFocusChanged);
    _mathFocus.removeListener(_handleFocusChanged);
    _nativeFocus.dispose();
    _mathFocus.dispose();
    _nativeScrollController.dispose();
    super.dispose();
  }

  void _handleFocusChanged() {
    if (!mounted) return;
    setState(() {});
    widget.onFocusChanged?.call(_isFocused);
  }

  // ── Swap logic (md §6) ────────────────────────────────────────────────────

  void _setMode(bool toMath) {
    final notifier = widget.isMathMode;
    if (notifier == null || notifier.value == toMath) return; // 1. guard

    // 2. clear BOTH controllers (project requirement).
    widget.nativeController.clear();
    widget.mathController?.clear();
    widget.onChanged('');

    // 3. flip mode → rebuilds the field.
    notifier.value = toMath;

    // 4. unfocus the old field.
    if (toMath) {
      _nativeFocus.unfocus();
    } else {
      _mathFocus.unfocus();
    }

    // 5. focus the new field on the next frame (it only exists post-rebuild).
    if (widget.interactionEnabled) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        (toMath ? _mathFocus : _nativeFocus).requestFocus();
      });
    }
  }

  void _clearText() {
    widget.nativeController.clear();
    widget.mathController?.clear();
    widget.onChanged('');
    if (mounted) setState(() {});
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    if (!_mathEnabled) {
      return _decorated(context, isMath: false, child: _buildNativeField(context));
    }
    return ValueListenableBuilder<bool>(
      valueListenable: widget.isMathMode!,
      builder: (context, isMath, _) =>
          _decorated(context, isMath: isMath, child: isMath ? _buildMathField(context) : _buildNativeField(context)),
    );
  }

  Widget _decorated(BuildContext context, {required bool isMath, required Widget child}) {
    final colors = context.x.colors;
    final borderColor = widget.showWrongFeedback
        ? colors.error
        : _isFocused
        ? colors.primary
        : colors.divider;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      constraints: BoxConstraints(minHeight: _isFocused ? 84 : 50),
      decoration: BoxDecoration(
        color: colors.textFieldBackground,
        borderRadius: BorderRadius.circular(widget.borderRadius),
        border: Border.all(color: borderColor, width: _isFocused || widget.showWrongFeedback ? 1.5 : 1),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        crossAxisAlignment: _isFocused ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          if (widget.leading != null) ...[widget.leading!, const SizedBox(width: 8)],
          Expanded(child: child),
          if (widget.showSwapButton && _mathEnabled) ...[
            const SizedBox(width: 8),
            Padding(
              padding: EdgeInsets.only(top: _isFocused ? 2 : 0),
              child: KeyboardModeSwapButton(
                isMath: isMath,
                enabled: widget.interactionEnabled,
                showClear: _hasContent,
                onChanged: _setMode,
                onClear: _clearText,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNativeField(BuildContext context) {
    final colors = context.x.colors;
    final textStyle = context.x.textStyle;
    return TextField(
      controller: widget.nativeController,
      focusNode: _nativeFocus,
      scrollController: _nativeScrollController,
      keyboardType: widget.isNumeric ? TextInputType.number : TextInputType.multiline,
      textInputAction: widget.isNumeric ? TextInputAction.done : TextInputAction.newline,
      minLines: widget.isNumeric ? 1 : (_isFocused ? 3 : 1),
      maxLines: 5,
      enableSuggestions: false,
      autocorrect: false,
      readOnly: !widget.interactionEnabled,
      style: textStyle.sfW400s16.copyWith(color: colors.text),
      cursorColor: colors.primary,
      onChanged: widget.interactionEnabled ? widget.onChanged : null,
      decoration: InputDecoration(
        isDense: true,
        border: InputBorder.none,
        hintText: widget.hintText,
        hintStyle: textStyle.sfW400s16.copyWith(color: colors.bannerSecondaryText),
        contentPadding: EdgeInsets.zero,
      ),
    );
  }

  Widget _buildMathField(BuildContext context) {
    final colors = context.x.colors;
    // Wrapped in MathKeyboardTheme (via AppMathKeyboardTheme) so the on-screen
    // keyboard follows the design tokens (light/dark). MathField renders the
    // inline expression here; the keyboard overlay reads the captured theme.
    return AppMathKeyboardTheme.wrap(
      context,
      child: MathField(
        controller: widget.mathController!,
        focusNode: _mathFocus,
        keyboardType: widget.isNumeric ? MathKeyboardType.numberOnly : MathKeyboardType.expression,
        variables: _mathVariables,
        opensKeyboard: widget.interactionEnabled,
        onChanged: (_) => widget.onChanged(_mathValue),
        onSubmitted: (_) => widget.onChanged(_mathValue),
        decoration: InputDecoration(
          isDense: true,
          border: InputBorder.none,
          hintText: widget.hintText,
          hintStyle: context.x.textStyle.sfW400s16.copyWith(color: colors.bannerSecondaryText),
          contentPadding: EdgeInsets.zero,
        ),
      ),
    );
  }

  /// Variables offered on the math keyboard's top row. MathField always
  /// prepends π and e — do not repeat `e` here.
  static const List<String> _mathVariables = [
    'x', 'y', 'z', 'a', 'b', 'c', 'd', 'f', 'g', 'h', 'i', 'j', //
    'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w',
  ];
}
