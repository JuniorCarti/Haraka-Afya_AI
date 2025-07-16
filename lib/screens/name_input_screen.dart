import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:haraka_afya_ai/screens/auth/email_verification_screen.dart';
import 'package:haraka_afya_ai/screens/home_screen.dart';
import 'package:haraka_afya_ai/screens/onboarding_screen.dart';

class NameInputScreen extends StatefulWidget {
  const NameInputScreen({super.key});

  @override
  State<NameInputScreen> createState() => _NameInputScreenState();
}

class _NameInputScreenState extends State<NameInputScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _pageController = PageController();
  bool _isLoading = false;
  final Color _primaryColor = const Color(0xFF0C6D5B); // Brand green color
  final Color _backgroundColor = const Color(0xFFF5F5F5); // Light background

  @override
  void dispose() {
    _firstNameController.dispose();
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
          onPressed: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const OnboardingScreens(),
            ),
          ),
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
                  count: 3, // Total onboarding steps
                  effect: WormEffect(
                    activeDotColor: _primaryColor,
                    dotColor: Colors.grey,
                    dotHeight: 10,
                    dotWidth: 10,
                    spacing: 8,
                  ),
                ),
              ),
              const SizedBox(height: 40),
              
              // Form Content
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "What's your name?",
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: _primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "We'll use this to personalize your experience",
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 40),
                    
                    // Name Input Field
                    TextFormField(
                      controller: _firstNameController,
                      decoration: InputDecoration(
                        labelText: 'First Name',
                        prefixIcon: Icon(Icons.person_outline, color: _primaryColor),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 16, horizontal: 16,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your first name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 30),
                    
                    // Continue Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _submitForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _primaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 16),
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
                                'Continue',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              
              // Divider with "OR"
              Row(
                children: [
                  const Expanded(child: Divider(color: Colors.grey)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      'OR',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  const Expanded(child: Divider(color: Colors.grey)),
                ],
              ),
              const SizedBox(height: 30),
              
              // Social Login Buttons
              _buildSocialButton(
                icon: FontAwesomeIcons.google,
                text: 'Continue with Google',
                color: Colors.red,
                onPressed: () => _handleSocialLogin('google'),
              ),
              const SizedBox(height: 16),
              _buildSocialButton(
                icon: FontAwesomeIcons.facebook,
                text: 'Continue with Facebook',
                color: Colors.blue,
                onPressed: () => _handleSocialLogin('facebook'),
              ),
              const SizedBox(height: 16),
              _buildSocialButton(
                icon: FontAwesomeIcons.xTwitter,
                text: 'Continue with X',
                color: Colors.black,
                onPressed: () => _handleSocialLogin('twitter'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSocialButton({
    required IconData icon,
    required String text,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: color,
        side: BorderSide(color: color),
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 12),
          Text(
            text,
            style: TextStyle(
              fontSize: 16,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      // Process name input flow
      _processNameInput().then((_) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const EmailVerificationScreen(),
          ),
        );
      }).catchError((error) {
        // Handle error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${error.toString()}')),
        );
      }).whenComplete(() {
        setState(() => _isLoading = false);
      });
    }
  }

  Future<void> _processNameInput() async {
    // Here you would typically:
    // 1. Save the name to your state management
    // 2. Possibly make an API call
    await Future.delayed(const Duration(seconds: 1)); // Simulate network call
  }

  void _handleSocialLogin(String provider) {
    setState(() => _isLoading = true);
    // Process social login
    _processSocialLogin(provider).then((_) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const HomeScreen(),
        ),
      );
    }).catchError((error) {
      // Handle error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$provider login failed: ${error.toString()}')),
      );
    }).whenComplete(() {
      setState(() => _isLoading = false);
    });
  }

  Future<void> _processSocialLogin(String provider) async {
    // Here you would:
    // 1. Authenticate with the social provider (Google/Facebook/X)
    // 2. Get user details from the provider
    // 3. Login or register the user in your backend
    await Future.delayed(const Duration(seconds: 1)); // Simulate network call
  }
}