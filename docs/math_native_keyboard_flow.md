# Math Keyboard + Native Keyboard — To'liq Flow va Integratsiya Hujjati

> Bu hujjat `ai_bek_mobile` loyihasidagi **matn (native) klaviatura ↔ formula (math) klaviatura** almashinuvi (swap) mexanizmini boshqa loyihaga ko'chirish uchun yozilgan. Barcha komponentlar, holatlar (state), swap case'lari, va math klaviaturaning **barcha** xususiyatlari (kategoriyalar, tugmalar, layout, tema, semantics) to'liq keltirilgan.

---

## 1. Umumiy tavsif

Foydalanuvchi javob maydoniga ikki xil kirish usulidan birini tanlaydi:

| Rejim | Controller | Qiymat turi | Klaviatura |
|---|---|---|---|
| **Text (native)** | `TextEditingController` | oddiy `String` | qurilma native klaviaturasi |
| **Formula (math)** | `MathFieldEditingController` | **TeX** `String` | ilova ichidagi on-screen math klaviatura |

Ikki rejim **mustaqil qiymat** saqlaydi. Rejim almashtirilganda (swap) **ikkala controller ham tozalanadi** (loyiha talabi shunday — pastda batafsil).

Rejimni bitta ixcham **icon-toggle** tugmasi boshqaradi (`KeyboardModeSwapButton`), u input maydonining ichida, o'ng tomonda joylashadi.

---

## 2. Bog'liqliklar (dependencies)

`pubspec.yaml`:

```yaml
dependencies:
  math_keyboard:
    path: packages/math_keyboard   # forked/kengaytirilgan versiya
  flutter_math_fork: ^0.7.4        # TeX renderlash uchun (math_keyboard ichida ishlatiladi)
```

> ⚠️ Muhim: bu loyihada `math_keyboard` **oddiy pub paketi emas**, balki `packages/math_keyboard/` ichidagi **kengaytirilgan fork**. Fork'ga qo'shilган narsalar:
> - Vertikal skroll qilinadigan **"symbols" sahifasi** (14 ta kategoriya, 250+ belgi)
> - `MathKeyboardTheme` + `MathKeyboardStyle` (design-system ranglari)
> - `MathKeyboardSemantics` (lokalizatsiya qilinadigan kategoriya sarlavhalari + a11y)
> - Landscape (yotiq) layout
>
> Boshqa loyihaga ko'chirishda **butun `packages/math_keyboard` papkasini** ko'chirish kerak, `pub.dev` versiyasi bu xususiyatlarni bermaydi.

---

## 3. Fayllar xaritasi (komponentlar)

```
lib/src/
├── core/theme/
│   └── app_math_keyboard_theme.dart        # MathKeyboardStyle qurilishi (light/dark)
├── features/child/test/presentation/
│   ├── state/
│   │   └── test_screen_state.dart          # mathController + isMathMode manbasi (yaratish/dispose)
│   └── widget/
│       ├── answer_attachments_scope.dart   # InheritedWidget — controllerlarni pastga uzatadi
│       ├── answer_composer_bar.dart        # tashqi qatlam (attach/voice/input joylashuvi)
│       ├── answer_input_field.dart         # ★ ASOSIY: native↔math swap mantig'i
│       └── keyboard_mode_swap_button.dart  # icon-toggle + clear (✕) tugmasi
└── packages/math_keyboard/                 # fork qilingan paket (butun holda)
    └── lib/src/
        ├── foundation/
        │   ├── keyboard_button.dart        # ★ barcha tugma/kategoriya konfiguratsiyasi
        │   ├── math_keyboard_semantics.dart# a11y + lokalizatsiya labellari
        │   ├── math2tex.dart / tex2math.dart # konvertatsiya
        │   └── node.dart                   # ifoda daraxti (expression tree)
        └── widgets/
            ├── math_field.dart             # MathField + MathFieldEditingController
            ├── math_keyboard.dart          # klaviatura UI (portrait/landscape, sahifalar)
            ├── math_keyboard_theme.dart    # MathKeyboardStyle/KeyStyle/Theme
            └── keyboard_button.dart        # tugma widgeti
```

---

## 4. Holat boshqaruvi (State)

Uchta obyekt butun oqimni boshqaradi. Ular **screen state**da yaratiladi va `InheritedWidget` orqali pastga uzatiladi.

### 4.1 Manba — `test_screen_state.dart`

```dart
// Native matn uchun (har savol uchun alohida yoki umumiy bo'lishi mumkin)
final TextEditingController nativeController = TextEditingController();

// Math (formula) uchun — TeX ifodani boshqaradi
final MathFieldEditingController mathController = MathFieldEditingController();

// Qaysi rejim faol: false = text, true = formula
final ValueNotifier<bool> isMathMode = ValueNotifier(false);

@override
void dispose() {
  mathController.dispose();
  isMathMode.dispose();
  nativeController.dispose();
  super.dispose();
}

// Yangi savolga o'tganda holatni tozalash:
void _resetAnswerInput() {
  nativeController.clear();
  mathController.clear();
  isMathMode.value = false;   // har doim text rejimidan boshlanadi
}
```

### 4.2 Uzatish — `answer_attachments_scope.dart` (InheritedWidget)

`MathFieldEditingController` va `ValueNotifier<bool> isMathMode` ni scaffold/question body orqali "prop drilling" qilmasdan pastga uzatadi. Test ekrani tashqarisida bu scope **yo'q** (`maybeOf`), shu sabab input maydoni oddiy text field'ga tushib qoladi (graceful degrade).

```dart
class AnswerAttachmentsScope extends InheritedWidget {
  final MathFieldEditingController mathController;
  final ValueNotifier<bool> isMathMode;
  // ... attachments / voice ...

  static AnswerAttachmentsScope? maybeOf(BuildContext context) =>
      context.getInheritedWidgetOfExactType<AnswerAttachmentsScope>();
}
```

> **Muhim qoida**: `math_keyboard` fork'i toza (pure) bo'lishi uchun, `MathField`da `context`/`BuildContext` orqali tema va semantics **tashqaridan** beriladi (`MathKeyboardTheme` wrapper). Controller esa state'da yaratiladi.

---

## 5. Asosiy widget — `AnswerInputField`

Bu — native↔math swap'ning yuragi. Kirish parametrlari:

```dart
AnswerInputField({
  required TextEditingController nativeController,
  MathFieldEditingController? mathController,   // null → faqat text (degrade)
  ValueNotifier<bool>? isMathMode,              // null → faqat text (degrade)
  required ValueChanged<String> onChanged,      // native matn YOKI TeX qaytadi
  required String hintText,
  bool isNumeric = false,
  bool interactionEnabled = true,               // check jarayonida false
  bool showWrongFeedback = false,               // qizil border
  bool isInCard = false,
  bool showSwapButton = true,
  ValueChanged<bool>? onFocusChanged,
  double borderRadius = 16,
});
```

### 5.1 Ichki holat

```dart
late final FocusNode _nativeFocus;   // native field fokusi
late final FocusNode _mathFocus;     // math field fokusi
late final ScrollController _nativeScrollController;

bool get _mathEnabled => mathController != null && isMathMode != null;
bool get _isFocused   => _nativeFocus.hasFocus || _mathFocus.hasFocus;
bool get _hasContent { // ikkala controllerdan ham tekshiradi
  final native = nativeController.text.trim();
  final math = mathController?.currentEditingValue(placeholderWhenEmpty: false).trim() ?? '';
  return native.isNotEmpty || math.isNotEmpty;
}
```

### 5.2 Math klaviaturadagi o'zgaruvchilar (top row)

Math klaviaturaning yuqori qatorida taklif qilinadigan harflar. 5 tadan ko'p bo'lsa, qator gorizontal skroll bo'ladi (paket 6-slotni "peek" qilib skroll borligini bildiradi).

```dart
// MathField har doim π va e ni old qatorga qo'shadi → e ni takrorlamang.
static const List<String> _mathVariables = [
  'x','y','z','a','b','c','d','f','g','h','i','j',
  'k','l','m','n','o','p','q','r','s','t','u','v','w',
];
```

### 5.3 Native field qurilishi

```dart
CustomTextFormFiled(
  controller: nativeController,
  focusNode: _nativeFocus,
  keyboardType: TextInputType.multiline,
  textInputAction: TextInputAction.newline,
  minLines: isNumeric ? 1 : (isFocused ? 3 : 1),
  maxLines: 5,
  enableSuggestions: false,
  autocorrect: false,
  onChanged: interactionEnabled ? onChanged : null,
  readOnly: !interactionEnabled,
);
```

### 5.4 Math field qurilishi

```dart
Theme(                         // cursor va onSurface ranglarini moslash
  data: theme.copyWith(...),
  child: MathKeyboardTheme(    // ★ design-system stil + lokalizatsiya semantics
    style: AppMathKeyboardTheme.styleOf(context),
    semantics: _mathSemantics(context),   // kategoriya sarlavhalari (l10n)
    child: MathField(
      controller: mathController,
      focusNode: _mathFocus,
      keyboardType: MathKeyboardType.expression,   // to'liq klaviatura
      variables: _mathVariables,
      opensKeyboard: interactionEnabled,
      decoration: InputDecoration(border: InputBorder.none, hintText: hintText, ...),
      onChanged: (_) => onChanged(_mathValue),     // _mathValue = TeX string
      onSubmitted: (_) => onChanged(_mathValue),
    ),
  ),
)

String get _mathValue =>
    mathController?.currentEditingValue(placeholderWhenEmpty: false) ?? '';
```

> `MathKeyboardType.expression` — to'liq klaviatura (raqamlar + funksiyalar + symbols sahifasi).
> `MathKeyboardType.numberOnly` — faqat raqam klaviaturasi (`isNumeric` uchun ishlatish mumkin).

---

## 6. ★ SWAP MANTIG'I — barcha case'lar

Swap `_setMode(bool toMath)` metodi orqali sodir bo'ladi (`answer_input_field.dart`):

```dart
void _setMode(bool toMath) {
  final notifier = widget.isMathMode;
  if (notifier == null || notifier.value == toMath) return;  // 1. Guard

  // 2. HAR IKKALA controllerni tozalash (loyiha talabi)
  widget.nativeController.clear();
  widget.mathController?.clear();
  widget.onChanged('');

  // 3. Rejimni o'zgartirish → ValueListenableBuilder qayta quradi
  notifier.value = toMath;

  // 4. Eski fieldan fokusni olib tashlash
  if (toMath) {
    _nativeFocus.unfocus();
  } else {
    _mathFocus.unfocus();
  }

  // 5. Yangi field faqat qayta qurilgandan keyin mavjud bo'ladi
  //    → keyingi frame'da fokus berish
  if (widget.interactionEnabled) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      (toMath ? _mathFocus : _nativeFocus).requestFocus();
    });
  }
}
```

### Swap flow diagrammasi

```
Foydalanuvchi toggle tugmasini bosadi
        │
        ▼
   _setMode(toMath)
        │
        ├─ notifier.value allaqachon shu qiymatda? ──► return (hech nima qilinmaydi)
        │
        ├─ nativeController.clear()      ┐
        ├─ mathController.clear()        ├─ IKKALA qiymat tozalanadi
        ├─ onChanged('')                 ┘
        │
        ├─ isMathMode.value = toMath ──► ValueListenableBuilder REBUILD
        │        │
        │        └─ isMath ? _buildMathField() : _buildNativeField()
        │
        ├─ eski fieldni unfocus()
        │
        └─ addPostFrameCallback ──► yangi fieldni requestFocus()
                                    (klaviatura avtomatik ochiladi)
```

### 6.1 Swap case'lari jadvali

| Holat | Amal | Natija |
|---|---|---|
| Text → Formula | toggle o'ng (fx) bosiladi | text tozalanadi, math field ochiladi, math klaviatura chiqadi |
| Formula → Text | toggle chap (⌨) bosiladi | math tozalanadi, native field ochiladi, native klaviatura chiqadi |
| Xuddi shu rejim qayta bosiladi | guard `return` | hech nima o'zgarmaydi |
| `interactionEnabled == false` (check ketmoqda) | fokus berilmaydi | swap ishlaydi, lekin klaviatura ochilmaydi |
| Kontent mavjud (`_hasContent`) | toggle o'rniga ✕ ko'rsatiladi | tanlangan-rejim indikatori doim ko'rinadi (pastga qarang) |

### 6.2 Toggle tugmasi — `KeyboardModeSwapButton`

Ixcham 2-segmentli toggle. **Muhim nuance**: kontent bo'lsa, tanlanmagan segment **clear (✕)** tugmasiga almashadi — shunda faol rejim indikatori doim ko'rinib turadi.

```dart
KeyboardModeSwapButton(
  isMath: isMath,
  onChanged: _setMode,          // (bool toMath)
  enabled: interactionEnabled,
  showClear: _hasContent,       // kontent bo'lsa ✕ ni ko'rsat
  onClear: _clearText,          // ikkala controllerni tozalaydi
);
```

Segment mantig'i:

| `showClear` | `isMath` | Chap slot | O'ng slot |
|---|---|---|---|
| false | — | ⌨ (keyboard icon) | fx (functions icon) |
| true | true (formula faol) | **✕ clear** | fx (tanlangan, primary rangda) |
| true | false (text faol) | ⌨ (tanlangan, primary rangda) | **✕ clear** |

- Ikonalar: `Icons.keyboard_outlined` (native), `Icons.functions_rounded` (math), `Icons.close_rounded` (clear).
- Tanlangan segment: `primary` fon + shadow + oq ikonka. Tanlanmagan: shaffof + `grey600Gray400` ikonka.
- Animatsiya: `AnimatedContainer` 180ms `easeOut`.
- `Semantics(button: true, label: isMath ? l10n.answerModeFormula : l10n.answerModeText)`.

### 6.3 Clear (✕) mantig'i

```dart
void _clearText() {
  widget.nativeController.clear();
  widget.mathController?.clear();
  widget.onChanged('');
}
```

---

## 7. Fokus / dinamik balandlik case'lari

`AnswerInputField` fokus holatiga qarab balandligini o'zgartiradi:

| Holat | minHeight | native minLines | math minHeight |
|---|---|---|---|
| Fokussiz | 50 | 1 | 44 |
| Fokusli | 84 | 3 | 72 |

- `AnimatedContainer` 200ms `easeOut` bilan silliq o'tadi.
- Fokusli holatda kontent `topLeft`, aks holda `centerLeft` da tekislanadi.
- `_handleFocusChanged` → `onFocusChanged(hasFocus)` callback'i tashqi qatlamga (composer bar) fokus o'zgarganini bildiradi.

---

## 8. Tashqi qatlam case'lari — `AnswerComposerBar`

Input maydoni yolg'iz emas; u attach va voice tugmalari bilan bitta qatorda joylashadi. Swap tugmasi input **ichida**, attach/voice tugmalari input **tashqarisida**.

Ko'rinish qoidalari (`math` rejimi swap flow'iga ta'sir qiladi):

```dart
// Math rejimida attach tugmasi yashiriladi — math klaviatura overlay uni yopadi:
final showAttach = interactionEnabled && !isFocused && !isMath
                   && !hasVoiceRecording && !isVoiceActive;

final showVoice  = isVoiceActive
                   || (interactionEnabled && !isFocused && !hasText && attachments.isEmpty);
```

| Holat | Attach | Input | Voice | Swap tugma |
|---|---|---|---|---|
| Bo'sh, fokussiz, text | ko'rinadi | ko'rinadi | ko'rinadi | ko'rinadi |
| Fokusli | yig'iladi (0 kenglik) | to'liq | yig'iladi | ko'rinadi |
| **Math rejimi** | **yashirin** | math field | yashirin | ko'rinadi |
| Ovoz yozilmoqda | yashirin | recording panel | mic (faol) | yashirin |
| Ovoz yozib bo'lindi | yashirin | audio progress bar | yashirin | yashirin |
| Attachment qo'shilgan | — | text kiritish mumkin | yashirin | (attachments strip yuqorida) |

- Tugmalarning paydo bo'lishi/yo'qolishi `AnimatedContainer` (200ms) + `AnimatedOpacity` (150ms) bilan.

---

## 9. ★ MATH KLAVIATURANING BARCHA XUSUSIYATLARI

Fork qilingan paketda math klaviatura **ikki turli** (`MathKeyboardType`) va **ikki orientatsiyali** (portrait/landscape) ishlaydi. Barcha tugmalar `keyboard_button.dart` (foundation) da e'lon qilingan.

### 9.1 Tugma turlari (`KeyboardButtonConfig`)

| Config | Vazifasi |
|---|---|
| `BasicKeyboardButtonConfig` | belgi/funksiya kiritadi. `label`, `value` (TeX), `args` (slotlar), `asTex` (label TeX bo'lib renderlanadimi), `keyboardCharacters` (fizik klaviaturadan trigger) |
| `DeleteButtonConfig` | ⌫ o'chirish |
| `PreviousButtonConfig` / `NextButtonConfig` | ◄ ► kursor harakati |
| `SubmitButtonConfig` | ✓ tasdiqlash / return |
| `PageButtonConfig` | `123 ⇄ fx` sahifa almashtirish |

`TeXArg` — funksiya slotlari: `braces` `{}`, `brackets` `[]`, `parentheses` `()`.

### 9.2 Standard (raqam) sahifasi — `standardKeyboard`

`MathKeyboardType.expression`ning **1-sahifasi** (portret):

```
7  8  9  ×(\cdot)  ÷(\frac)
4  5  6  +          −
1  2  3  .          ⌫
fx 0  ◄  ►          ✓(submit)
```

### 9.3 Funksiya sahifasi — `functionKeyboard`

`fx` tugmasi bosilganda ko'rsatiladigan **2-sahifa** (portret):

```
Qator 1:  a/b (\frac)   □²   □^□   sin   sin⁻¹
Qator 2:  √□   ⁿ√□       cos   cos⁻¹   ∞   ∈
Qator 3:  log_□(□)  ln(□)  tan   tan⁻¹   =   ≤
Qator 4:  123(page)  /   (   )   ◄   ►   ⌫
```

### 9.4 Faqat raqam klaviaturasi — `numberKeyboard`

`MathKeyboardType.numberOnly` uchun (masalan `isNumeric` javoblar):

```
7  8  9  −
4  5  6  .
1  2  3  ⌫
◄  0  ►  ✓
```

### 9.5 ★ "Symbols" sahifasi — vertikal skrollli (fork'ning asosiy qo'shimchasi)

`functionKeyboard`dan yana chuqurroq — **14 ta kategoriya, 250+ belgi**. Vertikal skroll bo'ladi, har kategoriya lokalizatsiya qilingan sarlavha bilan. Pastda doimiy boshqaruv paneli (`symbolPageControls`): `page ◄ ► ⌫ ✓`.

To'liq kategoriyalar ro'yxati (`symbolCategories`):

| # | ID | Sarlavha (l10n kaliti) | Belgilar (qisqacha) |
|---|---|---|---|
| 1 | `basic` | Basic operations (`mathCatBasic`) | + − × ÷ = ± ∓ ∗ · ∘ / , |
| 2 | `powers` | Powers, roots, fractions (`mathCatPowers`) | □² □^□ □_□ √□ ⁿ√□ a/b ½ ⅓ ⅔ ¼ ¾ ⅕ ⅙ ⅛ |
| 3 | `brackets` | Brackets (`mathCatBrackets`) | ( ) [ ] { } ⟨ ⟩ \| ‖ ⌊ ⌋ ⌈ ⌉ |
| 4 | `comparison` | Comparison (`mathCatComparison`) | < > ≤ ≥ ≠ ≈ ≅ ≡ ∝ ≪ ≫ ≐ ≜ ∼ ∽ |
| 5 | `greekLower` | Greek lowercase (`mathCatGreekLower`) | α β γ δ ε ζ η θ ι κ λ μ ν ξ π ρ σ τ υ φ χ ψ ω ϑ φ ϖ |
| 6 | `greekUpper` | Greek uppercase (`mathCatGreekUpper`) | Γ Δ Θ Λ Ξ Π Σ Υ Φ Ψ Ω |
| 7 | `calculus` | Calculus (`mathCatCalculus`) | ∫ ∬ ∭ ∮ ∯ ∂ ∇ ∑ ∏ ∐ lim ∞ ′ d |
| 8 | `sets` | Sets (`mathCatSets`) | ∈ ∉ ∋ ⊂ ⊃ ⊆ ⊇ ⊊ ⊋ ∪ ∩ ∖ ∅ ⊕ ⊗ △ ℝ ℤ ℚ ℕ ℂ ℙ ℍ ∁ |
| 9 | `logic` | Logic (`mathCatLogic`) | ∀ ∃ ∄ ∧ ∨ ¬ ⇒ ⇐ ⇔ → ↔ ⊢ ⊨ ∴ ∵ ⊤ ⊥ |
| 10 | `arrows` | Arrows (`mathCatArrows`) | → ← ↑ ↓ ↔ ↕ ⇒ ⇐ ⇑ ⇓ ⇔ ↦ ↪ ⟶ ⟵ ⟷ |
| 11 | `geometry` | Geometry (`mathCatGeometry`) | ° ∠ ∡ ⊥ ∥ ∦ ≅ ∼ ≈ △ ▽ □ ◯ • ⌢ ⊙ π |
| 12 | `functions` | Functions (`mathCatFunctions`) | sin cos tan cot sec csc arcsin arccos arctan sinh cosh tanh log ln lg exp mod gcd lcm max min |
| 13 | `special` | Special symbols (`mathCatSpecial`) | ! % … ⋯ ⋮ ⋱ ■ ℏ ℓ ı ȷ ≀ ∔ ⊖ ⊘ ⋆ † |
| 14 | `accents` | Accent marks (`mathCatAccents`) | x̄ x̂ x̃ ẋ ẍ x⃗ overline |

> Har bir belgi `flutter_math_fork` render qila oladigan **haqiqiy TeX token** kiritadi — hech qachon "error box" chiqmaydi.

### 9.6 Landscape (yotiq) layout

Yotiq holatda ikki panelli: chapda **funksiyalar** (`landscapeFunctionKeyboard`), o'ngda **raqamlar** (`landscapeNumberKeyboard`), va alohida to'liq balandlikdagi submit tugmasi.

### 9.7 Fizik klaviatura qo'llab-quvvatlash

Ko'p tugmalar `keyboardCharacters` orqali fizik klaviaturaga bog'langan: raqamlar, `+ - * / ^ = ( ) . ,` va harflar (`s`→sin, `c`→cos, `t`→tan, `r`→√, `l`→ln). `^` uchun "Dead" workaround (nemis klaviaturalari).

---

## 10. Tema / stillash — `AppMathKeyboardTheme`

`MathKeyboardStyle` design-system ranglaridan quriladi (light/dark alohida). Tugma toifalari:

| Kategoriya | Qaysi tugmalar | Light rang | Dark rang |
|---|---|---|---|
| `functionKey` | raqamlar (0-9) va matematik amallar (frac, sqrt...) | white | pinPut |
| `neutralKey` | operatorlar (+ − × ÷ =), qavslar, navigatsiya, o'zgaruvchilar | gray200 | textFildFill |
| `utilityKey` | delete, sahifa toggle (123/fx) | gray300 | gray600 |
| `primaryKey` | submit / return | primary | primary |

Boshqa parametrlar: `borderRadius` (yuqori 20), `boxShadow`, `keyHeight: 48`, `baseFontSize: 20`, `maxTextScaleFactor: 1`, `focusBorderColor: primary`, `focusBorderWidth: 2`, `rowSpacing: 6`.

```dart
static MathKeyboardStyle styleOf(BuildContext context) {
  final colors = context.colors;
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return fromColors(colors, isDark: isDark);
}
```

`MathKeyboardTheme(style: ..., semantics: ..., child: MathField(...))` orqali qo'llaniladi.

---

## 11. Lokalizatsiya + Semantics — `MathKeyboardSemantics`

Barcha string'lar `MathKeyboardSemantics.fallback` (inglizcha default) orqali beriladi, `.copyWith` bilan lokalizatsiya qilinadi. Kategoriya sarlavhalari `categoryLabels` map orqali (kalit = kategoriya `id`):

```dart
MathKeyboardSemantics _mathSemantics(BuildContext context) {
  final l10n = context.l10n;
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
```

Semantics'da yana: `deleteLabel`, `submitLabel`, `showNumbersKeyboardLabel`, `showFunctionsKeyboardLabel`, cursor labellari, `variableLabel(name)`, `numeratorLabel`, `denominatorLabel`, `exponentLabel`, va h.k. (a11y / screen reader uchun).

Kerakli `.arb` kalitlari (`en`/`ru`/`uz` uchun):
```
enterAnswerHint, answerModeText, answerModeFormula,
mathCatBasic, mathCatPowers, mathCatBrackets, mathCatComparison,
mathCatGreekLower, mathCatGreekUpper, mathCatCalculus, mathCatSets,
mathCatLogic, mathCatArrows, mathCatGeometry, mathCatFunctions,
mathCatSpecial, mathCatAccents
```

---

## 12. Qiymat (value) bilan ishlash — TeX

- Native rejim: `nativeController.text` — oddiy matn.
- Math rejim: `mathController.currentEditingValue(placeholderWhenEmpty: false)` — **TeX** string.
- `onChanged` **ikkala rejimda bir xil `String`** qaytaradi (native matn yoki TeX). Cubit/state faol rejimga qarab qaysi turda ekanini biladi (`isMathMode.value`).
- Backend'ga yuborishda: agar `isMathMode == true` → qiymat TeX ekanini belgilab yuboring (masalan `answer_format: "latex"`), aks holda `"text"`.
- TeX'ni renderlash (savol matni/javob ko'rsatish uchun): `flutter_math_fork` yoki `survey_latex_text.dart` (loyihadagi LaTeX render widget).
- TeX↔math konvertatsiya: paket ichida `math2tex.dart` / `tex2math.dart` + `TeXParser` (`math_expressions` bilan ifodani hisoblash mumkin).

---

## 13. Yangi loyihaga integratsiya qadamlari

1. **Paketni ko'chiring**: butun `packages/math_keyboard/` papkasini oling, `pubspec.yaml`ga path-dependency va `flutter_math_fork` qo'shing.
2. **Tema**: `app_math_keyboard_theme.dart`ni ko'chiring, `ThemeColors` token nomlarini o'z design-system'ingizga moslang.
3. **L10n**: 12-bo'limdagi `.arb` kalitlarni barcha tillarga qo'shing, `flutter gen-l10n` ishga tushiring.
4. **State**: ekran state'ida `TextEditingController`, `MathFieldEditingController`, `ValueNotifier<bool> isMathMode` yarating va `dispose` qiling.
5. **(Ixtiyoriy) Scope**: agar controllerlarni chuqur uzatish kerak bo'lsa `AnswerAttachmentsScope`ga o'xshash `InheritedWidget` yozing; oddiy holatda to'g'ridan-to'g'ri parametr sifatida bering.
6. **Widgetlar**: `AnswerInputField` + `KeyboardModeSwapButton`ni ko'chiring. Attach/voice kerak bo'lmasa, `AnswerComposerBar`ni tashlab, `AnswerInputField`ni to'g'ridan-to'g'ri ishlating.
7. **Ulash**:

```dart
AnswerInputField(
  nativeController: nativeController,
  mathController: mathController,
  isMathMode: isMathMode,
  hintText: context.l10n.enterAnswerHint,
  onChanged: (value) => cubit.onAnswerChanged(value, isMath: isMathMode.value),
  isNumeric: false,
  interactionEnabled: !state.isChecking,
  showWrongFeedback: state.isWrong,
);
```

8. **Test**: swap → ikkala controller tozalanishini, fokus keyingi frame'da o'tishini, `interactionEnabled=false`da klaviatura ochilmasligini tekshiring.

---

## 14. Eslatmalar / tuzoqlar (gotchas)

- **Swap'da tozalash** loyiha talabi — agar rejim almashganda qiymatni saqlamoqchi bo'lsangiz, `_setMode`dagi `clear()` chaqiruvlarini olib tashlang (lekin TeX↔text avtomatik konvertatsiya yo'q).
- Yangi field faqat rebuild'dan **keyin** mavjud → fokus doim `addPostFrameCallback` ichida.
- `MathField` `variables`ga `e` qo'shmang — paket `π` va `e` ni avtomatik qo'shadi.
- `maxTextScaleFactor: 1` — tizim shrift kattalashuvi klaviaturani buzmasligi uchun.
- Math rejimida `attach` tugmasi ataylab yashiriladi — math klaviatura overlay'i uni yopadi.
- Test ekrani tashqarisida (`scope == null`) → avtomatik oddiy text field (graceful degrade).
```
