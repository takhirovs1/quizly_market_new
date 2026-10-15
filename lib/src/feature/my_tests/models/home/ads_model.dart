/// GET /ads?placement=home — docs/home-flow.en.md §4.10 / §5.
/// Active, non-dismissed sponsor ads ordered by priority. Empty → hide section.
class AdsRequest {
  const AdsRequest({this.placement = 'home'});

  final String placement;

  Map<String, Object?> toJson() => <String, Object?>{'placement': placement};
}

class AdsResponse {
  const AdsResponse({this.items = const []});

  factory AdsResponse.fromJson(Map<String, Object?> json) {
    final root = json['data'] is Map<String, Object?> ? json['data']! as Map<String, Object?> : json;
    final list = (root['items'] ?? json['data']) as List<Object?>? ?? const <Object?>[];
    return AdsResponse(items: list.whereType<Map<String, Object?>>().map(AdItem.fromJson).toList());
  }

  final List<AdItem> items;
}

class AdItem {
  const AdItem({
    required this.id,
    required this.sponsorName,
    required this.logoUrl,
    required this.imageUrl,
    required this.title,
    required this.ctaText,
    required this.ctaUrl,
    required this.priority,
  });

  factory AdItem.fromJson(Map<String, Object?> json) => AdItem(
    id: json['id'] as String? ?? '',
    sponsorName: json['sponsor_name'] as String? ?? '',
    logoUrl: json['logo_url'] as String? ?? '',
    imageUrl: json['image_url'] as String? ?? '',
    title: json['title'] as String? ?? '',
    ctaText: json['cta_text'] as String? ?? '',
    ctaUrl: json['cta_url'] as String? ?? '',
    priority: (json['priority'] as num?)?.toInt() ?? 0,
  );

  final String id;
  final String sponsorName;
  final String logoUrl;
  final String imageUrl;
  final String title;
  final String ctaText;
  final String ctaUrl;
  final int priority;
}
