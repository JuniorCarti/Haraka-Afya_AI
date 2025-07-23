import 'package:flutter/material.dart';
import 'package:haraka_afya_ai/features/overview_page.dart';
import 'package:haraka_afya_ai/features/health_page.dart';
import 'package:haraka_afya_ai/features/settings.dart';

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
            SettingsPage(), // Keep this as const since we'll handle navigation internally
          ],
        ),
      ),
    );
  }
}