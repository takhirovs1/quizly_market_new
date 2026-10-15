/// Ad telemetry / dismissal — docs/home-flow.en.md §4.10 / §5.
/// POST /ads/{id}/dismiss · /impression · /click. Fire-and-forget (no body).
/// Separate request types per the "one model per endpoint" rule.
class AdDismissRequest {
  const AdDismissRequest({required this.adId});

  final String adId;

  Map<String, Object?> toJson() => const <String, Object?>{};
}

class AdImpressionRequest {
  const AdImpressionRequest({required this.adId});

  final String adId;

  Map<String, Object?> toJson() => const <String, Object?>{};
}

class AdClickRequest {
  const AdClickRequest({required this.adId});

  final String adId;

  Map<String, Object?> toJson() => const <String, Object?>{};
}
