import 'package:flutter/material.dart';
import 'package:haraka_afya_ai/features/overview_page.dart';
import 'package:haraka_afya_ai/features/health_page.dart';
import 'package:haraka_afya_ai/screens/privacy_security_screen.dart'; // Import your target screen

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: const Color(0xFFE6F6EC),
        appBar: AppBar(
          title: const Text(
            'Profile',
            style: TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: Colors.white,
          automaticallyImplyLeading: false,
          elevation: 1,
          bottom: TabBar(
            labelColor: const Color(0xFF16A249),
            unselectedLabelColor: Colors.grey,
            indicatorColor: const Color(0xFF16A249),
            tabs: const [
              Tab(text: 'Overview'),
              Tab(text: 'Health'),
              Tab(text: 'Settings'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            OverviewPage(),
            HealthPage(),
            _SettingsPage(), // Updated settings tab
          ],
        ),
      ),
    );
  }
}

// Rewritten Settings tab to include navigable list tiles
class _SettingsPage extends StatelessWidget {
  const _SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSettingsTile(
          context,
          title: 'Security Settings',
          icon: Icons.security,
          onTap: () => _navigateToPrivacySecurity(context),
        ),
        const SizedBox(height: 12),
        _buildSettingsTile(
          context,
          title: 'Privacy and Data',
          icon: Icons.privacy_tip,
          onTap: () => _navigateToPrivacySecurity(context),
        ),
        const SizedBox(height: 12),
        _buildSettingsTile(
          context,
          title: 'Help and Support',
          icon: Icons.support_agent,
          onTap: () => _navigateToPrivacySecurity(context),
        ),
      ],
    );
  }

  Widget _buildSettingsTile(BuildContext context,
      {required String title, required IconData icon, required VoidCallback onTap}) {
    return ListTile(
      tileColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      leading: Icon(icon, color: const Color(0xFF16A249)),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  void _navigateToPrivacySecurity(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PrivacySecurityScreen()),
    );
  }
}
