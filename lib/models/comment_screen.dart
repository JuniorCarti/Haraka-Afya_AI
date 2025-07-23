import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:haraka_afya_ai/widgets/reply_bottom_sheet.dart';

class CommentScreen extends StatefulWidget {
  final String postId;
  final String currentUserId;
  final String currentUserName;
  final String currentUserImage;
  final ScrollController scrollController;

  const CommentScreen({
    super.key,
    required this.postId,
    required this.currentUserId,
    required this.currentUserName,
    required this.currentUserImage,
    required this.scrollController,
  });

  @override
  State<CommentScreen> createState() => _CommentScreenState();
}

class _CommentScreenState extends State<CommentScreen> {
  final TextEditingController _commentController = TextEditingController();

  Future<void> _addComment(String text) async {
    final trimmedText = text.trim();
    if (trimmedText.isEmpty) return;

    final commentRef = FirebaseFirestore.instance
        .collection('posts')
        .doc(widget.postId)
        .collection('comments');

    await commentRef.add({
      'userId': widget.currentUserId,
      'userName': widget.currentUserName,
      'userImage': widget.currentUserImage,
      'text': trimmedText,
      'timestamp': FieldValue.serverTimestamp(),
      'likedBy': [],
      'replyCount': 0,
    });

    _commentController.clear();

    await FirebaseFirestore.instance
        .collection('posts')
        .doc(widget.postId)
        .update({'commentCount': FieldValue.increment(1)});
  }

  Future<void> _toggleLike(String commentId, List likedBy) async {
    final ref = FirebaseFirestore.instance
        .collection('posts')
        .doc(widget.postId)
        .collection('comments')
        .doc(commentId);

    final isLiked = likedBy.contains(widget.currentUserId);

    await ref.update({
      'likedBy': isLiked
          ? FieldValue.arrayRemove([widget.currentUserId])
          : FieldValue.arrayUnion([widget.currentUserId]),
    });
  }

  Future<void> _addReply(String parentCommentId, String text) async {
    final trimmedText = text.trim();
    if (trimmedText.isEmpty) return;

    final replyRef = FirebaseFirestore.instance
        .collection('posts')
        .doc(widget.postId)
        .collection('comments')
        .doc(parentCommentId)
        .collection('replies');

    await replyRef.add({
      'userId': widget.currentUserId,
      'userName': widget.currentUserName,
      'userImage': widget.currentUserImage,
      'text': trimmedText,
      'timestamp': FieldValue.serverTimestamp(),
      'likedBy': [],
    });

    await FirebaseFirestore.instance
        .collection('posts')
        .doc(widget.postId)
        .collection('comments')
        .doc(parentCommentId)
        .update({
      'replyCount': FieldValue.increment(1),
    });
  }

  void _showReplies(String commentId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) {
        return ReplyBottomSheet(
          postId: widget.postId,
          commentId: commentId,
          currentUserId: widget.currentUserId,
          currentUserName: widget.currentUserName,
          currentUserImage: widget.currentUserImage,
          onSendReply: _addReply,
        );
      },
    );
  }

  final List<String> quickReplies = [
    'Sending healing thoughts 💚',
    'Stay strong 💪',
    'Wishing you a quick recovery 🙏',
    'Take care of yourself 🌿',
    'Thanks for sharing 💬',
    'That’s very informative! 📚',
  ];

  @override
  Widget build(BuildContext context) {
    final commentStream = FirebaseFirestore.instance
        .collection('posts')
        .doc(widget.postId)
        .collection('comments')
        .orderBy('timestamp', descending: true)
        .snapshots();

    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: commentStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No comments yet.'));
                }

                final comments = snapshot.data!.docs;

                return ListView.builder(
                  controller: widget.scrollController,
                  padding: const EdgeInsets.all(12),
                  itemCount: comments.length,
                  itemBuilder: (context, index) {
                    final doc = comments[index];
                    final data = doc.data() as Map<String, dynamic>;
                    final likedBy = List<String>.from(data['likedBy'] ?? []);
                    final isLiked = likedBy.contains(widget.currentUserId);
                    final commentId = doc.id;

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            backgroundImage: NetworkImage(data['userImage'] ?? ''),
                            radius: 18,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  data['userName'] ?? 'Anonymous',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(data['text'] ?? ''),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    GestureDetector(
                                      onTap: () => _toggleLike(commentId, likedBy),
                                      child: Row(
                                        children: [
                                          Icon(
                                            isLiked ? Icons.favorite : Icons.favorite_border,
                                            size: 16,
                                            color: isLiked ? Colors.red : Colors.grey,
                                          ),
                                          const SizedBox(width: 4),
                                          Text('${likedBy.length}'),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    GestureDetector(
                                      onTap: () => _showReplies(commentId),
                                      child: StreamBuilder<QuerySnapshot>(
                                        stream: FirebaseFirestore.instance
                                            .collection('posts')
                                            .doc(widget.postId)
                                            .collection('comments')
                                            .doc(commentId)
                                            .collection('replies')
                                            .snapshots(),
                                        builder: (context, replySnapshot) {
                                          int replyCount = replySnapshot.data?.docs.length ?? 0;
                                          return Text(
                                            replyCount > 0
                                                ? '$replyCount Replies'
                                                : 'Reply',
                                            style: const TextStyle(
                                              color: Colors.blue,
                                              fontSize: 13,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            data['timestamp'] != null
                                ? DateFormat('MMM d • h:mm a').format((data['timestamp'] as Timestamp).toDate())
                                : '',
                            style: const TextStyle(fontSize: 11, color: Colors.grey),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),

          const Divider(height: 1),

          // Quick Replies
          Container(
            height: 42,
            margin: const EdgeInsets.only(bottom: 6),
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: quickReplies.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                return ActionChip(
                  label: Text(quickReplies[index]),
                  onPressed: () => _addComment(quickReplies[index]),
                  backgroundColor: Colors.green.shade50,
                  labelStyle: const TextStyle(color: Colors.green),
                );
              },
            ),
          ),

          // Comment Input
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: const InputDecoration(
                      hintText: 'Write a comment...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.green),
                  onPressed: () => _addComment(_commentController.text),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
