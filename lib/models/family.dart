class Family {
  final String id;
  final String name;
  final String description;
  final String creatorId;
  final List<String> members;
  final List<String> moderators;
  final List<String> followers;
  final DateTime createdAt;
  final String? imageUrl;
  final int memberCount;
  final bool isPublic;
  final String? joinCode;
  final MessageExpirationSettings expirationSettings; // NEW: Expiration settings

  Family({
    required this.id,
    required this.name,
    required this.description,
    required this.creatorId,
    required this.members,
    required this.moderators,
    required this.followers,
    required this.createdAt,
    this.imageUrl,
    required this.memberCount,
    required this.isPublic,
    this.joinCode,
    required this.expirationSettings, // NEW
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'creatorId': creatorId,
      'members': members,
      'moderators': moderators,
      'followers': followers,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'imageUrl': imageUrl,
      'memberCount': memberCount,
      'isPublic': isPublic,
      'joinCode': joinCode,
      'expirationSettings': expirationSettings.toMap(), // NEW
    };
  }

  factory Family.fromMap(Map<String, dynamic> map) {
    return Family(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      creatorId: map['creatorId'],
      members: List<String>.from(map['members'] ?? []),
      moderators: List<String>.from(map['moderators'] ?? []),
      followers: List<String>.from(map['followers'] ?? []),
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      imageUrl: map['imageUrl'],
      memberCount: map['memberCount'] ?? 0,
      isPublic: map['isPublic'] ?? true,
      joinCode: map['joinCode'],
      expirationSettings: map['expirationSettings'] != null 
          ? MessageExpirationSettings.fromMap(map['expirationSettings'])
          : MessageExpirationSettings.defaultSettings(), // NEW: Default if not set
    );
  }

  // Helper method to check if a user is following this family
  bool isUserFollowing(String userId) {
    return followers.contains(userId);
  }

  // Helper method to get total count (members + followers)
  int get totalParticipants {
    return memberCount + followers.length;
  }

  // NEW: Check if messages should expire
  bool get shouldMessagesExpire {
    return expirationSettings.enabled && expirationSettings.durationInMinutes > 0;
  }

  // NEW: Get expiration time for a message
  DateTime getExpirationTime(DateTime messageTime) {
    return messageTime.add(Duration(minutes: expirationSettings.durationInMinutes));
  }

  Family copyWith({
    String? id,
    String? name,
    String? description,
    String? creatorId,
    List<String>? members,
    List<String>? moderators,
    List<String>? followers,
    DateTime? createdAt,
    String? imageUrl,
    int? memberCount,
    bool? isPublic,
    String? joinCode,
    MessageExpirationSettings? expirationSettings, // NEW
  }) {
    return Family(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      creatorId: creatorId ?? this.creatorId,
      members: members ?? this.members,
      moderators: moderators ?? this.moderators,
      followers: followers ?? this.followers,
      createdAt: createdAt ?? this.createdAt,
      imageUrl: imageUrl ?? this.imageUrl,
      memberCount: memberCount ?? this.memberCount,
      isPublic: isPublic ?? this.isPublic,
      joinCode: joinCode ?? this.joinCode,
      expirationSettings: expirationSettings ?? this.expirationSettings, // NEW
    );
  }
}

// NEW: Message Expiration Settings Model
class MessageExpirationSettings {
  final bool enabled;
  final int durationInMinutes;
  final ExpirationType type;

  const MessageExpirationSettings({
    required this.enabled,
    required this.durationInMinutes,
    required this.type,
  });

  // Predefined expiration options
  static const MessageExpirationSettings never = MessageExpirationSettings(
    enabled: false,
    durationInMinutes: 0,
    type: ExpirationType.never,
  );

  static const MessageExpirationSettings fiveMinutes = MessageExpirationSettings(
    enabled: true,
    durationInMinutes: 5,
    type: ExpirationType.fiveMinutes,
  );

  static const MessageExpirationSettings oneHour = MessageExpirationSettings(
    enabled: true,
    durationInMinutes: 60,
    type: ExpirationType.oneHour,
  );

  static const MessageExpirationSettings twentyFourHours = MessageExpirationSettings(
    enabled: true,
    durationInMinutes: 1440, // 24 hours
    type: ExpirationType.twentyFourHours,
  );

  static const MessageExpirationSettings sevenDays = MessageExpirationSettings(
    enabled: true,
    durationInMinutes: 10080, // 7 days
    type: ExpirationType.sevenDays,
  );

  // Default settings (no expiration)
  static MessageExpirationSettings defaultSettings() {
    return never;
  }

  // Get all available expiration options
  static List<MessageExpirationSettings> get allOptions => [
    never,
    fiveMinutes,
    oneHour,
    twentyFourHours,
    sevenDays,
  ];

  // Get display name for the expiration setting
  String get displayName {
    switch (type) {
      case ExpirationType.never:
        return 'Never expire';
      case ExpirationType.fiveMinutes:
        return '5 minutes';
      case ExpirationType.oneHour:
        return '1 hour';
      case ExpirationType.twentyFourHours:
        return '24 hours';
      case ExpirationType.sevenDays:
        return '7 days';
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'enabled': enabled,
      'durationInMinutes': durationInMinutes,
      'type': type.toString().split('.').last,
    };
  }

  factory MessageExpirationSettings.fromMap(Map<String, dynamic> map) {
    final typeString = map['type'] ?? 'never';
    final type = ExpirationType.values.firstWhere(
      (e) => e.toString().split('.').last == typeString,
      orElse: () => ExpirationType.never,
    );

    return MessageExpirationSettings(
      enabled: map['enabled'] ?? false,
      durationInMinutes: map['durationInMinutes'] ?? 0,
      type: type,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MessageExpirationSettings &&
          runtimeType == other.runtimeType &&
          enabled == other.enabled &&
          durationInMinutes == other.durationInMinutes &&
          type == other.type;

  @override
  int get hashCode => Object.hash(enabled, durationInMinutes, type);
}

// NEW: Expiration Type Enum
enum ExpirationType {
  never,
  fiveMinutes,
  oneHour,
  twentyFourHours,
  sevenDays,
}