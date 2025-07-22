import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/post.dart';
import '../repositories/post_repository.dart';
import '../components/post_card.dart';  // Import PostCard
import 'create_post_screen.dart';    // Import CreatePostScreen

class CommunityScreen extends StatelessWidget {
  const CommunityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final postRepo = Provider.of<PostRepository>(context);

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
            itemBuilder: (context, index) => PostCard(
              post: posts[index],
              onLike: (postId) => postRepo.toggleLike(
                postId,
                'currentUserId', // Replace with actual user ID
                posts[index].likedBy,
              ),
              onComment: (postId) => _navigateToComments(context, postId),
              onShare: (post) => _sharePost(context, post),
            ),
          );
        },
      ),
    );
  }

  void _navigateToComments(BuildContext context, String postId) {
    // Implement comment screen navigation
  }

  void _sharePost(BuildContext context, Post post) {
    Share.share(
      '${post.title}\n\n${post.content}\n\nShared from Haraka Afya',
      subject: post.title,
    );
  }
}