import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Haraka-Afya'),
        backgroundColor: const Color(0xFF0C6D5B), // Matching your theme
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.medical_services, size: 80, color: Color(0xFF0C6D5B)),
            SizedBox(height: 20),
            Text(
              'Welcome to Haraka-Afya',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0C6D5B),
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Your AI Health Companion',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}