import 'package:cloud_firestore/cloud_firestore.dart';

enum MemberRole {
  listener,  // Regular listener
  speaker,   // Can speak in room
  moderator, // Room moderator
  admin,     // Room admin/host
}

class RoomMember {
  final String id;
  final String userId;
  final String username;
  final MemberRole role;
  final bool isSpeaking;
  final String avatar;
  final int points;
  final int level;
  final DateTime joinedAt;
  final DateTime lastActive;
  final bool isMuted;
  final bool isHandRaised;
  final List<String> achievements;
  final String title;
  final String messageColor;
  final int totalMessages;
  final int roomsJoined;
  final String sessionId;
  final bool isHost;

  RoomMember({
    required this.id,
    required this.userId,
    required this.username,
    required this.role,
    this.isSpeaking = false,
    this.avatar = '😊',
    this.points = 0,
    required this.level,
    required this.joinedAt,
    required this.lastActive,
    this.isMuted = false,
    this.isHandRaised = false,
    this.achievements = const [],
    this.title = 'Newcomer',
    this.messageColor = '#4A5568',
    this.totalMessages = 0,
    this.roomsJoined = 1,
    required this.sessionId,
    this.isHost = false,
  });

  // Helper method to convert Firebase Timestamp to DateTime
  static DateTime _parseTimestamp(dynamic timestamp) {
    try {
      if (timestamp == null) return DateTime.now();
      
      if (timestamp is Timestamp) {
        return timestamp.toDate();
      }
      
      if (timestamp is int) {
        return DateTime.fromMillisecondsSinceEpoch(timestamp);
      }
      
      if (timestamp is String) {
        return DateTime.tryParse(timestamp) ?? DateTime.now();
      }
      
      return DateTime.now();
    } catch (e) {
      print('❌ Error parsing timestamp: $e');
      return DateTime.now();
    }
  }

  // Helper method to convert string to MemberRole
  static MemberRole _stringToMemberRole(String? roleString) {
    try {
      if (roleString == null) return MemberRole.listener;
      
      switch (roleString.toLowerCase()) {
        case 'admin':
        case '0':
          return MemberRole.admin;
        case 'moderator':
        case '1':
          return MemberRole.moderator;
        case 'speaker':
        case '2':
          return MemberRole.speaker;
        case 'listener':
        case '3':
        default:
          return MemberRole.listener;
      }
    } catch (e) {
      print('❌ Error parsing role: $e');
      return MemberRole.listener;
    }
  }

  // Helper method to convert MemberRole to string
  static String _memberRoleToString(MemberRole role) {
    switch (role) {
      case MemberRole.admin:
        return 'admin';
      case MemberRole.moderator:
        return 'moderator';
      case MemberRole.speaker:
        return 'speaker';
      case MemberRole.listener:
        return 'listener';
    }
  }

  // Convert to Map for Firebase
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'username': username,
      'role': _memberRoleToString(role),
      'isSpeaking': isSpeaking,
      'avatar': avatar,
      'points': points,
      'level': level,
      'joinedAt': FieldValue.serverTimestamp(), // Use server timestamp
      'lastActive': FieldValue.serverTimestamp(), // Use server timestamp
      'isMuted': isMuted,
      'isHandRaised': isHandRaised,
      'achievements': achievements,
      'title': title,
      'messageColor': messageColor,
      'totalMessages': totalMessages,
      'roomsJoined': roomsJoined,
      'sessionId': sessionId,
      'isHost': isHost,
    };
  }

  // Create from Firebase document with proper error handling
  factory RoomMember.fromMap(Map<String, dynamic> data) {
    try {
      // Safely parse all fields with defaults
      final id = data['id']?.toString() ?? '';
      final userId = data['userId']?.toString() ?? '';
      final username = data['username']?.toString() ?? 'Anonymous';
      
      // Parse role safely
      final role = _stringToMemberRole(data['role']?.toString());
      
      // Parse timestamps safely
      final joinedAt = _parseTimestamp(data['joinedAt']);
      final lastActive = _parseTimestamp(data['lastActive']);
      
      // Parse numeric fields safely
      final points = (data['points'] is num) ? (data['points'] as num).toInt() : 0;
      final level = (data['level'] is num) ? (data['level'] as num).toInt() : 1;
      final totalMessages = (data['totalMessages'] is num) ? (data['totalMessages'] as num).toInt() : 0;
      final roomsJoined = (data['roomsJoined'] is num) ? (data['roomsJoined'] as num).toInt() : 1;
      
      // Parse boolean fields safely
      final isSpeaking = data['isSpeaking'] == true;
      final isMuted = data['isMuted'] == true;
      final isHandRaised = data['isHandRaised'] == true;
      final isHost = data['isHost'] == true;
      
      // Parse list fields safely
      final achievements = data['achievements'] is List
          ? List<String>.from(data['achievements'].map((item) => item.toString()))
          : <String>[];
      
      // Parse string fields safely
      final avatar = data['avatar']?.toString() ?? '😊';
      final title = data['title']?.toString() ?? 'Newcomer';
      final messageColor = data['messageColor']?.toString() ?? '#4A5568';
      final sessionId = data['sessionId']?.toString() ?? '';

      return RoomMember(
        id: id,
        userId: userId,
        username: username,
        role: role,
        isSpeaking: isSpeaking,
        avatar: avatar,
        points: points,
        level: level,
        joinedAt: joinedAt,
        lastActive: lastActive,
        isMuted: isMuted,
        isHandRaised: isHandRaised,
        achievements: achievements,
        title: title,
        messageColor: messageColor,
        totalMessages: totalMessages,
        roomsJoined: roomsJoined,
        sessionId: sessionId,
        isHost: isHost,
      );
    } catch (e) {
      print('❌ Error parsing RoomMember: $e');
      print('❌ Problematic data: $data');
      
      // Return a safe default member instead of crashing
      return RoomMember(
        id: 'error_${DateTime.now().millisecondsSinceEpoch}',
        userId: 'error_user',
        username: 'Error User',
        role: MemberRole.listener,
        isSpeaking: false,
        avatar: '❌',
        points: 0,
        level: 1,
        joinedAt: DateTime.now(),
        lastActive: DateTime.now(),
        isMuted: false,
        isHandRaised: false,
        achievements: [],
        title: 'Error',
        messageColor: '#FF0000',
        totalMessages: 0,
        roomsJoined: 1,
        sessionId: 'error_session',
        isHost: false,
      );
    }
  }

  // Copy with method for updates
  RoomMember copyWith({
    String? id,
    String? userId,
    String? username,
    MemberRole? role,
    bool? isSpeaking,
    String? avatar,
    int? points,
    int? level,
    DateTime? joinedAt,
    DateTime? lastActive,
    bool? isMuted,
    bool? isHandRaised,
    List<String>? achievements,
    String? title,
    String? messageColor,
    int? totalMessages,
    int? roomsJoined,
    String? sessionId,
    bool? isHost,
  }) {
    return RoomMember(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      username: username ?? this.username,
      role: role ?? this.role,
      isSpeaking: isSpeaking ?? this.isSpeaking,
      avatar: avatar ?? this.avatar,
      points: points ?? this.points,
      level: level ?? this.level,
      joinedAt: joinedAt ?? this.joinedAt,
      lastActive: lastActive ?? this.lastActive,
      isMuted: isMuted ?? this.isMuted,
      isHandRaised: isHandRaised ?? this.isHandRaised,
      achievements: achievements ?? this.achievements,
      title: title ?? this.title,
      messageColor: messageColor ?? this.messageColor,
      totalMessages: totalMessages ?? this.totalMessages,
      roomsJoined: roomsJoined ?? this.roomsJoined,
      sessionId: sessionId ?? this.sessionId,
      isHost: isHost ?? this.isHost,
    );
  }

  // Check if member is host/admin
  bool get isAdmin => role == MemberRole.admin || isHost;

  // Check if member is moderator
  bool get isModerator => role == MemberRole.moderator || isAdmin;

  // Check if member can speak
  bool get canSpeak => role == MemberRole.speaker || isModerator;

  // Check if member can moderate
  bool get canModerate => isModerator;

  // Get role display name
  String get roleDisplayName {
    if (isAdmin) return 'Host';
    switch (role) {
      case MemberRole.admin:
        return 'Host';
      case MemberRole.moderator:
        return 'Moderator';
      case MemberRole.speaker:
        return 'Speaker';
      case MemberRole.listener:
        return 'Listener';
    }
  }

  // Get role badge icon
  String get roleBadge {
    if (isAdmin) return '👑';
    switch (role) {
      case MemberRole.admin:
        return '👑';
      case MemberRole.moderator:
        return '⭐';
      case MemberRole.speaker:
        return '🎤';
      case MemberRole.listener:
        return '👂';
    }
  }

  // Calculate level based on points and activity
  int calculateLevel() {
    final baseLevel = (points / 100).floor() + 1;
    final activityBonus = (totalMessages / 50).floor();
    final roomsBonus = (roomsJoined / 5).floor();
    return (baseLevel + activityBonus + roomsBonus).clamp(1, 50);
  }

  // Add points to member
  RoomMember addPoints(int pointsToAdd) {
    final newPoints = points + pointsToAdd;
    final newLevel = calculateLevel();
    return copyWith(
      points: newPoints,
      level: newLevel,
    );
  }

  // Add achievement
  RoomMember addAchievement(String achievement) {
    final updatedAchievements = List<String>.from(achievements);
    if (!updatedAchievements.contains(achievement)) {
      updatedAchievements.add(achievement);
    }
    return copyWith(achievements: updatedAchievements);
  }

  // Get achievement title based on level
  String getAchievementTitle() {
    if (level >= 30) return 'Legend';
    if (level >= 25) return 'Master';
    if (level >= 20) return 'Expert';
    if (level >= 15) return 'Veteran';
    if (level >= 10) return 'Regular';
    if (level >= 5) return 'Active';
    if (level >= 3) return 'Member';
    return 'Newcomer';
  }

  // Get message color based on level and role
  String getMessageColor() {
    if (isAdmin) return '#FFD700'; // Gold for host/admin
    if (isModerator) return '#4CAF50'; // Green for moderator
    
    if (level >= 20) return '#FF6B6B'; // Bright red for legend
    if (level >= 15) return '#FFA500'; // Orange for veteran
    if (level >= 10) return '#48DBFB'; // Bright blue for regular
    if (level >= 5) return '#9B59B6'; // Purple for active
    if (level >= 3) return '#2ECC71'; // Green for member
    
    return '#4A5568'; // Default gray for newcomer
  }

  // Increment message count
  RoomMember incrementMessageCount() {
    return copyWith(
      totalMessages: totalMessages + 1,
      lastActive: DateTime.now(),
    );
  }

  // Update last active time
  RoomMember updateLastActive() {
    return copyWith(lastActive: DateTime.now());
  }

  // Toggle mute status
  RoomMember toggleMute() {
    return copyWith(isMuted: !isMuted);
  }

  // Toggle hand raise
  RoomMember toggleHandRaise() {
    return copyWith(isHandRaised: !isHandRaised);
  }

  // Promote to speaker
  RoomMember promoteToSpeaker() {
    return copyWith(role: MemberRole.speaker);
  }

  // Promote to moderator
  RoomMember promoteToModerator() {
    return copyWith(role: MemberRole.moderator);
  }

  // Promote to admin
  RoomMember promoteToAdmin() {
    return copyWith(
      role: MemberRole.admin,
      isHost: true,
    );
  }

  // Demote to listener
  RoomMember demoteToListener() {
    return copyWith(
      role: MemberRole.listener,
      isHost: false,
    );
  }

  // Get time since joined
  String get timeSinceJoined {
    final now = DateTime.now();
    final difference = now.difference(joinedAt);
    
    if (difference.inMinutes < 1) return 'Just joined';
    if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
    if (difference.inHours < 24) return '${difference.inHours}h ago';
    return '${difference.inDays}d ago';
  }

  // Check if member is active (within last 5 minutes)
  bool get isActive {
    final now = DateTime.now();
    return now.difference(lastActive).inMinutes < 5;
  }

  // Get activity status
  String get activityStatus {
    if (isSpeaking && !isMuted) return 'Speaking';
    if (isHandRaised) return 'Hand raised';
    if (isMuted) return 'Muted';
    if (isActive) return 'Active';
    return 'Away';
  }

  // Get activity status color
  String get activityStatusColor {
    if (isSpeaking && !isMuted) return '#4CAF50'; // Green for speaking
    if (isHandRaised) return '#FFA500'; // Orange for hand raised
    if (isMuted) return '#FF5722'; // Red for muted
    if (isActive) return '#2196F3'; // Blue for active
    return '#9E9E9E'; // Gray for away
  }

  // Check if member is valid (has required fields)
  bool get isValid {
    return id.isNotEmpty && 
           userId.isNotEmpty && 
           username.isNotEmpty &&
           username != 'Anonymous' &&
           username != 'Error User';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RoomMember &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'RoomMember(id: $id, username: $username, role: $role, level: $level, isSpeaking: $isSpeaking)';
  }

  // Create a default member for testing
  factory RoomMember.defaultMember({
    String? id,
    String? username,
    MemberRole role = MemberRole.listener,
  }) {
    final now = DateTime.now();
    return RoomMember(
      id: id ?? 'default_${now.millisecondsSinceEpoch}',
      userId: id ?? 'default_user_${now.millisecondsSinceEpoch}',
      username: username ?? 'New User',
      role: role,
      level: 1,
      joinedAt: now,
      lastActive: now,
      sessionId: 'default_session',
    );
  }

  // Create a host member
  factory RoomMember.hostMember({
    String? id,
    String? username,
  }) {
    final now = DateTime.now();
    return RoomMember(
      id: id ?? 'host_${now.millisecondsSinceEpoch}',
      userId: id ?? 'host_user_${now.millisecondsSinceEpoch}',
      username: username ?? 'Room Host',
      role: MemberRole.admin,
      level: 10,
      joinedAt: now,
      lastActive: now,
      sessionId: 'host_session',
      isHost: true,
    );
  }
}