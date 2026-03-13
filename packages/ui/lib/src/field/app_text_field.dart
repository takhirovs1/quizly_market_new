import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../border/smooth_rectangle_border.dart';
import '../extension/context_extension.dart';
import '../focus/disable_focus.dart';
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

  Color labelColor(bool? value) => switch (value) {
    _ when widget.errorText != null => Theme.of(context).appColors.error,
    true => Theme.of(context).appColors.primary,
    _ => Theme.of(context).appColors.gray,
  };

  Color borderColor(bool? value) => switch (value) {
    _ when widget.errorText != null => Theme.of(context).appColors.error,
    true => Theme.of(context).appColors.primary,
    _ => Theme.of(context).appColors.transparent,
  };

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
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      ValueListenableBuilder(
        valueListenable: isFocused,
        builder: (context, value, child) => DecoratedBox(
          decoration: ShapeDecoration(
            color: context.x.colors.bannerBackground,
            shape: SmoothRectangleBorders(
              borderRadius: BorderRadius.circular(16),
              smoothness: 1,
              side: BorderSide(width: 1.5, color: borderColor(value)),
            ),
          ),
          child: Row(
            children: [
              Expanded(child: child ?? const SizedBox.shrink()),
              ?widget.suffixWidget,
            ],
          ),
        ),
        child: SizedBox(
          height: 54,
          child: CupertinoButton(
            onPressed: widget.readOnly ? null : _focusNode.requestFocus,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            focusColor: Colors.transparent,
            focusNode: AlwaysDisabledFocusNode(),
            child: RepaintBoundary(
              child: TextFormField(
                readOnly: widget.readOnly,
                focusNode: _focusNode,
                autofocus: widget.autoFocus,
                cursorHeight: 18,
                controller: widget.controller,
                keyboardType: widget.keyboardType,
                textInputAction: widget.textInputAction,
                style: Theme.of(context).appTextStyles.w500s16,
                onFieldSubmitted: widget.onFieldSubmitted,
                textCapitalization: TextCapitalization.none,
                validator: widget.validator,
                onChanged: widget.onChanged,
                errorBuilder: (context, text) => const SizedBox.shrink(),
                decoration: InputDecoration(
                  errorText: null,
                  isDense: true,
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                  focusedBorder: InputBorder.none,
                  prefixIconConstraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  prefixIcon: widget.prefixWidget,
                  label: ValueListenableBuilder(
                    valueListenable: isFocused,
                    builder: (context, value, child) => AppText.w500s16(widget.title, color: labelColor(value)),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),

      if (widget.errorText != null) ...[
        const SizedBox(height: 4),
        Text(
          widget.errorText ?? '',
          style: Theme.of(context).appTextStyles.w400s10.copyWith(color: Theme.of(context).appColors.error),
        ),
      ],
    ],
  );
}
