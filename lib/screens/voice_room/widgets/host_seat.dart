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
    return GestureDetector(
      onTap: onHostTap,
      child: SizedBox(
        width: 100,
        height: 140,
        child: Column(
          children: [
            // Host avatar with crown
            Stack(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFFD700), Color(0xFFFFEC8B)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.yellow.withOpacity(0.4),
                        blurRadius: 15,
                        spreadRadius: 2,
                      ),
                    ],
                    border: Border.all(
                      color: Colors.yellow.shade300,
                      width: 2,
                    ),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      const Icon(Icons.chair_rounded, color: Colors.white, size: 30),
                      Positioned.fill(
                        child: CircleAvatar(
                          backgroundColor: Colors.transparent,
                          child: Text(
                            host.avatar,
                            style: const TextStyle(fontSize: 24),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Crown badge
                Positioned(
                  top: -2,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Colors.yellow,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.workspace_premium_rounded, size: 14, color: Colors.black),
                  ),
                ),
                // Speaking indicator
                if (host.isSpeaking)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.mic, size: 12, color: Colors.white),
                    ),
                  ),
                // Current user indicator
                if (isCurrentUser)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.person, size: 12, color: Colors.white),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            
            // Username with level badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        host.username,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(width: 4),
                      // Level badge
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
                  
                  // Role and title
                  Text(
                    host.roleDisplayName,
                    style: TextStyle(
                      color: Colors.yellow.shade300,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  
                  // Achievement title
                  if (host.level >= 3)
                    Text(
                      host.getAchievementTitle(),
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 8,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                ],
              ),
            ),
            
            // Activity status
            Container(
              margin: const EdgeInsets.only(top: 4),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: _getStatusColor(host),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                host.activityStatus.toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
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

  Color _getStatusColor(RoomMember member) {
    if (member.isSpeaking) return Colors.green;
    if (member.isHandRaised) return Colors.orange;
    if (member.isActive) return Colors.blue;
    return Colors.grey;
  }
}