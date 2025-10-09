import 'package:shared_preferences/shared_preferences.dart';

class AutoLockService {
  static const String _autoLockEnabledKey = 'auto_lock_enabled';
  static const String _autoLockTimeoutKey = 'auto_lock_timeout';
  
  // Default timeout values in minutes
  static const Map<String, int> timeoutOptions = {
    'Immediately': 0,
    '30 seconds': 1,
    '1 minute': 1,
    '5 minutes': 5,
    '10 minutes': 10,
    '30 minutes': 30,
  };

  // Check if auto-lock is enabled
  Future<bool> isAutoLockEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_autoLockEnabledKey) ?? false;
  }

  // Set auto-lock enabled/disabled
  Future<void> setAutoLockEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_autoLockEnabledKey, enabled);
  }

  // Get current timeout in minutes
  Future<int> getAutoLockTimeout() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_autoLockTimeoutKey) ?? 5; // Default 5 minutes
  }

  // Set auto-lock timeout
  Future<void> setAutoLockTimeout(int minutes) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_autoLockTimeoutKey, minutes);
  }

  // Get timeout in milliseconds for app lifecycle
  Future<int> getAutoLockTimeoutMs() async {
    final timeout = await getAutoLockTimeout();
    return timeout * 60 * 1000; // Convert minutes to milliseconds
  }

  // Get formatted timeout string for display
  String getFormattedTimeout(int minutes) {
    if (minutes == 0) return 'Immediately';
    if (minutes == 1) return '1 minute';
    return '$minutes minutes';
  }

  // Get all timeout options as display strings
  List<String> getTimeoutOptions() {
    return timeoutOptions.entries.map((entry) {
      if (entry.value == 0) return 'Immediately';
      if (entry.value == 1) return '1 minute';
      return '${entry.value} minutes';
    }).toList();
  }

  // Get timeout value from display string
  int getTimeoutFromString(String displayString) {
    final entry = timeoutOptions.entries.firstWhere(
      (entry) => getFormattedTimeout(entry.value) == displayString,
      orElse: () => const MapEntry('5 minutes', 5),
    );
    return entry.value;
  }
}