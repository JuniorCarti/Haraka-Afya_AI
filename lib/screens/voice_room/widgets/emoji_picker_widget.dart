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