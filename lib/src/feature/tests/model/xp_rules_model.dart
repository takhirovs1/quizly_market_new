import '../../../common/extension/number_extension.dart';

/// GET /api/xp/rules — the "XP qanday yig'iladi?" sheet.
class XpRulesResponse {
  const XpRulesResponse({this.rules = const <XpRule>[]});

  factory XpRulesResponse.fromJson(Map<String, Object?> json) {
    final root = json['data'] is Map<String, Object?> ? json['data']! as Map<String, Object?> : json;
    final list = (root['rules'] ?? json['data']) as List<Object?>? ?? const <Object?>[];
    return XpRulesResponse(rules: list.whereType<Map<String, Object?>>().map(XpRule.fromJson).toList());
  }

  final List<XpRule> rules;
}

class XpRule {
  const XpRule({
    required this.type,
    required this.xp,
    required this.text,
    required this.title,
    required this.description,
    required this.cap,
  });

  factory XpRule.fromJson(Map<String, Object?> json) => XpRule(
    type: json['type'] as String? ?? '',
    xp: json['xp'].toIntOrNull ?? 0,
    text: json['text'] as String? ?? '',
    title: json['title'] as String? ?? '',
    description: json['description'] as String? ?? '',
    cap: json['cap'] as String? ?? '',
  );

  final String type;
  final int xp;

  /// Short label ("Har bir to'g'ri javob").
  final String text;
  final String title;
  final String description;

  /// Daily-cap note, "" when none.
  final String cap;
}
