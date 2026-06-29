import '../../../common/extension/string_extension.dart';
import '../../../common/util/app_enum.dart';

class TestAttemptRequest {
  const TestAttemptRequest({this.limit = 20, this.offset = 0, this.mode});

  final int limit;
  final int offset;
  final TestMode? mode;

  Map<String, Object?> toJson() => {'limit': limit, 'offset': offset, if (mode != null) 'mode': mode?.value};
}

class TestAttemptResponse {
  const TestAttemptResponse({required this.items, required this.limit, required this.offset, required this.total});

  factory TestAttemptResponse.fromJson(Map<String, Object?> json) {
    final list = json['data'] as List<Object?>? ?? [];
    return TestAttemptResponse(
      items: list.map((e) => TestAttempt.fromJson(e as Map<String, Object?>)).toList(),
      limit: json['limit'] as int? ?? 20,
      offset: json['offset'] as int? ?? 0,
      total: json['total'] as int? ?? 0,
    );
  }

  final List<TestAttempt> items;
  final int limit;
  final int offset;
  final int total;
}

class TestAttempt {
  const TestAttempt({
    required this.id,
    required this.testId,
    required this.score,
    required this.correctAnswers,
    required this.totalQuestions,
    required this.timeSpent,
    required this.createdAt,
    required this.status,
    this.skipCount = 0,
  });

  factory TestAttempt.fromJson(Map<String, Object?> json) => TestAttempt(
    id: json['id']?.toString() ?? '',
    testId: json['test_id']?.toString() ?? '',
    score: (json['score'] as num?)?.toDouble() ?? 0.0,
    correctAnswers: (json['correct_count'] as num?)?.toInt() ?? (json['correct_answers'] as num?)?.toInt() ?? 0,
    totalQuestions: (json['total_questions'] as num?)?.toInt() ?? 0,
    timeSpent: (json['time_spent_sec'] as num?)?.toInt() ?? (json['time_spent'] as num?)?.toInt() ?? 0,
    createdAt: json['created_at'].toDateTimeOrNull ?? DateTime.now(),
    status: json['status'] as String? ?? 'completed',
    skipCount: (json['skip_count'] as num?)?.toInt() ?? 0,
  );

  final String id;
  final String testId;
  final double score;
  final int correctAnswers;
  final int totalQuestions;
  final int timeSpent;
  final DateTime createdAt;
  final String status;
  final int skipCount;
}
