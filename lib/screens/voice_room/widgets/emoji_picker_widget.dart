import 'package:flutter/material.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';

class EmojiPickerWidget extends StatefulWidget {
  final TextEditingController textController;
  final bool isVisible;
  final VoidCallback onVisibilityChanged;
  final Animation<Color?> gradientAnimation;

  const EmojiPickerWidget({
    super.key,
    required this.textController,
    required this.isVisible,
    required this.onVisibilityChanged,
    required this.gradientAnimation,
  });
   @override
  State<EmojiPickerWidget> createState() => _EmojiPickerWidgetState();
}

class _EmojiPickerWidgetState extends State<EmojiPickerWidget> {
  @override
  Widget build(BuildContext context) {
    if (!widget.isVisible) return const SizedBox.shrink();

    return SizedBox(
      height: 240,
      child: Column(
        children: [
          // Emoji picker header
          Container(
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A2E),
              border: Border(
                bottom: BorderSide(
                  color: widget.gradientAnimation.value!.withOpacity(0.3),
                ),
              ),
            ),