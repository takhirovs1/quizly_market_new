import 'package:flutter/material.dart';

import '../extension/context_extension.dart';
import '../theme/text.dart';
import '../theme/theme.dart';

/// {@template app_text_field}
/// AppTextField widget.
/// {@endtemplate}
class AppTextField extends StatefulWidget {
  /// {@macro app_text_field}
  const AppTextField({
    required this.title,
    required this.controller,
    this.focusNode,
    this.autoFocus = false,
    this.readOnly = false,
    this.errorText,
    this.prefixWidget,
    this.suffixWidget,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.validator,
    this.onFieldSubmitted,
    this.onChanged,
    super.key, // ignore: unused_element
  });

  final String title;
  final FocusNode? focusNode;
  final TextEditingController controller;
  final bool autoFocus;
  final bool readOnly;
  final String? errorText;
  final Widget? suffixWidget;
  final Widget? prefixWidget;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final FormFieldValidator<String>? validator;
  final void Function(String value)? onChanged;
  final void Function(String value)? onFieldSubmitted;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

abstract class AppTextFieldController extends State<AppTextField> {
  late final ValueNotifier<bool> isFocused;
  late final FocusNode _focusNode;

  void focusListener() => isFocused.value = _focusNode.hasFocus;

  @override
  void initState() {
    super.initState();

    _focusNode = (widget.focusNode ?? FocusNode())..addListener(focusListener);
    isFocused = ValueNotifier(false);
  }

  @override
  void dispose() {
    _focusNode
      ..removeListener(focusListener)
      ..dispose();

    isFocused.dispose();
    super.dispose();
  }
}

class _AppTextFieldState extends AppTextFieldController {
  @override
  Widget build(BuildContext context) => TextFormField(
    readOnly: widget.readOnly,
    focusNode: _focusNode,
    autofocus: widget.autoFocus,
    cursorHeight: 18,
    controller: widget.controller,
    keyboardType: widget.keyboardType,
    textInputAction: widget.textInputAction,
    style: Theme.of(context).appTextStyles.sfW500s16,
    onFieldSubmitted: widget.onFieldSubmitted,
    textCapitalization: TextCapitalization.none,
    validator: widget.validator,
    onChanged: widget.onChanged,
    errorBuilder: (context, text) => const SizedBox.shrink(),
    decoration: InputDecoration(
      errorText: null,
      isDense: true,
      filled: true,
      fillColor: context.x.colors.textFieldBackground,
      border: OutlineInputBorder(
        borderSide: BorderSide(width: 0, color: context.x.colors.transparent),
        borderRadius: BorderRadius.circular(12),
      ),
      contentPadding: const EdgeInsets.all(16),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(width: 0, color: context.x.colors.transparent),
        borderRadius: BorderRadius.circular(12),
      ),
      disabledBorder: OutlineInputBorder(
        borderSide: BorderSide(width: 0, color: context.x.colors.transparent),
        borderRadius: BorderRadius.circular(12),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(width: 0, color: context.x.colors.transparent),
        borderRadius: BorderRadius.circular(12),
      ),
      prefixIconConstraints: widget.prefixWidget != null ? const BoxConstraints(minWidth: 48, minHeight: 56) : null,
      prefixIcon: widget.prefixWidget != null
          ? Row(mainAxisSize: MainAxisSize.min, children: [const SizedBox(width: 16), widget.prefixWidget!])
          : null,
      hint: AppText.w400s16(widget.title, color: context.x.colors.bannerSecondaryText),
      suffixIcon: widget.suffixWidget,
    ),
  );
}
