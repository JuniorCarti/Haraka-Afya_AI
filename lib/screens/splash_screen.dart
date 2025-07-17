import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:haraka_afya_ai/screens/auth/sign_in_page.dart';
import 'package:haraka_afya_ai/screens/home_screen.dart';
import 'package:haraka_afya_ai/screens/onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthAndNavigation();
  }

  Future<void> _checkAuthAndNavigation() async {
    try {
      // Add slight delay for splash screen visibility
      await Future.delayed(const Duration(milliseconds: 1500));

      final prefs = await SharedPreferences.getInstance();
      final isFirstLaunch = prefs.getBool('onboardingComplete') ?? false;
      final user = FirebaseAuth.instance.currentUser;

      if (!mounted) return;

      if (user != null) {
        // User is authenticated - go to home
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const HomeScreen(),
            transitionDuration: const Duration(milliseconds: 500),
            transitionsBuilder: (_, a, __, c) => 
              FadeTransition(opacity: a, child: c),
          ),
        );
      } else if (isFirstLaunch) {
        // Onboarding completed but not logged in
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const SignInPage(),
            transitionDuration: const Duration(milliseconds: 500),
            transitionsBuilder: (_, a, __, c) => 
              FadeTransition(opacity: a, child: c),
          ),
        );
      } else {
        // First launch - show onboarding
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const OnboardingScreens(),
            transitionDuration: const Duration(milliseconds: 500),
            transitionsBuilder: (_, a, __, c) => 
              FadeTransition(opacity: a, child: c),
          ),
        );
        await prefs.setBool('onboardingComplete', true);
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const SignInPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0C6D5B), // Using your brand color
      body: Stack(
        children: [
          // Background elements
          Positioned.fill(
            child: Opacity(
              opacity: 0.1,
              child: SvgPicture.asset(
                'assets/patterns/health_pattern.svg',
                fit: BoxFit.cover,
              ),
            ),
          ),
          
          // Main content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animated logo container
                AnimatedContainer(
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.easeInOut,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Hero(
                    tag: 'app-logo',
                    child: SvgPicture.asset(
                      'assets/logo.svg',
                      width: 120,
                      height: 120,
                      placeholderBuilder: (context) =>
                          const CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                // App name with animation
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: 1),
                  duration: const Duration(milliseconds: 800),
                  builder: (_, value, child) => Opacity(
                    opacity: value,
                    child: Transform.translate(
                      offset: Offset(0, 20 * (1 - value)),
                      child: child,
                    ),
                  ),
                  child: const Text(
                    'Haraka-Afya',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // Tagline with animation
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: 1),
                  duration: const Duration(milliseconds: 1000),
                  curve: Curves.easeOut,
                  builder: (_, value, child) => Opacity(
                    opacity: value,
                    child: Transform.translate(
                      offset: Offset(0, 20 * (1 - value)),
                      child: child,
                    ),
                  ),
                  child: const Text(
                    'Your AI Health Companion',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Loading indicator at bottom
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Colors.white.withOpacity(0.8),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}