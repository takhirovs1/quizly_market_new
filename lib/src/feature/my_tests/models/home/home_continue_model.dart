import 'home_enums.dart';

/// GET /home/continue — docs/home-flow.en.md §4.1 / §5.
/// 200 → the most recent in-progress (test/exam/flashcard) session to resume.
/// 204 → no card; [HomeContinueResponse.data] is null and the client hides it.
class HomeContinueRequest {
  const HomeContinueRequest();

  Map<String, Object?> toJson() => const <String, Object?>{};
}

class HomeContinueResponse {
  const HomeContinueResponse({this.data});

  factory HomeContinueResponse.fromJson(Map<String, Object?> json) {
    final root = json['data'] is Map<String, Object?> ? json['data']! as Map<String, Object?> : json;
    if (root['session_id'] == null && root['test'] == null) return const HomeContinueResponse();
    return HomeContinueResponse(data: ContinueCardData.fromJson(root));
  }

  final ContinueCardData? data;
}

class ContinueCardData {
  const ContinueCardData({
    required this.sessionId,
    required this.testId,
    required this.testName,
    required this.organizationName,
    required this.organizationVerified,
    required this.imageUrl,
    required this.color,
    required this.mode,
    required this.answered,
    required this.total,
    required this.percent,
    required this.lastActivityAt,
  });

  factory ContinueCardData.fromJson(Map<String, Object?> json) {
    final test = json['test'] as Map<String, Object?>? ?? const <String, Object?>{};
    final org = test['organization'] as Map<String, Object?>? ?? const <String, Object?>{};
    return ContinueCardData(
      sessionId: json['session_id'] as String? ?? '',
      testId: test['id'] as String? ?? '',
      testName: test['name'] as String? ?? '',
      organizationName: org['name'] as String? ?? '',
      organizationVerified: org['verified'] as bool? ?? false,
      imageUrl: test['image_url'] as String? ?? '',
      color: test['color'] as String?,
      mode: SessionMode.fromValue(json['mode'] as String?),
      answered: (json['answered'] as num?)?.toInt() ?? 0,
      total: (json['total'] as num?)?.toInt() ?? 0,
      percent: (json['percent'] as num?)?.toInt() ?? 0,
      lastActivityAt: DateTime.tryParse(json['last_activity_at'] as String? ?? ''),
    );
  }

  final String sessionId;
  final String testId;
  final String testName;
  final String organizationName;
  final bool organizationVerified;

  /// Thumbnail URL; empty → solid [color] tile (v5 §5.3).
  final String imageUrl;

  /// Deterministic per-test hex tile color (v5 §5.3). Null → theme fallback.
  final String? color;
  final SessionMode mode;
  final int answered;
  final int total;
  final int percent;
  final DateTime? lastActivityAt;
}
