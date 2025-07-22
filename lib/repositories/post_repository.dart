import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/post.dart';

class PostRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<Post>> getPosts() {
    return _firestore
        .collection('posts')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Post.fromFirestore(doc))
            .toList());
  }

  Future<void> createPost(Post post) async {
    await _firestore.collection('posts').add(post.toMap());
  }

  Future<void> toggleLike(String postId, String userId, List<String> currentLikes) async {
    final isLiked = currentLikes.contains(userId);
    
    await _firestore.collection('posts').doc(postId).update({
      'likedBy': isLiked
          ? FieldValue.arrayRemove([userId])
          : FieldValue.arrayUnion([userId]),
    });
  }
}