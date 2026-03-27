import 'package:dio/dio.dart';

import '../../../core/constants/api_constants.dart';

class ChatRepository {
  final Dio _dio;

  ChatRepository(this._dio);

  Future<Map<String, dynamic>> askAi(String symptomText) async {
    final response = await _dio.post(
      ApiConstants.askAi,
      data: {'symptom_text': symptomText},
    );
    return Map<String, dynamic>.from(response.data as Map);
  }
}
