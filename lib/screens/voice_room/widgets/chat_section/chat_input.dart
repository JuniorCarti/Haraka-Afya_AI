import 'package:flutter/material.dart';

class ChatInput extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onSendMessage;
  final VoidCallback onToggleEmojiPicker;
  final bool showEmojiPicker;
  final Animation<Color?> gradientAnimation;

  const ChatInput({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.onSendMessage,
    required this.onToggleEmojiPicker,
    required this.showEmojiPicker,
    required this.gradientAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.4),
        border: Border(
          top: BorderSide(
            color: gradientAnimation.value!.withOpacity(0.2),
          ),
        ),
      ),
      child: Row(
        children: [
          // Emoji button
          _buildEmojiButton(),
          const SizedBox(width: 6),
          // Text input field
          _buildTextInput(),
          const SizedBox(width: 6),
          // Send button
          _buildSendButton(),
        ],
      ),
    );
  }

  Widget _buildEmojiButton() {
    return GestureDetector(
      onTap: onToggleEmojiPicker,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.emoji_emotions_outlined,
          color: showEmojiPicker ? gradientAnimation.value : Colors.white.withOpacity(0.7),
          size: 16,
        ),
      ),
    );
  }

  Widget _buildTextInput() {
    return Expanded(
      child: Container(
        constraints: const BoxConstraints(
          maxHeight: 80,
          minHeight: 36,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(18),
        ),
        child: TextField(
          controller: controller,
          focusNode: focusNode,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
          ),
          maxLines: null,
          textInputAction: TextInputAction.send,
          decoration: InputDecoration(
            hintText: 'Type a message...',
            hintStyle: TextStyle(
              color: Colors.white.withOpacity(0.4),
              fontSize: 12,
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 8),
            isDense: true,
          ),
          onSubmitted: (_) => onSendMessage(),
        ),
      ),
    );
  }

  Widget _buildSendButton() {
    return GestureDetector(
      onTap: onSendMessage,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              gradientAnimation.value!,
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
          size: 14,
        ),
      ),
    );
  }
}