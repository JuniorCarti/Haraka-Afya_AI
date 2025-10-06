import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:haraka_afya_ai/screens/community_screen.dart';
import 'package:haraka_afya_ai/screens/anonymous_chat_screen.dart';
import 'package:haraka_afya_ai/widgets/app_drawer.dart';
import 'package:haraka_afya_ai/features/learn_page.dart';
import 'package:haraka_afya_ai/features/symptoms_page.dart';
import 'package:haraka_afya_ai/features/hospitals_page.dart';
import 'package:haraka_afya_ai/features/profile_page.dart';
import 'package:haraka_afya_ai/features/chat/ai_assistant_popup.dart';
import 'package:haraka_afya_ai/screens/medication_reminder_page.dart';
import 'package:haraka_afya_ai/screens/donation_page.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:haraka_afya_ai/widgets/health_articles_carousel.dart';
import 'package:haraka_afya_ai/screens/subscription_plans_screen.dart';
import 'package:haraka_afya_ai/screens/upcoming_events.dart';
import 'package:lottie/lottie.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:iconsax/iconsax.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final PageController _pageController = PageController(initialPage: 0);
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  
  // Live rooms state
  int _liveRoomsCount = 0;
  bool _hasLiveRooms = false;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  @override
  void initState() {
    super.initState();
    _loadLiveRoomsCount();
  }

  // Fetch actual live rooms count from Firestore
  void _loadLiveRoomsCount() {
    _firestore
        .collection('voice_rooms')
        .where('isActive', isEqualTo: true)
        .snapshots()
        .listen((snapshot) {
      if (mounted) {
        setState(() {
          _liveRoomsCount = snapshot.docs.length;
          _hasLiveRooms = _liveRoomsCount > 0;
        });
      }
    });
  }
void _navigateToPage(int index) {
    setState(() {
      _currentIndex = index;
    });
    _pageController.jumpToPage(index);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: const AppDrawer(),
      backgroundColor: Colors.white,
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        children: const [
          HomeContent(),
          LearnPage(),
          SymptomsPage(),
          HospitalsPage(),
          ProfilePage(),
        ],
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }
Widget _buildBottomNavBar() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: const Color(0xFF259450),
          unselectedItemColor: Colors.grey.shade600,
          backgroundColor: Colors.white,
          elevation: 0,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          selectedFontSize: 11,
          unselectedFontSize: 11,
          iconSize: 24,
          onTap: _navigateToPage,
          items: [
            BottomNavigationBarItem(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _currentIndex == 0 ? const Color(0xFFEDFCF5) : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Iconsax.home_15),
              ),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _currentIndex == 1 ? const Color(0xFFEDFCF5) : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Iconsax.book_15),
              ),
              label: 'Learn',
            ),
            BottomNavigationBarItem(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _currentIndex == 2 ? const Color(0xFFEDFCF5) : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Iconsax.health5),
              ),
              label: 'Symptoms',
            ),
            BottomNavigationBarItem(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _currentIndex == 3 ? const Color(0xFFEDFCF5) : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Iconsax.hospital5),
              ),
              label: 'Hospitals',
            ),
