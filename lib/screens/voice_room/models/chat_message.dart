
import 'package:flutter/material.dart';

enum UserRole {
  user,      // Regular user
  moderator, // Room moderator
  admin,     // Room admin/host
  system,    // System messages
}

class ChatMessage {
  final String id;
  final String roomId;
  final String userId;
  final String username;
  final String text;
  final DateTime timestamp;
  final UserRole userRole;
  final int userLevel;
  final String messageColor;
  final bool isWelcomeMessage;
  final String sessionId;
  final List<String>? reactions;
  final String? replyToId;

  ChatMessage({
    required this.id,
    required this.roomId,
    required this.userId,
    required this.username,
    required this.text,
    required this.timestamp,
    this.userRole = UserRole.user,
    this.userLevel = 1,
    this.messageColor = '#4A5568',
    this.isWelcomeMessage = false,
    required this.sessionId,
    this.reactions,
    this.replyToId,
  });

  // Convert to Map for Firebase
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'roomId': roomId,
      'userId': userId,
      'username': username,
      'text': text,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'userRole': userRole.index,
      'userLevel': userLevel,
      'messageColor': messageColor,
      'isWelcomeMessage': isWelcomeMessage,
      'sessionId': sessionId,
      'reactions': reactions ?? [],
      'replyToId': replyToId,
    };
  }

  // Create from Firebase document
  factory ChatMessage.fromMap(Map<String, dynamic> data) {
    return ChatMessage(
      id: data['id'] ?? '',
      roomId: data['roomId'] ?? '',
      userId: data['userId'] ?? '',
      username: data['username'] ?? 'Anonymous',
      text: data['text'] ?? '',
      timestamp: DateTime.fromMillisecondsSinceEpoch(
          data['timestamp'] ?? DateTime.now().millisecondsSinceEpoch),
      userRole: UserRole.values[data['userRole'] ?? 0],
      userLevel: data['userLevel'] ?? 1,
      messageColor: data['messageColor'] ?? '#4A5568',
      isWelcomeMessage: data['isWelcomeMessage'] ?? false,
      sessionId: data['sessionId'] ?? '',
      reactions: data['reactions'] != null 
          ? List<String>.from(data['reactions'])
          : null,
      replyToId: data['replyToId'],
    );
  }

  // Copy with method for updates
  ChatMessage copyWith({
    String? id,
    String? roomId,
    String? userId,
    String? username,
    String? text,
    DateTime? timestamp,
    UserRole? userRole,
    int? userLevel,
    String? messageColor,
    bool? isWelcomeMessage,
    String? sessionId,
    List<String>? reactions,
    String? replyToId,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      roomId: roomId ?? this.roomId,
      userId: userId ?? this.userId,
      username: username ?? this.username,
      text: text ?? this.text,
      timestamp: timestamp ?? this.timestamp,
      userRole: userRole ?? this.userRole,
      userLevel: userLevel ?? this.userLevel,
      messageColor: messageColor ?? this.messageColor,
      isWelcomeMessage: isWelcomeMessage ?? this.isWelcomeMessage,
      sessionId: sessionId ?? this.sessionId,
      reactions: reactions ?? this.reactions,
      replyToId: replyToId ?? this.replyToId,
    );
  }

  // Get formatted time
  String get formattedTime {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inSeconds < 60) return 'Just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
    if (difference.inHours < 24) return '${difference.inHours}h ago';
    if (difference.inDays < 7) return '${difference.inDays}d ago';
    
    return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
  }

  // Get display name with role badge
  String get displayName {
    switch (userRole) {
      case UserRole.admin:
        return '$username 👑';
      case UserRole.moderator:
        return '$username ⭐';
      case UserRole.system:
        return 'System';
      case UserRole.user:
        return username;
    }
  }

  // Check if message is from system
  bool get isSystemMessage => userRole == UserRole.system;

  // Check if message is from admin
  bool get isAdminMessage => userRole == UserRole.admin;

  // Check if message is from moderator
  bool get isModeratorMessage => userRole == UserRole.moderator;

  // Get role badge icon
  String get roleBadge {
    switch (userRole) {
      case UserRole.admin:
        return '👑';
      case UserRole.moderator:
        return '⭐';
      case UserRole.system:
        return '🤖';
      case UserRole.user:
        return userLevel >= 5 ? '🔥' : userLevel >= 3 ? '🌟' : '';
    }
  }

  // Get background color based on role and level
  Color get backgroundColor {
    // Convert hex color to Color
    try {
      final hexColor = messageColor.replaceAll('#', '');
      final colorValue = int.parse(hexColor, radix: 16);
      return Color(colorValue | 0xFF000000);
    } catch (e) {
      // Fallback colors based on role and level
      if (isAdminMessage) return const Color(0xFFFFD700); // Gold
      if (isModeratorMessage) return const Color(0xFF4CAF50); // Green
      if (userLevel >= 10) return const Color(0xFFFF6B6B); // Bright red
      if (userLevel >= 5) return const Color(0xFF48DBFB); // Bright blue
      if (userLevel >= 3) return const Color(0xFFFFA500); // Orange
      return const Color(0xFFE2E8F0); // Default gray
    }
  }

  // Get text color based on background brightness
  Color get textColor {
    final bgColor = backgroundColor;
    final brightness = (bgColor.red * 0.299 + bgColor.green * 0.587 + bgColor.blue * 0.114) > 186;
    return brightness ? Colors.black : Colors.white;
  }

  // Check if message should have special styling
  bool get hasSpecialStyling => isAdminMessage || isModeratorMessage || userLevel >= 3;

  // Get border color for special messages
  Color get borderColor {
    if (isAdminMessage) return const Color(0xFFFFC107);
    if (isModeratorMessage) return const Color(0xFF388E3C);
    if (userLevel >= 10) return const Color(0xFFD32F2F);
    if (userLevel >= 5) return const Color(0xFF1976D2);
    if (userLevel >= 3) return const Color(0xFFFF9800);
    return Colors.transparent;
  }

  // Get achievement title based on level
  String get achievementTitle {
    if (userLevel >= 20) return 'Legend';
    if (userLevel >= 15) return 'Expert';
    if (userLevel >= 10) return 'Veteran';
    if (userLevel >= 5) return 'Regular';
    if (userLevel >= 3) return 'Active';
    return 'Newcomer';
  }

  // Check if message can be replied to
  bool get canReply => !isSystemMessage && replyToId == null;

  // Add reaction to message
  ChatMessage addReaction(String emoji) {
    final updatedReactions = List<String>.from(reactions ?? []);
    if (!updatedReactions.contains(emoji)) {
      updatedReactions.add(emoji);
    }
    return copyWith(reactions: updatedReactions);
  }

  // Remove reaction from message
  ChatMessage removeReaction(String emoji) {
    final updatedReactions = List<String>.from(reactions ?? []);
    updatedReactions.remove(emoji);
    return copyWith(reactions: updatedReactions);
  }

  // Check if message has reactions
  bool get hasReactions => (reactions?.isNotEmpty ?? false);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatMessage &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'ChatMessage(id: $id, username: $username, text: $text, role: $userRole, level: $userLevel)';
  }
}