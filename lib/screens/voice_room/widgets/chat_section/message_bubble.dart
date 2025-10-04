import 'package:flutter/material.dart';
import '../models/chat_message.dart';

class MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isCurrentUser;
  final String currentUserId;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isCurrentUser,
    required this.currentUserId,
  });

  @override
  Widget build(BuildContext context) {
    final messageColor = Color(int.parse(message.messageColor.replaceAll('#', '0xFF')));
    final isAdmin = message.userRole == UserRole.admin;
    
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: isCurrentUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isCurrentUser) ...[
            _buildUserAvatar(message),
            const SizedBox(width: 6),
          ],
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    messageColor.withOpacity(0.8),
                    messageColor.withOpacity(0.6),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  topLeft: isCurrentUser ? const Radius.circular(12) : const Radius.circular(4),
                  topRight: isCurrentUser ? const Radius.circular(4) : const Radius.circular(12),
                  bottomLeft: const Radius.circular(12),
                  bottomRight: const Radius.circular(12),
                ),
                boxShadow: [
                  BoxShadow(
                    color: messageColor.withOpacity(0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header with username and time
                  _buildMessageHeader(message, isAdmin),
                  const SizedBox(height: 4),
                  // Message text
                  _buildMessageText(message),
                  // Achievement badge for high-level users
                  if (message.userLevel >= 5 && !message.isSystemMessage && !isAdmin)
                    _buildAchievementBadge(message),
                ],
              ),
            ),
          ),
          if (isCurrentUser) ...[
            const SizedBox(width: 6),
            _buildUserAvatar(message),
          ],
        ],
      ),
    );
  }

  Widget _buildMessageHeader(ChatMessage message, bool isAdmin) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: Text(
            message.displayName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
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
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text(
              'Admin',
              style: TextStyle(
                color: Colors.white,
                fontSize: 6,
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
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              'Lvl ${message.userLevel}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 6,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
        const Spacer(),
        Text(
          message.formattedTime,
          style: TextStyle(
            color: Colors.white.withOpacity(0.6),
            fontSize: 8,
          ),
        ),
      ],
    );
  }

  Widget _buildMessageText(ChatMessage message) {
    return Text(
      message.text,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 11,
        height: 1.2,
      ),
    );
  }

  Widget _buildAchievementBadge(ChatMessage message) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(3),
        ),
        child: Text(
          message.achievementTitle,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 7,
            fontStyle: FontStyle.italic,
          ),
        ),
      ),
    );
  }

  Widget _buildUserAvatar(ChatMessage message) {
    final isAdmin = message.userRole == UserRole.admin;
    
    return Container(
      width: 28,
      height: 28,
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
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Center(
        child: Text(
          message.username.isNotEmpty ? message.username[0].toUpperCase() : '?',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}