import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:haraka_afya_ai/screens/subscription_plans_screen.dart';
import 'package:haraka_afya_ai/screens/privacy_security_screen.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    
    return Drawer(
      width: MediaQuery.of(context).size.width * 0.85,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(
              user?.displayName ?? 'User',
              style: const TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            accountEmail: Text(
              user?.email ?? '',
              style: const TextStyle(
                color: Colors.black87,
              ),
            ),
            currentAccountPicture: CircleAvatar(
              backgroundColor: const Color(0xFF16A249), // Dark green
              backgroundImage: user?.photoURL != null 
                  ? NetworkImage(user!.photoURL!)
                  : null,
              child: user?.photoURL == null
                  ? Text(
                      user?.displayName?.substring(0, 1).toUpperCase() ?? 'U',
                      style: const TextStyle(
                        fontSize: 36,
                        color: Colors.white,
                      ),
                    )
                  : null,
            ),
            decoration: const BoxDecoration(
              color: Color(0xFFF0FDF4), // Light green
            ),
          ),
          _buildDrawerItem(
            context,
            icon: Icons.person,
            title: 'Profile Settings',
            subtitle: 'Manage your account',
            route: '/profile',
          ),
          _buildDrawerItem(
            context,
            icon: Icons.credit_card,
            title: 'Subscription Plans',
            subtitle: 'Upgrade your plan',
            action: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SubscriptionPlansScreen()),
              );
            },
          ),
          _buildDrawerItem(
            context,
            icon: Icons.notifications,
            title: 'Notifications',
            subtitle: 'Manage alerts',
            route: '/notifications',
          ),
          _buildDrawerItem(
            context,
            icon: Icons.language,
            title: 'Language Settings',
            subtitle: 'Swahili, English, Sheng',
            route: '/language',
          ),
          _buildDrawerItem(
            context,
            icon: Icons.security,
            title: 'Privacy & Security',
            subtitle: 'Your data protection',
            action: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PrivacySecurityScreen()),
              );
            },
          ),
          _buildDrawerItem(
            context,
            icon: Icons.help,
            title: 'Help & Support',
            subtitle: 'Get assistance',
            route: '/help',
          ),
          const Divider(
            height: 1,
            thickness: 1,
            color: Colors.grey,
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text(
              'Sign Out', 
              style: TextStyle(color: Colors.red),
            ),
            onTap: () async {
              await FirebaseAuth.instance.signOut();
              if (!context.mounted) return;
              Navigator.pushReplacementNamed(context, '/signin');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    String? route,
    VoidCallback? action,
  }) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF16A249)), // Dark green
      title: Text(title),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: 12),
      ),
      onTap: () {
        Navigator.pop(context);
        if (action != null) {
          action();
        } else if (route != null) {
          Navigator.pushNamed(context, route);
        }
      },
    );
  }
}