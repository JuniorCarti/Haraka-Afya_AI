import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:haraka_afya_ai/screens/home_screen.dart';
import 'package:haraka_afya_ai/screens/auth/sign_in_page.dart';
import 'package:haraka_afya_ai/screens/auth/verification_screens/health_professional_verification.dart';
import 'package:haraka_afya_ai/screens/auth/verification_screens/partner_facility_verification.dart';
import 'package:haraka_afya_ai/screens/auth/verification_screens/support_partner_verification.dart';
import 'package:haraka_afya_ai/models/user_profile.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class CreatePasswordScreen extends StatefulWidget {
  final String firstName;
  final String email;
  final String? userType;
  final bool requiresVerification;

  const CreatePasswordScreen({
    super.key,
    required this.firstName,
    required this.email,
    this.userType,
    required this.requiresVerification,
  });

  @override
  State<CreatePasswordScreen> createState() => _CreatePasswordScreenState();
}

class _CreatePasswordScreenState extends State<CreatePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _pageController = PageController(initialPage: 3);
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _accountCreated = false;

  // Color scheme
  final Color _primaryColor = const Color(0xFF0C6D5B);
  final Color _backgroundColor = const Color(0xFFfcfcf5);

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: _primaryColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            children: [
              // Progress Indicator
              Center(
                child: SmoothPageIndicator(
                  controller: _pageController,
                  count: 4,
                  effect: WormEffect(
                    activeDotColor: _primaryColor,
                    dotColor: Colors.grey.shade300,
                    dotHeight: 10,
                    dotWidth: 10,
                    spacing: 8,
                  ),
                ),
              ),
              const SizedBox(height: 40),
              _accountCreated ? _buildSuccessUI() : _buildPasswordForm(),
              const SizedBox(height: 30),
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SignInPage(),
                      ),
                    );
                  },
                  child: RichText(
                    text: TextSpan(
                      text: 'Already have an account? ',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                      children: [
                        TextSpan(
                          text: 'Sign In',
                          style: TextStyle(
                            color: _primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
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

  Widget _buildPasswordForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Create a secure password",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: _primaryColor,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "For ${widget.email}",
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey.shade600,
          ),
        ),
        // Show user type if available
        if (widget.userType != null) ...[
          const SizedBox(height: 8),
          Text(
            "As a ${widget.userType}",
            style: TextStyle(
              fontSize: 14,
              color: _primaryColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
        // Show verification notice if required
        if (widget.requiresVerification) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              children: [
                Icon(Icons.verified_user, size: 14, color: _primaryColor),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    'Additional verification required after account creation',
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
        ],
        const SizedBox(height: 40),
        Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: Icon(Icons.lock_outline, color: _primaryColor),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off : Icons.visibility,
                      color: _primaryColor,
                    ),
                    onPressed: () {
                      setState(() => _obscurePassword = !_obscurePassword);
                    },
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Please enter a password';
                  if (value.length < 8) return 'Password must be at least 8 characters';
                  if (!value.contains(RegExp(r'[A-Z]'))) return 'Include at least one uppercase letter';
                  if (!value.contains(RegExp(r'[0-9]'))) return 'Include at least one number';
                  return null;
                },
              ),
              const SizedBox(height: 10),
              _buildPasswordRequirements(),
              const SizedBox(height: 20),
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: _obscureConfirmPassword,
                decoration: InputDecoration(
                  labelText: 'Confirm Password',
                  prefixIcon: Icon(Icons.lock_outline, color: _primaryColor),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                      color: _primaryColor,
                    ),
                    onPressed: () {
                      setState(() => _obscureConfirmPassword = !_obscureConfirmPassword);
                    },
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                ),
                validator: (value) {
                  if (value != _passwordController.text) return 'Passwords do not match';
                  return null;
                },
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitForm,
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
                      : Text(
                          widget.requiresVerification 
                            ? 'Create Account & Verify' 
                            : 'Create Account',
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
      ],
    );
  }

  Widget _buildPasswordRequirements() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Password must contain:', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
        const SizedBox(height: 4),
        _buildRequirementRow('8+ characters', _passwordController.text.length >= 8),
        _buildRequirementRow('1 uppercase letter', _passwordController.text.contains(RegExp(r'[A-Z]'))),
        _buildRequirementRow('1 number', _passwordController.text.contains(RegExp(r'[0-9]'))),
      ],
    );
  }

  Widget _buildRequirementRow(String text, bool met) {
    return Row(
      children: [
        Icon(met ? Icons.check_circle : Icons.circle, size: 12, color: met ? Colors.green : Colors.grey),
        const SizedBox(width: 4),
        Text(text, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
      ],
    );
  }

  Widget _buildSuccessUI() {
    return Column(
      children: [
        Icon(Icons.check_circle_outline, size: 80, color: _primaryColor),
        const SizedBox(height: 20),
        Text('Account created!', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: _primaryColor)),
        const SizedBox(height: 10),
        Text('Welcome to Haraka Afya, ${widget.firstName}!', style: TextStyle(fontSize: 16, color: Colors.grey.shade600)),
        // Show user type in success message
        if (widget.userType != null) ...[
          const SizedBox(height: 5),
          Text(
            'Registered as ${widget.userType}',
            style: TextStyle(
              fontSize: 14,
              color: _primaryColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
        // Show next steps for verification
        if (widget.requiresVerification) ...[
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _primaryColor.withOpacity(0.3)),
            ),
            child: Column(
              children: [
                Icon(Icons.verified_user, size: 40, color: _primaryColor),
                const SizedBox(height: 12),
                Text(
                  'Verification Required',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _primaryColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Please complete your professional verification to access all features.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 40),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: () {
              if (widget.requiresVerification) {
                _navigateToVerificationScreen();
              } else {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const HomeScreen()),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              widget.requiresVerification ? 'Continue to Verification' : 'Continue to App',
              style: const TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        // Create user with email and password
        final UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
              email: widget.email, 
              password: _passwordController.text
            );

        final User user = userCredential.user!;
        
        // Update display name
        await user.updateDisplayName(widget.firstName);
        
        // Send email verification
        await user.sendEmailVerification();

        // Create and save user profile with user type
        await _saveUserProfile(user.uid);

        setState(() {
          _isLoading = false;
          _accountCreated = true;
        });
      } on FirebaseAuthException catch (e) {
        setState(() => _isLoading = false);
        String errorMessage = 'Account creation failed';
        if (e.code == 'weak-password') {
          errorMessage = 'The password provided is too weak';
        } else if (e.code == 'email-already-in-use') {
          errorMessage = 'An account already exists for that email';
        } else if (e.code == 'invalid-email') {
          errorMessage = 'The email address is invalid';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage), 
            backgroundColor: Colors.red
          ),
        );
      } catch (e) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'), 
            backgroundColor: Colors.red
          ),
        );
      }
    }
  }

  Future<void> _saveUserProfile(String userId) async {
    try {
      // Determine verification status based on user type
      final requiresVerification = widget.userType == 'Health Professional' || 
                                  widget.userType == 'Partner Facility' || 
                                  widget.userType == 'Support Partner';
      
      final userProfile = UserProfile(
        uid: userId,
        firstName: widget.firstName,
        lastName: '', // Can be updated later
        email: widget.email,
        userType: widget.userType ?? 'Health Explorer',
        phoneNumber: '',
        age: 0,
        subscriptionType: 'free',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isProfileComplete: widget.userType != null,
        isVerified: false,
        verificationStatus: requiresVerification ? 'pending' : 'not_required',
      );

      // Save to Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .set(userProfile.toMap());

      print('User profile saved successfully for $userId as ${widget.userType}');
    } catch (e) {
      print('Error saving user profile: $e');
      // Don't throw error here - the account is already created
    }
  }

  void _navigateToVerificationScreen() {
    switch (widget.userType) {
      case 'Health Professional':
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => HealthProfessionalVerificationScreen(
              userId: FirebaseAuth.instance.currentUser!.uid,
              firstName: widget.firstName,
              email: widget.email,
              userType: widget.userType!,
              isSocialSignUp: false,
            ),
          ),
        );
        break;
      case 'Partner Facility':
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => PartnerFacilityVerificationScreen(
              userId: FirebaseAuth.instance.currentUser!.uid,
              firstName: widget.firstName,
              email: widget.email,
              userType: widget.userType!,
              isSocialSignUp: false,
            ),
          ),
        );
        break;
      case 'Support Partner':
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => SupportPartnerVerificationScreen(
              userId: FirebaseAuth.instance.currentUser!.uid,
              firstName: widget.firstName,
              email: widget.email,
              userType: widget.userType!,
              isSocialSignUp: false,
            ),
          ),
        );
        break;
      default:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
    }
  }
}