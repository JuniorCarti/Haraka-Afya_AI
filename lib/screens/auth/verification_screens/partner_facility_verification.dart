import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:haraka_afya_ai/screens/home_screen.dart';
import 'package:haraka_afya_ai/models/user_profile.dart';

class PartnerFacilityVerificationScreen extends StatefulWidget {
  final String userId;
  final String firstName;
  final String email;
  final String userType;
  final bool isSocialSignUp;

  const PartnerFacilityVerificationScreen({
    super.key,
    required this.userId,
    required this.firstName,
    required this.email,
    required this.userType,
    required this.isSocialSignUp,
  });

  @override
  State<PartnerFacilityVerificationScreen> createState() => _PartnerFacilityVerificationScreenState();
}

class _PartnerFacilityVerificationScreenState extends State<PartnerFacilityVerificationScreen> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _imagePicker = ImagePicker();
  
  // Form fields
  final _facilityNameController = TextEditingController();
  final _facilityTypeController = TextEditingController();
  final _licenseNumberController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _contactPersonController = TextEditingController();
  
  // State variables
  String? _selectedFacilityType;
  String? _accreditationImagePath;
  String? _facilityPhotoPath;
  bool _isLoading = false;
  bool _agreedToTerms = false;

  final Color _primaryColor = const Color(0xFF0C6D5B);
  final Color _backgroundColor = const Color(0xFFfcfcf5);

  // Facility types
  final List<String> _facilityTypes = [
    'Hospital',
    'Clinic',
    'Medical Center',
    'Specialty Center',
    'Diagnostic Center',
    'Pharmacy',
    'Rehabilitation Center',
    'Palliative Care Center',
    'Research Institute',
    'Other'
  ];

  @override
  void dispose() {
    _facilityNameController.dispose();
    _facilityTypeController.dispose();
    _licenseNumberController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _contactPersonController.dispose();
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
          'Facility Verification',
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
                  'Verify Your Healthcare Facility',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: _primaryColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Please provide your facility information for verification. This helps patients find trusted healthcare providers.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 32),

                // Facility Name
                _buildFormField(
                  label: 'Facility Name',
                  controller: _facilityNameController,
                  hintText: 'Enter official facility name',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter facility name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Facility Type Dropdown
                _buildFacilityTypeDropdown(),
                const SizedBox(height: 20),

                // License/Registration Number
                _buildFormField(
                  label: 'Facility License/Registration Number',
                  controller: _licenseNumberController,
                  hintText: 'Enter government registration number',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter license number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Address
                _buildFormField(
                  label: 'Facility Address',
                  controller: _addressController,
                  hintText: 'Full physical address',
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter facility address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Phone Number
                _buildFormField(
                  label: 'Official Phone Number',
                  controller: _phoneController,
                  hintText: 'Primary contact number',
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter phone number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Contact Person
                _buildFormField(
                  label: 'Contact Person Name',
                  controller: _contactPersonController,
                  hintText: 'Primary contact person',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter contact person name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Accreditation Document Upload
                _buildImageUploadSection(
                  title: 'Upload Accreditation Certificate',
                  description: 'Official healthcare facility accreditation',
                  imagePath: _accreditationImagePath,
                  onTap: () => _pickImage(isAccreditation: true),
                ),
                const SizedBox(height: 20),

                // Facility Photo Upload
                _buildImageUploadSection(
                  title: 'Upload Facility Photo',
                  description: 'Clear photo of your healthcare facility',
                  imagePath: _facilityPhotoPath,
                  onTap: () => _pickImage(isAccreditation: false),
                ),
                const SizedBox(height: 20),

                // Services Offered
                _buildServicesSection(),
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

  Widget _buildFacilityTypeDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Facility Type',
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
            value: _selectedFacilityType,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            ),
            items: _facilityTypes.map((String type) {
              return DropdownMenuItem<String>(
                value: type,
                child: Text(type),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                _selectedFacilityType = newValue;
              });
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please select facility type';
              }
              return null;
            },
            hint: const Text('Select facility type'),
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
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.check_circle, color: _primaryColor, size: 40),
                            const SizedBox(height: 8),
                            Text(
                              'Document Selected',
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
                              if (onTap == () => _pickImage(isAccreditation: true)) {
                                _accreditationImagePath = null;
                              } else {
                                _facilityPhotoPath = null;
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

  Widget _buildServicesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Services Offered',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade700,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Common healthcare services (select all that apply):',
                style: TextStyle(color: Colors.grey.shade600),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  'Primary Care',
                  'Specialty Care',
                  'Emergency Services',
                  'Laboratory Services',
                  'Radiology',
                  'Pharmacy',
                  'Surgery',
                  'Maternity Care',
                  'Pediatric Care',
                  'Cancer Care',
                  'Mental Health',
                  'Rehabilitation',
                ].map((service) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: _primaryColor),
                    ),
                    child: Text(
                      service,
                      style: TextStyle(color: _primaryColor, fontSize: 12),
                    ),
                  );
                }).toList(),
              ),
            ],
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
                'I certify that this facility is properly licensed and accredited to provide healthcare services.',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 4),
              GestureDetector(
                onTap: _showTermsDialog,
                child: Text(
                  'Read Facility Agreement',
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

  Future<void> _pickImage({required bool isAccreditation}) async {
    final XFile? image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 80,
    );

    if (image != null) {
      setState(() {
        if (isAccreditation) {
          _accreditationImagePath = image.path;
        } else {
          _facilityPhotoPath = image.path;
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
      if (_accreditationImagePath == null || _facilityPhotoPath == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please upload both accreditation and facility photos'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      setState(() => _isLoading = true);

      try {
        final verificationData = {
          'facilityName': _facilityNameController.text.trim(),
          'facilityType': _selectedFacilityType,
          'licenseNumber': _licenseNumberController.text.trim(),
          'address': _addressController.text.trim(),
          'phone': _phoneController.text.trim(),
          'contactPerson': _contactPersonController.text.trim(),
          'accreditationImageUploaded': true,
          'facilityPhotoUploaded': true,
          'submittedAt': DateTime.now().millisecondsSinceEpoch,
          'status': 'under_review',
        };

        await _updateUserProfile(verificationData);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Facility verification submitted successfully!'),
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
      lastName: '',
      email: widget.email,
      userType: widget.userType,
      phoneNumber: _phoneController.text.trim(),
      age: 0,
      subscriptionType: 'free',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isProfileComplete: true,
      isVerified: false,
      verificationStatus: 'pending',
      verificationData: verificationData,
      facilityName: _facilityNameController.text.trim(),
      facilityType: _selectedFacilityType,
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
        title: Text('Facility Agreement'),
        content: SingleChildScrollView(
          child: Text(
            'By submitting your facility information:\n\n'
            '1. You certify that this facility is properly licensed and accredited\n'
            '2. You agree to maintain healthcare standards and regulations\n'
            '3. You understand that false information may result in removal\n'
            '4. You consent to verification with relevant authorities\n'
            '5. You agree to provide accurate service information to patients\n'
            '6. You commit to maintaining patient confidentiality and privacy\n\n'
            'Your facility information will be displayed to help patients find appropriate care.',
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