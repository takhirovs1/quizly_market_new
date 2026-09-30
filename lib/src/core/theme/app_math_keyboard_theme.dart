import 'package:flutter/material.dart';
import 'package:math_keyboard/math_keyboard.dart';

import '../../common/extension/context_extension.dart';

/// Builds a [MathKeyboardStyle] and localized [MathKeyboardSemantics] from the
/// app's design tokens, so the in-app math keyboard follows the light/dark
/// theme instead of the fork's hardcoded dark palette.
///
/// See docs/math_native_keyboard_flow.md §10–11.
abstract final class AppMathKeyboardTheme {
  static MathKeyboardStyle styleOf(BuildContext context) {
    final colors = context.x.colors;
    final isDark = context.x.isDarkMode;

    return MathKeyboardStyle(
      backgroundColor: isDark ? colors.cardBackground2 : colors.surface,
      functionKeyColor: isDark ? colors.scaffoldBackground : colors.white,
      neutralKeyColor: colors.textFieldBackground,
      utilityKeyColor: isDark ? colors.textFieldBackground : colors.divider,
      primaryKeyColor: colors.primary,
      keyTextColor: colors.text,
      primaryKeyTextColor: colors.onPrimary,
      variableRowColor: isDark ? colors.scaffoldBackground : colors.textFieldBackground,
      // A subtle brand tint on press reads well on both light and dark keys.
      pressedOverlayColor: colors.primary,
    );
  }

  static MathKeyboardSemantics semanticsOf(BuildContext context) {
    final l10n = context.x.l10n;
    return MathKeyboardSemantics.fallback.copyWith(
      categoryLabels: {
        'basic': l10n.mathCatBasic,
        'powers': l10n.mathCatPowers,
        'brackets': l10n.mathCatBrackets,
        'comparison': l10n.mathCatComparison,
        'greekLower': l10n.mathCatGreekLower,
        'greekUpper': l10n.mathCatGreekUpper,
        'calculus': l10n.mathCatCalculus,
        'sets': l10n.mathCatSets,
        'logic': l10n.mathCatLogic,
        'arrows': l10n.mathCatArrows,
        'geometry': l10n.mathCatGeometry,
        'functions': l10n.mathCatFunctions,
        'special': l10n.mathCatSpecial,
        'accents': l10n.mathCatAccents,
      },
    );
  }

  /// Wraps [child] in a [MathKeyboardTheme] carrying the app style + semantics.
  static Widget wrap(BuildContext context, {required Widget child}) =>
      MathKeyboardTheme(style: styleOf(context), semantics: semanticsOf(context), child: child);
}
