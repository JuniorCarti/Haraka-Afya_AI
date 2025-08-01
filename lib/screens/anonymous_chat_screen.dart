import 'package:flutter/material.dart';
import 'package:haraka_afya_ai/models/message.dart';
import 'package:haraka_afya_ai/services/anonymous_chat_service.dart';
import 'package:haraka_afya_ai/widgets/app_drawer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class AnonymousChatScreen extends StatefulWidget {
  const AnonymousChatScreen({super.key});

  @override
  State<AnonymousChatScreen> createState() => _AnonymousChatScreenState();
}

class _AnonymousChatScreenState extends State<AnonymousChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final AnonymousChatService _chatService = AnonymousChatService();
  final User? _user = FirebaseAuth.instance.currentUser;
  final _scrollController = ScrollController();
  Color _chatBackgroundColor = Colors.white;
  String? _chatBackgroundImage;

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Anonymous Support Space'),
        backgroundColor: const Color(0xFF128C7E), // WhatsApp green color
        elevation: 1,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline, color: Colors.white),
            onPressed: _showPrivacyInfo,
          ),
          IconButton(
            icon: const Icon(Icons.wallpaper, color: Colors.white),
            onPressed: _showBackgroundOptions,
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: Container(
        decoration: _buildBackgroundDecoration(),
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<List<AnonymousMessage>>(
                stream: _chatService.getMessages(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final messages = snapshot.data!;
                  
                  return ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(8),
                    reverse: true, // WhatsApp-like reverse list
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      return _buildMessageWithReplies(messages[index]);
                    },
                  );
                },
              ),
            ),
            _buildMessageInput(),
          ],
        ),
      ),
    );
  }

  BoxDecoration? _buildBackgroundDecoration() {
    if (_chatBackgroundImage != null) {
      return BoxDecoration(
        image: DecorationImage(
          image: AssetImage(_chatBackgroundImage!),
          fit: BoxFit.cover,
        ),
      );
    }
    return BoxDecoration(
      color: _chatBackgroundColor,
    );
  }

  Widget _buildMessageWithReplies(AnonymousMessage message) {
    return Column(
      children: [
        _buildMessageBubble(message),
        StreamBuilder<List<AnonymousMessage>>(
          stream: _chatService.getReplies(message.id),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const SizedBox.shrink();
            
            final replies = snapshot.data!;
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: replies.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(left: 32.0),
                  child: _buildMessageBubble(replies[index]),
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildMessageBubble(AnonymousMessage message) {
    // In a true anonymous system, we don't know who sent the message
    // So all messages appear as from others
    final isReply = message.parentId != null;
    final bubbleColor = isReply ? Colors.grey[50] : Colors.white;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75,
            ),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: bubbleColor,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(8),
                topRight: const Radius.circular(8),
                bottomLeft: const Radius.circular(8),
                bottomRight: const Radius.circular(8),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.person_outline, 
                        size: 12, color: Colors.white),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Anonymous',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  message.content,
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      DateFormat('h:mm a').format(message.timestamp),
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(
                  message.likedBy.contains(_user?.uid)
                      ? Icons.favorite
                      : Icons.favorite_outline,
                  color: message.likedBy.contains(_user?.uid)
                      ? Colors.red
                      : Colors.grey,
                  size: 16,
                ),
                onPressed: () {
                  if (_user != null) {
                    _chatService.likeMessage(message.id, _user.uid);
                  }
                },
              ),
              Text(
                '${message.likes}',
                style: const TextStyle(fontSize: 12),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.reply, size: 16),
                onPressed: () {
                  _showReplyDialog(message.id);
                },
              ),
              PopupMenuButton(
                icon: const Icon(Icons.more_vert, size: 16),
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'report',
                    child: Text('Report'),
                  ),
                ],
                onSelected: (value) {
                  if (value == 'report') {
                    _chatService.reportMessage(message.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Message reported to moderators'),
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).padding.bottom, // Account for nav bar
        left: 8,
        right: 8,
        top: 8,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, -1),
            ),
          ],
        ),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.emoji_emotions_outlined),
              onPressed: () {},
            ),
            Expanded(
              child: TextField(
                controller: _messageController,
                maxLines: null,
                decoration: InputDecoration(
                  hintText: 'Type a message...',
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.attach_file),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.camera_alt),
              onPressed: () {},
            ),
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: CircleAvatar(
                backgroundColor: const Color(0xFF128C7E),
                child: IconButton(
                  icon: const Icon(Icons.send, color: Colors.white),
                  onPressed: () {
                    if (_messageController.text.trim().isNotEmpty) {
                      _chatService.postMessage(_messageController.text.trim());
                      _messageController.clear();
                      _scrollController.animateTo(
                        0,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOut,
                      );
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showReplyDialog(String parentId) {
    final replyController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('Reply Anonymously'),
          content: TextField(
            controller: replyController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Write your reply...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.grey[100],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (replyController.text.trim().isNotEmpty) {
                  _chatService.postMessage(
                    replyController.text.trim(),
                    parentId: parentId,
                  );
                  Navigator.pop(context);
                }
              },
              child: const Text('Send'),
            ),
          ],
        );
      },
    );
  }

  void _showPrivacyInfo() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('Privacy Information'),
          content: const SingleChildScrollView(
            child: Text(
              'This is a completely anonymous space:\n\n'
              '• Your identity is never revealed\n'
              '• Messages are not linked to your account\n'
              '• Be kind and respectful to others\n'
              '• Report any inappropriate content\n\n'
              'Moderators may remove harmful content, but cannot identify who posted it.',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showBackgroundOptions() {
    final backgroundOptions = [
      {'name': 'Default', 'color': Colors.white},
      {'name': 'Light Green', 'color': const Color(0xFFE8F5E9)},
      {'name': 'Light Blue', 'color': const Color(0xFFE3F2FD)},
      {'name': 'Light Grey', 'color': const Color(0xFFEEEEEE)},
      {'name': 'Pattern 1', 'image': 'assets/chat_bg_1.png'},
      {'name': 'Pattern 2', 'image': 'assets/chat_bg_2.png'},
    ];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('Choose Chat Background'),
          content: SizedBox(
            width: double.maxFinite,
            child: GridView.builder(
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 1.5,
              ),
              itemCount: backgroundOptions.length,
              itemBuilder: (context, index) {
                final option = backgroundOptions[index];
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (option.containsKey('image')) {
                        _chatBackgroundImage = option['image'] as String;
                        _chatBackgroundColor = Colors.white;
                      } else {
                        _chatBackgroundColor = option['color'] as Color;
                        _chatBackgroundImage = null;
                      }
                    });
                    Navigator.pop(context);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: option['color'] as Color?,
                      image: option.containsKey('image')
                          ? DecorationImage(
                              image: AssetImage(option['image'] as String),
                              fit: BoxFit.cover,
                            )
                          : null,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Center(
                      child: Text(
                        option['name'] as String,
                        style: TextStyle(
                          color: option.containsKey('image') 
                              ? Colors.white 
                              : Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }
}