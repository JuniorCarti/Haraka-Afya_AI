import 'package:flutter/material.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import '../models/chat_message.dart';

class ChatSection extends StatefulWidget {
  final List<ChatMessage> chatMessages;
  final TextEditingController chatController;
  final Function(ChatMessage) onSendMessage;
  final bool isAdmin;
  final Function(String)? onRoomInfoUpdate;
  final String currentRoomId;
  final String currentUserId;
  final String currentUsername;
  final UserRole currentUserRole;
  final int currentUserLevel;
  final Function()? onSwitchToSpeaker;

  const ChatSection({
    super.key,
    required this.chatMessages,
    required this.chatController,
    required this.onSendMessage,
    this.isAdmin = false,
    this.onRoomInfoUpdate,
    required this.currentRoomId,
    required this.currentUserId,
    required this.currentUsername,
    required this.currentUserRole,
    required this.currentUserLevel,
    this.onSwitchToSpeaker,
  });

  @override
  State<ChatSection> createState() => _ChatSectionState();
}

class _ChatSectionState extends State<ChatSection> with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  bool _showEmojiPicker = false;
  final FocusNode _focusNode = FocusNode();
  late AnimationController _animationController;
  late Animation<Color?> _gradientAnimation;
  bool _isExpanded = false;
  late AnimationController _expandController;
  final double _collapsedHeight = 60.0;
  final double _expandedHeight = 200.0;

  @override
  void initState() {
    super.initState();
    
    _expandController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    
    _animationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
    
    _gradientAnimation = ColorTween(
      begin: const Color(0xFFFF6B6B),
      end: const Color(0xFF4ECDC4),
    ).animate(_animationController);
    
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        setState(() {
          _showEmojiPicker = false;
        });
      }
    });
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _expandController.forward();
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToBottom();
        });
      } else {
        _expandController.reverse();
        _showEmojiPicker = false;
      }
    });
  }

  @override
  void didUpdateWidget(covariant ChatSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.chatMessages.length > oldWidget.chatMessages.length && _isExpanded) {
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients && _isExpanded) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _toggleEmojiPicker() {
    if (!_isExpanded) {
      _toggleExpanded();
      Future.delayed(const Duration(milliseconds: 200), () {
        setState(() {
          _showEmojiPicker = true;
        });
      });
    } else {
      setState(() {
        _showEmojiPicker = !_showEmojiPicker;
      });
    }
    if (!_showEmojiPicker) {
      _focusNode.requestFocus();
    }
  }

  void _onEmojiSelected(Emoji emoji) {
    final text = widget.chatController.text;
    final selection = widget.chatController.selection;
    final newText = text.replaceRange(
      selection.start,
      selection.end,
      emoji.emoji,
    );
    widget.chatController.value = widget.chatController.value.copyWith(
      text: newText,
      selection: TextSelection.collapsed(
        offset: selection.start + emoji.emoji.length,
      ),
    );
  }

  void _sendMessage() {
    final text = widget.chatController.text.trim();
    if (text.isNotEmpty) {
      final message = ChatMessage(
        id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
        roomId: widget.currentRoomId,
        userId: widget.currentUserId,
        username: widget.currentUsername,
        text: text,
        timestamp: DateTime.now(),
        userRole: widget.currentUserRole,
        userLevel: widget.currentUserLevel,
        messageColor: _getUserMessageColor(),
        isWelcomeMessage: false,
        sessionId: 'current',
      );
      widget.onSendMessage(message);
      widget.chatController.clear();
      setState(() {
        _showEmojiPicker = false;
      });
    }
  }

  String _getUserMessageColor() {
    if (widget.currentUserRole == UserRole.admin) return '#FFD700';
    if (widget.currentUserRole == UserRole.moderator) return '#4CAF50';
    if (widget.currentUserLevel >= 10) return '#FF6B6B';
    if (widget.currentUserLevel >= 5) return '#48DBFB';
    if (widget.currentUserLevel >= 3) return '#FFA500';
    return '#4A5568';
  }

  void _showSwitchToSpeakerDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          'Switch to Speaker Seat',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Do you want to switch from host seat to a speaker seat? This will allow you to participate more actively in the conversation.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              widget.onSwitchToSpeaker?.call();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            child: const Text('Switch to Speaker'),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    final isCurrentUser = message.userId == widget.currentUserId;
    final messageColor = Color(int.parse(message.messageColor.replaceAll('#', '0xFF')));
    final isAdmin = message.userRole == UserRole.admin;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: isCurrentUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isCurrentUser) ...[
            _buildAnimatedAvatar(message),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    messageColor.withOpacity(0.9),
                    messageColor.withOpacity(0.7),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  topLeft: isCurrentUser ? const Radius.circular(16) : const Radius.circular(8),
                  topRight: isCurrentUser ? const Radius.circular(8) : const Radius.circular(16),
                  bottomLeft: const Radius.circular(16),
                  bottomRight: const Radius.circular(16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: messageColor.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text(
                            // Show the actual username instead of "You"
                            message.displayName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (isAdmin) ...[
                            const SizedBox(width: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'Admin',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 7,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                          if (message.userLevel >= 3 && !isAdmin) ...[
                            const SizedBox(width: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF48DBFB), Color(0xFF4ECDC4)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'Lvl ${message.userLevel}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 7,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      Text(
                        message.formattedTime,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 9,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    message.text,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      height: 1.3,
                    ),
                  ),
                  if (message.userLevel >= 5 && !message.isSystemMessage && !isAdmin)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          message.achievementTitle,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          if (isCurrentUser) ...[
            const SizedBox(width: 8),
            _buildAnimatedAvatar(message),
          ],
        ],
      ),
    );
  }

  Widget _buildAnimatedAvatar(ChatMessage message) {
    final isAdmin = message.userRole == UserRole.admin;
    
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        gradient: isAdmin 
            ? const LinearGradient(
                colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : LinearGradient(
                colors: [
                  Colors.blue.shade400,
                  Colors.purple.shade400,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: isAdmin ? Colors.orange.withOpacity(0.3) : Colors.blue.withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          message.username.isNotEmpty ? message.username[0].toUpperCase() : '?',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  void _showRoomInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => RoomInfoDialog(
        roomId: widget.currentRoomId,
        isAdmin: widget.isAdmin,
        onRoomInfoUpdate: widget.onRoomInfoUpdate,
        onSwitchToSpeaker: widget.onSwitchToSpeaker,
      ),
    );
  }

  Widget _buildCollapsedView() {
    final latestMessage = widget.chatMessages.isNotEmpty 
        ? widget.chatMessages.last 
        : null;
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _gradientAnimation.value!.withOpacity(0.9),
            const Color(0xFF4ECDC4).withOpacity(0.9),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
        boxShadow: [
          BoxShadow(
            color: _gradientAnimation.value!.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(
            Icons.chat_bubble_rounded,
            color: Colors.white,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Room Chat',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                if (latestMessage != null)
                  Text(
                    '${latestMessage.username}: ${latestMessage.text}',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 10,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  )
                else
                  Text(
                    'Tap to chat with others',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 10,
                    ),
                  ),
              ],
            ),
          ),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${widget.chatMessages.length}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              GestureDetector(
                onTap: _toggleExpanded,
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _isExpanded ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_up,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExpandedView() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF1A1A2E).withOpacity(0.98),
            const Color(0xFF16213E).withOpacity(0.98),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _gradientAnimation.value!.withOpacity(0.9),
                  const Color(0xFF4ECDC4).withOpacity(0.9),
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.chat_bubble_rounded,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: _showRoomInfoDialog,
                        child: Row(
                          children: [
                            Text(
                              'Room Chat',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (widget.isAdmin)
                              const Padding(
                                padding: EdgeInsets.only(left: 4),
                                child: Icon(Icons.settings, size: 12, color: Colors.white),
                              ),
                          ],
                        ),
                      ),
                      Text(
                        '${widget.chatMessages.length} messages • Tap to minimize',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
                if (widget.isAdmin && widget.onSwitchToSpeaker != null)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: _showSwitchToSpeakerDialog,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.blue.withOpacity(0.5)),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.swap_horiz, size: 12, color: Colors.white),
                            SizedBox(width: 4),
                            Text(
                              'Switch Seat',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                GestureDetector(
                  onTap: _toggleExpanded,
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.keyboard_arrow_down,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Messages area
          Expanded(
            child: Container(
              decoration: const BoxDecoration(),
              child: widget.chatMessages.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.forum_outlined,
                            size: 36,
                            color: _gradientAnimation.value!.withOpacity(0.5),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'No messages yet',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Start the conversation!',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.5),
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(8),
                      itemCount: widget.chatMessages.length,
                      itemBuilder: (context, index) {
                        return _buildMessageBubble(widget.chatMessages[index]);
                      },
                    ),
            ),
          ),

          // Emoji picker
          if (_showEmojiPicker)
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A2E),
                border: Border(
                  top: BorderSide(
                    color: _gradientAnimation.value!.withOpacity(0.3),
                  ),
                ),
              ),
              child: EmojiPicker(
                onEmojiSelected: (category, emoji) => _onEmojiSelected(emoji),
                config: Config(
                  columns: 7,
                  emojiSizeMax: 28.0,
                  bgColor: Colors.transparent,
                  indicatorColor: _gradientAnimation.value!,
                  iconColor: Colors.grey,
                  iconColorSelected: _gradientAnimation.value!,
                  backspaceColor: _gradientAnimation.value!,
                  skinToneDialogBgColor: const Color(0xFF1A1A2E),
                  skinToneIndicatorColor: _gradientAnimation.value!,
                  enableSkinTones: true,
                  recentsLimit: 28,
                  noRecents: const Text(
                    'No Recents',
                    style: TextStyle(fontSize: 16, color: Colors.black26),
                  ),
                  tabIndicatorAnimDuration: kTabScrollDuration,
                  categoryIcons: const CategoryIcons(),
                  buttonMode: ButtonMode.MATERIAL,
                ),
              ),
            ),

          // Input area
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              border: Border(
                top: BorderSide(
                  color: _gradientAnimation.value!.withOpacity(0.2),
                ),
              ),
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: _toggleEmojiPicker,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.emoji_emotions_outlined,
                      color: _showEmojiPicker ? _gradientAnimation.value : Colors.white.withOpacity(0.7),
                      size: 18,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    constraints: const BoxConstraints(
                      maxHeight: 70,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: TextField(
                      controller: widget.chatController,
                      focusNode: _focusNode,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                      ),
                      maxLines: null,
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        hintStyle: TextStyle(
                          color: Colors.white.withOpacity(0.4),
                          fontSize: 13,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _sendMessage,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          _gradientAnimation.value!,
                          const Color(0xFF4ECDC4),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.send_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
          height: _isExpanded ? _expandedHeight : _collapsedHeight,
          child: _isExpanded ? _buildExpandedView() : _buildCollapsedView(),
        );
      },
    );
  }

  @override
  void dispose() {
    _expandController.dispose();
    _animationController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }
}

class RoomInfoDialog extends StatefulWidget {
  final String roomId;
  final bool isAdmin;
  final Function(String)? onRoomInfoUpdate;
  final Function()? onSwitchToSpeaker;

  const RoomInfoDialog({
    super.key,
    required this.roomId,
    required this.isAdmin,
    this.onRoomInfoUpdate,
    this.onSwitchToSpeaker,
  });

  @override
  State<RoomInfoDialog> createState() => _RoomInfoDialogState();
}

class _RoomInfoDialogState extends State<RoomInfoDialog> with TickerProviderStateMixin {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _welcomeController = TextEditingController();
  late AnimationController _animationController;
  late Animation<Color?> _dialogGradientAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat(reverse: true);
    
    _dialogGradientAnimation = ColorTween(
      begin: const Color(0xFFFF6B6B),
      end: const Color(0xFF4ECDC4),
    ).animate(_animationController);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _showSwitchToSpeakerDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          'Switch to Speaker Seat',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Do you want to switch from host seat to a speaker seat? This will allow you to participate more actively in the conversation while maintaining admin privileges.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              widget.onSwitchToSpeaker?.call();
              Navigator.pop(context); // Close room info dialog too
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            child: const Text('Switch to Speaker'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _dialogGradientAnimation.value!,
                  const Color(0xFF1A1A2E),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A2E),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.settings_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Room Settings',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (widget.isAdmin) ...[
                    _buildRadiantTextField(
                      controller: _nameController,
                      label: 'Room Name',
                      hint: 'Enter room name...',
                      icon: Icons.room_preferences_rounded,
                    ),
                    const SizedBox(height: 12),
                    _buildRadiantTextField(
                      controller: _descController,
                      label: 'Description',
                      hint: 'Enter room description...',
                      maxLines: 2,
                      icon: Icons.description_rounded,
                    ),
                    const SizedBox(height: 12),
                  ],
                  _buildRadiantTextField(
                    controller: _welcomeController,
                    label: 'Welcome Message',
                    hint: 'Enter welcome message for new users...',
                    maxLines: 3,
                    icon: Icons.waving_hand_rounded,
                  ),
                  
                  // Switch to Speaker option for hosts
                  if (widget.isAdmin && widget.onSwitchToSpeaker != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blue.withOpacity(0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.swap_horiz, size: 16, color: Colors.blue),
                              SizedBox(width: 8),
                              Text(
                                'Host Options',
                                style: TextStyle(
                                  color: Colors.blue,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Switch to a speaker seat to participate more actively in conversations.',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 10,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: _showSwitchToSpeakerDialog,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              minimumSize: const Size(double.infinity, 36),
                            ),
                            child: const Text(
                              'Switch to Speaker Seat',
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  
                  if (!widget.isAdmin)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_rounded,
                            color: _dialogGradientAnimation.value,
                            size: 12,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Only room admins can change room settings',
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white54,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        ),
                        child: const Text('Cancel'),
                      ),
                      if (widget.isAdmin)
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                _dialogGradientAnimation.value!,
                                const Color(0xFF4ECDC4),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: TextButton(
                            onPressed: () {
                              if (_nameController.text.isNotEmpty) {
                                widget.onRoomInfoUpdate?.call(_nameController.text);
                              }
                              Navigator.of(context).pop();
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                            ),
                            child: const Text(
                              'Save Changes',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildRadiantTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    int maxLines = 1,
    IconData? icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (icon != null)
              Padding(
                padding: const EdgeInsets.only(right: 6),
                child: Icon(
                  icon,
                  size: 14,
                  color: Colors.white70,
                ),
              ),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.white.withOpacity(0.1),
                Colors.white.withOpacity(0.05),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
            ),
          ),
          child: TextField(
            controller: controller,
            style: const TextStyle(color: Colors.white, fontSize: 13),
            maxLines: maxLines,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(12),
            ),
          ),
        ),
      ],
    );
  }
}