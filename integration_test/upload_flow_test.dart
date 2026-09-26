// Drives the REAL app (real DI, octopus, session) through both upload flows:
//   #9  manual: meta → review/edit screen → type a question
//   #7  file:   parsed csv → mapping wizard → continue → review/edit
//
// Run: .fvm/flutter_sdk/bin/flutter test integration_test/upload_flow_test.dart -d macos
import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:octopus/octopus.dart';
import 'package:quizly_market/main.dart' as app;
import 'package:quizly_market/src/common/router/pages.dart';
import 'package:quizly_market/src/feature/upload/screen/create_test_questions_screen.dart';
import 'package:quizly_market/src/feature/upload/screen/file_upload_screen.dart';
import 'package:quizly_market/src/feature/upload/screen/manual_upload_screen.dart';
import 'package:quizly_market/src/feature/upload/widget/import_mapping_step.dart';
import 'package:quizly_market/src/feature/upload/widget/question_card.dart';

/// Pumps until [finder] matches or [timeout] elapses (pumpAndSettle would
/// never settle because of looping shimmer animations).
Future<void> pumpUntil(WidgetTester tester, Finder finder, {Duration timeout = const Duration(seconds: 30)}) async {
  final end = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(end)) {
    // NOTE: live-binding pumps only advance animations reliably with pump
    // durations that cover the transition (short pumps stall route tickers).
    await tester.pump(const Duration(seconds: 1));
    if (finder.evaluate().isNotEmpty) return;
  }
  // Diagnostic snapshot before failing: which screen are we on?
  final texts = tester.allWidgets
      .whereType<Text>()
      .map((t) => t.data)
      .whereType<String>()
      .where((s) => s.trim().isNotEmpty)
      .take(40)
      .join(' | ');
  fail('pumpUntil timed out waiting for $finder.\nVisible texts: $texts');
}

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  // Route transitions are real-time animations — without fullyLive they never
  // finish and the pushed route stays offstage forever.
  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;

  testWidgets('manual flow: meta -> review screen -> typing works', (tester) async {
    app.main();
    // Wait for the router itself — the splash Scaffold appears earlier but
    // lives OUTSIDE the Octopus scope.
    final router = find.byType(OctopusNavigator, skipOffstage: false);
    await pumpUntil(tester, router, timeout: const Duration(seconds: 60));
    await tester.pump(const Duration(seconds: 1));

    // Navigate directly via octopus (bottom-nav labels vary by locale).
    final context = tester.element(router.first);
    unawaited(context.octopus.push(Routes.manualUpload));
    await pumpUntil(tester, find.byType(ManualUploadScreen));

    // Fill required meta fields + proceed by driving the real state object —
    // synthetic taps/typing are flaky on an unfocused macOS window, and the
    // point is to verify the APP logic (guards, route, review screen).
    final manualState = tester.state<State<ManualUploadScreen>>(find.byType(ManualUploadScreen)) as dynamic;
    manualState.universityController.text = 'Test University';
    manualState.testNameController.text = 'Integration Test';
    await tester.pump(const Duration(milliseconds: 300));
    expect(manualState.canProceed as bool, isTrue);
    manualState.onSubmitProceed();
    await pumpUntil(tester, find.byType(CreateTestQuestionsScreen));

    // #9: the review/edit screen must render a question card and accept input.
    await pumpUntil(tester, find.byType(QuestionCard));
    final textFields = find.byType(TextField);
    await pumpUntil(tester, textFields);
    await tester.enterText(textFields.first, 'Savol matni 1');
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Savol matni 1'), findsOneWidget);

    // Back out to home for the second flow.
    unawaited(context.octopus.pop());
    await tester.pump(const Duration(seconds: 1));
    unawaited(context.octopus.pop());
    await tester.pump(const Duration(seconds: 1));

    // ── File flow: parsed csv -> mapping wizard -> continue -> review ──
    unawaited(context.octopus.push(Routes.fileUpload));
    await pumpUntil(tester, find.byType(FileUploadScreen));

    // Fill meta + feed a csv straight into the cubit (no native dialog).
    final state = tester.state<State<FileUploadScreen>>(find.byType(FileUploadScreen)) as dynamic;
    state.universityController.text = 'Import University';
    state.testNameController.text = 'Import Test';
    await tester.pump(const Duration(milliseconds: 300));
    await state.mappingCubit.parseFile(
      bytes: utf8.encode('savol,javob a,javob b,togri\nQ1,x,y,1\nQ2,m,n,2\nQ3,p,q,2\n'),
      fileName: 'integration.csv',
    );

    // #7: wizard step must appear with the parsed grid.
    await pumpUntil(tester, find.byType(ImportMappingStep));
    expect(find.text('integration.csv'), findsOneWidget);

    // Continue → review/edit with the 3 imported questions (drive state).
    expect(state.mappingCubit.state.canConfirm as bool, isTrue);
    state.onConfirmMapping();
    await pumpUntil(tester, find.byType(CreateTestQuestionsScreen));
    await pumpUntil(tester, find.byType(QuestionCard));
    expect(find.byType(QuestionCard, skipOffstage: false), findsNWidgets(3));

    unawaited(context.octopus.pop());
    await tester.pump(const Duration(seconds: 1));
    unawaited(context.octopus.pop());
    await tester.pump(const Duration(seconds: 1));
  });
}
