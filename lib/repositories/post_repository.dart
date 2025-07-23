import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/post.dart';
import '../models/comment.dart';

class PostRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Stream all posts ordered by latest first
  Stream<List<Post>> getPosts() {
    return _firestore
        .collection('posts')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Post.fromFirestore(doc)).toList());
  }

  /// Create a new post
  Future<void> createPost(Post post) async {
    await _firestore.collection('posts').add(post.toMap());
  }

  /// Toggle like on a post and update likeCount accordingly
  Future<void> togglePostLike(
      String postId, String userId, List<String> currentLikes) async {
    final isLiked = currentLikes.contains(userId);

    await _firestore.collection('posts').doc(postId).update({
      'likedBy': isLiked
          ? FieldValue.arrayRemove([userId])
          : FieldValue.arrayUnion([userId]),
      'likeCount': FieldValue.increment(isLiked ? -1 : 1),
    });
  }

  /// Add a comment to a post and increment commentCount
  Future<void> addComment(String postId, Comment comment) async {
    final commentRef = _firestore
        .collection('posts')
        .doc(postId)
        .collection('comments');

    await commentRef.add(comment.toMap());

    await _firestore.collection('posts').doc(postId).update({
      'commentCount': FieldValue.increment(1),
    });
  }

  /// Stream comments for a specific post
  Stream<List<Comment>> getComments(String postId) {
    return _firestore
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Comment.fromFirestore(doc)).toList());
  }

  /// Toggle like on a specific comment
  Future<void> toggleCommentLike({
    required String postId,
    required String commentId,
    required String userId,
    required List<String> currentLikes,
  }) async {
    final isLiked = currentLikes.contains(userId);

    await _firestore
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .doc(commentId)
        .update({
      'likedBy': isLiked
          ? FieldValue.arrayRemove([userId])
          : FieldValue.arrayUnion([userId]),
    });
  }

  /// Add a reply to a comment and increment replyCount
  Future<void> addReply({
    required String postId,
    required String commentId,
    required Comment reply,
  }) async {
    final replyRef = _firestore
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .doc(commentId)
        .collection('replies');

    await replyRef.add(reply.toMap());

    await _firestore
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .doc(commentId)
        .update({
      'replyCount': FieldValue.increment(1),
    });
  }

  /// Stream replies to a specific comment
  Stream<List<Comment>> getReplies({
    required String postId,
    required String commentId,
  }) {
    return _firestore
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .doc(commentId)
        .collection('replies')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Comment.fromFirestore(doc)).toList());
  }
}
