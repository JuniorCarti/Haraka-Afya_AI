import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';

// Screens
import 'screens/splash_screen.dart';
import 'screens/auth/sign_in_page.dart';
import 'screens/home_screen.dart';
import 'screens/community_screen.dart';
import 'screens/create_post_screen.dart';
import 'screens/privacy_security_screen.dart'; // Added import

// Features
import 'features/learn_page.dart';
import 'features/symptoms_page.dart';
import 'features/hospitals_page.dart';
import 'features/profile_page.dart';

// Models & Repositories
import 'models/post.dart';
import 'repositories/post_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Load environment variables
  await dotenv.load(fileName: ".env");
  
  runApp(
    MultiProvider(
      providers: [
        Provider<PostRepository>(
          create: (_) => PostRepository(),
        ),
        // Add other providers as needed
      ],
      child: const HarakaAfyaApp(),
    ),
  );
}

class HarakaAfyaApp extends StatelessWidget {
  const HarakaAfyaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Haraka Afya AI',
      theme: _buildAppTheme(),
      home: const SplashScreen(),
      routes: _buildAppRoutes(),
    );
  }

  ThemeData _buildAppTheme() {
    return ThemeData(
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
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: IconThemeData(color: Color(0xFF0C6D5B)),
      ),
    );
  }

  Map<String, WidgetBuilder> _buildAppRoutes() {
    return {
      '/auth': (context) => const AuthWrapper(),
      '/signin': (context) => const SignInPage(),
      '/home': (context) => const HomeScreen(),
      '/community': (context) => const CommunityScreen(),
      '/create_post': (context) => const CreatePostScreen(),
      '/learn': (context) => const LearnPage(),
      '/symptoms': (context) => const SymptomsPage(),
      '/hospitals': (context) => const HospitalsPage(),
      '/profile': (context) => const ProfilePage(),
      '/privacy_security': (context) => const PrivacySecurityScreen(), // Added route
    };
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        
        if (snapshot.hasError) {
          return const Scaffold(
            body: Center(child: Text('Authentication error')),
          );
        }
        
        return snapshot.hasData ? const HomeScreen() : const SignInPage();
      },
    );
  }
}