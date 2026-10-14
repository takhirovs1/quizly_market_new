import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';

/// A widget that renders text containing LaTeX math formulas.
///
/// - If the entire text is plain (no LaTeX) or only wrapped in `\text{...}`,
///   renders as a normal [Text] widget (supports wrapping).
/// - If the text contains mixed sentences with LaTeX formulas or `\text{...}`
///   blocks, parses into inline [TextSpan] and [WidgetSpan]s with [Text.rich]
///   so text wraps naturally without scaling down.
/// - If the text is a pure standalone formula, renders using [Math.tex]
///   wrapped in [FittedBox] to prevent horizontal overflow.
class LatexTextWidget extends StatelessWidget {
  const LatexTextWidget({
    required this.text,
    this.style,
    this.textColor,
    this.maxLines,
    this.overflow,
    this.textAlign,
    super.key,
  });

  final String text;
  final TextStyle? style;
  final Color? textColor;
  final int? maxLines;
  final TextOverflow? overflow;
  final TextAlign? textAlign;

  /// Checks if the text contains LaTeX markup that must be rendered with the
  /// math engine rather than shown as raw text.
  static bool _hasMathContent(String s) {
    if (s.isEmpty) return false;

    // Fill-in-the-blank underscores (e.g. "___", "________") are plain text, not math.
    final clean = s.replaceAll(RegExp('_{2,}'), ' ');

    // If all \text{...} blocks are stripped, does anything remain that has math?
    final withoutTextBlocks = clean.replaceAll(RegExp(r'\\text\{[^{}]*\}'), ' ').trim();
    if (withoutTextBlocks.isEmpty) {
      return false;
    }

    // TeX math commands other than \text (e.g. \frac, \sqrt, \sin, \alpha, \pm, etc.)
    if (RegExp(r'\\(?!text\b)[a-zA-Z]').hasMatch(clean)) return true;

    // Inline math delimiters: $...$ or $$...$$
    if (RegExp(r'\$[^\$]+\$').hasMatch(clean)) return true;

    // Superscript used for exponents (e.g. x^2, a^{n}, 180^\circ).
    if (RegExp(r'[A-Za-z0-9)}\]]\s*\^\s*(?:\{[^}]+\}|[0-9a-zA-Z+-])').hasMatch(clean)) return true;

    // Subscript used for indices (e.g. x_1, a_{ij}, H_2O).
    // Must be preceded by a variable/digit/bracket, followed by index or {...}.
    // Must NOT be surrounded by underscores (e.g. not fill-in-the-blank).
    if (RegExp(r'(?<!_)[A-Za-z0-9)}\]]\s*_\s*(?:\{[^}]+\}|[0-9a-zA-Z])(?!_)').hasMatch(clean)) {
      return true;
    }

    // If the string contains \text{...} AND there is something non-whitespace left
    // in withoutTextBlocks that looks like a formula (e.g. "= 2x + 1"):
    if (clean.contains(r'\text{') && RegExp(r'[=<>+\-*/]').hasMatch(withoutTextBlocks)) {
      return true;
    }

    return false;
  }

  /// Parses mixed text + LaTeX into inline spans so text wraps naturally
  /// across multiple lines instead of being scaled down into a single line.
  static List<InlineSpan>? _parseSpans(String text, TextStyle effectiveStyle, Color? effectiveColor) {
    final mathStyle = effectiveStyle.copyWith(color: effectiveColor);

    // 1. Strings with \text{...} blocks:
    // e.g. \text{Agar } f(x)=2x+1 \text{ bo'lsa, } f(3)=?
    final textBlockPattern = RegExp(r'\\text\{([^{}]*)\}');
    if (textBlockPattern.hasMatch(text)) {
      final spans = <InlineSpan>[];
      var lastIndex = 0;
      for (final match in textBlockPattern.allMatches(text)) {
        if (match.start > lastIndex) {
          final mathPart = text.substring(lastIndex, match.start).trim();
          if (mathPart.isNotEmpty) {
            spans.add(
              WidgetSpan(
                alignment: PlaceholderAlignment.middle,
                child: Math.tex(
                  mathPart,
                  textStyle: mathStyle,
                  mathStyle: MathStyle.text,
                  onErrorFallback: (_) => Text(mathPart, style: effectiveStyle),
                ),
              ),
            );
          }
        }
        final textPart = match.group(1) ?? '';
        if (textPart.isNotEmpty) {
          spans.add(TextSpan(text: textPart, style: effectiveStyle));
        }
        lastIndex = match.end;
      }
      if (lastIndex < text.length) {
        final mathPart = text.substring(lastIndex).trim();
        if (mathPart.isNotEmpty) {
          spans.add(
            WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: Math.tex(
                mathPart,
                textStyle: mathStyle,
                mathStyle: MathStyle.text,
                onErrorFallback: (_) => Text(mathPart, style: effectiveStyle),
              ),
            ),
          );
        }
      }
      return spans;
    }

    // 2. Strings with $...$ blocks:
    // e.g. Agar $f(x)=2x+1$ bo'lsa, $f(3)=?
    final dollarPattern = RegExp(r'\$([^\$]+)\$');
    if (dollarPattern.hasMatch(text)) {
      final spans = <InlineSpan>[];
      var lastIndex = 0;
      for (final match in dollarPattern.allMatches(text)) {
        if (match.start > lastIndex) {
          final textPart = text.substring(lastIndex, match.start);
          if (textPart.isNotEmpty) {
            spans.add(TextSpan(text: textPart, style: effectiveStyle));
          }
        }
        final mathPart = match.group(1)?.trim() ?? '';
        if (mathPart.isNotEmpty) {
          spans.add(
            WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: Math.tex(
                mathPart,
                textStyle: mathStyle,
                mathStyle: MathStyle.text,
                onErrorFallback: (_) => Text(mathPart, style: effectiveStyle),
              ),
            ),
          );
        }
        lastIndex = match.end;
      }
      if (lastIndex < text.length) {
        final textPart = text.substring(lastIndex);
        if (textPart.isNotEmpty) {
          spans.add(TextSpan(text: textPart, style: effectiveStyle));
        }
      }
      return spans;
    }

    // 3. Plain text question followed by a formula without delimiters:
    // e.g. "Quyidagi ifodani hisoblang: \frac{x^2 - 1}{x - 1}"
    final firstBackslash = text.indexOf(r'\');
    if (firstBackslash > 0) {
      final prefix = text.substring(0, firstBackslash);
      final mathPart = text.substring(firstBackslash).trim();
      if (prefix.trim().contains(' ') && RegExp('[a-zA-Z]').hasMatch(prefix)) {
        return [
          TextSpan(text: prefix, style: effectiveStyle),
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: Math.tex(
              mathPart,
              textStyle: mathStyle,
              mathStyle: MathStyle.text,
              onErrorFallback: (_) => Text(mathPart, style: effectiveStyle),
            ),
          ),
        ];
      }
    }

    return null;
  }

  /// Strips `\text{...}` wrappers from text for cleaner display.
  static String _stripTextWrappers(String s) =>
      s.replaceAllMapped(RegExp(r'\\text\{([^}]*)\}'), (m) => m.group(1) ?? '');

  @override
  Widget build(BuildContext context) {
    if (text.isEmpty) return const SizedBox.shrink();

    final effectiveStyle = style ?? DefaultTextStyle.of(context).style;
    final effectiveColor = textColor ?? effectiveStyle.color ?? Theme.of(context).textTheme.bodyLarge?.color;

    // If no real math content, render as plain Text (stripping any residual \text{...})
    if (!_hasMathContent(text)) {
      final plain = _stripTextWrappers(text);
      return Text(plain, style: effectiveStyle, maxLines: maxLines, overflow: overflow, textAlign: textAlign);
    }

    // Try parsing mixed text + math so sentences wrap across lines naturally
    final spans = _parseSpans(text, effectiveStyle, effectiveColor);
    if (spans != null && spans.isNotEmpty) {
      return Text.rich(
        TextSpan(style: effectiveStyle, children: spans),
        textAlign: textAlign,
        maxLines: maxLines,
        overflow: overflow,
      );
    }

    // Render standalone math formula, wrapped in FittedBox to prevent horizontal overflow
    final alignment = textAlign == TextAlign.center
        ? Alignment.center
        : (textAlign == TextAlign.end ? AlignmentDirectional.centerEnd : AlignmentDirectional.centerStart);
    return Align(
      alignment: alignment,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: alignment,
        child: Math.tex(
          text,
          textStyle: effectiveStyle.copyWith(color: effectiveColor),
          mathStyle: MathStyle.display,
          onErrorFallback: (error) => Text(
            _stripTextWrappers(text),
            style: effectiveStyle,
            maxLines: maxLines,
            overflow: overflow,
            textAlign: textAlign,
          ),
        ),
      ),
    );
  }
}
