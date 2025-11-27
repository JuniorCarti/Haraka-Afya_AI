import 'package:flutter/foundation.dart';
import 'package:haraka_afya_ai/models/user_profile.dart';
import 'package:haraka_afya_ai/services/user_service.dart';

class UserProvider with ChangeNotifier {
  final UserService _userService = UserService();
  
  UserProfile? _currentUser;
  bool _isLoading = false;
  String? _error;

  UserProfile? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Load current user from Firebase
  Future<void> loadCurrentUser() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentUser = await _userService.getCurrentUser();
    } catch (e) {
      _error = 'Failed to load user: $e';
      print('Error loading user: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update user profile in Firebase
  Future<void> updateProfile(Map<String, dynamic> updates) async {
    if (_currentUser == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      await _userService.updateUserProfile(_currentUser!.uid, updates);
      await loadCurrentUser(); // Reload user data
    } catch (e) {
      _error = 'Failed to update profile: $e';
      notifyListeners();
    }
  }

  // Update user type in Firebase
  Future<void> updateUserType(String userType) async {
    if (_currentUser == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      await _userService.updateUserType(_currentUser!.uid, userType);
      await loadCurrentUser(); // Reload user data
    } catch (e) {
      _error = 'Failed to update user type: $e';
      notifyListeners();
    }
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Sign out
  void signOut() {
    _currentUser = null;
    _error = null;
    _isLoading = false;
    notifyListeners();
  }
}