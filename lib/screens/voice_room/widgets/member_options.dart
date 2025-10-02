import 'package:flutter/material.dart';
import '../models/room_member.dart';

class MemberOptions extends StatelessWidget {
  final RoomMember member;
  final VoidCallback onSendGift;
  final VoidCallback onRemoveMember;
  final VoidCallback onMuteMember;

  const MemberOptions({
    super.key,
    required this.member,
    required this.onSendGift,
    required this.onRemoveMember,
    required this.onMuteMember,
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
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.white.withOpacity(0.1),
                  child: Text(member.avatar, style: const TextStyle(fontSize: 20)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        member.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        member.role,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
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
              ],
            ),
            const SizedBox(height: 20),
            _buildMemberActionButton(
              icon: Icons.card_giftcard_rounded,
              label: 'Send Gift',
              onTap: onSendGift,
            ),
            _buildMemberActionButton(
              icon: Icons.person_remove_rounded,
              label: 'Remove from Room',
              onTap: onRemoveMember,
              isDanger: true,
            ),
            _buildMemberActionButton(
              icon: Icons.volume_off_rounded,
              label: 'Mute User',
              onTap: onMuteMember,
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildMemberActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isDanger = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDanger ? Colors.red : Colors.white,
        size: 20,
      ),
      title: Text(
        label,
        style: TextStyle(
          color: isDanger ? Colors.red : Colors.white,
          fontSize: 14,
        ),
      ),
      onTap: onTap,
    );
  }
}