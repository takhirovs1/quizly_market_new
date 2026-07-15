import '../../../common/constant/urls.dart';
import '../../../common/service/api_client.dart';
import '../model/login_with_telegram.dart';

abstract interface class IMainRepository {
  Future<void> getMe();

  Future<LoginWithTelegramResponse> signInWithTelegram(LoginWithTelegramRequest request);
}

final class MainRepositoryImpl implements IMainRepository {
  const MainRepositoryImpl({required this.apiClient});
  final ApiClient apiClient;

  @override
  Future<void> getMe() async {
    await apiClient.get(Urls.getMe);
  }

  @override
  Future<LoginWithTelegramResponse> signInWithTelegram(LoginWithTelegramRequest request) async {
    final response = await apiClient.post(Urls.loginWithTelegram, body: request.toJson());
    return LoginWithTelegramResponse.fromJson(response);
  }
}
