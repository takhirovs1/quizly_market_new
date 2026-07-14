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
  static final _pureTextPattern = RegExp(r'^\\text\{(.+)\}$', dotAll: true);

  /// Checks if the text contains real LaTeX math commands.
  static bool _hasMathContent(String s) {
    // Remove all \text{...} blocks first
    final stripped = s.replaceAll(RegExp(r'\\text\{[^}]*\}'), ' ');
    // Check for real math commands, operators, etc.
    return RegExp(
          r'\\(?:frac|sqrt|sin|cos|tan|log|int|sum|pi|approx|pm|cdot|dots|times|div|leq|geq|neq|infty|alpha|beta|gamma|delta|theta|lambda|sigma|omega|left|right)\b',
        ).hasMatch(stripped) ||
        // Superscript/subscript with actual math meaning (e.g., x^2, H_2O)
        RegExp(r'[a-zA-Z0-9]\^|[a-zA-Z0-9]_[a-zA-Z0-9{]').hasMatch(stripped) ||
        // Fractions and other structural commands
        RegExp(r'\\[a-zA-Z]+\{').hasMatch(stripped);
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
