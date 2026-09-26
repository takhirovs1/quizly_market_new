import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:localization/localization.dart';
import 'package:math_keyboard/math_keyboard.dart';
import 'package:ui/ui.dart';

/// Replicates create_test_questions_screen's desktop body structure to find
/// which wrapper collapses the CustomScrollView to zero height.
void main() {
  Widget shell({required Widget child}) => MaterialApp(
    theme: AppThemeData.light(),
    localizationsDelegates: AppLocalization.localizationsDelegates,
    supportedLocales: AppLocalization.supportedLocales,
    home: child,
  );

  Widget scrollBody() => CustomScrollView(
    slivers: [
      const SliverToBoxAdapter(child: Text('HEADER')),
      SliverList.builder(itemCount: 1, itemBuilder: (_, _) => const SizedBox(height: 80, child: Text('CARD'))),
    ],
  );

  Future<void> expectVisible(WidgetTester tester, String variant) async {
    await tester.pump(const Duration(milliseconds: 100));
    final header = find.text('HEADER');
    final card = find.text('CARD');
    expect(header, findsOneWidget, reason: '$variant: header missing');
    expect(card, findsOneWidget, reason: '$variant: card missing');
  }

  testWidgets('A: plain Scaffold + Center/ConstrainedBox', (tester) async {
    await tester.pumpWidget(
      shell(
        child: Scaffold(
          appBar: AppBar(title: const Text('t')),
          body: SafeArea(
            child: Center(
              child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 680), child: scrollBody()),
            ),
          ),
        ),
      ),
    );
    await expectVisible(tester, 'A');
  });

  testWidgets('B: + MathKeyboardViewInsets wrapper', (tester) async {
    await tester.pumpWidget(
      shell(
        child: MathKeyboardViewInsets(
          child: Scaffold(
            appBar: AppBar(title: const Text('t')),
            body: SafeArea(
              child: Center(
                child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 680), child: scrollBody()),
              ),
            ),
          ),
        ),
      ),
    );
    await expectVisible(tester, 'B');
  });

  testWidgets('C: + QuizAppBar (as in the real screen)', (tester) async {
    await tester.pumpWidget(
      shell(
        child: MathKeyboardViewInsets(
          child: Scaffold(
            appBar: const QuizAppBar(title: 't', telegramWebAppSafeAreaInsetTop: 0, showBackButton: true),
            body: SafeArea(
              child: Center(
                child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 680), child: scrollBody()),
              ),
            ),
          ),
        ),
      ),
    );
    await expectVisible(tester, 'C');
  });
}
