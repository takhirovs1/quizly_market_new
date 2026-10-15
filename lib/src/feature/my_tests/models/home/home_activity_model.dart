/// GET /home/activity — docs/home-flow.en.md §4.8 / §5.
/// Weekly finished-session bar chart (Mon–Sun) + total, delta vs last week,
/// and the current streak.
class HomeActivityRequest {
  const HomeActivityRequest();

  Map<String, Object?> toJson() => const <String, Object?>{};
}

class HomeActivityResponse {
  const HomeActivityResponse({this.days = const [], this.totalThisWeek = 0, this.deltaPercent = 0, this.streak = 0});

  factory HomeActivityResponse.fromJson(Map<String, Object?> json) {
    final root = json['data'] is Map<String, Object?> ? json['data']! as Map<String, Object?> : json;
    final days = root['days'] as List<Object?>? ?? const <Object?>[];
    return HomeActivityResponse(
      days: days.whereType<Map<String, Object?>>().map(ActivityDay.fromJson).toList(),
      totalThisWeek: (root['total_this_week'] as num?)?.toInt() ?? 0,
      deltaPercent: (root['delta_percent'] as num?)?.toInt() ?? 0,
      streak: (root['streak'] as num?)?.toInt() ?? 0,
    );
  }

  final List<ActivityDay> days;
  final int totalThisWeek;
  final int deltaPercent;
  final int streak;
}

class ActivityDay {
  const ActivityDay({required this.weekday, required this.count, required this.isToday});

  factory ActivityDay.fromJson(Map<String, Object?> json) => ActivityDay(
    weekday: (json['weekday'] as num?)?.toInt() ?? 1,
    count: (json['count'] as num?)?.toInt() ?? 0,
    isToday: json['is_today'] as bool? ?? false,
  );

  /// 1 = Monday … 7 = Sunday.
  final int weekday;
  final int count;
  final bool isToday;
}
