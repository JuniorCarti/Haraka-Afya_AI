import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:haraka_afya_ai/screens/home_screen.dart';
import 'package:haraka_afya_ai/models/user_profile.dart';

class HealthProfessionalVerificationScreen extends StatefulWidget {
  final String userId;
  final String firstName;
  final String email;
  final String userType;
  final bool isSocialSignUp;

  const HealthProfessionalVerificationScreen({
    super.key,
    required this.userId,
    required this.firstName,
    required this.email,
    required this.userType,
    required this.isSocialSignUp,
  });

  @override
  State<HealthProfessionalVerificationScreen> createState() => _HealthProfessionalVerificationScreenState();
}

class _HealthProfessionalVerificationScreenState extends State<HealthProfessionalVerificationScreen> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _imagePicker = ImagePicker();
  
  // Form fields
  final _licenseNumberController = TextEditingController();
  final _specialtyController = TextEditingController();
  final _institutionController = TextEditingController();
  final _yearsOfExperienceController = TextEditingController();
  
  // State variables
  String? _selectedSpecialty;
  String? _licenseImagePath;
  String? _idCardImagePath;
  bool _isLoading = false;
  bool _agreedToTerms = false;

  final Color _primaryColor = const Color(0xFF0C6D5B);
  final Color _backgroundColor = const Color(0xFFfcfcf5);

  // Medical specialties
  final List<String> _specialties = [
    'Oncology',
    'Cardiology',
    'Pediatrics',
    'Internal Medicine',
    'Surgery',
    'Gynecology',
    'Psychiatry',
    'Neurology',
    'Radiology',
    'Pathology',
    'Emergency Medicine',
    'Family Medicine',
    'Dermatology',
    'Ophthalmology',
    'ENT',
    'Orthopedics',
    'Urology',
    'Endocrinology',
    'Gastroenterology',
    'Pulmonology',
    'Nephrology',
    'Hematology',
    'Other'
  ];

  @override
  void dispose() {
    _licenseNumberController.dispose();
    _specialtyController.dispose();
    _institutionController.dispose();
    _yearsOfExperienceController.dispose();
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
          'Professional Verification',
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
                  'Verify Your Medical Credentials',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: _primaryColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Please provide your professional information for verification. This helps maintain trust in our healthcare community.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 32),

                // License Number
                _buildFormField(
                  label: 'Medical License Number',
                  controller: _licenseNumberController,
                  hintText: 'Enter your official license number',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your license number';
                    }
                    if (value.length < 4) {
                      return 'Please enter a valid license number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Specialty Dropdown
                _buildSpecialtyDropdown(),
                const SizedBox(height: 20),

                // Institution
                _buildFormField(
                  label: 'Current Institution/Hospital',
                  controller: _institutionController,
                  hintText: 'Where do you currently practice?',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your institution name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Years of Experience
                _buildFormField(
                  label: 'Years of Experience',
                  controller: _yearsOfExperienceController,
                  hintText: 'e.g., 5',
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter years of experience';
                    }
                    final years = int.tryParse(value);
                    if (years == null || years < 0 || years > 50) {
                      return 'Please enter a valid number (0-50)';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // License Upload
                _buildImageUploadSection(
                  title: 'Upload Medical License',
                  description: 'Clear photo of your official medical license',
                  imagePath: _licenseImagePath,
                  onTap: () => _pickImage(isLicense: true),
                ),
                const SizedBox(height: 20),

                // ID Card Upload
                _buildImageUploadSection(
                  title: 'Upload Professional ID',
                  description: 'Hospital ID card or professional identification',
                  imagePath: _idCardImagePath,
                  onTap: () => _pickImage(isLicense: false),
                ),
                const SizedBox(height: 20),

                // Terms Agreement
                _buildTermsAgreement(),
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
                            'Submit for Verification',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 20),

                // Note about verification process
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: _primaryColor, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Verification typically takes 1-2 business days. You\'ll receive limited access until verified.',
                          style: TextStyle(
                            fontSize: 12,
                            color: _primaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormField({
    required String label,
    required TextEditingController controller,
    required String hintText,
    required String? Function(String?) validator,
    TextInputType keyboardType = TextInputType.text,
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

  Widget _buildSpecialtyDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Medical Specialty',
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
            value: _selectedSpecialty,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            ),
            items: _specialties.map((String specialty) {
              return DropdownMenuItem<String>(
                value: specialty,
                child: Text(specialty),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                _selectedSpecialty = newValue;
              });
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please select your specialty';
              }
              return null;
            },
            hint: const Text('Select your medical specialty'),
          ),
        ),
      ],
    );
  }

  Widget _buildImageUploadSection({
    required String title,
    required String description,
    required String? imagePath,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade700,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: double.infinity,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: imagePath != null ? _primaryColor : Colors.grey.shade300,
                width: imagePath != null ? 2 : 1,
              ),
            ),
            child: imagePath != null
                ? Stack(
                    children: [
                      // In a real app, you'd display the actual image
                      // For now, we'll show a placeholder
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.check_circle, color: _primaryColor, size: 40),
                            const SizedBox(height: 8),
                            Text(
                              'Image Selected',
                              style: TextStyle(
                                color: _primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: IconButton(
                          icon: Icon(Icons.close, color: Colors.red),
                          onPressed: () {
                            setState(() {
                              if (onTap == () => _pickImage(isLicense: true)) {
                                _licenseImagePath = null;
                              } else {
                                _idCardImagePath = null;
                              }
                            });
                          },
                        ),
                      ),
                    ],
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.cloud_upload_outlined, color: Colors.grey.shade400, size: 40),
                      const SizedBox(height: 8),
                      Text(
                        'Tap to upload',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                      Text(
                        description,
                        style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildTermsAgreement() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Checkbox(
          value: _agreedToTerms,
          onChanged: (bool? value) {
            setState(() {
              _agreedToTerms = value ?? false;
            });
          },
          activeColor: _primaryColor,
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'I certify that the information provided is accurate and I am a licensed healthcare professional.',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 4),
              GestureDetector(
                onTap: () {
                  // Show terms and conditions
                  _showTermsDialog();
                },
                child: Text(
                  'Read Terms & Conditions',
                  style: TextStyle(
                    color: _primaryColor,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _pickImage({required bool isLicense}) async {
    final XFile? image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 80,
    );

    if (image != null) {
      setState(() {
        if (isLicense) {
          _licenseImagePath = image.path;
        } else {
          _idCardImagePath = image.path;
        }
      });
    }
  }

  Future<void> _submitVerification() async {
    if (!_agreedToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please agree to the terms and conditions'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      if (_licenseImagePath == null || _idCardImagePath == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please upload both license and ID card images'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      setState(() => _isLoading = true);

      try {
        // In a real app, you would upload images to cloud storage here
        // For now, we'll simulate the process

        // Create verification data
        final verificationData = {
          'licenseNumber': _licenseNumberController.text.trim(),
          'specialty': _selectedSpecialty,
          'institution': _institutionController.text.trim(),
          'yearsOfExperience': int.parse(_yearsOfExperienceController.text.trim()),
          'licenseImageUploaded': true,
          'idCardImageUploaded': true,
          'submittedAt': DateTime.now().millisecondsSinceEpoch,
          'status': 'under_review',
        };

        // Update user profile with verification data
        await _updateUserProfile(verificationData);

        // Navigate to home screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Verification submitted successfully!'),
            backgroundColor: Colors.green,
          ),
        );

      } catch (e) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit verification: $e'),
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
      lastName: '', // Can be updated later
      email: widget.email,
      userType: widget.userType,
      phoneNumber: '',
      age: 0,
      subscriptionType: 'free',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isProfileComplete: true,
      isVerified: false, // Will be true after admin verification
      verificationStatus: 'pending',
      verificationData: verificationData,
      professionalLicense: _licenseNumberController.text.trim(),
      specialty: _selectedSpecialty,
    );

    await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .set(userProfile.toMap());
  }

  void _showTermsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Terms & Conditions'),
        content: SingleChildScrollView(
          child: Text(
            'By submitting your professional credentials:\n\n'
            '1. You certify that you are a licensed healthcare professional\n'
            '2. You agree to maintain professional conduct on the platform\n'
            '3. You understand that false information may result in account suspension\n'
            '4. You consent to verification of your credentials with relevant authorities\n'
            '5. You agree to comply with all applicable healthcare regulations and laws\n\n'
            'Your information will be kept confidential and used solely for verification purposes.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }
}