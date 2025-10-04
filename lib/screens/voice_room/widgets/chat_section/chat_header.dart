import 'package:flutter/material.dart';

class ChatHeader extends StatelessWidget {
  final int messageCount;
  final bool isAdmin;
  final VoidCallback onToggleExpanded;
  final VoidCallback onShowRoomInfo;
  final VoidCallback? onSwitchToSpeaker;
  final VoidCallback onShowSwitchToSpeakerDialog;
  final Animation<Color?> gradientAnimation;

  const ChatHeader({
    super.key,
    required this.messageCount,
    required this.isAdmin,
    required this.onToggleExpanded,
    required this.onShowRoomInfo,
    this.onSwitchToSpeaker,
    required this.onShowSwitchToSpeakerDialog,
    required this.gradientAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            gradientAnimation.value!.withOpacity(0.9),
            const Color(0xFF4ECDC4).withOpacity(0.9),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.chat_bubble_rounded,
            color: Colors.white,
            size: 16,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: GestureDetector(
              onTap: onShowRoomInfo,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Room Chat',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (isAdmin)
                        const Padding(
                          padding: EdgeInsets.only(left: 4),
                          child: Icon(Icons.settings, size: 10, color: Colors.white),
                        ),
                    ],
                  ),
                  Text(
                    '$messageCount messages • Tap to minimize',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 8,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isAdmin && onSwitchToSpeaker != null)
            Padding(
              padding: const EdgeInsets.only(right: 6),
              child: GestureDetector(
                onTap: onShowSwitchToSpeakerDialog,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.blue.withOpacity(0.5)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.swap_horiz, size: 10, color: Colors.white),
                      SizedBox(width: 2),
                      Text(
                        'Switch',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          GestureDetector(
            onTap: onToggleExpanded,
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: Colors.white,
                size: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}