import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:haraka_afya_ai/screens/home_screen.dart';
import 'package:haraka_afya_ai/models/user_profile.dart';

class SupportPartnerVerificationScreen extends StatefulWidget {
  final String userId;
  final String firstName;
  final String email;
  final String userType;
  final bool isSocialSignUp;

  const SupportPartnerVerificationScreen({
    super.key,
    required this.userId,
    required this.firstName,
    required this.email,
    required this.userType,
    required this.isSocialSignUp,
  });

  @override
  State<SupportPartnerVerificationScreen> createState() => _SupportPartnerVerificationScreenState();
}

class _SupportPartnerVerificationScreenState extends State<SupportPartnerVerificationScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Form fields
  final _patientNameController = TextEditingController();
  final _patientEmailController = TextEditingController();
  final _patientPhoneController = TextEditingController();
  final _relationshipController = TextEditingController();
  final _supportDescriptionController = TextEditingController();
  
  // State variables
  String? _selectedRelationship;
  bool _isLoading = false;
  bool _agreedToTerms = false;
  bool _patientConsent = false;

  final Color _primaryColor = const Color(0xFF0C6D5B);
  final Color _backgroundColor = const Color(0xFFfcfcf5);

  // Relationship types
  final List<String> _relationships = [
    'Spouse/Partner',
    'Parent',
    'Child',
    'Sibling',
    'Other Family',
    'Friend',
    'Caregiver',
    'Legal Guardian',
    'Other'
  ];

  @override
  void dispose() {
    _patientNameController.dispose();
    _patientEmailController.dispose();
    _patientPhoneController.dispose();
    _relationshipController.dispose();
    _supportDescriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: _primaryColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Support Partner Verification',
          style: TextStyle(color: _primaryColor, fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Text(
                  'Connect as a Support Partner',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: _primaryColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Please provide information about the person you\'re supporting to ensure proper connection and privacy.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 32),

                // Patient Information Section
                _buildSectionHeader('Patient Information'),
                const SizedBox(height: 16),

                // Patient Name
                _buildFormField(
                  label: 'Patient Full Name',
                  controller: _patientNameController,
                  hintText: 'Enter the full name of the person you\'re supporting',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter patient name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Patient Email
                _buildFormField(
                  label: 'Patient Email (Optional)',
                  controller: _patientEmailController,
                  hintText: 'Patient\'s email for connection',
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                        return 'Please enter a valid email';
                      }
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Patient Phone
                _buildFormField(
                  label: 'Patient Phone (Optional)',
                  controller: _patientPhoneController,
                  hintText: 'Patient\'s phone number',
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    // Optional field, no validation needed
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Relationship Dropdown
                _buildRelationshipDropdown(),
                const SizedBox(height: 20),

                // Support Description
                _buildFormField(
                  label: 'How do you provide support?',
                  controller: _supportDescriptionController,
                  hintText: 'Describe your role in supporting this person (e.g., emotional support, appointment coordination, medication management)',
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please describe your support role';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Connection Methods Section
                _buildSectionHeader('Connection Methods'),
                const SizedBox(height: 16),

                _buildConnectionMethods(),
                const SizedBox(height: 20),

                // Consent Section
                _buildSectionHeader('Consent & Agreement'),
                const SizedBox(height: 16),

                // Patient Consent
                _buildConsentCheckbox(
                  value: _patientConsent,
                  onChanged: (value) => setState(() => _patientConsent = value ?? false),
                  text: 'I have obtained consent from the patient to be their support partner',
                ),
                const SizedBox(height: 12),

                // Terms Agreement
                _buildConsentCheckbox(
                  value: _agreedToTerms,
                  onChanged: (value) => setState(() => _agreedToTerms = value ?? false),
                  text: 'I agree to respect patient privacy and use information responsibly',
                ),
                const SizedBox(height: 20),

                // Privacy Notice
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.security, color: _primaryColor, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Patient information will be kept confidential and used only for connection purposes.',
                          style: TextStyle(
                            fontSize: 12,
                            color: _primaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submitVerification,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
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
                        : const Text(
                            'Request Connection',
                            style: TextStyle(
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
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: _primaryColor,
      ),
    );
  }

  Widget _buildFormField({
    required String label,
    required TextEditingController controller,
    required String hintText,
    required String? Function(String?) validator,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade700,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hintText,
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 16,
              horizontal: 16,
            ),
          ),
          validator: validator,
        ),
      ],
    );
  }

  Widget _buildRelationshipDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Relationship to Patient',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade700,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonFormField<String>(
            value: _selectedRelationship,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            ),
            items: _relationships.map((String relationship) {
              return DropdownMenuItem<String>(
                value: relationship,
                child: Text(relationship),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                _selectedRelationship = newValue;
              });
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please select your relationship';
              }
              return null;
            },
            hint: const Text('Select relationship'),
          ),
        ),
      ],
    );
  }

  Widget _buildConnectionMethods() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'How would you like to connect with the patient?',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 12),
          _buildConnectionOption(
            title: 'Email Invitation',
            description: 'Send connection request via email',
            icon: Icons.email,
          ),
          const SizedBox(height: 12),
          _buildConnectionOption(
            title: 'Manual Verification',
            description: 'Our team will help verify the connection',
            icon: Icons.verified_user,
          ),
          const SizedBox(height: 12),
          _buildConnectionOption(
            title: 'Share Connection Code',
            description: 'Share a code with the patient to connect',
            icon: Icons.qr_code,
          ),
        ],
      ),
    );
  }

  Widget _buildConnectionOption({
    required String title,
    required String description,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: _primaryColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade800,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Radio<bool>(
            value: true,
            groupValue: true, // Always selected for simplicity
            onChanged: null,
            activeColor: _primaryColor,
          ),
        ],
      ),
    );
  }

  Widget _buildConsentCheckbox({
    required bool value,
    required ValueChanged<bool?> onChanged,
    required String text,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Checkbox(
          value: value,
          onChanged: onChanged,
          activeColor: _primaryColor,
        ),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 14),
          ),
        ),
      ],
    );
  }

  Future<void> _submitVerification() async {
    if (!_agreedToTerms || !_patientConsent) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please agree to all terms and obtain patient consent'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        final verificationData = {
          'patientName': _patientNameController.text.trim(),
          'patientEmail': _patientEmailController.text.trim(),
          'patientPhone': _patientPhoneController.text.trim(),
          'relationship': _selectedRelationship,
          'supportDescription': _supportDescriptionController.text.trim(),
          'patientConsent': _patientConsent,
          'submittedAt': DateTime.now().millisecondsSinceEpoch,
          'status': 'pending_connection',
          'connectionMethod': 'email_invitation', // Default method
        };

        await _updateUserProfile(verificationData);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Support partner request submitted successfully!'),
            backgroundColor: Colors.green,
          ),
        );

      } catch (e) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit request: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _updateUserProfile(Map<String, dynamic> verificationData) async {
    final userProfile = UserProfile(
      uid: widget.userId,
      firstName: widget.firstName,
      lastName: '',
      email: widget.email,
      userType: widget.userType,
      phoneNumber: '',
      age: 0,
      subscriptionType: 'free',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isProfileComplete: true,
      isVerified: false,
      verificationStatus: 'pending',
      verificationData: verificationData,
      supportedPatientId: null, // Will be set after patient accepts
    );

    await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .set(userProfile.toMap());

    // In a real app, you would also:
    // 1. Send email invitation to patient
    // 2. Create a pending connection record
    // 3. Notify admins about the connection request
  }
}