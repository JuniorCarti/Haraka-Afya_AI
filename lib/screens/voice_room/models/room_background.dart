import 'package:flutter/material.dart';

class RoomBackground {
  final String id;
  final String name;
  final String imageUrl;
  final int requiredLevel;
  final bool isPremium;
  final Color primaryColor;
  final Color secondaryColor;

  RoomBackground({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.requiredLevel,
    this.isPremium = false,
    required this.primaryColor,
    required this.secondaryColor,
  });

  // Check if background is unlocked for user level
  bool isUnlocked(int userLevel) {
    return userLevel >= requiredLevel;
  }

  // Default backgrounds
  static List<RoomBackground> get defaultBackgrounds => [
    RoomBackground(
      id: 'default',
      name: 'Default',
      imageUrl: '',
      requiredLevel: 1,
      primaryColor: const Color(0xFF0A0A0A),
      secondaryColor: const Color(0xFF1A1A1A),
    ),
    RoomBackground(
      id: 'ocean',
      name: 'Ocean Blue',
      imageUrl: 'https://images.unsplash.com/photo-1505142468610-359e7d316be0?w=800',
      requiredLevel: 1,
      primaryColor: const Color(0xFF0A2463),
      secondaryColor: const Color(0xFF3E92CC),
    ),
    RoomBackground(
      id: 'forest',
      name: 'Forest Green',
      imageUrl: 'https://images.unsplash.com/photo-1448375240586-882707db888b?w=800',
      requiredLevel: 5,
      primaryColor: const Color(0xFF1B4332),
      secondaryColor: const Color(0xFF40916C),
    ),
    RoomBackground(
      id: 'sunset',
      name: 'Sunset Glow',
      imageUrl: 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=800',
      requiredLevel: 10,
      primaryColor: const Color(0xFF6A040F),
      secondaryColor: const Color(0xFFF48C06),
    ),
    RoomBackground(
      id: 'mountain',
      name: 'Mountain Peak',
      imageUrl: 'https://images.unsplash.com/photo-1464822759844-e2d5bc8c1c8a?w=800',
      requiredLevel: 15,
      primaryColor: const Color(0xFF2D3748),
      secondaryColor: const Color(0xFF718096),
    ),
    RoomBackground(
      id: 'galaxy',
      name: 'Galaxy',
      imageUrl: 'https://images.unsplash.com/photo-1462331940025-496dfbfc7564?w=800',
      requiredLevel: 20,
      isPremium: true,
      primaryColor: const Color(0xFF1A1A2E),
      secondaryColor: const Color(0xFF16213E),
    ),
    RoomBackground(
      id: 'aurora',
      name: 'Northern Lights',
      imageUrl: 'https://images.unsplash.com/photo-1502134249126-9f3755a50d78?w=800',
      requiredLevel: 25,
      isPremium: true,
      primaryColor: const Color(0xFF0F3460),
      secondaryColor: const Color(0xFF533483),
    ),
    RoomBackground(
      id: 'crystal',
      name: 'Crystal Cave',
      imageUrl: 'https://images.unsplash.com/photo-1518837695005-2083093ee35b?w=800',
      requiredLevel: 30,
      isPremium: true,
      primaryColor: const Color(0xFF2D00F7),
      secondaryColor: const Color(0xFF6A00F4),
    ),
  ];
}