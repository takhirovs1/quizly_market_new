import '../../../common/extension/number_extension.dart';

/// Session modes (backend `StartSessionRequest.mode`).
enum SessionRunMode {
  test,
  exam,
  flashcard,
  random,
  mistakes;

  static SessionRunMode fromValue(String? value) => switch (value) {
    'exam' => SessionRunMode.exam,
    'flashcard' => SessionRunMode.flashcard,
    'random' => SessionRunMode.random,
    'mistakes' => SessionRunMode.mistakes,
    _ => SessionRunMode.test,
  };

  String get value => name;
}

/// POST /api/sessions — start a random / mistakes (or test/exam/flashcard) session.
class StartSessionRequest {
  const StartSessionRequest({required this.mode, this.testId, this.count, this.scope});

  /// Random practice over all purchased tests: `count` ∈ {10, 20, 30}.
  const StartSessionRequest.random(int count) : this(mode: SessionRunMode.random, count: count);

  /// Mistakes practice across all tests, or a single test when [testId] is set.
  const StartSessionRequest.mistakes({String? testId})
    : this(mode: SessionRunMode.mistakes, testId: testId, scope: testId == null ? 'all' : 'test');

  final SessionRunMode mode;
  final String? testId;
  final int? count;
  final String? scope;

  Map<String, Object?> toJson() => <String, Object?>{
    'mode': mode.value,
    if (testId != null) 'test_id': testId,
    if (count != null) 'count': count,
    if (scope != null) 'scope': scope,
  };
}

/// GET /api/sessions/:id — resume, or the body of POST /api/sessions.
class SessionResponse {
  const SessionResponse({
    required this.sessionId,
    required this.mode,
    required this.status,
    required this.total,
    required this.currentIndex,
    required this.answered,
    required this.correct,
    required this.wrong,
    required this.questions,
    required this.answers,
    this.scorePercent,
  });

  factory SessionResponse.fromJson(Map<String, Object?> json) {
    final root = json['data'] is Map<String, Object?> ? json['data']! as Map<String, Object?> : json;
    final questions = root['questions'] as List<Object?>? ?? const <Object?>[];
    final answers = root['answers'] as List<Object?>? ?? const <Object?>[];
    return SessionResponse(
      sessionId: root['session_id'] as String? ?? root['id'] as String? ?? '',
      mode: SessionRunMode.fromValue(root['mode'] as String?),
      status: root['status'] as String? ?? 'in_progress',
      total: root['total'].toIntOrNull ?? questions.length,
      currentIndex: root['current_index'].toIntOrNull ?? 0,
      answered: root['answered'].toIntOrNull ?? 0,
      correct: root['correct'].toIntOrNull ?? 0,
      wrong: root['wrong'].toIntOrNull ?? 0,
      scorePercent: root['score_percent'].toIntOrNull,
      questions: questions.whereType<Map<String, Object?>>().map(SessionQuestion.fromJson).toList(),
      answers: answers.whereType<Map<String, Object?>>().map(SessionSavedAnswer.fromJson).toList(),
    );
  }

  final String sessionId;
  final SessionRunMode mode;

  /// in_progress | finished | abandoned.
  final String status;
  final int total;
  final int currentIndex;
  final int answered;
  final int correct;
  final int wrong;
  final int? scorePercent;
  final List<SessionQuestion> questions;
  final List<SessionSavedAnswer> answers;
}

class SessionQuestion {
  const SessionQuestion({
    required this.id,
    required this.index,
    required this.text,
    required this.imageUrl,
    required this.options,
    this.sourceTestName,
  });

  factory SessionQuestion.fromJson(Map<String, Object?> json) {
    final options = json['options'] as List<Object?>? ?? const <Object?>[];
    final source = json['source_test'] as Map<String, Object?>?;
    return SessionQuestion(
      id: json['id'] as String? ?? '',
      index: json['index'].toIntOrNull ?? 0,
      text: json['text'] as String? ?? '',
      imageUrl: (json['image_url'] ?? json['photo_url']) as String?,
      options: options.whereType<Map<String, Object?>>().map(SessionOption.fromJson).toList(),
      sourceTestName: source?['name'] as String?,
    );
  }

  final String id;
  final int index;
  final String text;
  final String? imageUrl;
  final List<SessionOption> options;

  /// "Manba: …" — the test a random-session question was pulled from.
  final String? sourceTestName;
}

class SessionOption {
  const SessionOption({required this.id, required this.text, required this.imageUrl});

  factory SessionOption.fromJson(Map<String, Object?> json) => SessionOption(
    id: json['id'] as String? ?? '',
    text: json['text'] as String? ?? '',
    imageUrl: (json['image_url'] ?? json['photo_url']) as String?,
  );

  final String id;
  final String text;
  final String? imageUrl;
}

/// A previously-saved answer returned on resume (`answers[]`).
class SessionSavedAnswer {
  const SessionSavedAnswer({required this.questionId, required this.optionId, required this.isCorrect});

  factory SessionSavedAnswer.fromJson(Map<String, Object?> json) => SessionSavedAnswer(
    questionId: json['question_id'] as String? ?? '',
    optionId: json['option_id'] as String? ?? '',
    isCorrect: json['is_correct'] as bool? ?? false,
  );

  final String questionId;
  final String optionId;
  final bool isCorrect;
}

/// POST /api/sessions/:id/answers.
class SessionAnswerRequest {
  const SessionAnswerRequest({required this.questionId, required this.optionId, this.timeSpentMs});

  final String questionId;
  final String optionId;
  final int? timeSpentMs;

  Map<String, Object?> toJson() => <String, Object?>{
    'question_id': questionId,
    'option_id': optionId,
    if (timeSpentMs != null) 'time_spent_ms': timeSpentMs,
  };
}

class SessionAnswerResult {
  const SessionAnswerResult({
    required this.isCorrect,
    required this.correctOptionId,
    required this.xpGained,
    required this.mistakeResolved,
    required this.answeredCount,
  });

  factory SessionAnswerResult.fromJson(Map<String, Object?> json) {
    final root = json['data'] is Map<String, Object?> ? json['data']! as Map<String, Object?> : json;
    return SessionAnswerResult(
      isCorrect: root['is_correct'] as bool? ?? false,
      correctOptionId: root['correct_option_id'] as String?,
      xpGained: root['xp_gained'].toIntOrNull ?? 0,
      mistakeResolved: root['mistake_resolved'] as bool? ?? false,
      answeredCount: root['answered_count'].toIntOrNull ?? 0,
    );
  }

  final bool isCorrect;
  final String? correctOptionId;
  final int xpGained;
  final bool mistakeResolved;
  final int answeredCount;
}

/// POST /api/sessions/:id/finish.
class SessionFinishRequest {
  const SessionFinishRequest({this.timeSpentSec});

  final int? timeSpentSec;

  Map<String, Object?> toJson() => <String, Object?>{if (timeSpentSec != null) 'time_spent_sec': timeSpentSec};
}

class SessionResult {
  const SessionResult({
    required this.sessionId,
    required this.mode,
    required this.scorePercent,
    required this.correct,
    required this.wrong,
    required this.skipped,
    required this.total,
    required this.answered,
    required this.timeSpentSec,
    required this.xpTotal,
    required this.mistakesResolvedCount,
    this.ratingRank,
  });

  factory SessionResult.fromJson(Map<String, Object?> json) {
    final root = json['data'] is Map<String, Object?> ? json['data']! as Map<String, Object?> : json;
    return SessionResult(
      sessionId: root['session_id'] as String? ?? '',
      mode: SessionRunMode.fromValue(root['mode'] as String?),
      scorePercent: root['score_percent'].toIntOrNull ?? 0,
      correct: root['correct'].toIntOrNull ?? 0,
      wrong: root['wrong'].toIntOrNull ?? 0,
      skipped: root['skipped'].toIntOrNull ?? 0,
      total: root['total'].toIntOrNull ?? 0,
      answered: root['answered'].toIntOrNull ?? 0,
      timeSpentSec: (root['time_spent_sec'] ?? root['duration_sec']).toIntOrNull ?? 0,
      xpTotal: (root['xp_total'] ?? root['xp_gained'] ?? root['xp']).toIntOrNull ?? 0,
      mistakesResolvedCount: root['mistakes_resolved_count'].toIntOrNull ?? 0,
      ratingRank: root['rating_rank'].toIntOrNull,
    );
  }

  final String sessionId;
  final SessionRunMode mode;
  final int scorePercent;
  final int correct;
  final int wrong;
  final int skipped;
  final int total;
  final int answered;
  final int timeSpentSec;
  final int xpTotal;
  final int mistakesResolvedCount;
  final int? ratingRank;
}

/// GET /api/me/mistakes/summary — the Mistakes picker.
class MistakesSummary {
  const MistakesSummary({this.total = 0, this.byTest = const <MistakesByTest>[]});

  factory MistakesSummary.fromJson(Map<String, Object?> json) {
    final root = json['data'] is Map<String, Object?> ? json['data']! as Map<String, Object?> : json;
    final list = root['by_test'] as List<Object?>? ?? const <Object?>[];
    return MistakesSummary(
      total: root['total'].toIntOrNull ?? 0,
      byTest: list.whereType<Map<String, Object?>>().map(MistakesByTest.fromJson).toList(),
    );
  }

  final int total;
  final List<MistakesByTest> byTest;
}

class MistakesByTest {
  const MistakesByTest({required this.testId, required this.name, required this.count});

  factory MistakesByTest.fromJson(Map<String, Object?> json) => MistakesByTest(
    testId: json['test_id'] as String? ?? '',
    name: json['name'] as String? ?? '',
    count: json['count'].toIntOrNull ?? 0,
  );

  final String testId;
  final String name;
  final int count;
}
