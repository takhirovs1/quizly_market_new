import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:localization/localization.dart';
import 'package:quizly_market/src/feature/upload/bloc/import_mapping_cubit.dart';
import 'package:quizly_market/src/feature/upload/model/import_mapping_models.dart';
import 'package:quizly_market/src/feature/upload/model/test_question_model.dart';
import 'package:quizly_market/src/feature/upload/widget/import_mapping_step.dart';
import 'package:quizly_market/src/feature/upload/widget/question_card.dart';
import 'package:ui/ui.dart';

Widget harness(Widget child) => MaterialApp(
  theme: AppThemeData.light(),
  localizationsDelegates: AppLocalization.localizationsDelegates,
  supportedLocales: AppLocalization.supportedLocales,
  home: Scaffold(body: SingleChildScrollView(child: child)),
);

void main() {
  testWidgets('QuestionCard renders expanded with dual-input fields and image buttons', (tester) async {
    final question = QuestionModel();
    question.nativeController.text = '2+2=?';
    question.answers[0].nativeController.text = '4';
    question.answers[0].isCorrect = true;
    question.answers[1].nativeController.text = '5';

    await tester.pumpWidget(
      harness(
        QuestionCard(
          index: 0,
          question: question,
          onToggleExpand: () {},
          onRemoveQuestion: () {},
          onAddAnswer: () {},
          onRemoveAnswer: (_) {},
          onToggleCorrect: (_) {},
          onTextChanged: (_) {},
          onPickImage: ({int? answerIndex}) {},
          onRemoveImage: ({int? answerIndex}) {},
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 400));

    expect(tester.takeException(), isNull);
    expect(find.text('2+2=?'), findsOneWidget);
    expect(find.text('4'), findsOneWidget);

    question.dispose();
  });

  testWidgets('QuestionCard renders collapsed (imported) without exceptions', (tester) async {
    final draft = MappedQuestionDraft(
      sourceRow: 2,
      question: 'Imported question',
      options: const ['a', 'b', 'c'],
      correctFlags: const [false, true, false],
    );
    final question = draft.toQuestionModel();

    await tester.pumpWidget(
      harness(
        QuestionCard(
          index: 3,
          question: question,
          onToggleExpand: () {},
          onRemoveQuestion: () {},
          onAddAnswer: () {},
          onRemoveAnswer: (_) {},
          onToggleCorrect: (_) {},
          onTextChanged: (_) {},
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 400));

    expect(tester.takeException(), isNull);
    question.dispose();
  });

  testWidgets('ImportMappingStep renders full wizard for a parsed csv', (tester) async {
    final cubit = ImportMappingCubit();
    // parseFile awaits a zero-delay timer — run it outside FakeAsync.
    await tester.runAsync(
      () => cubit.parseFile(
        bytes: utf8.encode('savol,javob a,javob b,togri\nQ1,x,y,1\nQ2,m,n,2\n'),
        fileName: 'demo.csv',
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AppThemeData.light(),
        localizationsDelegates: AppLocalization.localizationsDelegates,
        supportedLocales: AppLocalization.supportedLocales,
        home: Scaffold(
          body: ImportMappingStep(cubit: cubit, onConfirm: () {}),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 400));

    expect(tester.takeException(), isNull);
    expect(find.text('demo.csv'), findsOneWidget);
    // Both draft rows must be visible in the live preview.
    expect(find.textContaining('Q1'), findsWidgets);

    await cubit.close();
  });
}
