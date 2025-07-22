import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:haraka_afya_ai/screens/auth/sign_in_page.dart';
import 'package:haraka_afya_ai/screens/privacy_security_screen.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  void _navigateToPrivacySecurity(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const PrivacySecurityScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final FirebaseAuth auth = FirebaseAuth.instance;

    return Container(
      color: const Color(0xFFE6F6EC),
      child: ListView(
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
            onTap: () => _navigateToPrivacySecurity(context),
          ),
          _buildSettingsItem(
            title: 'Privacy & Data',
            subtitle: 'Data protection settings',
            icon: Icons.privacy_tip,
            onTap: () => _navigateToPrivacySecurity(context),
          ),
          _buildSettingsItem(
            title: 'Help & Support',
            subtitle: 'Get assistance',
            icon: Icons.help_center,
            onTap: () => _navigateToPrivacySecurity(context),
          ),
          const Divider(),
          _buildSettingsItem(
            title: 'Sign Out',
            subtitle: 'Log out of your account',
            icon: Icons.logout,
            color: Colors.red,
            onTap: () async {
              try {
                await auth.signOut();
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
      ),
    );
  }

  Widget _buildSettingsItem({
    required String title,
    required String subtitle,
    required IconData icon,
    Color color = const Color(0xFF16A249),
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