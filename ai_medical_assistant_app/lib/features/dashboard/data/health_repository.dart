import 'package:dio/dio.dart';

import '../../../core/constants/api_constants.dart';
import '../../../shared/models/health_data.dart';

class HealthRepository {
  final Dio _dio;

  HealthRepository(this._dio);

  Future<HealthData> fetchHealthData() async {
    final response = await _dio.get(ApiConstants.healthData);
    return HealthData.fromJson(Map<String, dynamic>.from(response.data as Map));
  }

  Future<void> updateHealthData({required int steps, required int heartRate, required double sleepHours}) async {
    await _dio.post(
      ApiConstants.healthData,
      data: {
        'steps': steps,
        'heart_rate': heartRate,
        'sleep_hours': sleepHours,
      },
    );
  }
}
