import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:haraka_afya_ai/screens/auth/sign_in_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Profile'),
          automaticallyImplyLeading: false,
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Overview'),
              Tab(text: 'Health'),
              Tab(text: 'Settings'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Overview Tab
            const Center(child: Text('Overview Content')),
            
            // Health Tab
            const Center(child: Text('Health Content')),
            
            // Settings Tab
            _buildSettingsList(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsList(BuildContext context) {
    final FirebaseAuth _auth = FirebaseAuth.instance;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSettingsItem(
          title: 'Subscription Plans',
          subtitle: 'Manage your plan',
          icon: Icons.subscriptions,
          onTap: () {
            // Navigate to subscription plans
          },
        ),
        _buildSettingsItem(
          title: 'Notifications',
          subtitle: 'Push notifications & alerts',
          icon: Icons.notifications,
          onTap: () {
            // Navigate to notification settings
          },
        ),
        _buildSettingsItem(
          title: 'Security Settings',
          subtitle: '2FA, biometric login & sessions',
          icon: Icons.security,
          onTap: () {
            // Navigate to security settings
          },
        ),
        _buildSettingsItem(
          title: 'Privacy & Data',
          subtitle: 'Data protection settings',
          icon: Icons.privacy_tip,
          onTap: () {
            // Navigate to privacy settings
          },
        ),
        _buildSettingsItem(
          title: 'Help & Support',
          subtitle: 'Get assistance',
          icon: Icons.help_center,
          onTap: () {
            // Navigate to help center
          },
        ),
        const Divider(),
        _buildSettingsItem(
          title: 'Sign Out',
          subtitle: 'Log out of your account',
          icon: Icons.logout,
          color: Colors.red,
          onTap: () async {
            try {
              await _auth.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const SignInPage()),
              );
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error signing out: ${e.toString()}')),
              );
            }
          },
        ),
      ],
    );
  }

  Widget _buildSettingsItem({
    required String title,
    required String subtitle,
    required IconData icon,
    Color color = Colors.blue,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title, style: TextStyle(color: color)),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}