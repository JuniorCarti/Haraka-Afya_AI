import 'package:flutter/material.dart';

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
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.black.withOpacity(0.95),
              Colors.black.withOpacity(0.85),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          border: Border(
            top: BorderSide(
              color: Colors.white.withOpacity(0.15),
              width: 0.5,
            ),
          ),
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 400, // Prevent overflow on large screens
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Left side - Utility buttons
              Flexible(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    _buildActionButton(
                      icon: Icons.sports_esports_rounded,
                      label: 'Games',
                      onPressed: onShowGamesMenu,
                      color: const Color(0xFF6C5CE7),
                    ),
                    const SizedBox(width: 12),
                    
                    _buildActionButton(
                      icon: Icons.card_giftcard_rounded,
                      label: 'Gifts',
                      onPressed: onShowGiftMenu,
                      color: const Color(0xFFE84393),
                    ),
                    const SizedBox(width: 12),
                    
                    // Background button - only for host
                    if (isHost)
                      _buildActionButton(
                        icon: Icons.wallpaper_rounded,
                        label: 'BG',
                        onPressed: onShowBackgroundMenu,
                        color: const Color(0xFF00B894),
                      ),
                  ],
                ),
              ),
              
              // Center - Microphone control (always centered)
              _buildMicrophoneButton(),
              
              // Right side - Leave button
              Flexible(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _buildLeaveButton(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required Color color,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                color.withOpacity(0.9),
                color.withOpacity(0.7),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: IconButton(
            icon: Icon(
              icon,
              color: Colors.white,
              size: 20,
            ),
            onPressed: onPressed,
            padding: EdgeInsets.zero,
            tooltip: label,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildMicrophoneButton() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: isMuted 
                ? const LinearGradient(
                    colors: [Color(0xFF636E72), Color(0xFF2D3436)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : const LinearGradient(
                    colors: [Color(0xFF00B894), Color(0xFF00A085)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
            boxShadow: [
              BoxShadow(
                color: (isMuted ? const Color(0xFF636E72) : const Color(0xFF00B894)).withOpacity(0.4),
                blurRadius: 12,
                spreadRadius: 1,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Pulsing animation when not muted
              if (!isMuted)
                Positioned.fill(
                  child: Container(
                    margin: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFF00B894).withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                  ),
                ),
              
              IconButton(
                icon: Icon(
                  isMuted ? Icons.mic_off_rounded : Icons.mic_rounded,
                  color: Colors.white,
                  size: 24,
                ),
                onPressed: onToggleMicrophone,
                padding: EdgeInsets.zero,
                tooltip: isMuted ? 'Unmute' : 'Mute',
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          isMuted ? 'Muted' : 'Live',
          style: TextStyle(
            color: isMuted ? const Color(0xFFE17055) : const Color(0xFF00B894),
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildLeaveButton() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFE17055), Color(0xFFD63031)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFD63031).withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: IconButton(
            icon: const Icon(
              Icons.logout_rounded,
              color: Colors.white,
              size: 20,
            ),
            onPressed: onLeaveRoom,
            padding: EdgeInsets.zero,
            tooltip: 'Leave Room',
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Leave',
          style: TextStyle(
            color: const Color(0xFFE17055).withOpacity(0.9),
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}