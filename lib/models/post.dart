import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String id;
  final String authorId;
  final String authorName;
  final String authorImage;
  final String title;
  final String content;
  final List<String> mediaUrls;
  final DateTime timestamp;
  final List<String> likedBy;
  final int commentCount;
  final int likeCount;

  Post({
    required this.id,
    required this.authorId,
    required this.authorName,
    required this.authorImage,
    required this.title,
    required this.content,
    this.mediaUrls = const [],
    required this.timestamp,
    this.likedBy = const [],
    this.commentCount = 0,
    this.likeCount = 0,
  });

  /// Create Post object from Firestore document
  factory Post.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return Post(
      id: doc.id,
      authorId: data['authorId'] ?? '',
      authorName: data['authorName'] ?? '',
      authorImage: data['authorImage'] ?? '',
      title: data['title'] ?? '',
      content: data['content'] ?? '',
      mediaUrls: List<String>.from(data['mediaUrls'] ?? []),
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      likedBy: List<String>.from(data['likedBy'] ?? []),
      commentCount: data['commentCount'] ?? 0,
      likeCount: data['likeCount'] ?? 0,
    );
  }

  /// Convert Post object to Firestore map
  Map<String, dynamic> toMap() {
    return {
      'authorId': authorId,
      'authorName': authorName,
      'authorImage': authorImage,
      'title': title,
      'content': content,
      'mediaUrls': mediaUrls,
      'timestamp': Timestamp.fromDate(timestamp),
      'likedBy': likedBy,
      'commentCount': commentCount,
      'likeCount': likeCount,
    };
  }
}
