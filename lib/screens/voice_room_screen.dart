import 'package:flutter/material.dart';
import 'package:haraka_afya_ai/widgets/app_drawer.dart';

class VoiceRoomScreen extends StatefulWidget {
  const VoiceRoomScreen({super.key});

  @override
  State<VoiceRoomScreen> createState() => _VoiceRoomScreenState();
}
class _VoiceRoomScreenState extends State<VoiceRoomScreen> {
  final List<RoomMember> _members = [];
  final List<RoomGame> _availableGames = [
    RoomGame('Pool Billiard', Icons.sports, Colors.green),
    RoomGame('Sudoku', Icons.grid_4x4, Colors.blue),
    RoomGame('Roll Dice', Icons.casino, Colors.orange),
    RoomGame('Chess', Icons.extension, Colors.brown),
    RoomGame('Cards', Icons.style, Colors.red),
    RoomGame('Word Game', Icons.text_fields, Colors.purple),
  ];
final List<Gift> _availableGifts = [
    Gift('Rose', '🌹', 10, Colors.red),
    Gift('Crown', '👑', 100, Colors.yellow),
    Gift('Star', '⭐', 50, Colors.blue),
    Gift('Heart', '💖', 20, Colors.pink),
    Gift('Trophy', '🏆', 200, Colors.orange),
    Gift('Diamond', '💎', 500, Colors.cyan),
  ];
@override
  void initState() {
    super.initState();
    _initializeRoom();
  }

  void _initializeRoom() {
    // Add admin
    _members.add(RoomMember(
      name: 'You',
      role: 'Admin',
      isSpeaking: true,
      avatar: '👑',
      points: 1200,
    ));
    // Add some sample members
    _members.addAll([
      RoomMember(name: 'Alex', role: 'Speaker', isSpeaking: true, avatar: '😊', points: 800),
      RoomMember(name: 'Sam', role: 'Speaker', isSpeaking: true, avatar: '🎤', points: 650),
      RoomMember(name: 'Jordan', role: 'Listener', isSpeaking: false, avatar: '👂', points: 450),
      RoomMember(name: 'Taylor', role: 'Listener', isSpeaking: false, avatar: '🌟', points: 300),
      RoomMember(name: 'Casey', role: 'Listener', isSpeaking: false, avatar: '🎧', points: 200),
    ]);
  }

@override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: AppBar(
          title: const Text(
            'Support Room',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          centerTitle: true,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFD8FBE5), Color(0xFFE3F2FD)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          elevation: 2,
          actions: [
            IconButton(
              icon: const Icon(Icons.people_alt, color: Colors.black),
              onPressed: _showRoomInfo,
            ),
            IconButton(
              icon: const Icon(Icons.more_vert, color: Colors.black),
              onPressed: _showRoomOptions,
            ),
          ],
        ),
      ),
      drawer: const AppDrawer(),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1a2b3c), Color(0xFF0d1b2a)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            // Room header with info
            _buildRoomHeader(),
            
            // Main room layout with seats
            Expanded(
              child: _buildRoomLayout(),
            ),
            
            // Bottom controls
            _buildBottomControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildRoomHeader() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        border: Border(
          bottom: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
      ),
      child: Row(
        children: [
          // Room status
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.green),
            ),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                const Text(
                  'LIVE',
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Room members count
          const Icon(Icons.people_outline, color: Colors.white54, size: 16),
          const SizedBox(width: 4),
          Text(
            '${_members.length}/9',
            style: const TextStyle(color: Colors.white54, fontSize: 12),
          ),
          const SizedBox(width: 16),
          // Room topic
          Expanded(
            child: Text(
              'Mental Health Support & Games',
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 12,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
