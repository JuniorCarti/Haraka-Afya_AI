import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
    // Original screens
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
      'buttonText': 'Continue',
      'bgColor': Colors.black.withOpacity(0.4),
    },
    // New user type-focused screens
    {
      'title': 'Your Health Community Awaits',
      'description':
          'Join a supportive network of Health Explorers, In-Care Members, Support Partners, Health Professionals, and Partner Facilities.',
      'image': 'https://images.unsplash.com/photo-1609777913028-e2de3dfdeeb1?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MTR8fGhlYWx0aCUyMGNvbW11bml0eXxlbnwwfHwwfHx8MA%3D%3D',
      'buttonText': 'Continue',
      'bgColor': Colors.black.withOpacity(0.5),
    },
    {
      'title': 'Find Your Role in Health',
      'description':
          'Whether you\'re exploring wellness, receiving care, supporting others, or providing expertise - your journey matters here.',
      'image': 'https://plus.unsplash.com/premium_photo-1664475543697-229156438e1e?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MXx8cm9sZSUyMGluJTIwaGVhbHRofGVufDB8fDB8fHww',
      'buttonText': 'Get Started',
      'bgColor': Colors.black.withOpacity(0.5),
    },
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboardingComplete', true);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const NameInputScreen()),
    );
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
                onComplete: _completeOnboarding,
                controller: _controller,
              );
            },
          ),

          // Skip Button
          Positioned(
            top: MediaQuery.of(context).padding.top + 20,
            right: 20,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(15),
              ),
              child: TextButton(
                onPressed: _completeOnboarding,
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
            bottom: 120, // Raised above button area
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
  final VoidCallback onComplete;
  final PageController controller;
  final Color _primaryColor = const Color(0xFF0C6D5B);

  const OnboardingPage({
    super.key,
    required this.title,
    required this.description,
    required this.imagePath,
    required this.buttonText,
    required this.isLastPage,
    required this.bgColor,
    required this.onComplete,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Handle both local assets and network images
        Positioned.fill(
          child: imagePath.startsWith('http')
              ? Image.network(
                  imagePath,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      color: Colors.grey[300],
                      child: Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: _primaryColor.withOpacity(0.1),
                      child: Center(
                        child: Icon(
                          Icons.health_and_safety,
                          size: 100,
                          color: _primaryColor,
                        ),
                      ),
                    );
                  },
                )
              : Image.asset(
                  imagePath,
                  fit: BoxFit.cover,
                ),
        ),

        Container(
          color: bgColor,
        ),

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

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (isLastPage) {
                      onComplete();
                    } else {
                      controller.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeIn,
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: Text(
                    buttonText,
                    style: TextStyle(
                      fontSize: 18,
                      color: _primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ],
    );
  }
}