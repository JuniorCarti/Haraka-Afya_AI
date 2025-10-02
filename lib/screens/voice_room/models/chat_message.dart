class ChatMessage {
  final String id;
  final String user;
  final String userId;
  final String message;
  final DateTime timestamp;

  ChatMessage({
    required this.id,
    required this.user,
    required this.userId,
    required this.message,
    required this.timestamp,
  });

  // Convert to Map for Firebase
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user': user,
      'userId': userId,
      'message': message,
      'timestamp': timestamp.millisecondsSinceEpoch,
    };
  }

  // Create from Firebase document
  factory ChatMessage.fromMap(Map<String, dynamic> data) {
    return ChatMessage(
      id: data['id'] ?? '',
      user: data['user'] ?? 'Anonymous',
      userId: data['userId'] ?? '',
      message: data['message'] ?? '',
      timestamp: DateTime.fromMillisecondsSinceEpoch(data['timestamp'] ?? DateTime.now().millisecondsSinceEpoch),
    );
  }

  // Get formatted time
  String get formattedTime {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes} min ago';
    if (difference.inHours < 24) return '${difference.inHours} hours ago';
    return '${difference.inDays} days ago';
  }
}