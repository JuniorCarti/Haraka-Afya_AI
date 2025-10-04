import 'package:flutter/material.dart';
import '../models/room_member.dart';

class HostSeat extends StatelessWidget {
  final RoomMember host;
  final VoidCallback? onHostTap;
  final bool isCurrentUser;

  const HostSeat({
    super.key, 
    required this.host,
    this.onHostTap,
    this.isCurrentUser = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8),
      child: GestureDetector(
        onTap: onHostTap,
        child: MouseRegion(
          cursor: onHostTap != null ? SystemMouseCursors.click : SystemMouseCursors.basic,
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 120,
              minWidth: 100,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Host Avatar with Status Indicators
                _buildHostAvatar(),
                const SizedBox(height: 8),
                
                // User Info Section
                _buildUserInfo(),
                const SizedBox(height: 4),
                
                // Status Badge
                _buildStatusBadge(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHostAvatar() {
    return SizedBox(
      width: 84,
      height: 84,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Main Avatar Container
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFFFFD700), Color(0xFFFFA000)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.amber.withOpacity(0.4),
                  blurRadius: 12,
                  spreadRadius: 2,
                  offset: const Offset(0, 4),
                ),
              ],
              border: Border.all(
                color: Colors.amber.shade400,
                width: 2.5,
              ),
            ),
            child: Center(
              child: Text(
                host.avatar,
                style: const TextStyle(fontSize: 28),
              ),
            ),
          ),
          
          // Crown Badge - Top Center
          Positioned(
            top: -4,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFFFD700), Color(0xFFFFA000)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.workspace_premium_rounded,
                size: 16,
                color: Colors.white,
              ),
            ),
          ),
          
          // Speaking Indicator - Bottom Left
          if (host.isSpeaking)
            Positioned(
              bottom: 2,
              left: 2,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 3,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.mic_rounded,
                  size: 12,
                  color: Colors.white,
                ),
              ),
            ),
          
          // Current User Indicator - Bottom Right
          if (isCurrentUser)
            Positioned(
              bottom: 2,
              right: 2,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 3,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.person_rounded,
                  size: 12,
                  color: Colors.white,
                ),
              ),
            ),
          
          // Muted Indicator - Overlay when muted
          if (!host.isSpeaking && host.isMuted)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(
                    Icons.mic_off_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildUserInfo() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.black.withOpacity(0.7),
            Colors.black.withOpacity(0.5),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Username and Level
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  host.username,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                    height: 1.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  color: _getLevelColor(host.level),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'L${host.level}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          
          // Role
          Text(
            host.roleDisplayName.toUpperCase(),
            style: TextStyle(
              color: Colors.amber.shade300,
              fontSize: 9,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
          
          // Achievement Title (for high level users)
          if (host.level >= 5)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                host.getAchievementTitle(),
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 8,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: _getStatusColor(host),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: _getStatusColor(host).withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getStatusIcon(host),
            size: 10,
            color: Colors.white,
          ),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              _getStatusText(host).toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 8,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Color _getLevelColor(int level) {
    if (level >= 20) return const Color(0xFFE74C3C);
    if (level >= 15) return const Color(0xFFE67E22);
    if (level >= 10) return const Color(0xFF9B59B6);
    if (level >= 5) return const Color(0xFF3498DB);
    if (level >= 3) return const Color(0xFF2ECC71);
    return const Color(0xFF95A5A6);
  }

  Color _getStatusColor(RoomMember member) {
    if (member.isSpeaking) return const Color(0xFF27AE60);
    if (member.isHandRaised) return const Color(0xFFF39C12);
    if (member.isActive) return const Color(0xFF2980B9);
    return const Color(0xFF7F8C8D);
  }

  IconData _getStatusIcon(RoomMember member) {
    if (member.isSpeaking) return Icons.mic_rounded;
    if (member.isHandRaised) return Icons.back_hand_rounded;
    if (member.isActive) return Icons.online_prediction_rounded;
    return Icons.offline_bolt_rounded;
  }

  String _getStatusText(RoomMember member) {
    if (member.isSpeaking) return 'Speaking';
    if (member.isHandRaised) return 'Hand Raised';
    if (member.isActive) return 'Active';
    return 'Away';
  }
}