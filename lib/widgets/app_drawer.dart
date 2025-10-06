import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:haraka_afya_ai/screens/subscription_plans_screen.dart';
import 'package:haraka_afya_ai/screens/privacy_security_screen.dart';
import 'package:haraka_afya_ai/screens/upcoming_events.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Drawer(
      width: MediaQuery.of(context).size.width * 0.85,
      backgroundColor: Colors.white,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Custom Header
          Container(
            height: 200,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF259450),
                  Color(0xFF1976D2),
                ],
              ),
            ),
            child: Stack(
              children: [
                // Background pattern
                Positioned(
                  top: 20,
                  right: 20,
                  child: Opacity(
                    opacity: 0.1,
                    child: Icon(
                      Icons.medical_services,
                      size: 80,
                      color: Colors.white,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: 2,
                              ),
                              image: user?.photoURL != null
                                  ? DecorationImage(
                                      image: NetworkImage(user!.photoURL!),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                            ),
                            child: user?.photoURL == null
                                ? Container(
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white,
                                    ),
                                    child: Center(
                                      child: Text(
                                        user?.displayName?.substring(0, 1).toUpperCase() ?? 'U',
                                        style: const TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF259450),
                                        ),
                                      ),
                                    ),
                                  )
                                : null,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  user?.displayName ?? 'User',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  user?.email ?? '',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.9),
                                    fontSize: 14,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Text(
                                    'Premium Member',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          _buildDrawerItem(
            context,
            icon: Icons.person_outline,
            title: 'Profile Settings',
            subtitle: 'Manage your account',
            route: '/profile',
          ),
          _buildDrawerItem(
            context,
            icon: Icons.workspace_premium,
            title: 'Subscription Plans',
            subtitle: 'Upgrade your plan',
            action: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SubscriptionPlansScreen(),
                ),
              );
            },
            isPremium: true,
          ),
          _buildDrawerItem(
            context,
            icon: Icons.event_outlined,
            title: 'Upcoming Events',
            subtitle: 'View community events',
            action: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const UpcomingEventsScreen(),
                  settings: const RouteSettings(name: '/upcoming-events'),
                ),
              );
            },
          ),
          _buildDrawerItem(
            context,
            icon: Icons.notifications_outlined,
            title: 'Notifications',
            subtitle: 'Manage alerts',
            route: '/notifications',
          ),
          _buildDrawerItem(
            context,
            icon: Icons.language_outlined,
            title: 'Language Settings',
            subtitle: 'Swahili, English, Sheng',
            route: '/language',
          ),
          _buildDrawerItem(
            context,
            icon: Icons.security_outlined,
            title: 'Privacy & Security',
            subtitle: 'Your data protection',
            action: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PrivacySecurityScreen(),
                  settings: const RouteSettings(name: '/privacy-security'),
                ),
              );
            },
          ),
          _buildDrawerItem(
            context,
            icon: Icons.help_outline,
            title: 'Help & Support',
            subtitle: 'Get assistance',
            route: '/help',
          ),
          const SizedBox(height: 16),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Divider(
              height: 1,
              thickness: 1,
              color: Color(0xFFEEEEEE),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFFFEBEE),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFFFCDD2),
                width: 1,
              ),
            ),
            child: ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.logout,
                  color: Colors.red,
                  size: 20,
                ),
              ),
              title: const Text(
                'Sign Out',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: const Text(
                'Secure logout from your account',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.red,
                ),
              ),
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                if (!context.mounted) return;
                Navigator.pushReplacementNamed(context, '/signin');
              },
            ),
          ),
          const SizedBox(height: 20),
          // Footer
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Text(
                  'Haraka Afya AI',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Version 1.0.0',
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
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
    bool isPremium = false,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isPremium 
                ? const Color(0xFFFFD700).withOpacity(0.2)
                : const Color(0xFFE8F5E9),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: isPremium 
                ? const Color(0xFFFFA000)
                : const Color(0xFF259450),
            size: 20,
          ),
        ),
        title: Row(
          children: [
            Text(
              title,
              style: TextStyle(
                color: const Color(0xFF1A1A1A),
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            if (isPremium) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFFFFD700),
                      Color(0xFFFFA000),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'PRO',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
        trailing: Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.arrow_forward_ios,
            size: 12,
            color: Colors.grey,
          ),
        ),
        onTap: () {
          Navigator.pop(context); 
          if (action != null) {
            action();
          } else if (route != null) {
            Navigator.pushNamed(context, route);
          }
        },
      ),
    );
  }
}