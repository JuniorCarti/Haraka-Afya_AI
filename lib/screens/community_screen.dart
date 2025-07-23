import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:share_plus/share_plus.dart';

import '../models/post.dart';
import '../repositories/post_repository.dart';
import '../components/post_card.dart';
import 'create_post_screen.dart';
import '../models/comment_screen.dart'; // ✅ Adjust if in a different path

class CommunityScreen extends StatelessWidget {
  const CommunityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final postRepo = Provider.of<PostRepository>(context);
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Center(child: Text('Please log in to access the community.'));
    }

    final String currentUserId = user.uid;
    final String currentUserName = user.displayName ?? 'Anonymous';
    final String currentUserImage = user.photoURL ?? 'https://example.com/default_avatar.png';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Community'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CreatePostScreen()),
            ),
          ),
        ],
      ),
      body: StreamBuilder<List<Post>>(
        stream: postRepo.getPosts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final posts = snapshot.data ?? [];

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index];
              return PostCard(
                post: post,
                currentUserId: currentUserId,
                onLike: (postId) => postRepo.togglePostLike(
                  postId,
                  currentUserId,
                  post.likedBy,
                ),
                onComment: (postId) => _showCommentsBottomSheet(
                  context,
                  postId,
                  currentUserId,
                  currentUserName,
                  currentUserImage,
                ),
                onShare: (post) => _sharePost(context, post),
              );
            },
          );
        },
      ),
    );
  }

  void _sharePost(BuildContext context, Post post) {
    Share.share(
      '${post.title}\n\n${post.content}\n\nShared from Haraka Afya',
      subject: post.title,
    );
  }

  void _showCommentsBottomSheet(
    BuildContext context,
    String postId,
    String currentUserId,
    String currentUserName,
    String currentUserImage,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        minChildSize: 0.4,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return CommentScreen(
            postId: postId,
            currentUserId: currentUserId,
            currentUserName: currentUserName,
            currentUserImage: currentUserImage,
            scrollController: scrollController,
          );
        },
      ),
    );
  }
}
