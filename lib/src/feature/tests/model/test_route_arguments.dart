import '../../../common/util/app_enum.dart';
import '../../../common/util/logger.dart' as log_util;

class TestResultArguments {
  const TestResultArguments({
    required this.testId,
    required this.correct,
    required this.wrong,
    required this.total,
    required this.time,
    this.attemptId,
    this.testName,
    this.description,
    this.academicYear,
    this.semester,
    this.questionCount,
    this.lastAttemptCorrect,
    this.lastAttemptTotal,
    this.lastAttemptTime,
    this.lastAttemptDate,
    this.lastAttemptSkip,
    this.mode = TestResultMode.test,
    this.xp,
  });

  factory TestResultArguments.fromArguments(Map<String, String> args) => TestResultArguments(
    testId: args['id'] ?? '',
    correct: int.tryParse(args['correct'] ?? '') ?? 0,
    wrong: int.tryParse(args['wrong'] ?? '') ?? 0,
    total: int.tryParse(args['total'] ?? '') ?? 0,
    time: int.tryParse(args['time'] ?? '') ?? 0,
    attemptId: args['attemptId'] ?? args['attempt_id'],
    testName: args['name'],
    description: args['description'],
    academicYear: args['academicYear'] ?? args['academic_year'],
    semester: int.tryParse(args['semester'] ?? ''),
    questionCount: int.tryParse(args['questionCount'] ?? args['question_count'] ?? ''),
    lastAttemptCorrect: int.tryParse(args['lastAttemptCorrect'] ?? args['last_attempt_correct'] ?? ''),
    lastAttemptTotal: int.tryParse(args['lastAttemptTotal'] ?? args['last_attempt_total'] ?? ''),
    lastAttemptTime: int.tryParse(args['lastAttemptTime'] ?? args['last_attempt_time'] ?? ''),
    lastAttemptDate: args['lastAttemptDate'] ?? args['last_attempt_date'],
    lastAttemptSkip: int.tryParse(args['lastAttemptSkip'] ?? args['last_attempt_skip'] ?? ''),
    mode: TestResultMode.fromValue(args['mode']),
    xp: int.tryParse(args['xp'] ?? ''),
  );

  final String testId;
  final int correct;
  final int wrong;
  final int total;
  final int time;
  final String? attemptId;
  final String? testName;
  final String? description;
  final String? academicYear;
  final int? semester;
  final int? questionCount;
  final int? lastAttemptCorrect;
  final int? lastAttemptTotal;
  final int? lastAttemptTime;
  final String? lastAttemptDate;
  final int? lastAttemptSkip;

  /// Which flow produced the result — drives "Qayta ishlash" and XP rules.
  final TestResultMode mode;

  /// XP earned, as returned by the server. `null` → estimated from docs §4.5.
  final int? xp;

  int get skipped => (total - correct - wrong).clamp(0, total);

  int get scorePercent => total == 0 ? 0 : (correct * 100 / total).round();

  /// Server XP when available, otherwise the docs §4.5 estimate:
  /// +10 per correct answer, +50 when every question was answered.
  /// Flashcards are self-graded and give no XP.
  int get earnedXp {
    if (xp != null) return xp!;
    if (!mode.givesXp) return 0;
    return correct * 10 + (total > 0 && skipped == 0 ? 50 : 0);
  }

  Map<String, String> toArguments() => {
    'id': testId,
    'mode': mode.value,
    'xp': ?xp?.toString(),
    'correct': correct.toString(),
    'wrong': wrong.toString(),
    'total': total.toString(),
    'time': time.toString(),
    'attemptId': ?attemptId,
    'name': ?testName,
    'description': ?description,
    'academicYear': ?academicYear,
    'semester': ?semester?.toString(),
    'questionCount': ?questionCount?.toString(),
    'lastAttemptCorrect': ?lastAttemptCorrect?.toString(),
    'lastAttemptTotal': ?lastAttemptTotal?.toString(),
    'lastAttemptTime': ?lastAttemptTime?.toString(),
    'lastAttemptDate': ?lastAttemptDate,
    'lastAttemptSkip': ?lastAttemptSkip?.toString(),
  };
}

/// Flow that produced a [TestResultArguments].
enum TestResultMode {
  test('test'),
  university('university'),
  flashcard('flashcard'),
  random('random');

  const TestResultMode(this.value);

  final String value;

  bool get givesXp => this != flashcard;

  static TestResultMode fromValue(String? value) => switch (value?.toLowerCase()) {
    'university' => university,
    'flashcard' => flashcard,
    'random' => random,
    _ => test,
  };

  static TestResultMode fromTestMode(TestMode mode) => switch (mode) {
    TestMode.university => university,
    TestMode.custom => test,
  };
}

class TestSolvingArguments {
  const TestSolvingArguments({
    required this.testId,
    required this.attemptId,
    required this.startRange,
    required this.endRange,
    required this.timeOptionName,
    required this.shuffleOptionName,
    this.mode = TestMode.custom,
    this.lastAttemptCorrect,
    this.lastAttemptTotal,
    this.lastAttemptTime,
    this.lastAttemptDate,
    this.lastAttemptSkip,
  });

  factory TestSolvingArguments.fromArguments(Map<String, String> args) {
    log_util.info('TestSolvingArguments.fromArguments args: $args');
    return TestSolvingArguments(
      testId: args['id'] ?? '',
      attemptId: args['attemptId'] ?? args['attempt_id'] ?? '',
      startRange: int.tryParse(args['start'] ?? '') ?? 1,
      endRange: int.tryParse(args['end'] ?? '') ?? 20,
      timeOptionName: args['time'] ?? '',
      shuffleOptionName: args['shuffle'] ?? '',
      mode: TestMode.fromValue(args['mode']),
      lastAttemptCorrect: int.tryParse(args['lastAttemptCorrect'] ?? args['last_attempt_correct'] ?? ''),
      lastAttemptTotal: int.tryParse(args['lastAttemptTotal'] ?? args['last_attempt_total'] ?? ''),
      lastAttemptTime: int.tryParse(args['lastAttemptTime'] ?? args['last_attempt_time'] ?? ''),
      lastAttemptDate: args['lastAttemptDate'] ?? args['last_attempt_date'],
      lastAttemptSkip: int.tryParse(args['lastAttemptSkip'] ?? args['last_attempt_skip'] ?? ''),
    );
  }

  final String testId;
  final String attemptId;
  final int startRange;
  final int endRange;
  final String timeOptionName;
  final String shuffleOptionName;
  final TestMode mode;
  final int? lastAttemptCorrect;
  final int? lastAttemptTotal;
  final int? lastAttemptTime;
  final String? lastAttemptDate;
  final int? lastAttemptSkip;

  Map<String, String> toArguments() => {
    'id': testId,
    'attemptId': attemptId,
    'start': startRange.toString(),
    'end': endRange.toString(),
    'time': timeOptionName,
    'shuffle': shuffleOptionName,
    'mode': mode.value,
    'lastAttemptCorrect': ?lastAttemptCorrect?.toString(),
    'lastAttemptTotal': ?lastAttemptTotal?.toString(),
    'lastAttemptTime': ?lastAttemptTime?.toString(),
    'lastAttemptDate': ?lastAttemptDate,
    'lastAttemptSkip': ?lastAttemptSkip?.toString(),
  };
}
