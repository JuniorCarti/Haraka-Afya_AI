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
    required this.activeSpeakersCount,
  });

  @override
  Widget build(BuildContext context) {
    final host = members.firstWhere((member) => member.isHost, orElse: () => members.first);
    final listenersCount = members.where((member) => member.role == MemberRole.listener).length;
    final speakersCount = members.where((member) => member.role == MemberRole.speaker).length;
    final moderatorsCount = members.where((member) => member.role == MemberRole.moderator).length;
    final totalMembers = members.length;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.black.withOpacity(0.8), Colors.transparent],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Row(
        children: [
          // Total members count - NEW FEATURE
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.blue),
            ),
            child: Row(
              children: [
                const Icon(Icons.people_alt_rounded, color: Colors.blue, size: 14),
                const SizedBox(width: 6),
                Text(
                  '$totalMembers',
                  style: const TextStyle(
                    color: Colors.blue,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Live badge with active speakers
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.red),
            ),
            child: Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  'LIVE • $activeSpeakersCount',
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Members breakdown
          _buildMemberTypeCount(
            icon: Icons.workspace_premium_rounded,
            count: 1, // Host
            color: Colors.yellow,
            tooltip: 'Host',
          ),
          
          if (moderatorsCount > 0)
            _buildMemberTypeCount(
              icon: Icons.star_rounded,
              count: moderatorsCount,
              color: Colors.green,
              tooltip: 'Moderators',
            ),
            
          _buildMemberTypeCount(
            icon: Icons.mic_rounded,
            count: speakersCount,
            color: Colors.blue,
            tooltip: 'Speakers',
          ),
          
          _buildMemberTypeCount(
            icon: Icons.headset_rounded,
            count: listenersCount,
            color: Colors.grey,
            tooltip: 'Listeners',
          ),

          const SizedBox(width: 8),

          // Host level and info
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _getLevelColor(host.level).withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _getLevelColor(host.level)),
            ),
            child: Row(
              children: [
                Icon(Icons.star_rounded, color: _getLevelColor(host.level), size: 12),
                const SizedBox(width: 4),
                Text(
                  'Lvl ${host.level}',
                  style: TextStyle(
                    color: _getLevelColor(host.level),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  host.getAchievementTitle(),
                  style: TextStyle(
                    color: _getLevelColor(host.level),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),

          const Spacer(),

          // Room info
          Expanded(
            child: GestureDetector(
              onTap: isCurrentUserHost ? onRoomInfoEdit : null,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: isCurrentUserHost 
                      ? Border.all(color: Colors.white.withOpacity(0.3))
                      : null,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            roomName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isCurrentUserHost)
                          const Icon(Icons.edit_rounded, size: 12, color: Colors.white54),
                      ],
                    ),
                    if (roomDescription.isNotEmpty)
                      Text(
                        roomDescription,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 10,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Host actions
          if (isCurrentUserHost) ...[
            IconButton(
              icon: const Icon(Icons.wallpaper_rounded, color: Colors.white54, size: 20),
              onPressed: onBackgroundChange,
              tooltip: 'Change Room Background',
            ),
            IconButton(
              icon: const Icon(Icons.settings_rounded, color: Colors.white54, size: 20),
              onPressed: onRoomInfoEdit,
              tooltip: 'Room Settings',
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMemberTypeCount({
    required IconData icon,
    required int count,
    required Color color,
    required String tooltip,
  }) {
    if (count == 0) return const SizedBox.shrink();
    
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Tooltip(
        message: tooltip,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(icon, color: color, size: 12),
              const SizedBox(width: 4),
              Text(
                '$count',
                style: TextStyle(
                  color: color,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getLevelColor(int level) {
    if (level >= 20) return Colors.red;
    if (level >= 15) return Colors.orange;
    if (level >= 10) return Colors.purple;
    if (level >= 5) return Colors.blue;
    if (level >= 3) return Colors.green;
    return Colors.grey;
  }
}