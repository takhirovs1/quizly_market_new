/// GET /home/actions — docs/home-flow.en.md §5.
/// Drives the Actions row: whether the user owns tests (enables the row),
/// the mistakes badge count, and the flashcard-eligible test count.
class HomeActionsRequest {
  const HomeActionsRequest();

  Map<String, Object?> toJson() => const <String, Object?>{};
}

class HomeActionsResponse {
  const HomeActionsResponse({this.hasPurchasedTests = false, this.mistakesCount = 0, this.flashcardTestsCount = 0});

  factory HomeActionsResponse.fromJson(Map<String, Object?> json) {
    final root = json['data'] is Map<String, Object?> ? json['data']! as Map<String, Object?> : json;
    return HomeActionsResponse(
      hasPurchasedTests: root['has_purchased_tests'] as bool? ?? false,
      mistakesCount: (root['mistakes_count'] as num?)?.toInt() ?? 0,
      flashcardTestsCount: (root['flashcard_tests_count'] as num?)?.toInt() ?? 0,
    );
  }

  final bool hasPurchasedTests;
  final int mistakesCount;
  final int flashcardTestsCount;
}
