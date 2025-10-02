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

  // Convert to Map for Firebase
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'imageUrl': imageUrl,
      'requiredLevel': requiredLevel,
      'isPremium': isPremium,
      'primaryColor': primaryColor.value,
      'secondaryColor': secondaryColor.value,
    };
  }

  // Create from Firebase document
  factory RoomBackground.fromMap(Map<String, dynamic> data) {
    return RoomBackground(
      id: data['id'] ?? 'default',
      name: data['name'] ?? 'Default',
      imageUrl: data['imageUrl'] ?? '',
      requiredLevel: data['requiredLevel'] ?? 1,
      isPremium: data['isPremium'] ?? false,
      primaryColor: Color(data['primaryColor'] ?? 0xFF0A0A0A),
      secondaryColor: Color(data['secondaryColor'] ?? 0xFF1A1A1A),
    );
  }

  // Check if background is unlocked for user level
  bool isUnlocked(int userLevel) {
    return userLevel >= requiredLevel;
  }

  // Get display name with premium indicator
  String get displayName {
    return isPremium ? '$name ⭐' : name;
  }

  // Get gradient for background
  Gradient get gradient {
    return LinearGradient(
      colors: [primaryColor, secondaryColor],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
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

  // Find background by ID
  static RoomBackground getById(String id) {
    return defaultBackgrounds.firstWhere(
      (bg) => bg.id == id,
      orElse: () => defaultBackgrounds.first,
    );
  }

  // Get unlocked backgrounds for user level
  static List<RoomBackground> getUnlockedBackgrounds(int userLevel) {
    return defaultBackgrounds.where((bg) => bg.isUnlocked(userLevel)).toList();
  }

  // Get locked backgrounds for user level
  static List<RoomBackground> getLockedBackgrounds(int userLevel) {
    return defaultBackgrounds.where((bg) => !bg.isUnlocked(userLevel)).toList();
  }

  // Get next background to unlock
  static RoomBackground? getNextBackgroundToUnlock(int userLevel) {
    final locked = getLockedBackgrounds(userLevel);
    if (locked.isEmpty) return null;
    
    return locked.reduce((a, b) => 
      a.requiredLevel < b.requiredLevel ? a : b
    );
  }

  // Get progress to next background
  static double getUnlockProgress(int userLevel) {
    final nextBg = getNextBackgroundToUnlock(userLevel);
    if (nextBg == null) return 1.0; // All unlocked
    
    final currentMaxLevel = getUnlockedBackgrounds(userLevel)
        .map((bg) => bg.requiredLevel)
        .fold(0, (max, level) => level > max ? level : max);
    
    final progress = (userLevel - currentMaxLevel) / 
                    (nextBg.requiredLevel - currentMaxLevel);
    
    return progress.clamp(0.0, 1.0);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RoomBackground && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'RoomBackground(id: $id, name: $name, requiredLevel: $requiredLevel, isPremium: $isPremium)';
  }
}