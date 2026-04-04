import 'package:dio/dio.dart';

import '../../../common/constant/urls.dart';
import '../models/test_mode.dart';

abstract interface class IMyTestRepository {
  Future<List<TestModel>> getMyTests(TestModelRequest request);
}

final class MyTestRepositoryImpl implements IMyTestRepository {
  const MyTestRepositoryImpl({required this.dio});
  final Dio dio;

  @override
  Future<List<TestModel>> getMyTests(TestModelRequest request) async {
    final response = await dio.get<Map<String, Object?>>(Urls.getMyTests, queryParameters: request.toJson());
    return (response.data?['items'] as List<Map<String, Object?>>?)?.map(TestModel.fromJson).toList() ?? [];
  }
}
