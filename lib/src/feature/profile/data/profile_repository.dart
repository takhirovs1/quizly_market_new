import 'package:dio/dio.dart';

import '../../../common/constant/urls.dart';
import '../model/profile_model.dart';

abstract interface class IProfileRepository {
  Future<ProfileModelResponse> getProfile();
  Future<void> updateLanguage(String language);
}

final class ProfileRepositoryImpl implements IProfileRepository {
  const ProfileRepositoryImpl({required this.dio});
  final Dio dio;

  @override
  Future<ProfileModelResponse> getProfile() async {
    final response = await dio.get<Map<String, Object?>>(Urls.getMe);
    final root = response.data ?? {};
    final data = root['data'] as Map<String, Object?>? ?? root;
    return ProfileModelResponse.fromJson(data);
  }

  @override
  Future<void> updateLanguage(String language) async {
    await dio.put<void>(Urls.updateLanguage, data: {'language': language});
  }
}
