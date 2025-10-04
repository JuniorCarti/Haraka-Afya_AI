import 'package:flutter/material.dart';
import '../models/chat_message.dart';
import 'emoji_picker_widget.dart';
import 'message_bubble.dart';
import 'chat_input.dart';
import 'chat_header.dart';
import 'room_info_dialog.dart';

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
  final double _collapsedHeight = 70.0;
  final double _expandedHeight = 320.0;

  @override
  void initState() {
    super.initState();
    
    _expandController = AnimationController(
      duration: const Duration(milliseconds: 300),
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
    
    _focusNode.addListener(_onFocusChange);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  void _onFocusChange() {
    if (!_focusNode.hasFocus && _showEmojiPicker) {
      setState(() {
        _showEmojiPicker = false;
      });
    }
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
        _focusNode.unfocus();
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
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    }
  }

  void _toggleEmojiPicker() {
    if (!_isExpanded) {
      _toggleExpanded();
      Future.delayed(const Duration(milliseconds: 150), () {
        setState(() {
          _showEmojiPicker = true;
        });
      });
    } else {
      setState(() {
        _showEmojiPicker = !_showEmojiPicker;
        if (_showEmojiPicker) {
          _focusNode.unfocus();
        } else {
          _focusNode.requestFocus();
        }
      });
    }
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
        backgroundColor: const Color(0xFF1A1A2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
      height: _collapsedHeight,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
        boxShadow: [
          BoxShadow(
            color: _gradientAnimation.value!.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header row
          Row(
            children: [
              const Icon(
                Icons.chat_bubble_rounded,
                color: Colors.white,
                size: 16,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Room Chat',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${widget.chatMessages.length}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              GestureDetector(
                onTap: _toggleExpanded,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.keyboard_arrow_up_rounded,
                    color: Colors.white,
                    size: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          // Latest message preview
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: latestMessage != null
                  ? Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${latestMessage.username}: ${latestMessage.text}',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 9,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          latestMessage.formattedTime,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.6),
                            fontSize: 8,
                          ),
                        ),
                      ],
                    )
                  : Center(
                      child: Text(
                        'Tap to start chatting',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 9,
                        ),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpandedView() {
    return Container(
      height: _expandedHeight,
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
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          ChatHeader(
            messageCount: widget.chatMessages.length,
            isAdmin: widget.isAdmin,
            onToggleExpanded: _toggleExpanded,
            onShowRoomInfo: _showRoomInfoDialog,
            onSwitchToSpeaker: widget.onSwitchToSpeaker,
            onShowSwitchToSpeakerDialog: _showSwitchToSpeakerDialog,
            gradientAnimation: _gradientAnimation,
          ),

          // Messages area
          Expanded(
            child: Container(
              decoration: const BoxDecoration(),
              child: widget.chatMessages.isEmpty
                  ? _buildEmptyChatState()
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      itemCount: widget.chatMessages.length,
                      itemBuilder: (context, index) {
                        return MessageBubble(
                          message: widget.chatMessages[index],
                          isCurrentUser: widget.chatMessages[index].userId == widget.currentUserId,
                          currentUserId: widget.currentUserId,
                        );
                      },
                    ),
            ),
          ),

          // Emoji picker
          EmojiPickerWidget(
            textController: widget.chatController,
            isVisible: _showEmojiPicker,
            onVisibilityChanged: _toggleEmojiPicker,
            gradientAnimation: _gradientAnimation,
          ),

          // Input area
          ChatInput(
            controller: widget.chatController,
            focusNode: _focusNode,
            onSendMessage: _sendMessage,
            onToggleEmojiPicker: _toggleEmojiPicker,
            showEmojiPicker: _showEmojiPicker,
            gradientAnimation: _gradientAnimation,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyChatState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.forum_outlined,
              size: 28,
              color: _gradientAnimation.value!.withOpacity(0.4),
            ),
            const SizedBox(height: 6),
            Text(
              'No messages yet',
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Start the conversation!',
              style: TextStyle(
                color: Colors.white.withOpacity(0.4),
                fontSize: 8,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
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
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }
}