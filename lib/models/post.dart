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
    this.likeCount = 0, String? imageUrl,
  });

  /// Creates a Post object from a Firestore document with null safety
  factory Post.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!; // Using ! since we expect data to exist

    // Helper function to safely parse lists
    List<String> parseStringList(dynamic value) {
      if (value == null) return [];
      try {
        return List<String>.from(value);
      } catch (e) {
        return [];
      }
    }

    return Post(
      id: doc.id,
      authorId: data['authorId'] as String? ?? '',
      authorName: data['authorName'] as String? ?? '',
      authorImage: data['authorImage'] as String? ?? '',
      title: data['title'] as String? ?? '',
      content: data['content'] as String? ?? '',
      mediaUrls: parseStringList(data['mediaUrls']),
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      likedBy: parseStringList(data['likedBy']),
      commentCount: (data['commentCount'] as num?)?.toInt() ?? 0,
      likeCount: (data['likeCount'] as num?)?.toInt() ?? 0,
    );
  }

  /// Creates a Post object from a Firestore query document snapshot
  factory Post.fromQueryDocumentSnapshot(
      QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    return Post.fromFirestore(doc);
  }

  /// Converts Post object to Firestore map with type safety
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

  /// Creates a copy of the Post with updated fields
  Post copyWith({
    String? id,
    String? authorId,
    String? authorName,
    String? authorImage,
    String? title,
    String? content,
    List<String>? mediaUrls,
    DateTime? timestamp,
    List<String>? likedBy,
    int? commentCount,
    int? likeCount,
  }) {
    return Post(
      id: id ?? this.id,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      authorImage: authorImage ?? this.authorImage,
      title: title ?? this.title,
      content: content ?? this.content,
      mediaUrls: mediaUrls ?? this.mediaUrls,
      timestamp: timestamp ?? this.timestamp,
      likedBy: likedBy ?? this.likedBy,
      commentCount: commentCount ?? this.commentCount,
      likeCount: likeCount ?? this.likeCount,
    );
  }

  /// Returns whether the post is liked by a specific user
  bool isLikedBy(String userId) {
    return likedBy.contains(userId);
  }

  /// Returns a new Post with the like status toggled for a user
  Post toggleLike(String userId) {
    final newLikedBy = List<String>.from(likedBy);
    if (newLikedBy.contains(userId)) {
      newLikedBy.remove(userId);
    } else {
      newLikedBy.add(userId);
    }
    return copyWith(
      likedBy: newLikedBy,
      likeCount: newLikedBy.length,
    );
  }

  @override
  String toString() {
    return 'Post{id: $id, title: $title, author: $authorName, likes: $likeCount}';
  }
}