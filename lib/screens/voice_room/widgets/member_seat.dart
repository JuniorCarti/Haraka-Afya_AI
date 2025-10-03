import 'package:flutter/material.dart';
import '../models/room_member.dart';

class MemberSeat extends StatelessWidget {
  final RoomMember member;
  final VoidCallback onTap;
  final bool isCurrentUser;

  const MemberSeat({
    super.key, 
    required this.member,
    required this.onTap,
    this.isCurrentUser = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        child: Column(
          children: [
            // Member avatar with status indicators
            Stack(
              children: [
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: _getMemberGradient(member),
                    boxShadow: [
                      BoxShadow(
                        color: _getMemberGlowColor(member),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ],
                    border: Border.all(
                      color: _getMemberBorderColor(member),
                      width: 2,
                    ),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Icon(
                        Icons.chair_rounded,
                        color: Colors.white.withOpacity(0.3),
                        size: 28,
                      ),
                      Positioned.fill(
                        child: CircleAvatar(
                          backgroundColor: Colors.transparent,
                          child: Text(
                            member.avatar,
                            style: const TextStyle(fontSize: 20),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Speaking indicator
                if (member.isSpeaking)
                  Positioned(
                    bottom: 2,
                    right: 2,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.mic_rounded, size: 8, color: Colors.white),
                    ),
                  ),
                
                // Hand raised indicator
                if (member.isHandRaised)
                  Positioned(
                    top: 2,
                    left: 2,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        color: Colors.orange,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.front_hand_rounded, size: 8, color: Colors.white),
                    ),
                  ),
                
                // Muted indicator
                if (member.isMuted)
                  Positioned(
                    top: 2,
                    right: 2,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.volume_off_rounded, size: 8, color: Colors.white),
                    ),
                  ),
                
                // Current user indicator
                if (isCurrentUser)
                  Positioned(
                    bottom: 2,
                    left: 2,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.person_rounded, size: 8, color: Colors.white),
                    ),
                  ),
                
                // Role badge
                Positioned(
                  top: -2,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          member.roleBadge,
                          style: const TextStyle(fontSize: 8),
                        ),
                        if (member.level >= 5)
                          Padding(
                            padding: const EdgeInsets.only(left: 2),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 1),
                              decoration: BoxDecoration(
                                color: _getLevelColor(member.level),
                                borderRadius: BorderRadius.circular(2),
                              ),
                              child: Text(
                                '${member.level}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 6,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 6),
            
            // Username and info
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          member.username,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                            fontSize: 11,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (member.level >= 3 && member.level < 5)
                        Padding(
                          padding: const EdgeInsets.only(left: 2),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 1),
                            decoration: BoxDecoration(
                              color: _getLevelColor(member.level),
                              borderRadius: BorderRadius.circular(2),
                            ),
                            child: Text(
                              'L${member.level}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 6,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  
                  Text(
                    member.roleDisplayName,
                    style: TextStyle(
                      color: _getRoleTextColor(member.role),
                      fontSize: 9,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  
                  // Achievement title for high-level users
                  if (member.level >= 5)
                    Text(
                      member.getAchievementTitle(),
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 8,
                        fontStyle: FontStyle.italic,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Gradient _getMemberGradient(RoomMember member) {
    if (member.isHost) {
      return const LinearGradient(
        colors: [Color(0xFFFFD700), Color(0xFFFFEC8B)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    } else if (member.isModerator) {
      return const LinearGradient(
        colors: [Color(0xFF4CAF50), Color(0xFF45a049)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    } else if (member.isSpeaking) {
      return const LinearGradient(
        colors: [Color(0xFF2196F3), Color(0xFF1976D2)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    } else {
      return LinearGradient(
        colors: [Colors.grey.shade800, Colors.grey.shade600],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    }
  }

  Color _getMemberGlowColor(RoomMember member) {
    if (member.isHost) {
      return Colors.yellow.withOpacity(0.4);
    } else if (member.isModerator) {
      return Colors.green.withOpacity(0.4);
    } else if (member.isSpeaking) {
      return Colors.blue.withOpacity(0.4);
    } else if (member.isHandRaised) {
      return Colors.orange.withOpacity(0.4);
    } else {
      return Colors.black.withOpacity(0.3);
    }
  }

  Color _getMemberBorderColor(RoomMember member) {
    if (member.isHost) {
      return Colors.yellow.shade300;
    } else if (member.isModerator) {
      return Colors.green.shade300;
    } else if (member.isSpeaking) {
      return Colors.blue.shade300;
    } else if (member.level >= 10) {
      return Colors.purple.shade300;
    } else if (member.level >= 5) {
      return Colors.blue.shade300;
    } else {
      return Colors.transparent;
    }
  }

  Color _getRoleTextColor(MemberRole role) {
    switch (role) {
      case MemberRole.admin:
        return Colors.yellow;
      case MemberRole.moderator:
        return Colors.green.shade300;
      case MemberRole.speaker:
        return Colors.blue.shade300;
      case MemberRole.listener:
        return Colors.white.withOpacity(0.6);
    }
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