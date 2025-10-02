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
