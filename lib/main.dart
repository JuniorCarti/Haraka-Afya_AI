import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(const HarakaAfyaApp());
}

class HarakaAfyaApp extends StatelessWidget {
  const HarakaAfyaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Haraka Afya AI',
      home: const SplashScreen(),
    );
  }
}
