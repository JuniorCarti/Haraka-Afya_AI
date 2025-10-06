import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
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

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late final AnimationController _logoController;
  late final AnimationController _titleController;
  late final AnimationController _subtitleController;
  late final AnimationController _backgroundController;
  
  late final Animation<double> _logoAnimation;
  late final Animation<double> _titleAnimation;
  late final Animation<double> _subtitleAnimation;
  late final Animation<Color?> _backgroundAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize controllers
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _titleController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _subtitleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _backgroundController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // Define animations
    _logoAnimation = CurvedAnimation(
      parent: _logoController,
      curve: Curves.elasticOut,
    );

    _titleAnimation = CurvedAnimation(
      parent: _titleController,
      curve: Curves.easeOutCubic,
    );

    _subtitleAnimation = CurvedAnimation(
      parent: _subtitleController,
      curve: Curves.easeOut,
    );

    _backgroundAnimation = ColorTween(
      begin: const Color(0xFFEDFCF5),
      end: const Color(0xFFF8F9FA),
    ).animate(_backgroundController);

    _startAnimations();
    _navigateAfterDelay();
  }

  Future<void> _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _backgroundController.forward();
    await Future.delayed(const Duration(milliseconds: 200));
    _logoController.forward();
    await Future.delayed(const Duration(milliseconds: 500));
    _titleController.forward();
    await Future.delayed(const Duration(milliseconds: 300));
    _subtitleController.forward();
  }

  Future<void> _navigateAfterDelay() async {
    await Future.delayed(const Duration(seconds: 3));

    final prefs = await SharedPreferences.getInstance();
    final isFirstLaunch = prefs.getBool('onboardingComplete') ?? false;
    final user = FirebaseAuth.instance.currentUser;

    if (!mounted) return;

    if (user != null) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const HomeScreen(),
          transitionDuration: const Duration(milliseconds: 800),
          transitionsBuilder: (_, a, __, c) => FadeTransition(
            opacity: a,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1.0, 0.0),
                end: Offset.zero,
              ).animate(CurvedAnimation(parent: a, curve: Curves.easeInOut)),
              child: c,
            ),
          ),
        ),
      );
    } else if (isFirstLaunch) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const SignInPage(),
          transitionDuration: const Duration(milliseconds: 800),
          transitionsBuilder: (_, a, __, c) => FadeTransition(
            opacity: a,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1.0, 0.0),
                end: Offset.zero,
              ).animate(CurvedAnimation(parent: a, curve: Curves.easeInOut)),
              child: c,
            ),
          ),
        ),
      );
    } else {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const OnboardingScreens(),
          transitionDuration: const Duration(milliseconds: 800),
          transitionsBuilder: (_, a, __, c) => FadeTransition(
            opacity: a,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1.0, 0.0),
                end: Offset.zero,
              ).animate(CurvedAnimation(parent: a, curve: Curves.easeInOut)),
              child: c,
            ),
          ),
        ),
      );
      await prefs.setBool('onboardingComplete', true);
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _titleController.dispose();
    _subtitleController.dispose();
    _backgroundController.dispose();
    super.dispose();
  }

  Widget _buildAnimatedLogo() {
    return ScaleTransition(
      scale: _logoAnimation,
      child: Container(
        padding: const EdgeInsets.all(30),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF259450),
              Color(0xFF1976D2),
            ],
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF259450).withOpacity(0.4),
              blurRadius: 30,
              spreadRadius: 5,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Hero(
          tag: 'app-logo',
          child: Lottie.asset(
            'assets/animations/splash.json',
            width: 120,
            height: 120,
            repeat: true,
            animate: true,
            filterQuality: FilterQuality.high,
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedTitle() {
    return FadeTransition(
      opacity: _titleAnimation,
      child: SlideTransition(
        position: _titleAnimation.drive(
          Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero),
        ),
        child: ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [
              Color(0xFF259450),
              Color(0xFF1976D2),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(bounds),
          child: const Text(
            'Haraka Afya',
            style: TextStyle(
              fontSize: 42,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
              color: Colors.white, // This will be overridden by gradient
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedSubtitle() {
    return FadeTransition(
      opacity: _subtitleAnimation,
      child: SlideTransition(
        position: _subtitleAnimation.drive(
          Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero),
        ),
        child: const Text(
          'Empowering Cancer Care Through AI',
          style: TextStyle(
            color: Color(0xFF666666),
            fontSize: 16,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.5,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return FadeTransition(
      opacity: _subtitleAnimation,
      child: Column(
        children: [
          SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                const Color(0xFF259450).withOpacity(0.8),
              ),
            ),
          ),
          const SizedBox(height: 16),
          AnimatedOpacity(
            opacity: _subtitleController.value,
            duration: const Duration(milliseconds: 500),
            child: Text(
              'Loading your health journey...',
              style: TextStyle(
                color: const Color(0xFF666666).withOpacity(0.7),
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackgroundElements() {
    return Positioned.fill(
      child: AnimatedBuilder(
        animation: _backgroundController,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  _backgroundAnimation.value!,
                  _backgroundAnimation.value!.withOpacity(0.9),
                ],
              ),
            ),
            child: CustomPaint(
              painter: _BackgroundPainter(animation: _backgroundController),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _backgroundController,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  _backgroundAnimation.value!,
                  _backgroundAnimation.value!.withGreen(250),
                ],
              ),
            ),
            child: Stack(
              children: [
                _buildBackgroundElements(),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(40),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildAnimatedLogo(),
                        const SizedBox(height: 40),
                        _buildAnimatedTitle(),
                        const SizedBox(height: 16),
                        _buildAnimatedSubtitle(),
                        const SizedBox(height: 60),
                        _buildLoadingIndicator(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _BackgroundPainter extends CustomPainter {
  final Animation<double> animation;

  _BackgroundPainter({required this.animation});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF259450).withOpacity(0.05 * animation.value)
      ..style = PaintingStyle.fill;

    // Draw some subtle background shapes
    final path = Path()
      ..addOval(Rect.fromCircle(
        center: Offset(size.width * 0.2, size.height * 0.1),
        radius: 80 * animation.value,
      ))
      ..addOval(Rect.fromCircle(
        center: Offset(size.width * 0.8, size.height * 0.8),
        radius: 120 * animation.value,
      ))
      ..addOval(Rect.fromCircle(
        center: Offset(size.width * 0.6, size.height * 0.3),
        radius: 60 * animation.value,
      ));

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}