class Medication {
  final int? id;
  final String name;
  final String dosage;
  final String reminderTime;
  final bool isTaken;

  Medication({
    this.id,
    required this.name,
    required this.dosage,
    required this.reminderTime,
    this.isTaken = false,
  });

  factory Medication.fromJson(Map<String, dynamic> json) {
    return Medication(
      id: json['id'] as int?,
      name: json['name'] as String,
      dosage: json['dosage'] as String,
      reminderTime: json['reminder_time'] as String,
      isTaken: json['is_taken'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'dosage': dosage,
      'reminder_time': reminderTime,
      'is_taken': isTaken,
    };
  }
}
