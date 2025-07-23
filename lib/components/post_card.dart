import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/post.dart';

class PostCard extends StatelessWidget {
  final Post post;
  final String currentUserId;
  final Function(String) onLike;
  final Function(String) onComment;
  final Function(Post) onShare;

  const PostCard({
    super.key,
    required this.post,
    required this.currentUserId,
    required this.onLike,
    required this.onComment,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 12),
            Text(post.content),
            if (post.mediaUrls.isNotEmpty) _buildMedia(),
            const SizedBox(height: 12),
            _buildSummaryRow(),
            const Divider(height: 24),
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
        Expanded(
          child: Column(
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
        ),
      ],
    );
  }

  Widget _buildMedia() {
    return Column(
      children: post.mediaUrls
          .map(
            (url) => Padding(
              padding: const EdgeInsets.only(top: 8),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(url),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildSummaryRow() {
    final formattedComments = NumberFormat.compact().format(post.commentCount);
    final formattedLikes = NumberFormat.compact().format(post.likeCount);

    return Row(
      children: [
        const Text(
          'Comments',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(width: 6),
        Text(
          formattedComments,
          style: const TextStyle(color: Colors.grey, fontSize: 14),
        ),
        const SizedBox(width: 16),
        const Text(
          'Likes',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(width: 6),
        Text(
          formattedLikes,
          style: const TextStyle(color: Colors.grey, fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildActions() {
    final isLiked = post.likedBy.contains(currentUserId);

    return Row(
      children: [
        IconButton(
          icon: Icon(
            isLiked ? Icons.favorite : Icons.favorite_border,
            color: isLiked ? Colors.red : Colors.grey,
          ),
          onPressed: () => onLike(post.id),
        ),
        const SizedBox(width: 4),
        Text(
          NumberFormat.compact().format(post.likeCount),
          style: const TextStyle(fontSize: 13),
        ),
        const SizedBox(width: 16),
        IconButton(
          icon: const Icon(Icons.comment, color: Colors.grey),
          onPressed: () => onComment(post.id),
        ),
        const SizedBox(width: 4),
        Text(
          NumberFormat.compact().format(post.commentCount),
          style: const TextStyle(fontSize: 13),
        ),
        const Spacer(),
        IconButton(
          icon: const Icon(Icons.share, color: Colors.grey),
          onPressed: () => onShare(post),
        ),
      ],
    );
  }
}
