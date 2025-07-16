import 'package:flutter/material.dart';
import 'package:haraka_afya_ai/screens/name_input_screen.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnboardingScreens extends StatefulWidget {
  const OnboardingScreens({super.key});

  @override
  State<OnboardingScreens> createState() => _OnboardingScreensState();
}

class _OnboardingScreensState extends State<OnboardingScreens> {
  final PageController _controller = PageController();
  int _currentPage = 0;
  final Color _primaryColor = const Color(0xFF0C6D5B); // Brand green color

  final List<Map<String, dynamic>> _onboardingData = [
    {
      'title': 'AI-Powered Health Analysis',
      'description':
          'Get instant health insights powered by advanced AI technology. Describe your symptoms in English, Swahili, or Sheng.',
      'image': 'assets/onboarding1.jpg',
      'buttonText': 'Continue',
      'bgColor': Colors.black.withOpacity(0.4),
    },
    {
      'title': 'Instant Healthcare Access',
      'description':
          'Connect with healthcare providers instantly. Find nearby hospitals, clinics, and emergency services in real-time.',
      'image': 'assets/onboarding2.jpg',
      'buttonText': 'Continue',
      'bgColor': Colors.black.withOpacity(0.4),
    },
    {
      'title': '24/7 Health Support',
      'description':
          'Your health companion is always available. Get medical guidance, track symptoms, and stay informed about your wellness.',
      'image': 'assets/onboarding3.jpg',
      'buttonText': 'Get Started',
      'bgColor': Colors.black.withOpacity(0.4),
    },
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _controller,
            itemCount: _onboardingData.length,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemBuilder: (context, index) {
              return OnboardingPage(
                title: _onboardingData[index]['title']!,
                description: _onboardingData[index]['description']!,
                imagePath: _onboardingData[index]['image']!,
                buttonText: _onboardingData[index]['buttonText']!,
                isLastPage: index == _onboardingData.length - 1,
                bgColor: _onboardingData[index]['bgColor']!,
              );
            },
          ),
          
          // Sleek Skip Button
          Positioned(
            top: MediaQuery.of(context).padding.top + 20,
            right: 20,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const NameInputScreen()),
                  );
                },
                child: const Text(
                  'SKIP',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ),
          ),
          
          // Page Indicator
          Positioned(
            bottom: 120, // Increased from 100 to prevent overlap
            left: 0,
            right: 0,
            child: Center(
              child: SmoothPageIndicator(
                controller: _controller,
                count: _onboardingData.length,
                effect: const WormEffect(
                  activeDotColor: Colors.white,
                  dotColor: Colors.white54,
                  dotHeight: 8,
                  dotWidth: 8,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class OnboardingPage extends StatelessWidget {
  final String title;
  final String description;
  final String imagePath;
  final String buttonText;
  final bool isLastPage;
  final Color bgColor;
  final Color _primaryColor = const Color(0xFF0C6D5B);

  const OnboardingPage({
    super.key,
    required this.title,
    required this.description,
    required this.imagePath,
    required this.buttonText,
    required this.isLastPage,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Full-screen background image
        Positioned.fill(
          child: Image.asset(
            imagePath,
            fit: BoxFit.cover,
          ),
        ),
        
        // Color overlay
        Container(
          color: bgColor,
        ),
        
        // Content
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  height: 1.3,
                ),
              ),
              
              const SizedBox(height: 16),
              
              Text(
                description,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  height: 1.5,
                ),
              ),
              
              const SizedBox(height: 40),
              
              // Fixed button with proper spacing
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (isLastPage) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const NameInputScreen()),
                      );
                    } else {
                      final onboardingState = context.findAncestorStateOfType<_OnboardingScreensState>();
                      onboardingState?._controller.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeIn,
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12), // More modern 12px radius
                    ),
                    elevation: 2,
                  ),
                  child: Text(
                    buttonText,
                    style: TextStyle(
                      fontSize: 18,
                      color: _primaryColor, // Using brand color for text
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20), // Added extra spacing
            ],
          ),
        ),
      ],
    );
  }
}