import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'screens/splash_screen.dart';
import 'screens/auth/sign_in_page.dart';
import 'screens/home_screen.dart';
import 'features/learn_page.dart';
import 'features/symptoms_page.dart';
import 'features/hospitals_page.dart';
import 'features/profile_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const HarakaAfyaApp());
}

class HarakaAfyaApp extends StatelessWidget {
  const HarakaAfyaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Haraka Afya AI',
      theme: ThemeData(
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: const Color(0xFFF5F5F5),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0C6D5B),
          primary: const Color(0xFF0C6D5B),
          secondary: const Color(0xFF4CAF50),
        ),
        useMaterial3: true,
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          selectedItemColor: Color(0xFF0C6D5B),
          unselectedItemColor: Colors.grey,
        ),
      ),
      // Start with splash screen
      home: const SplashScreen(),
      // Define all routes
      routes: {
        '/auth': (context) => const AuthWrapper(),
        '/signin': (context) => const SignInPage(),
        '/home': (context) => const HomeScreen(),
        '/learn': (context) => const LearnPage(),
        '/symptoms': (context) => const SymptomsPage(),
        '/hospitals': (context) => const HospitalsPage(),
        '/profile': (context) => const ProfilePage(),
      },
    );
  }
}

// Handles authentication state and routing
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Show loading indicator while checking auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // If user is logged in, go to home page
        if (snapshot.hasData) {
          return const HomeScreen();
        }
        
        // If not logged in, go to sign in page
        return const SignInPage();
      },
    );
  }
}