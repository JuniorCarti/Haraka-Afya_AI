import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:haraka_afya_ai/models/family.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';

// Screens
import 'screens/splash_screen.dart';
import 'screens/auth/sign_in_page.dart';
import 'screens/home_screen.dart';
import 'screens/community_screen.dart';
import 'screens/create_post_screen.dart';
import 'screens/privacy_security_screen.dart';
import 'screens/subscription_plans_screen.dart'; 

// Family Chat Screens
import 'screens/families_home_screen.dart';
import 'screens/family_chat_screen.dart';

// Features
import 'features/learn_page.dart';
import 'features/symptoms_page.dart';
import 'features/hospitals_page.dart';
import 'features/profile_page.dart';

// Models & Repositories
import 'repositories/post_repository.dart';
import 'services/firestore_service.dart';

// Services
import 'services/family_service.dart';
import 'services/anonymous_chat_service.dart';
import 'services/mpesa_service.dart';
import 'services/user_service.dart';

// Providers
import 'providers/user_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Load environment variables with error handling
  try {
    await dotenv.load(fileName: ".env");
    print('✅ Environment variables loaded successfully');
    
    // Verify M-Pesa credentials are loaded
    final consumerKey = dotenv.get('MPESA_CONSUMER_KEY', fallback: '');
    final consumerSecret = dotenv.get('MPESA_CONSUMER_SECRET', fallback: '');
    
    if (consumerKey.isEmpty || consumerSecret.isEmpty) {
      print('⚠️ M-Pesa credentials not found in .env file');
    } else {
      print('✅ M-Pesa credentials loaded');
    }
  } catch (e) {
    print('❌ Error loading environment variables: $e');
  }

  runApp(
    MultiProvider(
      providers: [
        // State Management Providers
        ChangeNotifierProvider<UserProvider>(
          create: (_) => UserProvider(),
        ),
        
        // Service Providers
        Provider<PostRepository>(
          create: (_) => PostRepository(),
        ),
        Provider<FirestoreService>(
          create: (_) => FirestoreService(),
        ),
        Provider<FamilyService>(
          create: (_) => FamilyService(),
        ),
        Provider<AnonymousChatService>(
          create: (_) => AnonymousChatService(),
        ),
        Provider<MpesaService>(
          create: (_) => MpesaService(),
        ),
        Provider<UserService>(
          create: (_) => UserService(),
        ),
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
      
      // Enhanced theme for better UI
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: IconThemeData(color: Color(0xFF0C6D5B)),
        titleTextStyle: TextStyle(
          color: Color(0xFF0C6D5B),
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        selectedItemColor: Color(0xFF0C6D5B),
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
      ),
      
      // Enhanced button themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF0C6D5B),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      
      // Card theme
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      
      // Input decoration theme
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF0C6D5B)),
        ),
        filled: true,
        fillColor: Colors.white,
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
      '/privacy_security': (context) => const PrivacySecurityScreen(),
      '/subscription': (context) => const SubscriptionPlansScreen(),
      
      // Family Chat Routes
      '/families': (context) => const FamiliesHomeScreen(),
      '/family_chat': (context) {
        final family = ModalRoute.of(context)!.settings.arguments as Family;
        return FamilyChatScreen(family: family);
      },
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
            backgroundColor: Colors.white,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0C6D5B)),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Loading...',
                    style: TextStyle(
                      color: Color(0xFF0C6D5B),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            backgroundColor: Colors.white,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: Colors.red,
                    size: 64,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Authentication Error',
                    style: TextStyle(
                      color: Colors.red.shade700,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Please restart the app',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      // Try to reload the auth state
                      FirebaseAuth.instance.authStateChanges().first;
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0C6D5B),
                    ),
                    child: const Text(
                      'Retry',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        // If user is authenticated, load their profile and show home screen
        if (snapshot.hasData) {
          // Initialize user provider with current user data
          final userProvider = Provider.of<UserProvider>(context, listen: false);
          WidgetsBinding.instance.addPostFrameCallback((_) {
            userProvider.loadCurrentUser();
          });
          return const HomeScreen();
        }

        // If no user is authenticated, show sign in page
        return const SignInPage();
      },
    );
  }
}