import 'package:cloud_firestore/cloud_firestore.dart';

class AnonymousMessage {
  final String id;
  final String content;
  final String? parentId;
  final DateTime timestamp;
  final int likes;
  final List<String> likedBy;
  final bool reported;

  AnonymousMessage({
    required this.id,
    required this.content,
    this.parentId,
    required this.timestamp,
    this.likes = 0,
    this.likedBy = const [],
    this.reported = false,
  });

  factory AnonymousMessage.fromMap(Map<String, dynamic> map) {
    return AnonymousMessage(
      id: map['id'] ?? '',
      content: map['content'] ?? '',
      parentId: map['parentId'],
      timestamp: (map['timestamp'] as Timestamp).toDate(),
      likes: (map['likes'] as num?)?.toInt() ?? 0,
      likedBy: List<String>.from(map['likedBy'] ?? []),
      reported: map['reported'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'content': content,
      'parentId': parentId,
      'timestamp': Timestamp.fromDate(timestamp),
      'likes': likes,
      'likedBy': likedBy,
      'reported': reported,
    };
  }
}