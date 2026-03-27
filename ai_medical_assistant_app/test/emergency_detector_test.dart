import 'package:ai_medical_assistant_app/core/utils/emergency_detector.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('detects emergency keywords', () {
    expect(EmergencyDetector.isEmergency('I have severe bleeding'), isTrue);
    expect(EmergencyDetector.isEmergency('Mild headache since morning'), isFalse);
  });
}
