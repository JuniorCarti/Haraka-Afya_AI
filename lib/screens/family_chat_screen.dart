import 'package:flutter/material.dart';
import 'package:haraka_afya_ai/models/family.dart';
import 'package:haraka_afya_ai/models/message.dart';
import 'package:haraka_afya_ai/services/anonymous_chat_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class FamilyChatScreen extends StatefulWidget {
  final Family family;

  const FamilyChatScreen({super.key, required this.family});

  @override
  State<FamilyChatScreen> createState() => _FamilyChatScreenState();
}

class _FamilyChatScreenState extends State<FamilyChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final AnonymousChatService _chatService = AnonymousChatService();
  final User? _user = FirebaseAuth.instance.currentUser;
  final _scrollController = ScrollController();
  final FocusNode _messageFocusNode = FocusNode();
  String? _anonymousUsername;
  String _selectedBackground = 'default';
  bool _isSomeoneTyping = false;
  String? _typingUserName;
  
  final Map<String, dynamic> _backgroundOptions = {
    'default': {
      'type': 'color',
      'value': Color(0xFFFAFAFA),
      'textColor': Colors.black87,
      'bubbleOpacity': 1.0,
    },
    'gradient_blue': {
      'type': 'gradient',
      'value': LinearGradient(
        colors: [Color(0xFF667eea), Color(0xFF764ba2)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      'textColor': Colors.white,
      'bubbleOpacity': 0.9,
    },
    'gradient_green': {
      'type': 'gradient',
      'value': LinearGradient(
        colors: [Color(0xFF259450), Color(0xFF27AE60)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      'textColor': Colors.white,
      'bubbleOpacity': 0.9,
    },
    'image_nature': {
      'type': 'image',
      'value': 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80',
      'textColor': Colors.white,
      'bubbleOpacity': 0.85,
    },
    'dark': {
      'type': 'color',
      'value': Color(0xFF121212),
      'textColor': Colors.white,
      'bubbleOpacity': 0.9,
    },
  };

  @override
  void initState() {
    super.initState();
    _loadUsername();
    _setupTypingListener();
    
    // Listen for keyboard events
    _messageFocusNode.addListener(() {
      if (_messageFocusNode.hasFocus) {
        _scrollToBottom();
      }
    });
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _loadUsername() async {
    if (_user != null) {
      final username = await _chatService.getOrCreateUsername(_user.uid);
      setState(() {
        _anonymousUsername = username;
      });
    }
  }

  void _setupTypingListener() {
    // Simulate typing indicator - in real app, you'd listen to Firestore
    // for typing status updates from other users
    _messageController.addListener(() {
      // In a real app, you'd update Firestore with typing status
      // For demo, we'll simulate someone else typing randomly
      if (_messageController.text.isNotEmpty && _messageController.text.length % 10 == 0) {
        _simulateOtherUserTyping();
      }
    });
  }

  void _simulateOtherUserTyping() {
    if (!_isSomeoneTyping) {
      setState(() {
        _isSomeoneTyping = true;
        _typingUserName = 'MindfulWalker'; // Simulated user
      });
      
      // Auto hide after 3 seconds
      Future.delayed(Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            _isSomeoneTyping = false;
            _typingUserName = null;
          });
        }
      });
    }
  }

  Color _getBubbleColor(bool isCurrentUser) {
    final bgConfig = _backgroundOptions[_selectedBackground]!;
    
    if (isCurrentUser) {
      // Current user bubble color - green gradient
      return _selectedBackground == 'dark' 
          ? Color(0xFF259450).withOpacity(bgConfig['bubbleOpacity'])
          : Color(0xFF259450).withOpacity(bgConfig['bubbleOpacity']);
    } else {
      // Other user bubble color - light gray for modern look
      return _selectedBackground == 'dark'
          ? Color(0xFF2D2D2D).withOpacity(bgConfig['bubbleOpacity'])
          : Colors.white.withOpacity(bgConfig['bubbleOpacity']);
    }
  }

  Color _getTextColor(bool isCurrentUser) {
    final bgConfig = _backgroundOptions[_selectedBackground]!;
    
    if (isCurrentUser) {
      // Current user text - always white for better contrast
      return Colors.white;
    } else {
      // Other user text - depends on background
      return _selectedBackground == 'dark' ? Colors.white : Colors.black87;
    }
  }

  Color _getInputTextColor() {
    final bgConfig = _backgroundOptions[_selectedBackground]!;
    final backgroundColor = bgConfig['value'];
    
    // Calculate luminance to determine if background is dark
    if (backgroundColor is Color) {
      final luminance = backgroundColor.computeLuminance();
      return luminance > 0.5 ? Colors.black87 : Colors.white;
    } else if (bgConfig['type'] == 'gradient') {
      // For gradients, use the provided text color
      return bgConfig['textColor'];
    } else {
      // For images, use the provided text color
      return bgConfig['textColor'];
    }
  }

  Color _getInputBackgroundColor() {
    final bgConfig = _backgroundOptions[_selectedBackground]!;
    final backgroundColor = bgConfig['value'];
    
    if (backgroundColor is Color) {
      final luminance = backgroundColor.computeLuminance();
      return luminance > 0.5 
          ? Colors.white.withOpacity(0.95)
          : Colors.grey.shade800.withOpacity(0.95);
    } else {
      // For gradients and images, use semi-transparent white/black
      return _selectedBackground == 'dark'
          ? Colors.grey.shade800.withOpacity(0.95)
          : Colors.white.withOpacity(0.95);
    }
  }

  Widget _buildBackground() {
    final config = _backgroundOptions[_selectedBackground]!;
    
    if (config['type'] == 'image') {
      return Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: NetworkImage(config['value']),
            fit: BoxFit.cover,
          ),
        ),
      );
    } else if (config['type'] == 'gradient') {
      return Container(
        decoration: BoxDecoration(
          gradient: config['value'],
        ),
      );
    } else {
      return Container(
        color: config['value'],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: _selectedBackground == 'dark' ? Color(0xFF1A1A1A) : Colors.white,
        foregroundColor: _selectedBackground == 'dark' ? Colors.white : Colors.black87,
        elevation: 1,
        shadowColor: Colors.black12,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.family.name,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            Text(
              '${widget.family.memberCount} members • Online',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.normal,
                color: _selectedBackground == 'dark' ? Colors.grey.shade400 : Colors.grey.shade600,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.info_outline_rounded, size: 20),
            onPressed: _showFamilyInfo,
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert_rounded, size: 20),
            onSelected: (value) {
              if (value == 'background') {
                _showBackgroundSelector();
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'background',
                child: Row(
                  children: [
                    Icon(Icons.photo_library_rounded, color: Colors.grey.shade700),
                    SizedBox(width: 12),
                    Text('Change Background'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: GestureDetector(
        onTap: () {
          // Dismiss keyboard when tapping outside
          FocusScope.of(context).unfocus();
        },
        child: Stack(
          children: [
            // Background
            _buildBackground(),
            
            Column(
              children: [
                // Date banner
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Center(
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: _selectedBackground == 'dark' 
                            ? Colors.white.withOpacity(0.1)
                            : Colors.black.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        DateFormat('MMMM d, yyyy').format(DateTime.now()),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: _selectedBackground == 'dark' 
                              ? Colors.white.withOpacity(0.7)
                              : Colors.black.withOpacity(0.5),
                        ),
                      ),
                    ),
                  ),
                ),
                
                Expanded(
                  child: StreamBuilder<List<AnonymousMessage>>(
                    stream: _chatService.getFamilyMessages(widget.family.id),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Center(
                          child: Text(
                            'Error loading messages',
                            style: TextStyle(
                              color: _backgroundOptions[_selectedBackground]!['textColor'],
                            ),
                          ),
                        );
                      }

                      if (!snapshot.hasData) {
                        return Center(
                          child: CircularProgressIndicator(
                            color: _backgroundOptions[_selectedBackground]!['textColor'],
                          ),
                        );
                      }

                      final messages = snapshot.data!;

                      return Column(
                        children: [
                          Expanded(
                            child: messages.isEmpty
                                ? _buildEmptyChatState()
                                : ListView.builder(
                                    controller: _scrollController,
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    reverse: true,
                                    itemCount: messages.length,
                                    itemBuilder: (context, index) {
                                      return _buildMessageBubble(messages[index]);
                                    },
                                  ),
                          ),
                          
                          // Typing indicator positioned above input
                          if (_isSomeoneTyping) _buildTypingIndicator(),
                        ],
                      );
                    },
                  ),
                ),
                
                _buildMessageInput(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyChatState() {
    final textColor = _backgroundOptions[_selectedBackground]!['textColor'];
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: _selectedBackground == 'dark' 
                    ? Colors.white.withOpacity(0.05)
                    : Colors.black.withOpacity(0.03),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.forum_outlined,
                size: 48,
                color: textColor.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Start the Conversation',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Be the first to send a message in ${widget.family.name}',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: textColor.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(AnonymousMessage message) {
    final isCurrentUser = message.senderId == _user?.uid;
    final bgConfig = _backgroundOptions[_selectedBackground]!;
    final textColor = bgConfig['textColor'];
    
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: isCurrentUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isCurrentUser) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: _selectedBackground == 'dark' 
                    ? Color(0xFF1976D2)
                    : Color(0xFF1976D2).withOpacity(0.8),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                Icons.person_rounded,
                size: 16,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                if (!isCurrentUser) ...[
                  Padding(
                    padding: const EdgeInsets.only(left: 12, bottom: 4),
                    child: Text(
                      message.senderName ?? 'Anonymous',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                        color: textColor.withOpacity(0.7),
                      ),
                    ),
                  ),
                ],
                Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.75,
                  ),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _getBubbleColor(isCurrentUser),
                    borderRadius: BorderRadius.only(
                      topLeft: isCurrentUser ? Radius.circular(20) : Radius.circular(4),
                      topRight: isCurrentUser ? Radius.circular(4) : Radius.circular(20),
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                    boxShadow: [
                      if (isCurrentUser)
                        BoxShadow(
                          color: Color(0xFF259450).withOpacity(0.2),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        )
                      else
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        message.content,
                        style: TextStyle(
                          fontSize: 15,
                          height: 1.4,
                          color: _getTextColor(isCurrentUser),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: Text(
                          DateFormat('h:mm a').format(message.timestamp),
                          style: TextStyle(
                            fontSize: 10,
                            color: _getTextColor(isCurrentUser).withOpacity(0.5),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (isCurrentUser) ...[
            const SizedBox(width: 8),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF259450), Color(0xFF27AE60)],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                Icons.person_rounded,
                size: 16,
                color: Colors.white,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    final textColor = _backgroundOptions[_selectedBackground]!['textColor'];
    
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: _selectedBackground == 'dark' 
                  ? Colors.white.withOpacity(0.05)
                  : Colors.black.withOpacity(0.03),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTypingDots(textColor),
                SizedBox(width: 8),
                Text(
                  _typingUserName != null ? '$_typingUserName is typing...' : 'Someone is typing...',
                  style: TextStyle(
                    fontSize: 12,
                    color: textColor.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingDots(Color color) {
    return SizedBox(
      width: 24,
      height: 24,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildAnimatedDot(color, 0),
          _buildAnimatedDot(color, 200),
          _buildAnimatedDot(color, 400),
        ],
      ),
    );
  }

  Widget _buildAnimatedDot(Color color, int delay) {
    return TweenAnimationBuilder(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 1200),
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        return Container(
          margin: EdgeInsets.symmetric(horizontal: 1),
          width: 4,
          height: 4,
          decoration: BoxDecoration(
            color: color.withOpacity(value > 0.5 ? 0.6 : 0.3),
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }

  Widget _buildMessageInput() {
    final inputTextColor = _getInputTextColor();
    final inputBackgroundColor = _getInputBackgroundColor();
    
    return Container(
      margin: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      padding: EdgeInsets.only(
        bottom: 16,
        left: 16,
        right: 16,
        top: 8,
      ),
      decoration: BoxDecoration(
        color: inputBackgroundColor,
        border: Border(
          top: BorderSide(
            color: _selectedBackground == 'dark' 
                ? Colors.white.withOpacity(0.1)
                : Colors.black.withOpacity(0.05),
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Attachment button
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _selectedBackground == 'dark' 
                  ? Colors.white.withOpacity(0.1)
                  : Colors.black.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(Icons.add_rounded, size: 20),
              onPressed: () {},
              color: inputTextColor.withOpacity(0.7),
              padding: EdgeInsets.zero,
            ),
          ),
          SizedBox(width: 8),
          
          // Message input field
          Expanded(
            child: Container(
              constraints: BoxConstraints(
                maxHeight: 120,
              ),
              decoration: BoxDecoration(
                color: _selectedBackground == 'dark' 
                    ? Colors.white.withOpacity(0.08)
                    : Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _messageController,
                focusNode: _messageFocusNode,
                decoration: InputDecoration(
                  hintText: 'Type a message...',
                  hintStyle: TextStyle(
                    color: inputTextColor.withOpacity(0.4),
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                ),
                style: TextStyle(
                  color: inputTextColor,
                  fontSize: 15,
                ),
                onTap: _scrollToBottom,
                onChanged: (value) {
                  // In real app, update typing status in Firestore
                },
                maxLines: null,
                textInputAction: TextInputAction.newline,
                keyboardType: TextInputType.multiline,
              ),
            ),
          ),
          SizedBox(width: 8),
          
          // Send button
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF259450), Color(0xFF27AE60)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Color(0xFF259450).withOpacity(0.3),
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: IconButton(
              icon: Icon(Icons.send_rounded, color: Colors.white, size: 20),
              onPressed: () {
                if (_messageController.text.trim().isNotEmpty && _user != null) {
                  _chatService.postFamilyMessage(
                    familyId: widget.family.id,
                    content: _messageController.text.trim(),
                    userId: _user.uid,
                    senderName: _anonymousUsername,
                  );
                  _messageController.clear();
                  _scrollToBottom();
                  
                  // In real app, clear typing status from Firestore
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showFamilyInfo() {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: _selectedBackground == 'dark' ? Color(0xFF2D2D2D) : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF259450), Color(0xFF27AE60)],
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(Icons.group_rounded, color: Colors.white),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.family.name,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: _selectedBackground == 'dark' ? Colors.white : Colors.black87,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            '${widget.family.memberCount} members',
                            style: TextStyle(
                              color: _selectedBackground == 'dark' ? Colors.grey.shade400 : Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Text(
                  'Description',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: _selectedBackground == 'dark' ? Colors.white : Colors.black87,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  widget.family.description,
                  style: TextStyle(
                    color: _selectedBackground == 'dark' ? Colors.grey.shade300 : Colors.grey.shade700,
                  ),
                ),
                if (!widget.family.isPublic && widget.family.joinCode != null) ...[
                  SizedBox(height: 16),
                  Text(
                    'Join Code',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: _selectedBackground == 'dark' ? Colors.white : Colors.black87,
                    ),
                  ),
                  SizedBox(height: 8),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: _selectedBackground == 'dark' 
                          ? Colors.white.withOpacity(0.05)
                          : Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      widget.family.joinCode!,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF259450),
                      ),
                    ),
                  ),
                ],
                SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      backgroundColor: _selectedBackground == 'dark' 
                          ? Colors.white.withOpacity(0.1)
                          : Colors.grey.shade100,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Close',
                      style: TextStyle(
                        color: _selectedBackground == 'dark' ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showBackgroundSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: _selectedBackground == 'dark' ? Color(0xFF2D2D2D) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: _selectedBackground == 'dark' 
                        ? Colors.white.withOpacity(0.2)
                        : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Chat Background',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: _selectedBackground == 'dark' ? Colors.white : Colors.black87,
                ),
              ),
              SizedBox(height: 16),
              Expanded(
                child: GridView.builder(
                  shrinkWrap: true,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.6,
                  ),
                  itemCount: _backgroundOptions.length,
                  itemBuilder: (context, index) {
                    final key = _backgroundOptions.keys.elementAt(index);
                    final config = _backgroundOptions[key]!;
                    final isSelected = _selectedBackground == key;
                    
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedBackground = key;
                        });
                        Navigator.pop(context);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected ? Color(0xFF259450) : Colors.transparent,
                            width: 3,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: _buildBackgroundPreview(key, config),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBackgroundPreview(String key, Map<String, dynamic> config) {
    if (config['type'] == 'image') {
      return Stack(
        children: [
          Image.network(
            config['value'],
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          Container(
            color: Colors.black.withOpacity(0.3),
            child: Center(
              child: Text(
                key.split('_').map((word) => word[0].toUpperCase() + word.substring(1)).join(' '),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      );
    } else if (config['type'] == 'gradient') {
      return Container(
        decoration: BoxDecoration(
          gradient: config['value'],
        ),
        child: Center(
          child: Text(
            key.split('_').map((word) => word[0].toUpperCase() + word.substring(1)).join(' '),
            style: TextStyle(
              color: config['textColor'],
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    } else {
      return Container(
        color: config['value'],
        child: Center(
          child: Text(
            key[0].toUpperCase() + key.substring(1),
            style: TextStyle(
              color: config['textColor'],
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _messageFocusNode.dispose();
    super.dispose();
  }
}