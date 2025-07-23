class HealthStats {
  final double? height;
  final double? weight;
  final String bloodPressure;
  final double? bloodSugar;
  final int? heartRate;
  final String bloodType;

  HealthStats({
    this.height,
    this.weight,
    this.bloodPressure = '',
    this.bloodSugar,
    this.heartRate,
    this.bloodType = '',
  });

  factory HealthStats.fromMap(Map<String, dynamic>? data) {
    return HealthStats(
      height: data?['height']?.toDouble(),
      weight: data?['weight']?.toDouble(),
      bloodPressure: data?['bloodPressure'] ?? '',
      bloodSugar: data?['bloodSugar']?.toDouble(),
      heartRate: data?['heartRate']?.toInt(),
      bloodType: data?['bloodType'] ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
    'height': height,
    'weight': weight,
    'bloodPressure': bloodPressure,
    'bloodSugar': bloodSugar,
    'heartRate': heartRate,
    'bloodType': bloodType,
  };
}