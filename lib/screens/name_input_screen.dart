import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
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
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);

  final Color _primaryColor = const Color(0xFF0C6D5B);
  final Color _backgroundColor = const Color(0xFFfcfcf5);
  final Color _cardColor = Colors.white;

  @override
  void dispose() {
    _firstNameController.dispose();
    _pageController.dispose();
    _googleSignIn.disconnect();
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
            MaterialPageRoute(builder: (_) => const OnboardingScreens()),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            children: [
              SmoothPageIndicator(
                controller: _pageController,
                count: 3,
                effect: WormEffect(
                  activeDotColor: _primaryColor,
                  dotColor: Colors.grey.shade300,
                  dotHeight: 10,
                  dotWidth: 10,
                  spacing: 8,
                ),
              ),
              const SizedBox(height: 40),

              _buildNameForm(),

              const SizedBox(height: 30),
              _buildDivider(),
              const SizedBox(height: 30),

              _buildSocialButton(
                iconPath: 'assets/icons/google.png',
                text: 'Continue with Google',
                color: Colors.red,
                onPressed: _handleGoogleSignIn,
              ),
              const SizedBox(height: 12),
              _buildSocialButton(
                iconPath: 'assets/icons/facebook.png',
                text: 'Continue with Facebook',
                color: Colors.blue,
                onPressed: _handleFacebookSignIn,
              ),
              const SizedBox(height: 12),
              _buildSocialButton(
                iconPath: 'assets/icons/twitter.png',
                text: 'Continue with X',
                color: Colors.black,
                onPressed: _handleTwitterSignIn,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNameForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "What's your name?",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: _primaryColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "We'll use this to personalize your experience",
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 40),
          Container(
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
            ),
            child: TextFormField(
              controller: _firstNameController,
              decoration: InputDecoration(
                labelText: 'First Name',
                labelStyle: TextStyle(color: Colors.grey.shade600),
                prefixIcon: Icon(Icons.person_outline, color: _primaryColor),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 16, horizontal: 16,
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your first name';
                }
                return null;
              },
            ),
          ),
          const SizedBox(height: 30),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _submitForm,
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
                  : const Text(
                      'Continue',
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
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(
          child: Divider(
            color: Colors.grey.shade300,
            thickness: 1,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            'OR',
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 14,
            ),
          ),
        ),
        Expanded(
          child: Divider(
            color: Colors.grey.shade300,
            thickness: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildSocialButton({
    required String iconPath,
    required String text,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Container(
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
      ),
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: color,
          side: BorderSide(color: Colors.grey.shade200),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: _cardColor,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              iconPath,
              width: 20,
              height: 20,
            ),
            const SizedBox(width: 12),
            Text(
              text,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      _processNameInput().then((_) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const EmailVerificationScreen()),
        );
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $error')),
        );
      }).whenComplete(() {
        setState(() => _isLoading = false);
      });
    }
  }

  Future<void> _processNameInput() async {
    await Future.delayed(const Duration(seconds: 1));
    // Save name to Firestore or SharedPreferences here
  }

  Future<void> _handleGoogleSignIn() async {
    try {
      setState(() => _isLoading = true);
      
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        setState(() => _isLoading = false);
        return;
      }

      final GoogleSignInAuthentication googleAuth = 
          await googleUser.authentication;
      
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = 
          await FirebaseAuth.instance.signInWithCredential(credential);

      if (userCredential.user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    } on FirebaseAuthException catch (e) {
      setState(() => _isLoading = false);
      String errorMessage = 'Google sign-in failed';
      
      if (e.code == 'account-exists-with-different-credential') {
        errorMessage = 'Account exists with different sign-in method';
      } else if (e.code == 'invalid-credential') {
        errorMessage = 'Invalid credentials';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          duration: const Duration(seconds: 4),
        ),
      );
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error during Google sign-in: ${e.toString()}'),
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  Future<void> _handleFacebookSignIn() async {
    try {
      setState(() => _isLoading = true);
      // Implement Facebook login
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Facebook sign-in failed: $e')),
      );
    }
  }

  Future<void> _handleTwitterSignIn() async {
    try {
      setState(() => _isLoading = true);
      // Implement Twitter login
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Twitter sign-in failed: $e')),
      );
    }
  }
}