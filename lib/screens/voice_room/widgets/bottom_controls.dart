import 'package:flutter/material.dart';
import 'control_button.dart';

class BottomControls extends StatelessWidget {
  final bool isMuted;
  final VoidCallback onToggleMicrophone;
  final VoidCallback onShowGamesMenu;
  final VoidCallback onShowGiftMenu;
  final VoidCallback onLeaveRoom;

  const BottomControls({
    super.key,
    required this.isMuted,
    required this.onToggleMicrophone,
    required this.onShowGamesMenu,
    required this.onShowGiftMenu,
    required this.onLeaveRoom,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.8),
        border: Border(
          top: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
      ),
      child: Row(
        children: [
          ControlButton(
            icon: Icons.sports_esports_rounded,
            label: 'Games',
            onPressed: onShowGamesMenu,
          ),
          const SizedBox(width: 12),
          ControlButton(
            icon: Icons.card_giftcard_rounded,
            label: 'Gifts',
            onPressed: onShowGiftMenu,
          ),
          const Spacer(),
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              gradient: isMuted 
                  ? const LinearGradient(colors: [Colors.grey, Colors.grey])
                  : const LinearGradient(colors: [Color(0xFF4CAF50), Color(0xFF45a049)]),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: (isMuted ? Colors.grey : Colors.green).withOpacity(0.3),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: IconButton(
              icon: Icon(
                isMuted ? Icons.mic_off_rounded : Icons.mic_rounded,
                color: Colors.white,
                size: 20,
              ),
              onPressed: onToggleMicrophone,
            ),
          ),
          const Spacer(),
          ControlButton(
            icon: Icons.logout_rounded,
            label: 'Leave',
            onPressed: onLeaveRoom,
            isDanger: true,
          ),
        ],
      ),
    );
  }
}