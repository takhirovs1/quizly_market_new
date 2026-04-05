class TestResultResponseModel {
  TestResultResponseModel({
    this.id,
    this.userId,
    this.testId,
    this.purchaseId,
    this.status,
    this.correctCount,
    this.totalQuestions,
    this.score,
    this.startedAt,
    this.finishedAt,
    this.timeSpentSec,
    this.createdAt,
    this.updatedAt,
    this.skipCount,
    this.mode,
  });
  factory TestResultResponseModel.fromJson(Map<String, Object?> json) => TestResultResponseModel(
    id: json['id'] as int?,
    userId: json['user_id'] as String?,
    testId: json['test_id'] as int?,
    purchaseId: json['purchase_id'] as int?,
    status: json['status'] as String?,
    correctCount: json['correct_count'] as int?,
    totalQuestions: json['total_questions'] as int?,
    score: json['score'] as int?,
    startedAt: json['started_at'] == null ? null : DateTime.parse(json['started_at'] as String),
    finishedAt: json['finished_at'] == null ? null : DateTime.parse(json['finished_at'] as String),
    timeSpentSec: json['time_spent_sec'] as int?,
    skipCount: json['skip_count'] as int?,
    mode: json['mode'] as String?,
    createdAt: json['created_at'] == null ? null : DateTime.parse(json['created_at'] as String),
    updatedAt: json['updated_at'] == null ? null : DateTime.parse(json['updated_at'] as String),
  );
  final int? id;
  final String? userId;
  final int? testId;
  final int? purchaseId;
  final String? status;
  final int? correctCount;
  final int? totalQuestions;
  final int? score;
  final DateTime? startedAt;
  final DateTime? finishedAt;
  final int? timeSpentSec;
  final int? skipCount;
  final String? mode;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Map<String, Object?> toJson() => {
    'id': id,
    'user_id': userId,
    'test_id': testId,
    'purchase_id': purchaseId,
    'status': status,
    'correct_count': correctCount,
    'total_questions': totalQuestions,
    'score': score,
    'started_at': startedAt?.toIso8601String(),
    'finished_at': finishedAt?.toIso8601String(),
    'time_spent_sec': timeSpentSec,
    'skip_count': skipCount,
    'mode': mode,
    'created_at': createdAt?.toIso8601String(),
    'updated_at': updatedAt?.toIso8601String(),
  };
}
