import 'package:flutter/material.dart';

/// Visual styling for the on-screen [MathKeyboard].
///
/// The forked keyboard is theme-driven (see the host app's
/// `AppMathKeyboardTheme`) instead of the hardcoded dark palette the upstream
/// package ships. Provide a style via [MathKeyboardTheme]; when none is found
/// the keyboard falls back to [MathKeyboardStyle.dark] so it still renders.
@immutable
class MathKeyboardStyle {
  const MathKeyboardStyle({
    required this.backgroundColor,
    required this.functionKeyColor,
    required this.neutralKeyColor,
    required this.utilityKeyColor,
    required this.primaryKeyColor,
    required this.keyTextColor,
    required this.primaryKeyTextColor,
    required this.variableRowColor,
    required this.pressedOverlayColor,
    this.keyHeight = 48,
    this.baseFontSize = 20,
    this.topBorderRadius = 20,
    this.rowSpacing = 6,
  });

  /// The original upstream dark palette — used as the fallback.
  factory MathKeyboardStyle.dark() => const MathKeyboardStyle(
    backgroundColor: Colors.black,
    functionKeyColor: Color(0xFF1A1A1A),
    neutralKeyColor: Color(0xFF212121),
    utilityKeyColor: Color(0xFF212121),
    primaryKeyColor: Color(0xFF2F80ED),
    keyTextColor: Colors.white,
    primaryKeyTextColor: Colors.white,
    variableRowColor: Color(0xFF121212),
    pressedOverlayColor: Colors.white,
  );

  /// Keyboard background.
  final Color backgroundColor;

  /// Digits (0-9) and math functions (frac, sqrt, sin, …).
  final Color functionKeyColor;

  /// Operators (+ − × ÷ =), brackets, navigation and variable keys.
  final Color neutralKeyColor;

  /// Delete and page-toggle (123 / fx) keys.
  final Color utilityKeyColor;

  /// Submit / return key.
  final Color primaryKeyColor;

  /// Label/icon color on function, neutral and utility keys.
  final Color keyTextColor;

  /// Label/icon color on the primary (submit) key.
  final Color primaryKeyTextColor;

  /// Background of the variable suggestion row.
  final Color variableRowColor;

  /// Overlay drawn over a key while pressed (blended by the button).
  final Color pressedOverlayColor;

  final double keyHeight;
  final double baseFontSize;
  final double topBorderRadius;
  final double rowSpacing;

  MathKeyboardStyle copyWith({
    Color? backgroundColor,
    Color? functionKeyColor,
    Color? neutralKeyColor,
    Color? utilityKeyColor,
    Color? primaryKeyColor,
    Color? keyTextColor,
    Color? primaryKeyTextColor,
    Color? variableRowColor,
    Color? pressedOverlayColor,
    double? keyHeight,
    double? baseFontSize,
    double? topBorderRadius,
    double? rowSpacing,
  }) => MathKeyboardStyle(
    backgroundColor: backgroundColor ?? this.backgroundColor,
    functionKeyColor: functionKeyColor ?? this.functionKeyColor,
    neutralKeyColor: neutralKeyColor ?? this.neutralKeyColor,
    utilityKeyColor: utilityKeyColor ?? this.utilityKeyColor,
    primaryKeyColor: primaryKeyColor ?? this.primaryKeyColor,
    keyTextColor: keyTextColor ?? this.keyTextColor,
    primaryKeyTextColor: primaryKeyTextColor ?? this.primaryKeyTextColor,
    variableRowColor: variableRowColor ?? this.variableRowColor,
    pressedOverlayColor: pressedOverlayColor ?? this.pressedOverlayColor,
    keyHeight: keyHeight ?? this.keyHeight,
    baseFontSize: baseFontSize ?? this.baseFontSize,
    topBorderRadius: topBorderRadius ?? this.topBorderRadius,
    rowSpacing: rowSpacing ?? this.rowSpacing,
  );
}

/// Localized labels + a11y semantics for the math keyboard.
///
/// Only the fields the fork needs are declared; the host app overrides
/// [categoryLabels] and the action labels via [copyWith].
@immutable
class MathKeyboardSemantics {
  const MathKeyboardSemantics({
    this.categoryLabels = const {},
    this.deleteLabel = 'Delete',
    this.submitLabel = 'Submit',
    this.previousLabel = 'Previous',
    this.nextLabel = 'Next',
    this.showNumbersKeyboardLabel = 'Numbers',
    this.showFunctionsKeyboardLabel = 'Functions',
    this.showSymbolsKeyboardLabel = 'Symbols',
  });

  /// English defaults.
  static const MathKeyboardSemantics fallback = MathKeyboardSemantics();

  /// Category id → localized title, for the symbols page.
  final Map<String, String> categoryLabels;
  final String deleteLabel;
  final String submitLabel;
  final String previousLabel;
  final String nextLabel;
  final String showNumbersKeyboardLabel;
  final String showFunctionsKeyboardLabel;
  final String showSymbolsKeyboardLabel;

  String categoryLabel(String id, String fallbackTitle) => categoryLabels[id] ?? fallbackTitle;

  MathKeyboardSemantics copyWith({
    Map<String, String>? categoryLabels,
    String? deleteLabel,
    String? submitLabel,
    String? previousLabel,
    String? nextLabel,
    String? showNumbersKeyboardLabel,
    String? showFunctionsKeyboardLabel,
    String? showSymbolsKeyboardLabel,
  }) => MathKeyboardSemantics(
    categoryLabels: categoryLabels ?? this.categoryLabels,
    deleteLabel: deleteLabel ?? this.deleteLabel,
    submitLabel: submitLabel ?? this.submitLabel,
    previousLabel: previousLabel ?? this.previousLabel,
    nextLabel: nextLabel ?? this.nextLabel,
    showNumbersKeyboardLabel: showNumbersKeyboardLabel ?? this.showNumbersKeyboardLabel,
    showFunctionsKeyboardLabel: showFunctionsKeyboardLabel ?? this.showFunctionsKeyboardLabel,
    showSymbolsKeyboardLabel: showSymbolsKeyboardLabel ?? this.showSymbolsKeyboardLabel,
  );
}

/// Inherited widget that provides [MathKeyboardStyle] and
/// [MathKeyboardSemantics] to the [MathField] below it.
///
/// The [MathField] captures these at keyboard-open time and forwards them to
/// the keyboard overlay (which lives in the root Overlay, outside this subtree).
class MathKeyboardTheme extends InheritedWidget {
  const MathKeyboardTheme({required this.style, required this.semantics, required super.child, super.key});

  final MathKeyboardStyle style;
  final MathKeyboardSemantics semantics;

  static MathKeyboardTheme? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<MathKeyboardTheme>();

  static MathKeyboardStyle styleOf(BuildContext context) => maybeOf(context)?.style ?? MathKeyboardStyle.dark();

  static MathKeyboardSemantics semanticsOf(BuildContext context) =>
      maybeOf(context)?.semantics ?? MathKeyboardSemantics.fallback;

  @override
  bool updateShouldNotify(MathKeyboardTheme oldWidget) => style != oldWidget.style || semantics != oldWidget.semantics;
}
