import 'package:flutter/material.dart';
import '../models/room_member.dart';

class MemberOptions extends StatelessWidget {
  final RoomMember member;
  final bool isCurrentUserHost;
  final VoidCallback onSendGift;
  final VoidCallback onRemoveMember;
  final VoidCallback onMuteMember;
  final VoidCallback onPromoteToSpeaker;
  final VoidCallback onPromoteToModerator;
  final VoidCallback onDemoteToListener;
  final VoidCallback onTransferHost;

  const MemberOptions({
    super.key,
    required this.member,
    required this.isCurrentUserHost,
    required this.onSendGift,
    required this.onRemoveMember,
    required this.onMuteMember,
    required this.onPromoteToSpeaker,
    required this.onPromoteToModerator,
    required this.onDemoteToListener,
    required this.onTransferHost,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1A1A1A),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Member header with detailed info
            Row(
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.white.withOpacity(0.1),
                      radius: 24,
                      child: Text(
                        member.avatar,
                        style: const TextStyle(fontSize: 20),
                      ),
                    ),
                    // Role badge
                    Positioned(
                      bottom: -2,
                      right: -2,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.black,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          member.roleBadge,
                          style: const TextStyle(fontSize: 10),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            member.username,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(width: 6),
                          // Level badge
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: _getLevelColor(member.level),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Lvl ${member.level}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        member.roleDisplayName,
                        style: TextStyle(
                          color: _getRoleColor(member.role),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (member.title.isNotEmpty)
                        Text(
                          member.title,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 11,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.yellow.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${member.points} pts',
                        style: const TextStyle(
                          color: Colors.yellow,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Activity status
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: _getStatusColor(member),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        member.activityStatus,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            const Divider(color: Colors.white24, height: 1),
            const SizedBox(height: 16),

            // Member statistics
            _buildMemberStats(),

            const SizedBox(height: 16),
            const Divider(color: Colors.white24, height: 1),
            const SizedBox(height: 16),

            // Action buttons
            _buildActionButtons(),
            
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildMemberStats() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildStatItem(
          value: member.totalMessages.toString(),
          label: 'Messages',
          icon: Icons.chat_bubble_outline,
        ),
        _buildStatItem(
          value: member.roomsJoined.toString(),
          label: 'Rooms',
          icon: Icons.room,
        ),
        _buildStatItem(
          value: member.achievements.length.toString(),
          label: 'Badges',
          icon: Icons.emoji_events_outlined,
        ),
        _buildStatItem(
          value: member.timeSinceJoined,
          label: 'Joined',
          icon: Icons.access_time,
        ),
      ],
    );
  }

  Widget _buildStatItem({required String value, required String label, required IconData icon}) {
    return Column(
      children: [
        Icon(icon, size: 16, color: Colors.white54),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white54,
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        // Gift button - available for everyone
        _buildMemberActionButton(
          icon: Icons.card_giftcard_rounded,
          label: 'Send Gift',
          onTap: onSendGift,
          color: Colors.purple,
        ),

        // Host-only actions
        if (isCurrentUserHost && !member.isHost) ...[
          const SizedBox(height: 8),
          
          // Role management
          if (member.role == MemberRole.listener)
            _buildMemberActionButton(
              icon: Icons.mic_external_on_rounded,
              label: 'Promote to Speaker',
              onTap: onPromoteToSpeaker ?? () {},
              color: Colors.blue,
            ),

          if (member.role == MemberRole.listener || member.role == MemberRole.speaker)
            _buildMemberActionButton(
              icon: Icons.star_rounded,
              label: 'Promote to Moderator',
              onTap: onPromoteToModerator ?? () {},
              color: Colors.orange,
            ),

          if (member.role == MemberRole.speaker)
            _buildMemberActionButton(
              icon: Icons.volume_off_rounded,
              label: 'Demote to Listener',
              onTap: onDemoteToListener ?? () {},
              color: Colors.grey,
            ),

          // Host transfer
          if (!member.isHost)
            _buildMemberActionButton(
              icon: Icons.workspace_premium_rounded,
              label: 'Transfer Host Role',
              onTap: onTransferHost ?? () {},
              color: Colors.yellow,
            ),

          const SizedBox(height: 8),
        ],

        // Moderation actions (available to hosts and moderators)
        if (isCurrentUserHost || member.role == MemberRole.moderator) ...[
          _buildMemberActionButton(
            icon: member.isMuted ? Icons.volume_up_rounded : Icons.volume_off_rounded,
            label: member.isMuted ? 'Unmute User' : 'Mute User',
            onTap: onMuteMember,
            color: member.isMuted ? Colors.green : Colors.orange,
          ),
        ],

        // Remove member (host only)
        if (isCurrentUserHost && !member.isHost)
          _buildMemberActionButton(
            icon: Icons.person_remove_rounded,
            label: 'Remove from Room',
            onTap: onRemoveMember,
            color: Colors.red,
            isDanger: true,
          ),
      ],
    );
  }

  Widget _buildMemberActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color color = Colors.white,
    bool isDanger = false,
  }) {
    return ListTile(
      dense: true,
      leading: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: isDanger ? Colors.red : color,
          size: 18,
        ),
      ),
      title: Text(
        label,
        style: TextStyle(
          color: isDanger ? Colors.red : Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
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

  Color _getRoleColor(MemberRole role) {
    switch (role) {
      case MemberRole.admin:
        return Colors.yellow;
      case MemberRole.moderator:
        return Colors.green;
      case MemberRole.speaker:
        return Colors.blue;
      case MemberRole.listener:
        return Colors.grey;
    }
  }

  Color _getStatusColor(RoomMember member) {
    if (member.isSpeaking) return Colors.green;
    if (member.isHandRaised) return Colors.orange;
    if (member.isActive) return Colors.blue;
    return Colors.grey;
  }
}