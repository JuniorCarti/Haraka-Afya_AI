import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/post.dart';

class PostCard extends StatelessWidget {
  final Post post;
  final Function(String) onLike;
  final Function(String) onComment;
  final Function(Post) onShare;

  const PostCard({
    super.key,
    required this.post,
    required this.onLike,
    required this.onComment,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 12),
            Text(post.content),
            if (post.mediaUrls.isNotEmpty) _buildMedia(),
            const SizedBox(height: 12),
            _buildActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        CircleAvatar(
          backgroundImage: NetworkImage(post.authorImage),
          radius: 20,
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              post.authorName,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              DateFormat('MMM d, y • h:mm a').format(post.timestamp),
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMedia() {
    return Column(
      children: post.mediaUrls.map((url) => Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Image.network(url),
      )).toList(),
    );
  }

  Widget _buildActions() {
    return Row(
      children: [
        IconButton(
          icon: Icon(
            post.likedBy.contains('currentUserId') // Replace with actual user ID
                ? Icons.favorite
                : Icons.favorite_border,
            color: post.likedBy.contains('currentUserId') ? Colors.red : null,
          ),
          onPressed: () => onLike(post.id),
        ),
        Text(post.likedBy.length.toString()),
        const SizedBox(width: 16),
        IconButton(
          icon: const Icon(Icons.comment),
          onPressed: () => onComment(post.id),
        ),
        Text(post.commentCount.toString()),
        const Spacer(),
        IconButton(
          icon: const Icon(Icons.share),
          onPressed: () => onShare(post),
        ),
      ],
    );
  }
}