class EmergencyDetector {
  static const List<String> emergencyKeywords = [
    'chest pain',
    "can't breathe",
    'severe bleeding',
  ];

  static bool isEmergency(String input) {
    final lower = input.toLowerCase();
    return emergencyKeywords.any(lower.contains);
  }
}
