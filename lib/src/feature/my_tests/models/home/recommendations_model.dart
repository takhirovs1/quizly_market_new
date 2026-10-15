import '../../../../common/extension/number_extension.dart';

/// GET /recommendations?limit=10 — docs/home-flow.en.md §4.11 / §5.
///
/// The real backend returns the same test shape as `/api/tests` (numeric
/// `price`/`final_price`, `seller`/`university_name`, `liked`), so [fromJson]
/// accepts both that and the v5 shape (`organization`, string `price`,
/// `is_favorite`). Numeric money is formatted client-side as a fallback.
class RecommendationsRequest {
  const RecommendationsRequest({this.limit = 10});

  final int limit;

  Map<String, Object?> toJson() => <String, Object?>{'limit': limit};
}

class RecommendationsResponse {
  const RecommendationsResponse({this.titleKey = 'personalized', this.items = const []});

  factory RecommendationsResponse.fromJson(Map<String, Object?> json) {
    final root = json['data'] is Map<String, Object?> ? json['data']! as Map<String, Object?> : json;
    final list = (root['items'] ?? json['data']) as List<Object?>? ?? const <Object?>[];
    return RecommendationsResponse(
      titleKey: root['title_key'] as String? ?? 'personalized',
      items: list.whereType<Map<String, Object?>>().map(RecommendationItem.fromJson).toList(),
    );
  }

  /// "personalized" | "popular".
  final String titleKey;
  final List<RecommendationItem> items;

  bool get isPopularFallback => titleKey == 'popular';

  RecommendationsResponse copyWith({String? titleKey, List<RecommendationItem>? items}) =>
      RecommendationsResponse(titleKey: titleKey ?? this.titleKey, items: items ?? this.items);
}

class RecommendationItem {
  const RecommendationItem({
    required this.testId,
    required this.name,
    required this.organizationName,
    required this.organizationVerified,
    required this.imageUrl,
    required this.color,
    required this.rating,
    required this.ratingCount,
    required this.questionCount,
    required this.salesText,
    required this.price,
    required this.priceAmount,
    required this.oldPrice,
    required this.iosProductId,
    required this.discountPercent,
    required this.isFavorite,
    required this.initial,
  });

  factory RecommendationItem.fromJson(Map<String, Object?> json) {
    final org = json['organization'] as Map<String, Object?>?;
    final seller = json['seller'] as Map<String, Object?>?;
    final name = json['name'] as String? ?? '';

    // Money may arrive as a server display string (v5) or a number (real
    // backend). `final_price` is the discounted price; `price` the original.
    final rawCurrent = json['final_price'] ?? json['price'];
    final currentAmount = rawCurrent.toIntOrNull;
    final originalAmount = json['price'].toIntOrNull;
    final hasDiscount = originalAmount != null && currentAmount != null && originalAmount > currentAmount;

    return RecommendationItem(
      testId: json['test_id'] as String? ?? json['id']?.toString() ?? '',
      name: name,
      organizationName:
          org?['name'] as String? ?? json['university_name'] as String? ?? seller?['name'] as String? ?? '',
      organizationVerified: (org?['verified'] ?? seller?['verified']) as bool? ?? false,
      imageUrl: json['image_url'] as String? ?? '',
      color: json['color'] as String?,
      rating: (json['rating'] ?? json['rating_avg']).toDoubleOrZero,
      ratingCount: json['rating_count'].toIntOrNull ?? 0,
      questionCount: json['question_count'].toIntOrNull ?? 0,
      salesText: json['sales_text'] as String? ?? '',
      price: _money(rawCurrent),
      priceAmount: currentAmount,
      oldPrice: json['old_price'] is String && (json['old_price'] as String).isNotEmpty
          ? json['old_price'] as String
          : (hasDiscount ? _money(json['price']) : null),
      iosProductId: json['ios_product_id'] as String? ?? '',
      discountPercent: json['discount_percent'].toIntOrNull,
      isFavorite: (json['is_favorite'] ?? json['liked']) as bool? ?? false,
      initial: name.isNotEmpty ? name.substring(0, 1).toUpperCase() : '',
    );
  }

  /// A money value that may be a server display string or a raw number →
  /// display string. Numbers are formatted client-side ("10 000 UZS").
  static String _money(Object? value) {
    if (value == null) return '';
    if (value is String) return value;
    if (value is num) return value.formatUzs;
    return value.toString();
  }

  final String testId;
  final String name;
  final String organizationName;
  final bool organizationVerified;
  final String imageUrl;

  /// Deterministic per-test hex tile color (v5 §5.3). Null → theme fallback.
  final String? color;
  final double rating;
  final int ratingCount;
  final int questionCount;
  final String salesText;

  /// Server display string in UZS (e.g. "10 000 UZS"). iOS shows StoreKit price.
  final String price;

  /// Numeric price (v5): the amount behind [price]. Null on iOS. Display uses [price].
  final int? priceAmount;
  final String? oldPrice;
  final String iosProductId;
  final int? discountPercent;
  final bool isFavorite;
  final String initial;

  RecommendationItem copyWith({bool? isFavorite}) => RecommendationItem(
    testId: testId,
    name: name,
    organizationName: organizationName,
    organizationVerified: organizationVerified,
    imageUrl: imageUrl,
    color: color,
    rating: rating,
    ratingCount: ratingCount,
    questionCount: questionCount,
    salesText: salesText,
    price: price,
    priceAmount: priceAmount,
    oldPrice: oldPrice,
    iosProductId: iosProductId,
    discountPercent: discountPercent,
    isFavorite: isFavorite ?? this.isFavorite,
    initial: initial,
  );
}
