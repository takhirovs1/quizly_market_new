import 'home_enums.dart';

/// GET /me/tests?status=&limit=3 — docs/home-flow.en.md §5 ("My tests preview
/// + counts per status"). Live on the real backend (client-integration-v5.md
/// §3.3): items carry progress/mode/last_opened/rating and top-level counts.
class MyTestsPreviewRequest {
  const MyTestsPreviewRequest({this.status, this.limit = 3});

  final String? status;
  final int limit;

  Map<String, Object?> toJson() => <String, Object?>{
    if (status != null && status!.isNotEmpty) 'status': status,
    'limit': limit,
  };
}

class MyTestsPreviewResponse {
  const MyTestsPreviewResponse({this.items = const [], this.counts = const MyTestsStatusCounts()});

  factory MyTestsPreviewResponse.fromJson(Map<String, Object?> json) {
    final root = json['data'] is Map<String, Object?> ? json['data']! as Map<String, Object?> : json;
    final list = root['items'] as List<Object?>? ?? const <Object?>[];
    return MyTestsPreviewResponse(
      items: list.whereType<Map<String, Object?>>().map(MyTestPreviewItem.fromJson).toList(),
      counts: MyTestsStatusCounts.fromJson(root['counts'] as Map<String, Object?>? ?? const <String, Object?>{}),
    );
  }

  final List<MyTestPreviewItem> items;
  final MyTestsStatusCounts counts;
}

class MyTestsStatusCounts {
  const MyTestsStatusCounts({this.all = 0, this.notStarted = 0, this.inProgress = 0, this.completed = 0});

  factory MyTestsStatusCounts.fromJson(Map<String, Object?> json) => MyTestsStatusCounts(
    all: (json['all'] as num?)?.toInt() ?? 0,
    notStarted: (json['not_started'] as num?)?.toInt() ?? 0,
    inProgress: (json['in_progress'] as num?)?.toInt() ?? 0,
    completed: (json['completed'] as num?)?.toInt() ?? 0,
  );

  final int all;
  final int notStarted;
  final int inProgress;
  final int completed;
}

class MyTestPreviewItem {
  const MyTestPreviewItem({
    required this.testId,
    required this.name,
    required this.organizationName,
    required this.organizationVerified,
    required this.imageUrl,
    required this.color,
    required this.status,
    required this.answered,
    required this.total,
    required this.percent,
    required this.mode,
    required this.lastOpenedAt,
    required this.bestScorePercent,
    required this.ratingRank,
    required this.ratingTotalParticipants,
  });

  factory MyTestPreviewItem.fromJson(Map<String, Object?> json) {
    final org = json['organization'] as Map<String, Object?>? ?? const <String, Object?>{};
    final rating = json['rating'] as Map<String, Object?>?;
    return MyTestPreviewItem(
      testId: json['test_id'] as String? ?? json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      organizationName: org['name'] as String? ?? '',
      organizationVerified: org['verified'] as bool? ?? false,
      imageUrl: json['image_url'] as String? ?? '',
      color: json['color'] as String?,
      status: MyTestStatus.fromValue(json['status'] as String?),
      answered: (json['answered'] as num?)?.toInt() ?? 0,
      total: (json['total'] as num?)?.toInt() ?? 0,
      percent: (json['percent'] as num?)?.toInt() ?? 0,
      mode: SessionMode.fromValue(json['mode'] as String?),
      lastOpenedAt: DateTime.tryParse(json['last_opened_at'] as String? ?? ''),
      bestScorePercent: (json['best_score_percent'] as num?)?.toInt(),
      ratingRank: (rating?['rank'] as num?)?.toInt(),
      ratingTotalParticipants: (rating?['total_participants'] as num?)?.toInt(),
    );
  }

  final String testId;
  final String name;
  final String organizationName;
  final bool organizationVerified;

  /// Thumbnail URL; empty → render a solid [color] tile with the initial (v5 §5.3).
  final String imageUrl;

  /// Deterministic per-test hex tile color (v5 §5.3). Null → theme fallback.
  final String? color;
  final MyTestStatus status;
  final int answered;
  final int total;
  final int percent;
  final SessionMode mode;
  final DateTime? lastOpenedAt;
  final int? bestScorePercent;
  final int? ratingRank;
  final int? ratingTotalParticipants;
}
