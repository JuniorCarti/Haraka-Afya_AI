import 'package:flutter/material.dart';
import '../models/room_member.dart';

class RoomHeader extends StatelessWidget {
  final List<RoomMember> members;
  final VoidCallback onBackgroundChange;
  final VoidCallback onRoomInfoEdit;
  final String roomName;
  final String roomDescription;
  final bool isCurrentUserHost;
  final int activeSpeakersCount;

  const RoomHeader({
    super.key,
    required this.members,
    required this.onBackgroundChange,
    required this.onRoomInfoEdit,
    required this.roomName,
    required this.roomDescription,
    required this.isCurrentUserHost,
    required this.activeSpeakersCount, required bool hasAudioStream,
  });

  @override
  Widget build(BuildContext context) {
    final host = members.firstWhere(
      (member) => member.isHost, 
      orElse: () => members.isNotEmpty ? members.first : _createFallbackHost()
    );
    
    final listenersCount = members.where((member) => member.role == MemberRole.listener).length;
    final speakersCount = members.where((member) => member.role == MemberRole.speaker).length;
    final moderatorsCount = members.where((member) => member.role == MemberRole.moderator).length;
    final totalMembers = members.length;

    // Truncate room info to prevent overflow
    final displayName = _truncateText(roomName, 16); // Max 16 chars for room name
    final displayDescription = _truncateText(roomDescription, 30); // Max 30 chars for description

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.black.withOpacity(0.9),
            Colors.black.withOpacity(0.6),
            Colors.transparent,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: const [0.0, 0.7, 1.0],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Top Row - Stats and Controls
          Row(
            children: [
              // Total Members
              _buildStatBadge(
                icon: Icons.people_alt_rounded,
                value: '$totalMembers',
                color: Colors.blue,
                tooltip: 'Total Members',
              ),
              const SizedBox(width: 8),

              // Live Speakers
              _buildStatBadge(
                icon: Icons.mic_rounded,
                value: '$activeSpeakersCount',
                color: Colors.green,
                tooltip: 'Active Speakers',
                isLive: true,
              ),
              const SizedBox(width: 8),

              // Host Level
              _buildHostLevelBadge(host),
              
              const Spacer(),

              // Host Actions
              if (isCurrentUserHost) ...[
                _buildActionButton(
                  icon: Icons.wallpaper_rounded,
                  onPressed: onBackgroundChange,
                  tooltip: 'Change Background',
                  color: Colors.purple,
                ),
                const SizedBox(width: 8),
                _buildActionButton(
                  icon: Icons.settings_rounded,
                  onPressed: onRoomInfoEdit,
                  tooltip: 'Room Settings',
                  color: Colors.blue,
                ),
              ],
            ],
          ),
          
          const SizedBox(height: 8),
          
          // Bottom Row - Room Info and Member Breakdown
          Row(
            children: [
              // Room Info
              Expanded(
                child: _buildRoomInfo(
                  name: displayName,
                  description: displayDescription,
                  isEditable: isCurrentUserHost,
                  onEdit: onRoomInfoEdit,
                ),
              ),
              
              const SizedBox(width: 12),
              
              // Member Breakdown
              _buildMemberBreakdown(
                hostCount: 1,
                moderatorsCount: moderatorsCount,
                speakersCount: speakersCount,
                listenersCount: listenersCount,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatBadge({
    required IconData icon,
    required String value,
    required Color color,
    required String tooltip,
    bool isLive = false,
  }) {
    return Tooltip(
      message: tooltip,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isLive) ...[
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 4),
            ],
            Icon(
              icon,
              color: color,
              size: 12,
            ),
            const SizedBox(width: 4),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHostLevelBadge(RoomMember host) {
    return Tooltip(
      message: 'Host Level ${host.level} - ${host.getAchievementTitle()}',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: _getLevelColor(host.level).withOpacity(0.15),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: _getLevelColor(host.level).withOpacity(0.4)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.workspace_premium_rounded,
              color: _getLevelColor(host.level),
              size: 10,
            ),
            const SizedBox(width: 4),
            Text(
              'L${host.level}',
              style: TextStyle(
                color: _getLevelColor(host.level),
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onPressed,
    required String tooltip,
    required Color color,
  }) {
    return Tooltip(
      message: tooltip,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: IconButton(
          icon: Icon(icon, size: 14, color: color),
          onPressed: onPressed,
          padding: EdgeInsets.zero,
        ),
      ),
    );
  }

  Widget _buildRoomInfo({
    required String name,
    required String description,
    required bool isEditable,
    required VoidCallback onEdit,
  }) {
    return GestureDetector(
      onTap: isEditable ? onEdit : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isEditable ? Colors.white.withOpacity(0.2) : Colors.transparent,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (isEditable) ...[
                  const SizedBox(width: 4),
                  Icon(
                    Icons.edit_rounded,
                    size: 12,
                    color: Colors.white.withOpacity(0.6),
                  ),
                ],
              ],
            ),
            if (description.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(
                description,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 11,
                  height: 1.2,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMemberBreakdown({
    required int hostCount,
    required int moderatorsCount,
    required int speakersCount,
    required int listenersCount,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Host
          _buildRoleIndicator(
            count: hostCount,
            color: Colors.amber,
            tooltip: 'Host',
          ),
          
          if (moderatorsCount > 0) ...[
            const SizedBox(width: 6),
            _buildRoleIndicator(
              count: moderatorsCount,
              color: Colors.green,
              tooltip: 'Moderators',
            ),
          ],
          
          if (speakersCount > 0) ...[
            const SizedBox(width: 6),
            _buildRoleIndicator(
              count: speakersCount,
              color: Colors.blue,
              tooltip: 'Speakers',
            ),
          ],
          
          if (listenersCount > 0) ...[
            const SizedBox(width: 6),
            _buildRoleIndicator(
              count: listenersCount,
              color: Colors.grey,
              tooltip: 'Listeners',
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRoleIndicator({
    required int count,
    required Color color,
    required String tooltip,
  }) {
    return Tooltip(
      message: tooltip,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            '$count',
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  String _truncateText(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength - 3)}...';
  }

  Color _getLevelColor(int level) {
    if (level >= 20) return const Color(0xFFE74C3C);
    if (level >= 15) return const Color(0xFFE67E22);
    if (level >= 10) return const Color(0xFF9B59B6);
    if (level >= 5) return const Color(0xFF3498DB);
    if (level >= 3) return const Color(0xFF2ECC71);
    return const Color(0xFF95A5A6);
  }

  RoomMember _createFallbackHost() {
    return RoomMember(
      id: 'fallback_host',
      userId: 'fallback_host',
      username: 'No Host',
      role: MemberRole.admin,
      isSpeaking: false,
      avatar: '👑',
      points: 0,
      level: 1,
      joinedAt: DateTime.now(),
      lastActive: DateTime.now(),
      isMuted: false,
      isHandRaised: false,
      achievements: [],
      title: 'Host',
      messageColor: '#FFD700',
      totalMessages: 0,
      roomsJoined: 1,
      sessionId: 'fallback',
    );
  }
}