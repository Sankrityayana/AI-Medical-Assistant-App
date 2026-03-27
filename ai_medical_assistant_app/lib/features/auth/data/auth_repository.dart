import 'package:dio/dio.dart';

import '../../../core/constants/api_constants.dart';

class AuthRepository {
  final Dio _dio;

  AuthRepository(this._dio);

  Future<void> register({required String username, required String email, required String password}) async {
    await _dio.post(
      ApiConstants.register,
      data: {
        'username': username,
        'email': email,
        'password': password,
      },
    );
  }

  Future<Map<String, dynamic>> login({required String username, required String password}) async {
    final response = await _dio.post(
      ApiConstants.login,
      data: {
        'username': username,
        'password': password,
      },
    );
    return Map<String, dynamic>.from(response.data as Map);
  }
}
