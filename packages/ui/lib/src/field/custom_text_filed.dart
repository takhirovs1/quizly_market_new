import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../extension/context_extension.dart';

class CustomTextFiled extends StatefulWidget {
  const CustomTextFiled({
    super.key,
    this.fillColor,
    this.borderColor,
    this.controller,
    this.focusNode,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.height,
    this.borderWidth = 1.3,
    this.borderRadius = const BorderRadius.all(Radius.circular(8)),
    this.style,
    this.validator,
    this.contentPadding,
    this.enabledBorderColor,
    this.focusColor,
    this.hintStyle,
    this.hintText,
    this.labelStyle,
    this.labelText,
    this.prefixIcon,
    this.suffixIcon,
    this.cursorColor,
    this.action,
    this.keyboardType,
    this.inputFormatters,
    this.textCapitalization = TextCapitalization.none,
    this.maxLines = 1,
    this.minLines = 1,
  });
  final TextEditingController? controller;
  final void Function(String value)? onChanged;
  final void Function(String value)? onSubmitted;
  final VoidCallback? onTap;
  final FocusNode? focusNode;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final Color? fillColor;
  final Color? borderColor;
  final double? height;
  final double borderWidth;
  final BorderRadius borderRadius;
  final String? Function(String?)? validator;
  final TextStyle? style;
  final EdgeInsetsGeometry? contentPadding;
  final Color? focusColor;
  final Color? enabledBorderColor;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final String? hintText;
  final TextStyle? hintStyle;
  final String? labelText;
  final TextStyle? labelStyle;
  final Color? cursorColor;
  final Widget? action;
  final TextCapitalization textCapitalization;
  final int maxLines;
  final int minLines;

  @override
  State<CustomTextFiled> createState() => _CustomTextFiledState();
}

class _CustomTextFiledState extends State<CustomTextFiled> {
  ValueNotifier<bool> isFocused = ValueNotifier(false);
  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: SizedBox(
          height: widget.height,
          child: ValueListenableBuilder(
            valueListenable: isFocused,
            builder: (context, value, child) => TextFormField(
              textCapitalization: widget.textCapitalization,
              controller: widget.controller,
              onChanged: widget.onChanged,
              onTap: widget.onTap,
              onFieldSubmitted: widget.onSubmitted,
              focusNode: widget.focusNode,
              validator: widget.validator,
              keyboardType: widget.keyboardType,
              inputFormatters: widget.inputFormatters,
              style: widget.style ?? context.x.textStyle.sfW400s16,
              cursorColor: widget.cursorColor ?? context.x.colors.primary,
              maxLines: widget.maxLines,
              minLines: widget.minLines,
              decoration: InputDecoration(
                filled: true,
                fillColor: widget.fillColor ?? context.x.colors.cardBackground,
                contentPadding: widget.contentPadding,
                hoverColor: context.x.colors.transparent,
                suffixIcon: widget.suffixIcon,
                prefixIcon: widget.prefixIcon,
                hintText: widget.hintText,
                hintStyle: widget.hintStyle ?? context.x.textStyle.sfW400s16,
                labelText: widget.labelText,
                labelStyle: widget.labelStyle ?? context.x.textStyle.sfW400s16,
                border: _getBorder(context),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: widget.borderColor ?? context.x.colors.primary,
                    width: widget.borderWidth,
                  ),
                  borderRadius: widget.borderRadius,
                ),
                enabledBorder: _getBorder(context),
              ),
            ),
          ),
        ),
      ),
      if (widget.action != null) ...[widget.action!],
    ],
  );

  OutlineInputBorder _getBorder(BuildContext context) => OutlineInputBorder(
    borderSide: BorderSide(color: widget.enabledBorderColor ?? context.x.colors.transparent, width: widget.borderWidth),
    borderRadius: widget.borderRadius,
  );
}
