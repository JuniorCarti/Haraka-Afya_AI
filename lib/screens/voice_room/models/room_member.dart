class RoomMember {
  final String name;
  final String role;
  final bool isSpeaking;
  final String avatar;
  final int points;
  final bool isHost;

  RoomMember({
    required this.name,
    required this.role,
    required this.isSpeaking,
    required this.avatar,
    required this.points,
    required this.isHost,
  });
}