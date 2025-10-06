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
