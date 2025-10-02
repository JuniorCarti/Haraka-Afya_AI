class RoomMember {
  final String id;
  final String name;
  final String role;
  final bool isSpeaking;
  final String avatar;
  final int points;
  final bool isHost;
  final int level;
  final DateTime joinedAt;
  final String userId; // Firebase user ID

  RoomMember({
    required this.id,
    required this.name,
    required this.role,
    required this.isSpeaking,
    required this.avatar,
    required this.points,
    required this.isHost,
    required this.level,
    required this.joinedAt,
    required this.userId,
  });

  // Convert to Map for Firebase
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'role': role,
      'isSpeaking': isSpeaking,
      'avatar': avatar,
      'points': points,
      'isHost': isHost,
      'level': level,
      'joinedAt': joinedAt.millisecondsSinceEpoch,
      'userId': userId,
    };
  }

  // Create from Firebase document
  factory RoomMember.fromMap(Map<String, dynamic> data) {
    return RoomMember(
      id: data['id'] ?? '',
      name: data['name'] ?? 'Anonymous',
      role: data['role'] ?? 'Listener',
      isSpeaking: data['isSpeaking'] ?? false,
      avatar: data['avatar'] ?? '😊',
      points: data['points'] ?? 0,
      isHost: data['isHost'] ?? false,
      level: data['level'] ?? 1,
      joinedAt: DateTime.fromMillisecondsSinceEpoch(data['joinedAt'] ?? DateTime.now().millisecondsSinceEpoch),
      userId: data['userId'] ?? '',
    );
  }

  // Calculate level based on points
  int calculateLevel() {
    return (points / 100).floor() + 1;
  }
}