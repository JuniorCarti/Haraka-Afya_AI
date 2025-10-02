class RoomMember {
  final String name;
  final String role;
  final bool isSpeaking;
  final String avatar;
  final int points;
  final bool isHost;
  final int level; // Added level field

  RoomMember({
    required this.name,
    required this.role,
    required this.isSpeaking,
    required this.avatar,
    required this.points,
    required this.isHost,
    required this.level, // Added level field
  });

  // Calculate level based on points (example: 100 points per level)
  int calculateLevel() {
    return (points / 100).floor() + 1;
  }
}