import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Main App Pages
import 'package:haraka_afya_ai/features/learn_page.dart';
import 'package:haraka_afya_ai/features/symptoms_page.dart';
import 'package:haraka_afya_ai/features/hospitals_page.dart';
import 'package:haraka_afya_ai/features/profile_page.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final PageController _pageController = PageController(initialPage: 0);

  // Get personalized greeting based on time and user name
  String _getGreeting(String? displayName) {
    final hour = DateTime.now().hour;
    final name = displayName?.split(' ')[0] ?? 'there';
    
    return hour < 12 ? 'Good Morning, $name!'
         : hour < 17 ? 'Good Afternoon, $name!'
         : 'Good Evening, $name!';
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final greeting = _getGreeting(user?.displayName);

    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(), // Disable swipe
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
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color(0xFF0C6D5B),
      unselectedItemColor: Colors.grey,
      showSelectedLabels: true,
      showUnselectedLabels: true,
      onTap: (index) {
        setState(() => _currentIndex = index);
        _pageController.jumpToPage(index);
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.school_outlined),
          activeIcon: Icon(Icons.school),
          label: 'Learn',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.medical_services_outlined),
          activeIcon: Icon(Icons.medical_services),
          label: 'Symptoms',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.local_hospital_outlined),
          activeIcon: Icon(Icons.local_hospital),
          label: 'Hospitals',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outlined),
          activeIcon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
    );
  }
}

class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final displayName = user?.displayName ?? '';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Greeting Section
          _buildGreetingSection(context, displayName),
          const SizedBox(height: 24),
          
          // AI Assistant Card
          _buildAIAssistantCard(),
          const SizedBox(height: 24),
          
          // Emergency Services
          _buildEmergencyCard(),
          const SizedBox(height: 24),
          
          // Symptom Checker
          _buildSymptomChecker(),
          const SizedBox(height: 24),
          
          // Health Overview
          _buildHealthOverview(),
          const SizedBox(height: 24),
          
          // Quick Actions Grid
          _buildQuickActionsGrid(),
          const SizedBox(height: 24),
          
          // Health Tools
          _buildHealthTools(),
          const SizedBox(height: 24),
          
          // Health Tips
          _buildHealthTips(),
          const SizedBox(height: 24),
          
          // Medication Reminder
          _buildMedicationReminder(),
          const SizedBox(height: 24),
          
          // Premium Upgrade
          _buildPremiumUpgrade(),
        ],
      ),
    );
  }

  Widget _buildGreetingSection(BuildContext context, String displayName) {
    final hour = DateTime.now().hour;
    String greeting;
    
    if (hour < 12) {
      greeting = 'Good Morning';
    } else if (hour < 17) {
      greeting = 'Good Afternoon';
    } else {
      greeting = 'Good Evening';
    }

    final fullGreeting = displayName.isNotEmpty 
        ? '$greeting, ${displayName.split(' ')[0]}!'
        : '$greeting!';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          fullGreeting,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'How can I help you stay healthy today?',
          style: TextStyle(
            fontSize: 16,
            color: Colors.black54,
          ),
        ),
      ],
    );
  }

  Widget _buildAIAssistantCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.chat, color: Colors.green),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Need help? Chat with our AI assistant anytime!',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.arrow_forward, color: Colors.green),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmergencyCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: Colors.red[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.warning, color: Colors.red),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Emergency: Call 911 for severe symptoms',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.arrow_forward, color: Colors.red),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSymptomChecker() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'Tell me your symptoms',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.mic),
                  label: const Text('Speak'),
                  onPressed: () {},
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.keyboard),
                  label: const Text('Type'),
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Available in multiple languages',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthOverview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          title: 'Health Overview',
          actionText: 'View All',
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildHealthMetric(
              value: '72 bpm',
              label: 'Heart Rate',
              icon: Icons.favorite,
              color: Colors.red,
            ),
            _buildHealthMetric(
              value: '36.5°C',
              label: 'Temperature',
              icon: Icons.thermostat,
              color: Colors.orange,
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Text(
          'Last checked 2 days ago',
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildHealthMetric({
    required String value,
    required String label,
    required IconData icon,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, size: 40, color: color),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildQuickActionsGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Quick Actions'),
        const SizedBox(height: 12),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          childAspectRatio: 1.5,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          children: [
            _buildQuickAction(
              icon: Icons.search,
              label: 'Check Symptoms',
              color: Colors.blue,
            ),
            _buildQuickAction(
              icon: Icons.local_hospital,
              label: 'Find Hospitals',
              color: Colors.green,
            ),
            _buildQuickAction(
              icon: Icons.lightbulb,
              label: 'Health Tips',
              color: Colors.orange,
            ),
            _buildQuickAction(
              icon: Icons.emergency,
              label: 'Emergency',
              color: Colors.red,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickAction({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 30, color: color),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHealthTools() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Health Tools'),
        const SizedBox(height: 12),
        SizedBox(
          height: 120,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _buildHealthTool(
                icon: Icons.book,
                label: 'Medical Dictionary',
                description: '500+ terms explained',
                color: Colors.purple,
              ),
              const SizedBox(width: 12),
              _buildHealthTool(
                icon: Icons.notifications,
                label: 'Medication Reminders',
                description: 'Track your medications',
                color: Colors.blue,
              ),
              const SizedBox(width: 12),
              _buildHealthTool(
                icon: Icons.people,
                label: 'Health Community',
                description: 'Connect with others',
                color: Colors.green,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHealthTool({
    required IconData icon,
    required String label,
    required String description,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: SizedBox(
          width: 160,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 30, color: color),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHealthTips() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          title: "Today's Health Tips",
          actionText: 'View More',
        ),
        const SizedBox(height: 12),
        Column(
          children: [
            _buildHealthTip(
              tip: '1. Stay hydrated - aim for 8 glasses of water daily',
            ),
            const SizedBox(height: 8),
            _buildHealthTip(
              tip: '2. Take a 10-minute walk after meals',
            ),
            const SizedBox(height: 8),
            _buildHealthTip(
              tip: '3. Practice deep breathing for 5 minutes',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHealthTip({required String tip}) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            const Icon(Icons.lightbulb_outline, color: Colors.green, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(tip)),
          ],
        ),
      ),
    );
  }

  Widget _buildMedicationReminder() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.medical_services, color: Colors.blue, size: 40),
            const SizedBox(width: 16),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Medication Reminder',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text('Vitamin D'),
                  Text('Take with breakfast'),
                ],
              ),
            ),
            Column(
              children: [
                const Text('9:00 AM'),
                Switch(value: true, onChanged: (val) {}),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumUpgrade() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: const Color(0xFF0C6D5B),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.star, color: Colors.white, size: 40),
            const SizedBox(width: 16),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Upgrade to Premium',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Unlimited AI consultations & more features',
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF0C6D5B),
              ),
              child: const Text('Upgrade'),
            ),
          ],
        ),
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String title;
  final String? actionText;
  final VoidCallback? onAction;

  const SectionHeader({
    super.key,
    required this.title,
    this.actionText,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (actionText != null)
          TextButton(
            onPressed: onAction,
            child: Text(actionText!),
          ),
      ],
    );
  }
}