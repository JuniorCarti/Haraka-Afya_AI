import 'package:flutter/material.dart';
import '../models/room_member.dart';

class RoomHeader extends StatelessWidget {
  final List<RoomMember> members;
  final VoidCallback onBackgroundChange;
  final int hostLevel;

  const RoomHeader({
    super.key,
    required this.members,
    required this.onBackgroundChange,
    required this.hostLevel,
  });

  @override
  Widget build(BuildContext context) {
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
          // Live badge
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
                const Text(
                  'LIVE',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Members count
          const Icon(Icons.people_alt_rounded, color: Colors.white54, size: 16),
          const SizedBox(width: 4),
          Text(
            '${members.length}/9',
            style: const TextStyle(color: Colors.white54, fontSize: 12),
          ),
          const SizedBox(width: 8),
          // Host level
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue),
            ),
            child: Row(
              children: [
                const Icon(Icons.star_rounded, color: Colors.blue, size: 12),
                const SizedBox(width: 4),
                Text(
                  'Lvl $hostLevel',
                  style: const TextStyle(
                    color: Colors.blue,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Room topic
          Expanded(
            child: Text(
              'Mental Health Support • Games • Chat',
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 12,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          // Background change button (only for host)
          if (members.any((member) => member.isHost && member.name == 'You'))
            IconButton(
              icon: const Icon(Icons.wallpaper_rounded, color: Colors.white54, size: 20),
              onPressed: onBackgroundChange,
              tooltip: 'Change Room Background',
            ),
        ],
      ),
    );
  }
}