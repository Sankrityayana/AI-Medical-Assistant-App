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

  Future<Medication> addMedication(Medication medication) async {
    final response = await _dio.post(ApiConstants.medications, data: medication.toJson());
    return Medication.fromJson(Map<String, dynamic>.from(response.data as Map));
  }

  Future<void> markTaken(int id, bool taken) async {
    await _dio.patch('${ApiConstants.medications}/$id', data: {'is_taken': taken});
  }

  Future<Medication> updateMedication({
    required int id,
    required String name,
    required String dosage,
    required String reminderTime,
  }) async {
    final response = await _dio.patch(
      '${ApiConstants.medications}/$id',
      data: {
        'name': name,
        'dosage': dosage,
        'reminder_time': reminderTime,
      },
    );
    return Medication.fromJson(Map<String, dynamic>.from(response.data as Map));
  }

  Future<void> deleteMedication(int id) async {
    await _dio.delete('${ApiConstants.medications}/$id');
  }
}
