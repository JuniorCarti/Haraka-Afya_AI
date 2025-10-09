import 'package:shared_preferences/shared_preferences.dart';

class DataSharingService {
  static const String _dataSharingEnabledKey = 'data_sharing_enabled';
  static const String _dataSharingTypesKey = 'data_sharing_types';
  static const String _dataAnonymizationKey = 'data_anonymization_enabled';

  // Data types that can be shared
  static const Map<String, String> dataTypes = {
    'health_metrics': 'Health Metrics (blood pressure, heart rate)',
    'symptoms': 'Symptoms and medical history',
    'medication': 'Medication usage patterns',
    'lifestyle': 'Lifestyle and activity data',
    'demographics': 'Age, gender, and demographic info',
  };

  // Research purposes
  static const Map<String, String> researchPurposes = {
    'medical_research': 'Medical research studies',
    'treatment_improvement': 'Treatment improvement analysis',
    'public_health': 'Public health trends',
    'ai_training': 'AI model training (anonymized)',
  };

  // Check if data sharing is enabled
  Future<bool> isDataSharingEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_dataSharingEnabledKey) ?? false;
  }

  // Set data sharing enabled/disabled
  Future<void> setDataSharingEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_dataSharingEnabledKey, enabled);
  }

  // Get selected data types for sharing
  Future<Set<String>> getSelectedDataTypes() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? types = prefs.getStringList(_dataSharingTypesKey);
    return types != null ? Set.from(types) : Set.from(dataTypes.keys);
  }

  // Set selected data types for sharing
  Future<void> setSelectedDataTypes(Set<String> types) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_dataSharingTypesKey, types.toList());
  }

  // Check if data anonymization is enabled
  Future<bool> isAnonymizationEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_dataAnonymizationKey) ?? true; // Default to true for privacy
  }

  // Set data anonymization enabled/disabled
  Future<void> setAnonymizationEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_dataAnonymizationKey, enabled);
  }

  // Get data type display name
  String getDataTypeName(String key) {
    return dataTypes[key] ?? key;
  }

  // Get research purpose display name
  String getResearchPurposeName(String key) {
    return researchPurposes[key] ?? key;
  }

  // Get all data type keys
  List<String> getDataTypeKeys() {
    return dataTypes.keys.toList();
  }

  // Get all research purpose keys
  List<String> getResearchPurposeKeys() {
    return researchPurposes.keys.toList();
  }
}