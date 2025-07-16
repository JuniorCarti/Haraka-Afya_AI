import 'package:flutter/material.dart';
import 'package:haraka_afya_ai/screens/name_input_screen.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'home_screen.dart';

class OnboardingScreens extends StatefulWidget {
  const OnboardingScreens({super.key});

  @override
  State<OnboardingScreens> createState() => _OnboardingScreensState();
}

class _OnboardingScreensState extends State<OnboardingScreens> {
  final PageController _controller = PageController();
  int _currentPage = 0;

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
          
          // Skip Button (positioned top-right)
          Positioned(
            top: 50,
            right: 20,
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
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          
          // Page Indicator
          Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child: Center(
              child: SmoothPageIndicator(
                controller: _controller,
                count: _onboardingData.length,
                effect: const WormEffect(
                  activeDotColor: Colors.white,
                  dotColor: Colors.white54,
                  dotHeight: 10,
                  dotWidth: 10,
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
          padding: const EdgeInsets.all(20.0),
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
              
              const SizedBox(height: 20),
              
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
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    buttonText,
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.black,
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