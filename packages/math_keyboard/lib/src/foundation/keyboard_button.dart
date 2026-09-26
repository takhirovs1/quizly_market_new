import 'package:flutter/services.dart';
import 'package:math_keyboard/src/foundation/node.dart';

/// Class representing a button configuration.
abstract class KeyboardButtonConfig {
  /// Constructs a [KeyboardButtonConfig].
  const KeyboardButtonConfig({this.flex, this.keyboardCharacters = const []});

  /// Optional flex.
  final int? flex;

  /// The list of [KeyEvent.character] that should trigger this keyboard
  /// button on a physical keyboard.
  ///
  /// Note that the case of the characters is ignored.
  ///
  /// Special keyboard keys like backspace and arrow keys are specially handled
  /// and do *not* require this to be set.
  ///
  /// Must not be `null` but can be empty.
  final List<String> keyboardCharacters;
}

/// Class representing a button configuration for a [FunctionButton].
class BasicKeyboardButtonConfig extends KeyboardButtonConfig {
  /// Constructs a [KeyboardButtonConfig].
  const BasicKeyboardButtonConfig({
    required this.label,
    required this.value,
    this.args,
    this.asTex = false,
    this.highlighted = false,
    List<String> keyboardCharacters = const [],
    int? flex,
  }) : super(flex: flex, keyboardCharacters: keyboardCharacters);

  /// The label of the button.
  final String label;

  /// The value in tex.
  final String value;

  /// List defining the arguments for the function behind this button.
  final List<TeXArg>? args;

  /// Whether to display the label as TeX or as plain text.
  final bool asTex;

  /// The highlight level of this button.
  final bool highlighted;
}

/// Class representing a button configuration of the Delete Button.
class DeleteButtonConfig extends KeyboardButtonConfig {
  /// Constructs a [DeleteButtonConfig].
  DeleteButtonConfig({int? flex}) : super(flex: flex);
}

/// Class representing a button configuration of the Previous Button.
class PreviousButtonConfig extends KeyboardButtonConfig {
  /// Constructs a [DeleteButtonConfig].
  PreviousButtonConfig({int? flex}) : super(flex: flex);
}

/// Class representing a button configuration of the Next Button.
class NextButtonConfig extends KeyboardButtonConfig {
  /// Constructs a [DeleteButtonConfig].
  NextButtonConfig({int? flex}) : super(flex: flex);
}

/// Class representing a button configuration of the Submit Button.
class SubmitButtonConfig extends KeyboardButtonConfig {
  /// Constructs a [SubmitButtonConfig].
  SubmitButtonConfig({int? flex}) : super(flex: flex);
}

/// Class representing a button configuration of the Page Toggle Button.
class PageButtonConfig extends KeyboardButtonConfig {
  /// Constructs a [PageButtonConfig].
  const PageButtonConfig({int? flex}) : super(flex: flex);
}

/// List of keyboard button configs for the digits from 0-9.
///
/// List access from 0 to 9 will return the appropriate digit button.
final _digitButtons = [
  for (var i = 0; i < 10; i++) BasicKeyboardButtonConfig(label: '$i', value: '$i', keyboardCharacters: ['$i']),
];

const _decimalButton = BasicKeyboardButtonConfig(
  label: '.',
  value: '.',
  keyboardCharacters: ['.', ','],
  highlighted: true,
);

const _subtractButton = BasicKeyboardButtonConfig(label: '−', value: '-', keyboardCharacters: ['-'], highlighted: true);

/// Keyboard showing extended functionality.
final functionKeyboard = [
  [
    const BasicKeyboardButtonConfig(
      label: r'\frac{\Box}{\Box}',
      value: r'\frac',
      args: [TeXArg.braces, TeXArg.braces],
      asTex: true,
    ),
    const BasicKeyboardButtonConfig(label: r'\Box^2', value: '^2', args: [TeXArg.braces], asTex: true),
    const BasicKeyboardButtonConfig(
      label: r'\Box^{\Box}',
      value: '^',
      args: [TeXArg.braces],
      asTex: true,
      keyboardCharacters: [
        '^',
        // This is a workaround for keyboard layout that use ^ as a toggle key.
        // In that case, "Dead" is reported as the character (e.g. for German
        // keyboards).
        'Dead',
      ],
    ),
    const BasicKeyboardButtonConfig(label: r'\sin', value: r'\sin(', asTex: true, keyboardCharacters: ['s']),
    const BasicKeyboardButtonConfig(label: r'\sin^{-1}', value: r'\sin^{-1}(', asTex: true),
  ],
  [
    const BasicKeyboardButtonConfig(
      label: r'\sqrt{\Box}',
      value: r'\sqrt',
      args: [TeXArg.braces],
      asTex: true,
      keyboardCharacters: ['r'],
    ),
    const BasicKeyboardButtonConfig(
      label: r'\sqrt[\Box]{\Box}',
      value: r'\sqrt',
      args: [TeXArg.brackets, TeXArg.braces],
      asTex: true,
    ),
    const BasicKeyboardButtonConfig(label: r'\cos', value: r'\cos(', asTex: true, keyboardCharacters: ['c']),
    const BasicKeyboardButtonConfig(label: r'\cos^{-1}', value: r'\cos^{-1}(', asTex: true),
  ],
  [
    const BasicKeyboardButtonConfig(
      label: r'\log_{\Box}(\Box)',
      value: r'\log_',
      asTex: true,
      args: [TeXArg.braces, TeXArg.parentheses],
    ),
    const BasicKeyboardButtonConfig(label: r'\ln(\Box)', value: r'\ln(', asTex: true, keyboardCharacters: ['l']),
    const BasicKeyboardButtonConfig(label: r'\tan', value: r'\tan(', asTex: true, keyboardCharacters: ['t']),
    const BasicKeyboardButtonConfig(label: r'\tan^{-1}', value: r'\tan^{-1}(', asTex: true),
  ],
  [
    const PageButtonConfig(flex: 3),
    const BasicKeyboardButtonConfig(label: '(', value: '(', highlighted: true, keyboardCharacters: ['(']),
    const BasicKeyboardButtonConfig(label: ')', value: ')', highlighted: true, keyboardCharacters: [')']),
    PreviousButtonConfig(),
    NextButtonConfig(),
    DeleteButtonConfig(),
  ],
];

/// Standard keyboard for math expression input.
final standardKeyboard = [
  [
    _digitButtons[7],
    _digitButtons[8],
    _digitButtons[9],
    const BasicKeyboardButtonConfig(label: '×', value: r'\cdot', keyboardCharacters: ['*'], highlighted: true),
    const BasicKeyboardButtonConfig(
      label: '÷',
      value: r'\frac',
      keyboardCharacters: ['/'],
      args: [TeXArg.braces, TeXArg.braces],
      highlighted: true,
    ),
  ],
  [
    _digitButtons[4],
    _digitButtons[5],
    _digitButtons[6],
    const BasicKeyboardButtonConfig(label: '+', value: '+', keyboardCharacters: ['+'], highlighted: true),
    _subtractButton,
  ],
  [_digitButtons[1], _digitButtons[2], _digitButtons[3], _decimalButton, DeleteButtonConfig()],
  [const PageButtonConfig(), _digitButtons[0], PreviousButtonConfig(), NextButtonConfig(), SubmitButtonConfig()],
];

/// Keyboard getting shown for number input only.
final numberKeyboard = [
  [_digitButtons[7], _digitButtons[8], _digitButtons[9], _subtractButton],
  [_digitButtons[4], _digitButtons[5], _digitButtons[6], _decimalButton],
  [_digitButtons[1], _digitButtons[2], _digitButtons[3], DeleteButtonConfig()],
  [PreviousButtonConfig(), _digitButtons[0], NextButtonConfig(), SubmitButtonConfig()],
];

// ─── Symbols page (fork addition) ───────────────────────────────────────────

/// A named group of symbols shown on the scrollable "symbols" page.
class SymbolCategory {
  const SymbolCategory({required this.id, required this.titleFallback, required this.buttons});

  /// Stable id used to look up the localized title (see MathKeyboardSemantics).
  final String id;

  /// English fallback title.
  final String titleFallback;

  /// The symbol buttons in this category.
  final List<BasicKeyboardButtonConfig> buttons;
}

/// A leaf symbol button (label rendered as TeX, value inserted as a leaf).
BasicKeyboardButtonConfig _sym(String tex, {String? value}) =>
    BasicKeyboardButtonConfig(label: tex, value: value ?? tex, asTex: true);

/// A templated symbol button (inserts a function with placeholder args).
BasicKeyboardButtonConfig _tmpl(String label, String value, List<TeXArg> args) =>
    BasicKeyboardButtonConfig(label: label, value: value, args: args, asTex: true);

/// The 14-category, 250+ symbol set for the vertical scrollable symbols page.
/// Every value is a TeX token that `flutter_math_fork` can render.
final List<SymbolCategory> symbolCategories = [
  SymbolCategory(
    id: 'basic',
    titleFallback: 'Basic operations',
    buttons: [
      _sym('+'), _sym('-'), _sym(r'\times'), _sym(r'\div'), _sym('='), _sym(r'\pm'), _sym(r'\mp'), //
      _sym(r'\ast'),
      _sym(r'\cdot'),
      _sym(r'\circ'),
      _sym(r'\star'),
      _sym(r'\bullet'),
      _sym(r'\oplus'),
      _sym(r'\ominus'),
    ],
  ),
  SymbolCategory(
    id: 'powers',
    titleFallback: 'Powers, roots, fractions',
    buttons: [
      _tmpl(r'\Box^2', '^2', const [TeXArg.braces]),
      _tmpl(r'\Box^{\Box}', '^', const [TeXArg.braces]),
      _tmpl(r'\Box_{\Box}', '_', const [TeXArg.braces]),
      _tmpl(r'\sqrt{\Box}', r'\sqrt', const [TeXArg.braces]),
      _tmpl(r'\sqrt[\Box]{\Box}', r'\sqrt', const [TeXArg.brackets, TeXArg.braces]),
      _tmpl(r'\frac{\Box}{\Box}', r'\frac', const [TeXArg.braces, TeXArg.braces]),
      _sym(r'\frac{1}{2}'),
      _sym(r'\frac{1}{3}'),
      _sym(r'\frac{2}{3}'),
      _sym(r'\frac{1}{4}'),
      _sym(r'\frac{3}{4}'),
    ],
  ),
  SymbolCategory(
    id: 'brackets',
    titleFallback: 'Brackets',
    buttons: [
      _sym('('), _sym(')'), _sym('['), _sym(']'), _sym(r'\{', value: r'\{'), _sym(r'\}', value: r'\}'), //
      _sym(r'\langle'), _sym(r'\rangle'), _sym(r'|'), _sym(r'\|'),
      _sym(r'\lfloor'), _sym(r'\rfloor'), _sym(r'\lceil'), _sym(r'\rceil'),
    ],
  ),
  SymbolCategory(
    id: 'comparison',
    titleFallback: 'Comparison',
    buttons: [
      _sym('<'), _sym('>'), _sym(r'\leq'), _sym(r'\geq'), _sym(r'\neq'), _sym(r'\approx'), _sym(r'\cong'), //
      _sym(r'\equiv'), _sym(r'\propto'), _sym(r'\ll'), _sym(r'\gg'), _sym(r'\sim'), _sym(r'\simeq'), _sym(r'\doteq'),
    ],
  ),
  SymbolCategory(
    id: 'greekLower',
    titleFallback: 'Greek lowercase',
    buttons: [
      _sym(r'\alpha'), _sym(r'\beta'), _sym(r'\gamma'), _sym(r'\delta'), _sym(r'\epsilon'), _sym(r'\zeta'), //
      _sym(r'\eta'), _sym(r'\theta'), _sym(r'\iota'), _sym(r'\kappa'), _sym(r'\lambda'), _sym(r'\mu'), _sym(r'\nu'),
      _sym(r'\xi'), _sym(r'\pi'), _sym(r'\rho'), _sym(r'\sigma'), _sym(r'\tau'), _sym(r'\upsilon'), _sym(r'\phi'),
      _sym(r'\chi'), _sym(r'\psi'), _sym(r'\omega'), _sym(r'\varphi'), _sym(r'\vartheta'), _sym(r'\varpi'),
    ],
  ),
  SymbolCategory(
    id: 'greekUpper',
    titleFallback: 'Greek uppercase',
    buttons: [
      _sym(r'\Gamma'), _sym(r'\Delta'), _sym(r'\Theta'), _sym(r'\Lambda'), _sym(r'\Xi'), //
      _sym(r'\Pi'), _sym(r'\Sigma'), _sym(r'\Upsilon'), _sym(r'\Phi'), _sym(r'\Psi'), _sym(r'\Omega'),
    ],
  ),
  SymbolCategory(
    id: 'calculus',
    titleFallback: 'Calculus',
    buttons: [
      _tmpl(r'\int', r'\int', const []),
      _sym(r'\iint'), _sym(r'\iiint'), _sym(r'\oint'), _sym(r'\partial'), _sym(r'\nabla'), //
      _sym(r'\sum'), _sym(r'\prod'), _sym(r'\coprod'), _sym(r'\lim'), _sym(r'\infty'), _sym(r'\prime'), _sym('d'),
    ],
  ),
  SymbolCategory(
    id: 'sets',
    titleFallback: 'Sets',
    buttons: [
      _sym(r'\in'), _sym(r'\notin'), _sym(r'\ni'), _sym(r'\subset'), _sym(r'\supset'), _sym(r'\subseteq'), //
      _sym(r'\supseteq'), _sym(r'\cup'), _sym(r'\cap'), _sym(r'\setminus'), _sym(r'\emptyset'), _sym(r'\varnothing'),
      _sym(r'\mathbb{R}'), _sym(r'\mathbb{Z}'), _sym(r'\mathbb{Q}'), _sym(r'\mathbb{N}'), _sym(r'\mathbb{C}'),
    ],
  ),
  SymbolCategory(
    id: 'logic',
    titleFallback: 'Logic',
    buttons: [
      _sym(r'\forall'), _sym(r'\exists'), _sym(r'\nexists'), _sym(r'\wedge'), _sym(r'\vee'), _sym(r'\neg'), //
      _sym(r'\Rightarrow'), _sym(r'\Leftarrow'), _sym(r'\Leftrightarrow'), _sym(r'\to'), _sym(r'\leftrightarrow'),
      _sym(r'\vdash'), _sym(r'\models'), _sym(r'\therefore'), _sym(r'\because'), _sym(r'\top'), _sym(r'\bot'),
    ],
  ),
  SymbolCategory(
    id: 'arrows',
    titleFallback: 'Arrows',
    buttons: [
      _sym(r'\rightarrow'), _sym(r'\leftarrow'), _sym(r'\uparrow'), _sym(r'\downarrow'), _sym(r'\leftrightarrow'), //
      _sym(r'\updownarrow'), _sym(r'\Rightarrow'), _sym(r'\Leftarrow'), _sym(r'\Uparrow'), _sym(r'\Downarrow'),
      _sym(r'\Leftrightarrow'), _sym(r'\mapsto'), _sym(r'\hookrightarrow'), _sym(r'\longrightarrow'),
      _sym(r'\longleftarrow'), _sym(r'\longleftrightarrow'),
    ],
  ),
  SymbolCategory(
    id: 'geometry',
    titleFallback: 'Geometry',
    buttons: [
      _sym(r'\degree', value: r'^\circ'),
      _sym(r'\angle'),
      _sym(r'\measuredangle'),
      _sym(r'\perp'),
      _sym(r'\parallel'), //
      _sym(r'\nparallel'), _sym(r'\cong'), _sym(r'\sim'), _sym(r'\approx'), _sym(r'\triangle'), _sym(r'\square'),
      _sym(r'\bigcirc'), _sym(r'\bullet'), _sym(r'\odot'), _sym(r'\pi'),
    ],
  ),
  SymbolCategory(
    id: 'functions',
    titleFallback: 'Functions',
    buttons: [
      _sym(r'\sin', value: r'\sin('), _sym(r'\cos', value: r'\cos('), _sym(r'\tan', value: r'\tan('), //
      _sym(r'\cot', value: r'\cot('), _sym(r'\sec', value: r'\sec('), _sym(r'\csc', value: r'\csc('),
      _sym(r'\arcsin', value: r'\arcsin('), _sym(r'\arccos', value: r'\arccos('), _sym(r'\arctan', value: r'\arctan('),
      _sym(r'\sinh', value: r'\sinh('), _sym(r'\cosh', value: r'\cosh('), _sym(r'\tanh', value: r'\tanh('),
      _sym(r'\log', value: r'\log('), _sym(r'\ln', value: r'\ln('), _sym(r'\exp', value: r'\exp('),
      _sym(r'\gcd', value: r'\gcd('), _sym(r'\max', value: r'\max('), _sym(r'\min', value: r'\min('),
    ],
  ),
  SymbolCategory(
    id: 'special',
    titleFallback: 'Special symbols',
    buttons: [
      _sym('!'), _sym(r'\%', value: r'\%'), _sym(r'\ldots'), _sym(r'\cdots'), _sym(r'\vdots'), _sym(r'\ddots'), //
      _sym(r'\hbar'), _sym(r'\ell'), _sym(r'\Re'), _sym(r'\Im'), _sym(r'\wp'), _sym(r'\dagger'), _sym(r'\aleph'),
    ],
  ),
  SymbolCategory(
    id: 'accents',
    titleFallback: 'Accent marks',
    buttons: [
      _tmpl(r'\bar{\Box}', r'\bar', const [TeXArg.braces]),
      _tmpl(r'\hat{\Box}', r'\hat', const [TeXArg.braces]),
      _tmpl(r'\tilde{\Box}', r'\tilde', const [TeXArg.braces]),
      _tmpl(r'\dot{\Box}', r'\dot', const [TeXArg.braces]),
      _tmpl(r'\ddot{\Box}', r'\ddot', const [TeXArg.braces]),
      _tmpl(r'\vec{\Box}', r'\vec', const [TeXArg.braces]),
      _tmpl(r'\overline{\Box}', r'\overline', const [TeXArg.braces]),
    ],
  ),
];
