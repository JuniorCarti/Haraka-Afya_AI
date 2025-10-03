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
  });

  // Convert to Map for Firebase
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'username': username,
      'role': role.index,
      'isSpeaking': isSpeaking,
      'avatar': avatar,
      'points': points,
      'level': level,
      'joinedAt': joinedAt.millisecondsSinceEpoch,
      'lastActive': lastActive.millisecondsSinceEpoch,
      'isMuted': isMuted,
      'isHandRaised': isHandRaised,
      'achievements': achievements,
      'title': title,
      'messageColor': messageColor,
      'totalMessages': totalMessages,
      'roomsJoined': roomsJoined,
      'sessionId': sessionId,
    };
  }

  // Create from Firebase document
  factory RoomMember.fromMap(Map<String, dynamic> data) {
    return RoomMember(
      id: data['id'] ?? '',
      userId: data['userId'] ?? '',
      username: data['username'] ?? 'Anonymous',
      role: MemberRole.values[data['role'] ?? 0],
      isSpeaking: data['isSpeaking'] ?? false,
      avatar: data['avatar'] ?? '😊',
      points: data['points'] ?? 0,
      level: data['level'] ?? 1,
      joinedAt: DateTime.fromMillisecondsSinceEpoch(
          data['joinedAt'] ?? DateTime.now().millisecondsSinceEpoch),
      lastActive: DateTime.fromMillisecondsSinceEpoch(
          data['lastActive'] ?? DateTime.now().millisecondsSinceEpoch),
      isMuted: data['isMuted'] ?? false,
      isHandRaised: data['isHandRaised'] ?? false,
      achievements: data['achievements'] != null 
          ? List<String>.from(data['achievements'])
          : [],
      title: data['title'] ?? 'Newcomer',
      messageColor: data['messageColor'] ?? '#4A5568',
      totalMessages: data['totalMessages'] ?? 0,
      roomsJoined: data['roomsJoined'] ?? 1,
      sessionId: data['sessionId'] ?? '',
    );
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
    );
  }

  // Check if member is host/admin
  bool get isHost => role == MemberRole.admin;

  // Check if member is moderator
  bool get isModerator => role == MemberRole.moderator || role == MemberRole.admin;

  // Check if member can speak
  bool get canSpeak => role == MemberRole.speaker || role == MemberRole.moderator || role == MemberRole.admin;

  // Check if member can moderate
  bool get canModerate => role == MemberRole.moderator || role == MemberRole.admin;

  // Get role display name
  String get roleDisplayName {
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
    if (isHost) return '#FFD700'; // Gold for host
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

  // Demote to listener
  RoomMember demoteToListener() {
    return copyWith(role: MemberRole.listener);
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
    if (isSpeaking) return 'Speaking';
    if (isHandRaised) return 'Hand raised';
    if (isActive) return 'Active';
    return 'Away';
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
    return 'RoomMember(id: $id, username: $username, role: $role, level: $level)';
  }
}