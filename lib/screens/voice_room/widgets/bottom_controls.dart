import 'package:flutter/material.dart';
import 'control_button.dart';

class BottomControls extends StatelessWidget {
  final bool isMuted;
  final VoidCallback onToggleMicrophone;
  final VoidCallback onShowGamesMenu;
  final VoidCallback onShowGiftMenu;
  final VoidCallback onShowBackgroundMenu;
  final VoidCallback onLeaveRoom;
  final bool isHost;

  const BottomControls({
    super.key,
    required this.isMuted,
    required this.onToggleMicrophone,
    required this.onShowGamesMenu,
    required this.onShowGiftMenu,
    required this.onShowBackgroundMenu,
    required this.onLeaveRoom,
    required this.isHost,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.95),
        border: Border(
          top: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left side - Action buttons
          Row(
            children: [
              // Games button
              _buildMiniButton(
                icon: Icons.sports_esports_rounded,
                onPressed: onShowGamesMenu,
              ),
              const SizedBox(width: 6),
              
              // Gift button
              _buildMiniButton(
                icon: Icons.card_giftcard_rounded,
                onPressed: onShowGiftMenu,
              ),
              const SizedBox(width: 6),
              
              // Background button (only for host)
              if (isHost)
                _buildMiniButton(
                  icon: Icons.wallpaper_rounded,
                  onPressed: onShowBackgroundMenu,
                ),
            ],
          ),
          
          // Center - Mic control
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: isMuted 
                  ? const LinearGradient(colors: [Colors.grey, Colors.grey])
                  : const LinearGradient(colors: [Color(0xFF4CAF50), Color(0xFF45a049)]),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: (isMuted ? Colors.grey : Colors.green).withOpacity(0.3),
                  blurRadius: 4,
                ),
              ],
            ),
            child: IconButton(
              icon: Icon(
                isMuted ? Icons.mic_off_rounded : Icons.mic_rounded,
                color: Colors.white,
                size: 16,
              ),
              onPressed: onToggleMicrophone,
              padding: EdgeInsets.zero,
            ),
          ),
          
          // Right side - Leave button
          _buildMiniButton(
            icon: Icons.logout_rounded,
            onPressed: onLeaveRoom,
            isDanger: true,
          ),
        ],
      ),
    );
  }

  Widget _buildMiniButton({
    required IconData icon,
    required VoidCallback onPressed,
    bool isDanger = false,
  }) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: isDanger 
            ? Colors.red.withOpacity(0.2)
            : Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDanger 
              ? Colors.red.withOpacity(0.3)
              : Colors.white.withOpacity(0.2),
        ),
      ),
      child: IconButton(
        icon: Icon(
          icon,
          color: isDanger ? Colors.red : Colors.white,
          size: 16,
        ),
        onPressed: onPressed,
        padding: EdgeInsets.zero,
      ),
    );
  }
}