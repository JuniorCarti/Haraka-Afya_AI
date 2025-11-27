import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:haraka_afya_ai/screens/home_screen.dart';
import 'package:haraka_afya_ai/screens/auth/create_password_screen.dart';
import 'package:haraka_afya_ai/screens/auth/verification_screens/health_professional_verification.dart';
import 'package:haraka_afya_ai/screens/auth/verification_screens/partner_facility_verification.dart';
import 'package:haraka_afya_ai/screens/auth/verification_screens/support_partner_verification.dart';
import 'package:haraka_afya_ai/models/user_profile.dart';

class UserTypeSelectionScreen extends StatefulWidget {
  final String firstName;
  final String? email;
  final bool isSocialSignUp;
  
  const UserTypeSelectionScreen({
    super.key,
    required this.firstName,
    this.email,
    required this.isSocialSignUp,
  });

  @override
  State<UserTypeSelectionScreen> createState() => _UserTypeSelectionScreenState();
}

class _UserTypeSelectionScreenState extends State<UserTypeSelectionScreen> {
  String _selectedUserType = 'Health Explorer';
  bool _isLoading = false;
  
  final Color _primaryColor = const Color(0xFF0C6D5B);
  final Color _backgroundColor = const Color(0xFFfcfcf5);
  final Color _cardColor = Colors.white;

  final List<Map<String, dynamic>> _userTypes = [
    {
      'type': 'Health Explorer',
      'description': 'Learn about cancer prevention and track my health',
      'icon': Icons.explore,
      'requiresVerification': false,
      'verificationText': null,
    },
    {
      'type': 'In-Care Member', 
      'description': 'Currently receiving cancer care and support',
      'icon': Icons.health_and_safety,
      'requiresVerification': false,
      'verificationText': null,
    },
    {
      'type': 'Support Partner',
      'description': 'Supporting a loved one through their journey',
      'icon': Icons.family_restroom,
      'requiresVerification': true,
      'verificationText': 'Requires patient connection verification',
    },
    {
      'type': 'Health Professional',
      'description': 'Medical doctor, nurse, or healthcare provider',
      'icon': Icons.medical_services,
      'requiresVerification': true,
      'verificationText': 'Requires professional license verification',
    },
    {
      'type': 'Partner Facility',
      'description': 'Hospital, clinic, or healthcare organization',
      'icon': Icons.local_hospital,
      'requiresVerification': true,
      'verificationText': 'Requires facility accreditation verification',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: widget.isSocialSignUp 
            ? IconButton(
                icon: Icon(Icons.arrow_back, color: _primaryColor),
                onPressed: () {
                  // Sign out if they go back from social sign-up
                  FirebaseAuth.instance.signOut();
                  Navigator.pop(context);
                },
              )
            : IconButton(
                icon: Icon(Icons.arrow_back, color: _primaryColor),
                onPressed: () => Navigator.pop(context),
              ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Progress indicator (similar to name input screen)
              Container(
                alignment: Alignment.center,
                child: Container(
                  width: 60,
                  height: 6,
                  decoration: BoxDecoration(
                    color: _primaryColor.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: Stack(
                    children: [
                      Container(
                        width: 30,
                        height: 6,
                        decoration: BoxDecoration(
                          color: _primaryColor,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),
              
              // Welcome text
              Text(
                "Welcome, ${widget.firstName}!",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: _primaryColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "How will you use Haraka Afya?",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 16),
              
              // Verification notice
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: _primaryColor.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.verified_user, color: _primaryColor, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Some roles require additional verification to ensure community safety',
                        style: TextStyle(
                          fontSize: 12,
                          color: _primaryColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              // User type selection cards
              _buildUserTypeSelection(),
              
              const SizedBox(height: 30),
              
              // Continue button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _completeRegistration,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          widget.isSocialSignUp 
                            ? 'Complete Registration' 
                            : 'Continue',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserTypeSelection() {
    return Column(
      children: _userTypes.map((userType) {
        return _buildUserTypeCard(
          type: userType['type'] as String,
          description: userType['description'] as String,
          icon: userType['icon'] as IconData,
          isSelected: _selectedUserType == userType['type'],
          requiresVerification: userType['requiresVerification'] as bool,
          verificationText: userType['verificationText'] as String?,
        );
      }).toList(),
    );
  }

  Widget _buildUserTypeCard({
    required String type,
    required String description,
    required IconData icon,
    required bool isSelected,
    required bool requiresVerification,
    required String? verificationText,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: isSelected ? _primaryColor : Colors.transparent,
          width: 2,
        ),
      ),
      child: Column(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isSelected ? _primaryColor.withOpacity(0.1) : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: isSelected ? _primaryColor : Colors.grey.shade600,
                size: 20,
              ),
            ),
            title: Text(
              type,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isSelected ? _primaryColor : Colors.black87,
                fontSize: 16,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  description,
                  style: TextStyle(
                    color: isSelected ? _primaryColor.withOpacity(0.8) : Colors.grey.shade600,
                    fontSize: 14,
                  ),
                ),
                if (requiresVerification && verificationText != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.verified_user, size: 12, color: _primaryColor),
                      const SizedBox(width: 4),
                      Text(
                        verificationText,
                        style: TextStyle(
                          fontSize: 11,
                          color: _primaryColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
            trailing: isSelected 
                ? Icon(Icons.check_circle, color: _primaryColor, size: 24)
                : Icon(Icons.radio_button_unchecked, color: Colors.grey.shade400, size: 24),
            onTap: () {
              setState(() {
                _selectedUserType = type;
              });
            },
          ),
        ],
      ),
    );
  }

  Future<void> _completeRegistration() async {
    setState(() => _isLoading = true);
    
    try {
      if (widget.isSocialSignUp) {
        // Social sign-up - handle based on user type
        await _handleSocialSignUp();
      } else {
        // Email sign-up - handle based on user type
        await _handleEmailSignUp();
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Registration failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _handleSocialSignUp() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Check if user type requires verification
      if (_requiresVerification(_selectedUserType)) {
        // Navigate to appropriate verification screen
        await _navigateToVerificationScreen(user.uid);
      } else {
        // Save basic profile and go to home
        await _saveUserProfile(user.uid, _selectedUserType, isVerified: false);
        await user.updateDisplayName(widget.firstName);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    } else {
      throw Exception('No user found after social sign-up');
    }
  }

  Future<void> _handleEmailSignUp() async {
    // Check if user type requires verification
    if (_requiresVerification(_selectedUserType)) {
      // Navigate to password creation first, then verification
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => CreatePasswordScreen(
            firstName: widget.firstName,
            email: widget.email ?? '',
            userType: _selectedUserType,
            requiresVerification: true,
          ),
        ),
      );
    } else {
      // Navigate directly to password creation
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => CreatePasswordScreen(
            firstName: widget.firstName,
            email: widget.email ?? '',
            userType: _selectedUserType,
            requiresVerification: false,
          ),
        ),
      );
    }
  }

  Future<void> _navigateToVerificationScreen(String userId) async {
    switch (_selectedUserType) {
      case 'Health Professional':
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => HealthProfessionalVerificationScreen(
              userId: userId,
              firstName: widget.firstName,
              email: widget.email ?? '',
              userType: _selectedUserType,
              isSocialSignUp: true,
            ),
          ),
        );
        break;
      case 'Partner Facility':
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => PartnerFacilityVerificationScreen(
              userId: userId,
              firstName: widget.firstName,
              email: widget.email ?? '',
              userType: _selectedUserType,
              isSocialSignUp: true,
            ),
          ),
        );
        break;
      case 'Support Partner':
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => SupportPartnerVerificationScreen(
              userId: userId,
              firstName: widget.firstName,
              email: widget.email ?? '',
              userType: _selectedUserType,
              isSocialSignUp: true,
            ),
          ),
        );
        break;
      default:
        // Should not reach here for non-verified types
        await _saveUserProfile(userId, _selectedUserType, isVerified: false);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
    }
  }

  bool _requiresVerification(String userType) {
    return userType == 'Health Professional' || 
           userType == 'Partner Facility' || 
           userType == 'Support Partner';
  }

  Future<void> _saveUserProfile(String userId, String userType, {bool isVerified = false}) async {
    try {
      final userProfile = UserProfile(
        uid: userId,
        firstName: widget.firstName,
        lastName: '', // Can be updated later
        email: widget.email ?? '',
        userType: userType,
        phoneNumber: '',
        age: 0,
        subscriptionType: 'free',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isProfileComplete: true,
        isVerified: isVerified, // Add this field to UserProfile model
        verificationStatus: isVerified ? 'verified' : 'pending', // Add this field
      );

      // Save to Firestore using the UserProfile model
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .set(userProfile.toMap());

      print('User profile saved successfully for $userId as $userType (Verified: $isVerified)');
    } catch (e) {
      print('Error saving user profile: $e');
      throw Exception('Failed to save user profile: $e');
    }
  }
}