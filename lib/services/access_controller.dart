import 'package:haraka_afya_ai/models/user_profile.dart';

class AccessController {
  // Allow all features for all users during development
  static bool canAccessFeature(String featureName, UserProfile user) {
    return true;
  }

  // Get all available features
  static List<String> getAccessibleFeatures(UserProfile user) {
    return [
      'health_education',
      'symptom_checker', 
      'hospital_finder',
      'ai_assistant',
      'anonymous_chat',
      'medication_reminders',
      'health_tracking',
      'care_team_chat',
      'emergency_services',
      'patient_monitoring',
      'family_chat',
      'patient_management',
      'medical_consultation',
      'prescription_management',
      'facility_management',
      'appointment_scheduling',
      'billing_management',
      'premium_ai_consultation',
      'advanced_analytics',
    ];
  }

  // Allow all screens
  static bool canAccessScreen(String screenName, UserProfile user) {
    return true;
  }

  // Get all dashboard items
  static List<Map<String, dynamic>> getDashboardItems(UserProfile user) {
    return [
      {
        'title': 'Health Education',
        'icon': '📚',
        'feature': 'health_education',
        'route': 'LearnPage',
      },
      {
        'title': 'Symptom Checker',
        'icon': '🔍',
        'feature': 'symptom_checker',
        'route': 'SymptomsPage',
      },
      {
        'title': 'Find Hospitals',
        'icon': '🏥',
        'feature': 'hospital_finder',
        'route': 'HospitalsPage',
      },
      {
        'title': 'AI Assistant',
        'icon': '🤖',
        'feature': 'ai_assistant',
        'route': 'AiAssistantScreen',
      },
      {
        'title': 'Anonymous Chat',
        'icon': '💬',
        'feature': 'anonymous_chat',
        'route': 'AnonymousChatScreen',
      },
      {
        'title': 'Medication Reminders',
        'icon': '⏰',
        'feature': 'medication_reminders',
        'route': 'MedicationReminderPage',
      },
      {
        'title': 'Health Tracking',
        'icon': '📊',
        'feature': 'health_tracking',
        'route': 'HealthPage',
      },
      {
        'title': 'Family Chat',
        'icon': '👨‍👩‍👧‍👦',
        'feature': 'family_chat',
        'route': 'FamilyChatScreen',
      },
      {
        'title': 'Emergency Services',
        'icon': '🚑',
        'feature': 'emergency_services',
        'route': 'EmergencyServicesPage',
      },
    ];
  }

  // Get user type description
  static String getUserTypeDescription(String userType) {
    final descriptions = {
      'Health Explorer': 'Learn about cancer prevention and track my health',
      'In-Care Member': 'Currently receiving cancer care and support',
      'Support Partner': 'Supporting a loved one through their journey',
      'Health Professional': 'Medical doctor, nurse, or healthcare provider',
      'Partner Facility': 'Hospital, clinic, or healthcare organization',
    };
    return descriptions[userType] ?? '';
  }

  // No verification required for now
  static bool needsVerification(UserProfile user) {
    return false;
  }

  // No next steps for now
  static List<String> getNextSteps(UserProfile user) {
    return [];
  }
}