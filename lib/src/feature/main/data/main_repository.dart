import 'package:dio/dio.dart';

import '../../../common/constant/urls.dart';
import '../model/login_with_telegram.dart';

abstract interface class IMainRepository {
  Future<void> getMe();

  Future<LoginWithTelegramResponse> signInWithTelegram(LoginWithTelegramRequest request);
}

final class MainRepositoryImpl implements IMainRepository {
  const MainRepositoryImpl({required this.dio});
  final Dio dio;

  @override
  Future<void> getMe() async {
    await dio.get<Map<String, Object?>>(Urls.getMe);
  }

  @override
  Future<LoginWithTelegramResponse> signInWithTelegram(LoginWithTelegramRequest request) async {
    final response = await dio.post<Map<String, Object?>>(Urls.loginWithTelegram, data: request.toJson());
    return LoginWithTelegramResponse.fromJson(response.data ?? {});
  }
}
