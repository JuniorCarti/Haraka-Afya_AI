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
    this.isCurrentUser = false, void Function()? onLeaveSeat,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(4),
      child: GestureDetector(
        onTap: onTap,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Member Avatar with Status Indicators
                _buildMemberAvatar(),
                const SizedBox(height: 6),
                
                // User Information
                _buildUserInfo(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMemberAvatar() {
    return SizedBox(
      width: 68,
      height: 68,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Main Avatar Container
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: _getMemberGradient(member),
              boxShadow: [
                BoxShadow(
                  color: _getMemberGlowColor(member),
                  blurRadius: 6,
                  spreadRadius: 1,
                  offset: const Offset(0, 2),
                ),
              ],
              border: Border.all(
                color: _getMemberBorderColor(member),
                width: 2,
              ),
            ),
            child: Center(
              child: Text(
                member.avatar,
                style: const TextStyle(fontSize: 20),
              ),
            ),
          ),
          
          // Role Badge - Top Center
          Positioned(
            top: -2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.85),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _getMemberBorderColor(member).withOpacity(0.6),
                  width: 0.5,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    member.roleBadge,
                    style: const TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  if (member.level >= 5) ...[
                    const SizedBox(width: 2),
                    Container(
                      width: 2,
                      height: 2,
                      decoration: BoxDecoration(
                        color: _getLevelColor(member.level),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 2),
                    Text(
                      'L${member.level}',
                      style: TextStyle(
                        color: _getLevelColor(member.level),
                        fontSize: 7,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          
          // Speaking Indicator - Bottom Right
          if (member.isSpeaking)
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                width: 14,
                height: 14,
                decoration: const BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 2,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.mic_rounded,
                  size: 8,
                  color: Colors.white,
                ),
              ),
            ),
          
          // Hand Raised Indicator - Top Left
          if (member.isHandRaised)
            Positioned(
              top: 0,
              left: 0,
              child: Container(
                width: 14,
                height: 14,
                decoration: const BoxDecoration(
                  color: Colors.orange,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 2,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.front_hand_rounded,
                  size: 8,
                  color: Colors.white,
                ),
              ),
            ),
          
          // Muted Indicator - Top Right
          if (member.isMuted && !member.isSpeaking)
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                width: 14,
                height: 14,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 2,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.volume_off_rounded,
                  size: 8,
                  color: Colors.white,
                ),
              ),
            ),
          
          // Current User Indicator - Bottom Left
          if (isCurrentUser)
            Positioned(
              bottom: 0,
              left: 0,
              child: Container(
                width: 14,
                height: 14,
                decoration: const BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 2,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.person_rounded,
                  size: 8,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildUserInfo() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.black.withOpacity(0.7),
            Colors.black.withOpacity(0.4),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(10),
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
                  member.username,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 10,
                    height: 1.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
              if (member.level >= 3 && member.level < 5) ...[
                const SizedBox(width: 3),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                  decoration: BoxDecoration(
                    color: _getLevelColor(member.level),
                    borderRadius: BorderRadius.circular(3),
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
              ],
            ],
          ),
          
          const SizedBox(height: 2),
          
          // Role Display
          Text(
            member.roleDisplayName.toUpperCase(),
            style: TextStyle(
              color: _getRoleTextColor(member.role),
              fontSize: 8,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          
          // Achievement Title for High-Level Users
          if (member.level >= 5)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                member.getAchievementTitle(),
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 7,
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

  Gradient _getMemberGradient(RoomMember member) {
    if (member.isHost) {
      return const LinearGradient(
        colors: [Color(0xFFFFD700), Color(0xFFFFA000)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    } else if (member.isModerator) {
      return const LinearGradient(
        colors: [Color(0xFF4CAF50), Color(0xFF388E3C)],
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
        colors: [
          Colors.grey.shade700,
          Colors.grey.shade500,
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    }
  }

  Color _getMemberGlowColor(RoomMember member) {
    if (member.isHost) {
      return Colors.amber.withOpacity(0.4);
    } else if (member.isModerator) {
      return Colors.green.withOpacity(0.4);
    } else if (member.isSpeaking) {
      return Colors.blue.withOpacity(0.4);
    } else if (member.isHandRaised) {
      return Colors.orange.withOpacity(0.4);
    } else {
      return Colors.black.withOpacity(0.2);
    }
  }

  Color _getMemberBorderColor(RoomMember member) {
    if (member.isHost) {
      return Colors.amber.shade400;
    } else if (member.isModerator) {
      return Colors.green.shade400;
    } else if (member.isSpeaking) {
      return Colors.blue.shade400;
    } else if (member.level >= 10) {
      return Colors.purple.shade400;
    } else if (member.level >= 5) {
      return Colors.blue.shade400;
    } else {
      return Colors.transparent;
    }
  }

  Color _getRoleTextColor(MemberRole role) {
    switch (role) {
      case MemberRole.admin:
        return Colors.amber;
      case MemberRole.moderator:
        return Colors.green.shade300;
      case MemberRole.speaker:
        return Colors.blue.shade300;
      case MemberRole.listener:
        return Colors.white.withOpacity(0.6);
    }
  }

  Color _getLevelColor(int level) {
    if (level >= 20) return const Color(0xFFE74C3C);
    if (level >= 15) return const Color(0xFFE67E22);
    if (level >= 10) return const Color(0xFF9B59B6);
    if (level >= 5) return const Color(0xFF3498DB);
    if (level >= 3) return const Color(0xFF2ECC71);
    return const Color(0xFF95A5A6);
  }
}