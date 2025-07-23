import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class ReplyBottomSheet extends StatefulWidget {
  final String postId;
  final String commentId;
  final String currentUserId;
  final String currentUserName;
  final String currentUserImage;
  final Future<void> Function(String commentId, String text) onSendReply;

  const ReplyBottomSheet({
    super.key,
    required this.postId,
    required this.commentId,
    required this.currentUserId,
    required this.currentUserName,
    required this.currentUserImage,
    required this.onSendReply,
  });

  @override
  State<ReplyBottomSheet> createState() => _ReplyBottomSheetState();
}

class _ReplyBottomSheetState extends State<ReplyBottomSheet> {
  final TextEditingController _replyController = TextEditingController();

  Future<void> _toggleLike(String replyId, List likedBy) async {
    final ref = FirebaseFirestore.instance
        .collection('posts')
        .doc(widget.postId)
        .collection('comments')
        .doc(widget.commentId)
        .collection('replies')
        .doc(replyId);

    final isLiked = likedBy.contains(widget.currentUserId);

    await ref.update({
      'likedBy': isLiked
          ? FieldValue.arrayRemove([widget.currentUserId])
          : FieldValue.arrayUnion([widget.currentUserId]),
    });
  }

  @override
  Widget build(BuildContext context) {
    final replyStream = FirebaseFirestore.instance
        .collection('posts')
        .doc(widget.postId)
        .collection('comments')
        .doc(widget.commentId)
        .collection('replies')
        .orderBy('timestamp', descending: true)
        .snapshots();

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 12,
        right: 12,
        top: 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Replies',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: replyStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No replies yet.'));
                }

                final replies = snapshot.data!.docs;

                return ListView.builder(
                  padding: const EdgeInsets.only(bottom: 60),
                  itemCount: replies.length,
                  itemBuilder: (context, index) {
                    final doc = replies[index];
                    final data = doc.data() as Map<String, dynamic>;
                    final likedBy = List<String>.from(data['likedBy'] ?? []);
                    final isLiked = likedBy.contains(widget.currentUserId);

                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(data['userImage'] ?? ''),
                      ),
                      title: Text(data['userName'] ?? ''),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(data['text'] ?? ''),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              GestureDetector(
                                onTap: () => _toggleLike(doc.id, likedBy),
                                child: Row(
                                  children: [
                                    Icon(
                                      isLiked
                                          ? Icons.favorite
                                          : Icons.favorite_border,
                                      size: 16,
                                      color:
                                          isLiked ? Colors.red : Colors.grey,
                                    ),
                                    const SizedBox(width: 4),
                                    Text('${likedBy.length}'),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      trailing: Text(
                        data['timestamp'] != null
                            ? DateFormat('MMM d • h:mm a')
                                .format((data['timestamp'] as Timestamp).toDate())
                            : '',
                        style: const TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          const Divider(height: 1),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _replyController,
                  decoration: const InputDecoration(
                    hintText: 'Write a reply...',
                    contentPadding: EdgeInsets.symmetric(horizontal: 12),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.send, color: Colors.green),
                onPressed: () {
                  widget.onSendReply(widget.commentId, _replyController.text);
                  _replyController.clear();
                },
              ),
            ],
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
