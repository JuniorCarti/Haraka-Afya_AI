import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:haraka_afya_ai/screens/community_screen.dart';
import 'package:haraka_afya_ai/widgets/app_drawer.dart';
import 'package:haraka_afya_ai/features/learn_page.dart';
import 'package:haraka_afya_ai/features/symptoms_page.dart';
import 'package:haraka_afya_ai/features/hospitals_page.dart';
import 'package:haraka_afya_ai/features/profile_page.dart';
import 'package:haraka_afya_ai/features/chat/ai_assistant_popup.dart';
import 'package:haraka_afya_ai/screens/medication_reminder_page.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:haraka_afya_ai/widgets/health_articles_carousel.dart';
import 'package:haraka_afya_ai/screens/subscription_plans_screen.dart';
import 'package:haraka_afya_ai/screens/upcoming_events.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final PageController _pageController = PageController(initialPage: 0);
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void _navigateToPage(int index) {
    setState(() {
      _currentIndex = index;
    });
    _pageController.jumpToPage(index);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: const AppDrawer(),
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        children: const [
          HomeContent(),
          LearnPage(),
          SymptomsPage(),
          HospitalsPage(),
          ProfilePage(),
        ],
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey.shade300, width: 0.5)),
      ),
      child: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF259450),
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        elevation: 0,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        iconSize: 28,
        onTap: _navigateToPage,
        items: [
          _buildNavItem(
            icon: Icons.home_outlined,
            activeIcon: Icons.home,
            label: 'Home',
          ),
          _buildNavItem(
            icon: Icons.school_outlined,
            activeIcon: Icons.school,
            label: 'Learn',
          ),
          _buildNavItem(
            icon: Icons.medical_services_outlined,
            activeIcon: Icons.medical_services,
            label: 'Symptoms',
          ),
          _buildNavItem(
            icon: Icons.local_hospital_outlined,
            activeIcon: Icons.local_hospital,
            label: 'Hospitals',
          ),
          _buildNavItem(
            icon: Icons.person_outlined,
            activeIcon: Icons.person,
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  BottomNavigationBarItem _buildNavItem({
    required IconData icon,
    required IconData activeIcon,
    required String label,
  }) {
    return BottomNavigationBarItem(
      icon: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: Icon(icon, size: 26),
      ),
      activeIcon: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFEDFCF5),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Icon(
          activeIcon,
          size: 26,
          color: const Color(0xFF259450),
        ),
      ),
      label: label,
    );
  }
}

class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final greeting = _getGreeting(user?.displayName);

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverAppBar(
          pinned: true,
          floating: true,
          snap: false,
          title: const Text(
            'Health Community',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
          backgroundColor: Colors.white,
          elevation: 1,
        ),
        
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              _buildGreetingSection(context, greeting),
              const SizedBox(height: 16),
              _buildAIAssistantCard(context),
              const SizedBox(height: 16),
              _buildOurServicesSection(context),
              const SizedBox(height: 16),
              _buildEmergencyCard(context),
              const SizedBox(height: 16),
              _buildSymptomChecker(context),
              const SizedBox(height: 24),
              _buildUpcomingEventsCard(context),
              const SizedBox(height: 16),
              _buildCommunitySection(context),
              const SizedBox(height: 16),
              _buildHealthOverview(),
              const SizedBox(height: 16),
              _buildHealthTools(),
              const SizedBox(height: 16),
              _buildMedicationReminder(context),
              const SizedBox(height: 16),
              _buildPremiumUpgrade(context),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildGreetingSection(BuildContext context, String greeting) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          greeting,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'How can I help you stay healthy today?',
          style: TextStyle(
            fontSize: 14,
            color: Colors.black54,
          ),
        ),
      ],
    );
  }

  Widget _buildOurServicesSection(BuildContext context) {
    final homeState = context.findAncestorStateOfType<_HomeScreenState>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Our Services',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildServiceItem(
              icon: Icons.school,
              label: 'Learn',
              bgColor: const Color(0xFFE3F2FD),
              iconColor: const Color(0xFF1976D2),
              onTap: () => homeState?._navigateToPage(1),
            ),
            _buildServiceItem(
              icon: Icons.medical_services,
              label: 'Symptoms',
              bgColor: const Color(0xFFE8F5E9),
              iconColor: const Color(0xFF388E3C),
              onTap: () => homeState?._navigateToPage(2),
            ),
            _buildServiceItem(
              icon: Icons.local_hospital,
              label: 'Cancer Facilities',
              bgColor: const Color(0xFFF3E5F5),
              iconColor: const Color(0xFF8E24AA),
              onTap: () => homeState?._navigateToPage(3),
            ),
            _buildServiceItem(
              icon: Icons.volunteer_activism,
              label: 'Donate',
              bgColor: const Color(0xFFFFEBEE),
              iconColor: const Color(0xFFD32F2F),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Donation feature coming soon!')),
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildServiceItem({
    required IconData icon,
    required String label,
    required Color bgColor,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 30),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingEventsCard(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const UpcomingEventsScreen(),
            ),
          );
        },
        child: Column(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: Image.network(
                'https://t4.ftcdn.net/jpg/05/64/47/45/240_F_564474595_B2BrV5nZoyEAbfetpiRKMQeRWXf4KCbs.jpg',
                height: 120,
                width: double.infinity,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    height: 120,
                    color: Colors.grey[200],
                    child: Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 120,
                  color: Colors.grey[200],
                  child: const Icon(Icons.broken_image, size: 50, color: Colors.grey),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Upcoming Events',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Check out cancer awareness events near you',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, size: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommunitySection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Community Posts',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CommunityScreen(),
                  ),
                );
              },
              child: const Text(
                'See All',
                style: TextStyle(
                  color: Color(0xFF259450),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        const HealthArticlesCarousel(),
      ],
    );
  }

  Widget _buildAIAssistantCard(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => showDialog(
          context: context,
          builder: (context) => const AIAssistantPopup(),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF25D366),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.chat, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Haraka-Afya Support',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Chat with our AI assistant anytime!',
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmergencyCard(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.emergency, color: Colors.red[700], size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Emergency Services',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Multiple hospitals • Real-time ambulance tracking',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildEmergencyButton(
                    icon: Icons.phone,
                    label: 'Call 911',
                    color: Colors.red,
                    onPressed: () async {
                      const url = 'tel:911';
                      if (await canLaunchUrl(Uri.parse(url))) {
                        await launchUrl(Uri.parse(url));
                      }
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildEmergencyButton(
                    icon: Icons.local_taxi,
                    label: 'Uber Ambulance',
                    color: Colors.black,
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Opening Uber for ambulance request'),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmergencyButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      icon: Icon(icon, size: 16),
      label: Text(label, style: const TextStyle(fontSize: 12)),
      style: ElevatedButton.styleFrom(
        backgroundColor: color == Colors.red ? Colors.white : color,
        foregroundColor: color == Colors.red ? color : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: color == Colors.red 
              ? const BorderSide(color: Colors.red)
              : BorderSide.none,
        ),
        padding: const EdgeInsets.symmetric(vertical: 8),
      ),
      onPressed: onPressed,
    );
  }

  Widget _buildSymptomChecker(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          final homeState = context.findAncestorStateOfType<_HomeScreenState>();
          homeState?._navigateToPage(2);
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Hujambo! Tell me your symptoms',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '🩺Get quick, private health insights based on your symptoms',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHealthOverview() {
    return _buildSectionCard(
      title: 'Health Overview',
      description: 'Track your health metrics and get personalized insights.',
      onTap: () {},
    );
  }

  Widget _buildHealthTools() {
    return _buildSectionCard(
      title: 'Health Tools',
      description: 'BMI calculator, step tracker, and more.',
      onTap: () {},
    );
  }

  Widget _buildMedicationReminder(BuildContext context) {
    return _buildSectionCard(
      title: 'Medication Reminder',
      description: 'Set reminders for your medications and never miss a dose.',
      icon: Icons.alarm,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const MedicationReminderPage(),
          ),
        );
      },
    );
  }

  Widget _buildSectionCard({
    required String title,
    required String description,
    IconData? icon,
    VoidCallback? onTap,
  }) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              if (icon != null)
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Icon(icon, size: 20),
                ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPremiumUpgrade(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: const Color(0xFFD8FBE5),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Upgrade to Premium',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Unlock advanced features and personalized health insights.',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SubscriptionPlansScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF279A51),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Upgrade',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getGreeting(String? displayName) {
    final hour = DateTime.now().hour;
    final name = displayName?.split(' ')[0] ?? 'there';
    return hour < 12 ? 'Good Morning, $name!'
         : hour < 17 ? 'Good Afternoon, $name!'
         : 'Good Evening, $name!';
  }
}