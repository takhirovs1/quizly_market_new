import '../../../common/service/api_client.dart';
import '../../../common/util/logger.dart';
import '../../my_tests/models/demo_test_model.dart';
import '../model/manual_test_create_model.dart';
import '../model/publish_models.dart';
import '../model/test_import_models.dart';
import '../model/upload_pricing_model.dart';
import '../model/uploaded_test_model.dart';

abstract interface class IUploadRepository {
  /// Fetches dynamic pricing values (per_question_price, cashback_percent, min_questions).
  Future<UploadPricingModel> getPricing();

  /// Validates an Excel file without persisting (`POST /api/tests/import?dry_run=true`).
  Future<TestImportDryRunResponse> importDryRun({
    required List<int> fileBytes,
    required String fileName,
    required String name,
    String? description,
    String? categoryId,
    int? price,
    bool? isFree,
  });

  /// Imports an Excel file to create a draft test (`POST /api/tests/import`).
  Future<TestImportResponse> importTest({
    required List<int> fileBytes,
    required String fileName,
    required String name,
    String? description,
    String? categoryId,
    int? price,
    bool? isFree,
  });

  /// Creates a draft test manually with questions and options (`POST /api/tests`).
  Future<ManualTestCreateResponse> createManualTest(ManualTestCreateRequest request);

  /// Gets the publish quote for a draft test (`GET /api/tests/:id/publish-quote`).
  Future<PublishQuoteModel> getPublishQuote(String testId);

  /// Publishes a draft test by deducting the fee from the user's wallet (`POST /api/payments/tests/:id/publish`).
  Future<PublishWalletResponse> publishFromWallet(String testId);

  /// Initializes payment checkout (Payme or Click) for publishing (`POST /api/payments/tests/:id/publish/checkout`).
  Future<PublishCheckoutResponse> publishCheckout(String testId, {required String provider, String? redirectUrl});

  /// Polls payment status for card checkout (`GET /api/payments/:payment_id/status`).
  Future<PaymentStatusResponse> getPaymentStatus(String paymentId);

  /// Fetches customer tests with optional status filter (`GET /api/tests/my?status=...`).
  Future<List<UploadedTestModel>> getMyUploadedTests({String? status, int limit = 50, int offset = 0});

  /// Fetches test questions for preview (`GET /api/tests/:id/questions`).
  Future<List<DemoQuestion>> getTestQuestions(String testId);

  /// Downloads the Excel template workbook (`GET /api/tests/import/template`).
  Future<List<int>> downloadTemplate();
}

final class UploadRepositoryImpl implements IUploadRepository {
  const UploadRepositoryImpl({required this.apiClient});

  final ApiClient apiClient;

  @override
  Future<UploadPricingModel> getPricing() async {
    try {
      final response = await apiClient.get('/api/tests/pricing');
      return UploadPricingModel.fromJson(response);
    } catch (e, s) {
      info('GET PRICING API ERROR: $e $s');
      rethrow;
    }
  }

  @override
  Future<TestImportDryRunResponse> importDryRun({
    required List<int> fileBytes,
    required String fileName,
    required String name,
    String? description,
    String? categoryId,
    int? price,
    bool? isFree,
  }) async {
    try {
      final fields = <String, String>{
        'name': name,
        if (description != null && description.isNotEmpty) 'description': description,
        if (categoryId != null && categoryId.isNotEmpty) 'category_id': categoryId,
        if (price != null) 'price': price.toString(),
        if (isFree != null) 'is_free': isFree.toString(),
      };

      final response = await apiClient.multipartPost(
        '/api/tests/import',
        field: 'file',
        bytes: fileBytes,
        filename: fileName,
        fields: fields,
        queryParameters: {'dry_run': 'true'},
      );

      return TestImportDryRunResponse.fromJson(response);
    } catch (e, s) {
      info('IMPORT DRY RUN API ERROR: $e $s');
      rethrow;
    }
  }

  @override
  Future<TestImportResponse> importTest({
    required List<int> fileBytes,
    required String fileName,
    required String name,
    String? description,
    String? categoryId,
    int? price,
    bool? isFree,
  }) async {
    try {
      final fields = <String, String>{
        'name': name,
        if (description != null && description.isNotEmpty) 'description': description,
        if (categoryId != null && categoryId.isNotEmpty) 'category_id': categoryId,
        if (price != null) 'price': price.toString(),
        if (isFree != null) 'is_free': isFree.toString(),
      };

      final response = await apiClient.multipartPost(
        '/api/tests/import',
        field: 'file',
        bytes: fileBytes,
        filename: fileName,
        fields: fields,
      );

      return TestImportResponse.fromJson(response);
    } catch (e, s) {
      info('IMPORT TEST API ERROR: $e $s');
      rethrow;
    }
  }

  @override
  Future<ManualTestCreateResponse> createManualTest(ManualTestCreateRequest request) async {
    try {
      final response = await apiClient.post('/api/tests', body: request.toJson());
      return ManualTestCreateResponse.fromJson(response);
    } catch (e, s) {
      info('CREATE MANUAL TEST API ERROR: $e $s');
      rethrow;
    }
  }

  @override
  Future<PublishQuoteModel> getPublishQuote(String testId) async {
    try {
      final response = await apiClient.get('/api/tests/$testId/publish-quote');
      return PublishQuoteModel.fromJson(response);
    } catch (e, s) {
      info('GET PUBLISH QUOTE API ERROR: $e $s');
      rethrow;
    }
  }

  @override
  Future<PublishWalletResponse> publishFromWallet(String testId) async {
    try {
      final response = await apiClient.post('/api/payments/tests/$testId/publish');
      return PublishWalletResponse.fromJson(response);
    } catch (e, s) {
      info('PUBLISH WALLET API ERROR: $e $s');
      rethrow;
    }
  }

  @override
  Future<PublishCheckoutResponse> publishCheckout(
    String testId, {
    required String provider,
    String? redirectUrl,
  }) async {
    try {
      final body = <String, Object?>{
        'provider': provider,
        if (redirectUrl != null && redirectUrl.isNotEmpty) 'redirect_url': redirectUrl,
      };
      final response = await apiClient.post('/api/payments/tests/$testId/publish/checkout', body: body);
      return PublishCheckoutResponse.fromJson(response);
    } catch (e, s) {
      info('PUBLISH CHECKOUT API ERROR: $e $s');
      rethrow;
    }
  }

  @override
  Future<PaymentStatusResponse> getPaymentStatus(String paymentId) async {
    try {
      final response = await apiClient.get('/api/payments/$paymentId/status');
      return PaymentStatusResponse.fromJson(response);
    } catch (e, s) {
      info('GET PAYMENT STATUS API ERROR: $e $s');
      rethrow;
    }
  }

  @override
  Future<List<UploadedTestModel>> getMyUploadedTests({String? status, int limit = 50, int offset = 0}) async {
    try {
      final queryParams = <String, Object?>{
        if (status != null && status.isNotEmpty) 'status': status,
        'limit': limit,
        'offset': offset,
      };
      final response = await apiClient.get('/api/tests/my', queryParameters: queryParams);
      final data = response['data'];
      final List<Object?> items;
      if (data is List) {
        items = data;
      } else if (data is Map && data['items'] is List) {
        items = data['items'] as List<Object?>;
      } else if (data is Map && data['tests'] is List) {
        items = data['tests'] as List<Object?>;
      } else {
        items = [];
      }

      return items.whereType<Map<String, Object?>>().map(UploadedTestModel.fromJson).toList();
    } catch (e, s) {
      info('GET MY UPLOADED TESTS API ERROR: $e $s');
      rethrow;
    }
  }

  @override
  Future<List<DemoQuestion>> getTestQuestions(String testId) async {
    try {
      final response = await apiClient.get('/api/tests/$testId/questions');
      final dataMap = response['data'] as Map<String, Object?>?;
      final list = dataMap?['questions'] as List<Object?>? ?? [];
      return list.whereType<Map<String, Object?>>().map(DemoQuestion.fromJson).toList();
    } on Object catch (e, s) {
      info('GET TEST QUESTIONS ERROR: $e $s');
      return const [];
    }
  }

  @override
  Future<List<int>> downloadTemplate() async {
    try {
      return await apiClient.getBytes('/api/tests/import/template');
    } catch (e, s) {
      info('DOWNLOAD TEMPLATE API ERROR: $e $s');
      rethrow;
    }
  }
}
