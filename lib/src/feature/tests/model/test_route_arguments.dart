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
  });

  factory TestResultArguments.fromArguments(Map<String, String> args) => TestResultArguments(
    testId: args['id'] ?? '',
    correct: int.tryParse(args['correct'] ?? '') ?? 0,
    wrong: int.tryParse(args['wrong'] ?? '') ?? 0,
    total: int.tryParse(args['total'] ?? '') ?? 0,
    time: int.tryParse(args['time'] ?? '') ?? 0,
    attemptId: args['attempt_id'],
    testName: args['name'],
    description: args['description'],
    academicYear: args['academic_year'],
    semester: int.tryParse(args['semester'] ?? ''),
    questionCount: int.tryParse(args['question_count'] ?? ''),
    lastAttemptCorrect: int.tryParse(args['last_attempt_correct'] ?? ''),
    lastAttemptTotal: int.tryParse(args['last_attempt_total'] ?? ''),
    lastAttemptTime: int.tryParse(args['last_attempt_time'] ?? ''),
    lastAttemptDate: args['last_attempt_date'],
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

  Map<String, String> toArguments() => {
    'id': testId,
    'correct': correct.toString(),
    'wrong': wrong.toString(),
    'total': total.toString(),
    'time': time.toString(),
    if (attemptId != null) 'attempt_id': attemptId!,
    if (testName != null) 'name': testName!,
    if (description != null) 'description': description!,
    if (academicYear != null) 'academic_year': academicYear!,
    if (semester != null) 'semester': semester!.toString(),
    if (questionCount != null) 'question_count': questionCount!.toString(),
    if (lastAttemptCorrect != null) 'last_attempt_correct': lastAttemptCorrect!.toString(),
    if (lastAttemptTotal != null) 'last_attempt_total': lastAttemptTotal!.toString(),
    if (lastAttemptTime != null) 'last_attempt_time': lastAttemptTime!.toString(),
    if (lastAttemptDate != null) 'last_attempt_date': lastAttemptDate!,
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
    this.lastAttemptCorrect,
    this.lastAttemptTotal,
    this.lastAttemptTime,
    this.lastAttemptDate,
  });

  factory TestSolvingArguments.fromArguments(Map<String, String> args) => TestSolvingArguments(
    testId: args['id'] ?? '',
    attemptId: args['attempt_id'] ?? '',
    startRange: int.tryParse(args['start'] ?? '') ?? 1,
    endRange: int.tryParse(args['end'] ?? '') ?? 20,
    timeOptionName: args['time'] ?? '',
    shuffleOptionName: args['shuffle'] ?? '',
    lastAttemptCorrect: int.tryParse(args['last_attempt_correct'] ?? ''),
    lastAttemptTotal: int.tryParse(args['last_attempt_total'] ?? ''),
    lastAttemptTime: int.tryParse(args['last_attempt_time'] ?? ''),
    lastAttemptDate: args['last_attempt_date'],
  );

  final String testId;
  final String attemptId;
  final int startRange;
  final int endRange;
  final String timeOptionName;
  final String shuffleOptionName;
  final int? lastAttemptCorrect;
  final int? lastAttemptTotal;
  final int? lastAttemptTime;
  final String? lastAttemptDate;

  Map<String, String> toArguments() => {
    'id': testId,
    'attempt_id': attemptId,
    'start': startRange.toString(),
    'end': endRange.toString(),
    'time': timeOptionName,
    'shuffle': shuffleOptionName,
    if (lastAttemptCorrect != null) 'last_attempt_correct': lastAttemptCorrect!.toString(),
    if (lastAttemptTotal != null) 'last_attempt_total': lastAttemptTotal!.toString(),
    if (lastAttemptTime != null) 'last_attempt_time': lastAttemptTime!.toString(),
    if (lastAttemptDate != null) 'last_attempt_date': lastAttemptDate!,
  };
}
