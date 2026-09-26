import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';

/// A widget that renders text containing LaTeX math formulas.
///
/// - If the entire text is wrapped in `\text{...}`, extracts the inner
///   content and renders it as a normal [Text] widget (supports wrapping).
/// - If the text contains real LaTeX math commands, renders using [Math.tex]
///   wrapped in [FittedBox] to prevent overflow.
/// - If the text is plain (no LaTeX), renders using a normal [Text] widget.
class LatexTextWidget extends StatelessWidget {
  const LatexTextWidget({required this.text, this.style, this.textColor, this.maxLines, this.overflow, super.key});

  final String text;
  final TextStyle? style;
  final Color? textColor;
  final int? maxLines;
  final TextOverflow? overflow;

  /// Matches strings that are entirely `\text{...}` with nothing else.
  static final _pureTextPattern = RegExp(r'^\\text\{([^{}]*)\}$', dotAll: true);

  /// Checks if the text contains LaTeX markup that must be rendered with the
  /// math engine rather than shown as raw text.
  ///
  /// Any TeX command (`\text`, `\frac`, `\sin`, `\circ`, …) or a super/sub
  /// script (`x^2`, `a_1`, `180^\circ`, `b^{n}`) means the string is LaTeX.
  /// The previous heuristic stripped `\text{...}` first and then found no math
  /// in the remainder, so mixed strings like
  /// `\text{Agar } f(x)=2x+1 \text{ bo'lsa, } f(3)=?` leaked through as raw
  /// text — this now treats them as math.
  static bool _hasMathContent(String s) {
    // A backslash followed by a letter is a TeX command.
    if (RegExp(r'\\[a-zA-Z]').hasMatch(s)) return true;
    // Superscript/subscript used for exponents or indices.
    if (RegExp(r'[A-Za-z0-9)}\]]\s*[\^_]').hasMatch(s)) return true;
    return false;
  }

  /// Extracts plain text from `\text{...}` wrapper.
  static String? _extractPureText(String s) {
    final trimmed = s.trim();
    final match = _pureTextPattern.firstMatch(trimmed);
    return match?.group(1);
  }

  @override
  Widget build(BuildContext context) {
    if (text.isEmpty) return const SizedBox.shrink();

    // If the entire string is just \text{...}, render as plain Text
    final pureText = _extractPureText(text);
    if (pureText != null) {
      return Text(pureText, style: style, maxLines: maxLines, overflow: overflow);
    }

    // If no real math content, render as plain Text
    if (!_hasMathContent(text)) {
      return Text(text, style: style, maxLines: maxLines, overflow: overflow);
    }

    // Render as LaTeX math, wrapped to prevent overflow
    final effectiveStyle = style ?? DefaultTextStyle.of(context).style;
    final effectiveColor = textColor ?? effectiveStyle.color ?? Theme.of(context).textTheme.bodyLarge?.color;

    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: AlignmentDirectional.centerStart,
        child: Math.tex(
          text,
          textStyle: effectiveStyle.copyWith(color: effectiveColor),
          mathStyle: MathStyle.display,
          onErrorFallback: (error) =>
              Text(_stripTextWrappers(text), style: style, maxLines: maxLines, overflow: overflow),
        ),
      ),
    );
  }

  /// Strips `\text{...}` wrappers from fallback text for cleaner display.
  static String _stripTextWrappers(String s) =>
      s.replaceAllMapped(RegExp(r'\\text\{([^}]*)\}'), (m) => m.group(1) ?? '');
}
