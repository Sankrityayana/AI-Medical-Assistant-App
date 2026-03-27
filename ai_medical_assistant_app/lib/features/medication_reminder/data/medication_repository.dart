import 'package:dio/dio.dart';

import '../../../core/constants/api_constants.dart';
import '../../../shared/models/medication.dart';

class MedicationRepository {
  final Dio _dio;

  MedicationRepository(this._dio);

  Future<List<Medication>> fetchMedications() async {
    final response = await _dio.get(ApiConstants.medications);
    final data = response.data as List<dynamic>;
    return data.map((e) => Medication.fromJson(Map<String, dynamic>.from(e as Map))).toList();
  }

  Future<void> addMedication(Medication medication) async {
    await _dio.post(ApiConstants.medications, data: medication.toJson());
  }

  Future<void> markTaken(int id, bool taken) async {
    await _dio.patch('${ApiConstants.medications}/$id', data: {'is_taken': taken});
  }
}
