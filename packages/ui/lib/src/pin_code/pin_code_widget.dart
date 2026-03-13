import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// {@template pin_code}
/// PinCode widget.
/// {@endtemplate}
class PinCode extends StatefulWidget {
  /// {@macro pin_code}
  const PinCode({
    required this.controller,
    required this.focusNode,
    this.length = 5,
    this.enabled = true,
    this.textStyle,
    this.onChanged,
    this.onEditingComplete,
    this.onSubmitted,
    super.key,
  });

  /// Length of the pin code.
  final int length;
  final bool enabled;
  final FocusNode focusNode;
  final TextEditingController controller;
  final TextStyle? textStyle;
  final void Function(String value)? onChanged;
  final void Function()? onEditingComplete;
  final void Function(String value)? onSubmitted;

  @override
  State<PinCode> createState() => _PinCodeState();
}

/// State for widget PinCode.
class _PinCodeState extends State<PinCode> {
  late final FocusNode _internalFocus;
  late TextEditingController _controller;
  late _PinPainter _painter;

  static Widget? _doNotBuildCounter(
    BuildContext context, {
    required int currentLength,
    required int? maxLength,
    required bool isFocused,
  }) => null;

  /* #region Lifecycle */
  @override
  void initState() {
    super.initState();
    _internalFocus = widget.focusNode;

    _controller = widget.controller..addListener(_onValueChanged);
    _painter = _PinPainter(
      controller: _controller,
      length: widget.length,
      focusNode: _internalFocus,
      textPainter: TextPainter(textDirection: TextDirection.ltr, textScaler: TextScaler.noScaling, maxLines: 1),
      textStyle:
          widget.textStyle?.copyWith(height: 1) ??
          const TextStyle(
            height: 1,
            fontSize: 24,
            color: Colors.black,
            fontWeight: FontWeight.w600,
            fontFamily: 'OpenSans',
            package: 'ui',
          ),
    );
  }

  @override
  void didUpdateWidget(covariant PinCode oldWidget) {
    super.didUpdateWidget(oldWidget);
    _controller = widget.controller;
    if (!identical(widget.controller, _controller)) {
      _controller.removeListener(_onValueChanged);
      _controller = widget.controller;
      _painter = _painter.copyWith(controller: _controller);
    }
    if (!identical(widget.textStyle, oldWidget.textStyle)) {
      _painter = _painter.copyWith(
        textStyle:
            widget.textStyle?.copyWith(height: 1) ??
            const TextStyle(
              height: 1,
              fontSize: 24,
              color: Colors.black,
              fontWeight: FontWeight.w600,
              fontFamily: 'OpenSans',
              package: 'ui',
            ),
      );
    }
  }

  @override
  void dispose() {
    super.dispose();
    _controller.removeListener(_onValueChanged);
  }
  /* #endregion */

  void _onValueChanged() {
    if (_controller.text.length > widget.length) {
      _controller
        ..text = _controller.text.substring(0, widget.length)
        ..selection = TextSelection.fromPosition(TextPosition(offset: _controller.text.length));
    }
  }

  void _showMenu(BuildContext context, Offset position) {
    final localizations = MaterialLocalizations.of(context);
    final messenger = ScaffoldMessenger.maybeOf(context);
    showMenu<String>(
      context: context,
      positionBuilder: (context, constraints) => RelativeRect.fromLTRB(
        position.dx,
        position.dy,
        position.dx + constraints.biggest.width,
        position.dy + constraints.biggest.height,
      ),
      items: <PopupMenuEntry<String>>[
        PopupMenuItem<String>(
          value: 'paste',
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            spacing: 8,
            children: <Widget>[const Icon(Icons.paste, size: 20), Text(localizations.pasteButtonLabel)],
          ),
        ),
        if (_controller.text.isNotEmpty)
          PopupMenuItem<String>(
            value: 'clear',
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              spacing: 8,
              children: <Widget>[const Icon(Icons.clear, size: 20), Text(localizations.clearButtonTooltip)],
            ),
          ),
      ],
    ).then((value) async {
      switch (value) {
        case 'paste':
          final data = await Clipboard.getData(Clipboard.kTextPlain);
          final text = data?.text?.trim();
          if (text == null) {
            messenger
              ?..clearSnackBars()
              ..showSnackBar(const SnackBar(content: Text('Clipboard is empty'), duration: Duration(seconds: 5)));
            return;
          }
          final numbers = int.tryParse(text);
          if (numbers == null || text.length != widget.length) {
            messenger
              ?..clearSnackBars()
              ..showSnackBar(
                SnackBar(
                  content: Text('Must contain only ${widget.length} numbers'),
                  duration: const Duration(seconds: 5),
                ),
              );
            return;
          }
          _controller.text = text;
          break;
        case 'clear':
          _controller.clear();
        default:
          // Handle other cases if needed
          break;
      }
      if (value == 'paste') {
        await Clipboard.getData(Clipboard.kTextPlain).then<void>((clipboardData) {
          if (clipboardData?.text != null) {
            _controller.text = clipboardData!.text!;
            _onValueChanged();
          }
        });
      }
    }).ignore();
  }

  DateTime? _lastLongPressTime;

  @override
  Widget build(BuildContext context) => Center(
    child: SizedBox(
      height: 58,
      width: 338,
      child: Builder(
        builder: (context) => Stack(
          alignment: Alignment.center,
          fit: StackFit.expand,
          children: <Widget>[
            Positioned.fill(
              child: AbsorbPointer(
                absorbing: true, // it prevents on tap on the text field
                child: TextField(
                  enabled: widget.enabled,
                  canRequestFocus: true,
                  focusNode: _internalFocus,
                  controller: widget.controller,
                  cursorColor: Colors.transparent,
                  style: const TextStyle(fontSize: 10, height: 1, color: Colors.transparent),
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  enableInteractiveSelection: false,
                  showCursor: false,
                  cursorWidth: 1,
                  minLines: 1,
                  maxLines: 1,
                  autocorrect: false,
                  selectionControls: EmptyTextSelectionControls(),
                  selectionHeightStyle: BoxHeightStyle.tight,
                  selectionWidthStyle: BoxWidthStyle.tight,
                  textInputAction: TextInputAction.done,
                  maxLength: widget.length,
                  maxLengthEnforcement: MaxLengthEnforcement.enforced,
                  textDirection: TextDirection.ltr,
                  onChanged: widget.onChanged,
                  onEditingComplete: widget.onEditingComplete,
                  onSubmitted: widget.onSubmitted,
                  decoration: const InputDecoration(
                    constraints: BoxConstraints(maxWidth: 338, maxHeight: 48),
                    filled: false,
                    fillColor: Colors.transparent,
                    maintainHintSize: false,
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    errorBorder: InputBorder.none,
                    focusedErrorBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                  ),
                  buildCounter: _doNotBuildCounter,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.singleLineFormatter,
                    LengthLimitingTextInputFormatter(widget.length),
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                ),
              ),
            ),
            Positioned.fill(
              child: FocusScope(
                canRequestFocus: false,
                child: GestureDetector(
                  onTapDown: (details) {
                    _lastLongPressTime = DateTime.now();
                    if (!_internalFocus.hasFocus) {
                      _internalFocus.requestFocus();
                    } else {
                      _internalFocus.unfocus();
                    }
                  },
                  onTapUp: (details) {
                    final now = DateTime.now();
                    if (_lastLongPressTime case DateTime dt when now.difference(dt).inMilliseconds > 250) {
                      // If the long press was detected, show the context menu
                      _showMenu(context, details.globalPosition);
                    } else if (context.findRenderObject() case RenderBox box) {
                      // Try to focus specific box when tapped
                      final constraints = box.constraints;
                      final boxWidth = constraints.maxWidth / widget.length;
                      // Calculate the index of the box that was tapped
                      final index = (details.localPosition.dx / boxWidth).floor();
                      // Set the cursor position to the tapped box index
                      _controller.selection = TextSelection.fromPosition(
                        /* TextPosition(offset: index.clamp(0, _controller.text.length - 1)), */
                        TextPosition(
                          offset: index.clamp(0, math.max(0, math.min(widget.length - 1, _controller.text.length))),
                        ),
                      );
                      // Request focus when the user taps on the pin code area
                      if (!_internalFocus.hasFocus) _internalFocus.requestFocus();
                    }
                    _lastLongPressTime = null;
                  },
                  onSecondaryTapDown: (details) => _showMenu(context, details.globalPosition),
                  child: CustomPaint(isComplex: false, willChange: false, painter: _painter),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _PinPainter extends CustomPainter {
  _PinPainter({
    required this.controller,
    required this.focusNode,
    required this.length,
    required this.textPainter,
    required this.textStyle,
  }) : super(repaint: controller);

  final TextEditingController controller;
  final FocusNode focusNode;
  final int length;
  final TextPainter textPainter;
  final TextStyle textStyle;

  final Paint _unfocusedBoxPaint = Paint()
    ..color = Colors.grey
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.3
    ..isAntiAlias = true
    ..blendMode = BlendMode.src;
  final Paint _focusedBoxPaint = Paint()
    ..color = const Color(0xFF1C60E8)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.5
    ..isAntiAlias = true
    ..blendMode = BlendMode.src;
  final Paint _cursorPaint = Paint()
    ..color = const Color(0xFF1C60E8)
    ..strokeWidth = 2.0
    ..isAntiAlias = true
    ..blendMode = BlendMode.srcOver;

  _PinPainter copyWith({
    TextEditingController? controller,
    FocusNode? focusNode,
    TextPainter? textPainter,
    TextStyle? textStyle,
    int? length,
  }) => _PinPainter(
    controller: controller ?? this.controller,
    focusNode: focusNode ?? this.focusNode,
    textPainter: textPainter ?? this.textPainter,
    textStyle: textStyle ?? this.textStyle,
    length: length ?? this.length,
  );

  @override
  void paint(Canvas canvas, Size size) {
    final textLength = controller.text.length;
    final hasFocus = focusNode.hasFocus;
    const numBoxPadding = 4.0;
    final numBoxSize = Size(size.width / length - numBoxPadding * 2, size.height);
    // canvas.drawColor(Colors.white, BlendMode.srcIn);
    for (var i = 0; i < length; i++) {
      final x = (size.width / length) * i;

      final hasChar = i < textLength;
      final focused = hasFocus && i == controller.selection.end;

      final rect = Offset(x + numBoxPadding, 0) & numBoxSize;
      canvas.drawRRect(
        hasChar || focused
            ? RRect.fromRectAndRadius(rect, const Radius.circular(16))
            : RRect.fromRectAndRadius(rect.deflate(4), const Radius.circular(16)),
        hasFocus ? _focusedBoxPaint : _unfocusedBoxPaint,
      );

      // Draw the cursor line if the field has focus and the index is at the end of the text
      if (focused && !hasChar) {
        final centerX = x + (size.width / length) / 2;
        canvas.drawLine(Offset(centerX, 12), Offset(centerX, size.height - 12), _cursorPaint);
      }

      if (!hasChar) continue; // If there is no character at this index, skip drawing

      // Draw the character in the box
      textPainter
        ..text = TextSpan(
          text: controller.text[i],
          style: focused
              ? textStyle.copyWith(color: textStyle.color?.withValues(alpha: .45) ?? Colors.black45)
              : textStyle,
        )
        ..layout(maxWidth: size.width / length)
        ..paint(
          canvas,
          Offset(x + (size.width / length - textPainter.width) / 2, (size.height - textPainter.height) / 2),
        );
    }
  }

  @override
  bool shouldRepaint(_PinPainter oldDelegate) =>
      !identical(oldDelegate.controller, controller) ||
      !identical(oldDelegate.focusNode, focusNode) ||
      !identical(oldDelegate.textPainter, textPainter) ||
      !identical(oldDelegate.textStyle, textStyle);

  @override
  bool shouldRebuildSemantics(_PinPainter oldDelegate) => false;
}
