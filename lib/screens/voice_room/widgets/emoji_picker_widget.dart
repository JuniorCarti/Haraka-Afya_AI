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
             child: Row(
              children: [
                Text(
                  'Emojis',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: Icon(
                    Icons.close,
                    color: Colors.white.withOpacity(0.7),
                    size: 16,
                  ),
                  onPressed: widget.onVisibilityChanged,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                ),
              ],
            ),
          ),
          // Emoji picker
        Expanded(
            child: EmojiPicker(
              onEmojiSelected: (category, emoji) => _onEmojiSelected(emoji),
              config: Config(
                columns: 8,
                emojiSizeMax: 28.0,
                bgColor: Colors.transparent,
                indicatorColor: widget.gradientAnimation.value!,
                iconColor: Colors.grey,
                iconColorSelected: widget.gradientAnimation.value!,
                backspaceColor: widget.gradientAnimation.value!,
                skinToneDialogBgColor: const Color(0xFF1A1A2E),
                skinToneIndicatorColor: widget.gradientAnimation.value!,
                enableSkinTones: true,
                recentsLimit: 32,
                noRecents: const Text(
                  'No Recents',
                  style: TextStyle(fontSize: 14, color: Colors.black26),
                ),
                tabIndicatorAnimDuration: kTabScrollDuration,
                categoryIcons: const CategoryIcons(),
                buttonMode: ButtonMode.MATERIAL,
                initCategory: Category.RECENT,
              ),
            ),
          ),
        ],
      ),
    );
  }