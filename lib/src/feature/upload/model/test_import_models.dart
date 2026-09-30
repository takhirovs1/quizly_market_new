/// Represents a specific validation error in an uploaded XLSX row.
class ImportRowError {
  const ImportRowError({required this.row, required this.message});

  factory ImportRowError.fromJson(Map<String, Object?> json) =>
      ImportRowError(row: (json['row'] as num?)?.toInt() ?? 0, message: (json['message'] ?? '').toString());

  final int row;
  final String message;

  Map<String, Object?> toJson() => {'row': row, 'message': message};
}

/// Pricing breakdown included in import responses.
class ImportPricing {
  const ImportPricing({required this.perQuestionPrice, required this.cashbackPercent, required this.publishFee});

  factory ImportPricing.fromJson(Map<String, Object?> json) => ImportPricing(
    perQuestionPrice: (json['per_question_price'] as num?)?.toInt() ?? 100,
    cashbackPercent: (json['cashback_percent'] as num?)?.toInt() ?? 20,
    publishFee: (json['publish_fee'] as num?)?.toInt() ?? 0,
  );

  final int perQuestionPrice;
  final int cashbackPercent;
  final int publishFee;

  Map<String, Object?> toJson() => {
    'per_question_price': perQuestionPrice,
    'cashback_percent': cashbackPercent,
    'publish_fee': publishFee,
  };
}

/// Response returned from dry-run import (`POST /api/tests/import?dry_run=true`).
class TestImportDryRunResponse {
  const TestImportDryRunResponse({
    required this.name,
    required this.questionCount,
    required this.errors,
    required this.warnings,
    this.pricing,
  });

  factory TestImportDryRunResponse.fromJson(Map<String, Object?> json) {
    final data = (json['data'] as Map<String, Object?>?) ?? json;
    final errorsList = data['errors'] as List<Object?>? ?? [];
    final warningsList = data['warnings'] as List<Object?>? ?? [];
    final pricingMap = data['pricing'] as Map<String, Object?>?;

    return TestImportDryRunResponse(
      name: (data['name'] ?? '').toString(),
      questionCount: (data['question_count'] as num?)?.toInt() ?? 0,
      errors: errorsList.whereType<Map<String, Object?>>().map(ImportRowError.fromJson).toList(),
      warnings: warningsList.map((e) => e.toString()).toList(),
      pricing: pricingMap != null ? ImportPricing.fromJson(pricingMap) : null,
    );
  }

  final String name;
  final int questionCount;
  final List<ImportRowError> errors;
  final List<String> warnings;
  final ImportPricing? pricing;

  bool get hasErrors => errors.isNotEmpty;
  bool get isValid => errors.isEmpty;
}

/// Response returned from real import (`POST /api/tests/import`).
class TestImportResponse {
  const TestImportResponse({
    required this.testId,
    required this.testCode,
    required this.status,
    this.name,
    this.pricing,
    this.warnings = const [],
  });

  factory TestImportResponse.fromJson(Map<String, Object?> json) {
    final data = (json['data'] as Map<String, Object?>?) ?? json;
    final testMap = data['test'] as Map<String, Object?>? ?? data;
    final pricingMap = data['pricing'] as Map<String, Object?>?;
    final warningsList = data['warnings'] as List<Object?>? ?? [];

    return TestImportResponse(
      testId: (testMap['id'] ?? '').toString(),
      testCode: (testMap['code'] ?? '').toString(),
      status: (testMap['status'] ?? 'draft').toString(),
      name: testMap['name']?.toString(),
      pricing: pricingMap != null ? ImportPricing.fromJson(pricingMap) : null,
      warnings: warningsList.map((e) => e.toString()).toList(),
    );
  }

  final String testId;
  final String testCode;
  final String status;
  final String? name;
  final ImportPricing? pricing;
  final List<String> warnings;
}
