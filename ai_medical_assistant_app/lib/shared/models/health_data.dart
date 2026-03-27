class HealthData {
  final int steps;
  final int heartRate;
  final double sleepHours;

  HealthData({required this.steps, required this.heartRate, required this.sleepHours});

  factory HealthData.fromJson(Map<String, dynamic> json) {
    return HealthData(
      steps: json['steps'] as int? ?? 0,
      heartRate: json['heart_rate'] as int? ?? 0,
      sleepHours: (json['sleep_hours'] as num?)?.toDouble() ?? 0,
    );
  }
}
