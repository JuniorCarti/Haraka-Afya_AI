import 'package:cloud_firestore/cloud_firestore.dart';

class Comment {
  final String id;
  final String userId;
  final String userName;
  final String userImage;
  final String text;
  final DateTime timestamp;
  final List<String> likedBy;
  final int replyCount;

  Comment({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userImage,
    required this.text,
    required this.timestamp,
    required this.likedBy,
    required this.replyCount,
  });

  factory Comment.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Comment(
      id: doc.id,
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? 'Anonymous',
      userImage: data['userImage'] ?? '',
      text: data['text'] ?? '',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      likedBy: List<String>.from(data['likedBy'] ?? []),
      replyCount: (data['replyCount'] ?? 0) as int,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'userImage': userImage,
      'text': text,
      'timestamp': Timestamp.fromDate(timestamp),
      'likedBy': likedBy,
      'replyCount': replyCount,
    };
  }
}
