import '../../../common/extension/number_extension.dart';

/// GET /api/tests/:id/rating — the per-test leaderboard (Figma "C · Test rating").
/// Ranked by each participant's first finished test/exam attempt.
class TestRatingResponse {
  const TestRatingResponse({
    this.entries = const <RatingEntry>[],
    this.me,
    this.canJoin = false,
    this.totalParticipants = 0,
  });

  factory TestRatingResponse.fromJson(Map<String, Object?> json) {
    final root = json['data'] is Map<String, Object?> ? json['data']! as Map<String, Object?> : json;
    final list = root['entries'] as List<Object?>? ?? const <Object?>[];
    final me = root['me'] as Map<String, Object?>?;
    return TestRatingResponse(
      entries: list.whereType<Map<String, Object?>>().map(RatingEntry.fromJson).toList(),
      me: me == null ? null : RatingEntry.fromJson(me),
      canJoin: root['can_join'] as bool? ?? false,
      totalParticipants: root['total_participants'].toIntOrNull ?? 0,
    );
  }

  final List<RatingEntry> entries;

  /// The caller's pinned row; null until they finish a first attempt.
  final RatingEntry? me;

  /// No row yet and the caller may still attempt the test (shows the join card).
  final bool canJoin;
  final int totalParticipants;
}

class RatingEntry {
  const RatingEntry({
    required this.rank,
    required this.name,
    required this.color,
    required this.avatarUrl,
    required this.scorePercent,
    required this.durationSec,
    required this.isMe,
  });

  factory RatingEntry.fromJson(Map<String, Object?> json) {
    final user = json['user'] as Map<String, Object?>? ?? const <String, Object?>{};
    return RatingEntry(
      rank: json['rank'].toIntOrNull ?? 0,
      name: user['name'] as String? ?? '',
      color: user['color'] as String?,
      avatarUrl: (user['avatar_url'] as String?)?.isNotEmpty == true ? user['avatar_url'] as String? : null,
      scorePercent: json['score_percent'].toIntOrNull ?? 0,
      durationSec: json['duration_sec'].toIntOrNull,
      isMe: json['is_me'] as bool? ?? false,
    );
  }

  final int rank;
  final String name;

  /// Deterministic avatar tile colour (hex); null → theme fallback.
  final String? color;
  final String? avatarUrl;
  final int scorePercent;
  final int? durationSec;
  final bool isMe;

  String get initial => name.isNotEmpty ? name.substring(0, 1).toUpperCase() : '?';
}
