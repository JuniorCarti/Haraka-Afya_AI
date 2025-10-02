import 'package:flutter/material.dart';
import '../models/room_member.dart';

class MemberSeat extends StatelessWidget {
  final RoomMember member;
  final VoidCallback onTap;

  const MemberSeat({super.key, required this.member, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        child: Column(
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: member.isSpeaking
                      ? [const Color(0xFF4CAF50), const Color(0xFF45a049)]
                      : [Colors.grey.shade800, Colors.grey.shade600],
                ),
                boxShadow: [
                  BoxShadow(
                    color: member.isSpeaking
                        ? Colors.green.withOpacity(0.3)
                        : Colors.black.withOpacity(0.3),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ],
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
                  if (member.isSpeaking)
                    Positioned(
                      bottom: 2,
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: const BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.mic_rounded, size: 8, color: Colors.white),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Text(
              member.name,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
                fontSize: 11,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              member.role,
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 9,
              ),
            ),
          ],
        ),
      ),
    );
  }
}