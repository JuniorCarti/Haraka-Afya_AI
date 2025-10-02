import 'package:flutter/material.dart';
import 'package:haraka_afya_ai/screens/voice_room/widgets/game_card.dart';
import 'package:haraka_afya_ai/screens/voice_room/widgets/gift_card.dart';
import 'package:haraka_afya_ai/screens/voice_room/widgets/member_options.dart';
import 'package:haraka_afya_ai/screens/voice_room/widgets/background_selector.dart';
import 'package:haraka_afya_ai/widgets/app_drawer.dart';
import 'package:haraka_afya_ai/screens/voice_room/models/room_member.dart';
import 'package:haraka_afya_ai/screens/voice_room/models/room_game.dart';
import 'package:haraka_afya_ai/screens/voice_room/models/gift.dart';
import 'package:haraka_afya_ai/screens/voice_room/models/chat_message.dart';
import 'package:haraka_afya_ai/screens/voice_room/models/room_background.dart';
import 'package:haraka_afya_ai/screens/voice_room/widgets/room_header.dart';
import 'package:haraka_afya_ai/screens/voice_room/widgets/host_seat.dart';
import 'package:haraka_afya_ai/screens/voice_room/widgets/member_seat.dart';
import 'package:haraka_afya_ai/screens/voice_room/widgets/empty_seat.dart';
import 'package:haraka_afya_ai/screens/voice_room/widgets/chat_section.dart';
import 'package:haraka_afya_ai/screens/voice_room/widgets/bottom_controls.dart';

class VoiceRoomScreen extends StatefulWidget {
  const VoiceRoomScreen({super.key});

  @override
  State<VoiceRoomScreen> createState() => _VoiceRoomScreenState();
}

class _VoiceRoomScreenState extends State<VoiceRoomScreen> {
  final List<RoomMember> _members = [];
  final List<RoomGame> _availableGames = [
    RoomGame('Pool', Icons.sports, Colors.green),
    RoomGame('Sudoku', Icons.grid_4x4, Colors.blue),
    RoomGame('Dice', Icons.casino, Colors.orange),
    RoomGame('Chess', Icons.extension, Colors.brown),
    RoomGame('Cards', Icons.style, Colors.red),
    RoomGame('Words', Icons.text_fields, Colors.purple),
  ];

  final List<Gift> _availableGifts = [
    Gift('Rose', '🌹', 10, Colors.red),
    Gift('Crown', '👑', 100, Colors.yellow),
    Gift('Star', '⭐', 50, Colors.blue),
    Gift('Heart', '💖', 20, Colors.pink),
    Gift('Trophy', '🏆', 200, Colors.orange),
    Gift('Diamond', '💎', 500, Colors.cyan),
  ];

  final TextEditingController _chatController = TextEditingController();
  final List<ChatMessage> _chatMessages = [];
  bool _isMuted = false;
  
  // Background state
  RoomBackground _currentBackground = RoomBackground.defaultBackgrounds.first;
  final List<RoomBackground> _availableBackgrounds = RoomBackground.defaultBackgrounds;

  @override
  void initState() {
    super.initState();
    _initializeRoom();
    _initializeSampleChat();
  }

  void _initializeRoom() {
    // Add admin (with level)
    _members.add(RoomMember(
      name: 'You',
      role: 'Host',
      isSpeaking: true,
      avatar: '👑',
      points: 1200,
      isHost: true,
      level: 12, // Example level
    ));
    
    // Add some sample members (with levels)
    _members.addAll([
      RoomMember(name: 'Alex', role: 'Speaker', isSpeaking: true, avatar: '😊', points: 800, isHost: false, level: 8),
      RoomMember(name: 'Sam', role: 'Speaker', isSpeaking: true, avatar: '🎤', points: 650, isHost: false, level: 6),
      RoomMember(name: 'Jordan', role: 'Listener', isSpeaking: false, avatar: '👂', points: 450, isHost: false, level: 4),
      RoomMember(name: 'Taylor', role: 'Listener', isSpeaking: false, avatar: '🌟', points: 300, isHost: false, level: 3),
      RoomMember(name: 'Casey', role: 'Listener', isSpeaking: false, avatar: '🎧', points: 200, isHost: false, level: 2),
    ]);
  }

  void _initializeSampleChat() {
    _chatMessages.addAll([
      ChatMessage(user: 'Alex', message: 'Hello everyone! 👋', time: '2 min ago'),
      ChatMessage(user: 'Sam', message: 'Great to be here!', time: '1 min ago'),
      ChatMessage(user: 'Jordan', message: 'Thanks for the support 💚', time: 'Just now'),
    ]);
  }

  // Background change method
  void _changeBackground(RoomBackground background) {
    setState(() {
      _currentBackground = background;
    });
    Navigator.pop(context); // Close the background selector
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Room background changed to ${background.name}'),
        backgroundColor: Colors.green,
      ),
    );
  }

  // Show background selector
  void _showBackgroundMenu() {
    final host = _members.firstWhere((member) => member.isHost && member.name == 'You');
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return BackgroundSelector(
          backgrounds: _availableBackgrounds,
          currentBackground: _currentBackground,
          userLevel: host.level,
          onBackgroundSelected: _changeBackground,
          onClose: () => Navigator.pop(context),
        );
      },
    );
  }

  void _sendChatMessage() {
    if (_chatController.text.trim().isNotEmpty) {
      setState(() {
        _chatMessages.add(ChatMessage(
          user: 'You',
          message: _chatController.text.trim(),
          time: 'Just now',
        ));
        _chatController.clear();
      });
    }
  }

  void _toggleMicrophone() {
    setState(() {
      _isMuted = !_isMuted;
    });
  }

  void _showGiftMenuForUser(RoomMember member) {
    _showGiftMenu();
  }

  void _removeMember(RoomMember member) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Removed ${member.name} from room'),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _muteMember(RoomMember member) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${member.name} has been muted'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  // Placeholder methods
  void _showRoomInfo() {
    // TODO: Implement room info dialog
  }

  void _showRoomOptions() {
    // TODO: Implement room options menu
  }

  void _joinSeat() {
    // TODO: Implement join seat functionality
  }

  void _leaveRoom() {
    // TODO: Implement leave room functionality
  }

  void _startGame(RoomGame game) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Starting ${game.name}...'),
        backgroundColor: Colors.green,
      ),
    );
    Navigator.pop(context);
  }

  void _sendGiftToRoom(Gift gift) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Sent ${gift.emoji} ${gift.name} to the room!'),
        backgroundColor: Colors.pink,
      ),
    );
    Navigator.pop(context);
  }

  void _showGamesMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.6,
          decoration: const BoxDecoration(
            color: Color(0xFF1A1A1A),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Choose a Game',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.3,
                  ),
                  itemCount: _availableGames.length,
                  itemBuilder: (context, index) {
                    final game = _availableGames[index];
                    return GameCard(
                      game: game,
                      onTap: () => _startGame(game),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showGiftMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.7,
          decoration: const BoxDecoration(
            color: Color(0xFF1A1A1A),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Send a Gift',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.yellow.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.yellow),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.emoji_events_rounded, color: Colors.yellow, size: 16),
                    const SizedBox(width: 8),
                    const Text(
                      'Your Points: ',
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                    Text(
                      '1200',
                      style: const TextStyle(
                        color: Colors.yellow,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.9,
                  ),
                  itemCount: _availableGifts.length,
                  itemBuilder: (context, index) {
                    final gift = _availableGifts[index];
                    return GiftCard(
                      gift: gift,
                      onTap: () => _sendGiftToRoom(gift),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showMemberOptions(RoomMember member) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return MemberOptions(
          member: member,
          onSendGift: () {
            Navigator.pop(context);
            _showGiftMenuForUser(member);
          },
          onRemoveMember: () {
            Navigator.pop(context);
            _removeMember(member);
          },
          onMuteMember: () {
            Navigator.pop(context);
            _muteMember(member);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final host = _members.firstWhere((member) => member.isHost && member.name == 'You');
    
    return Scaffold(
      backgroundColor: _currentBackground.primaryColor,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: AppBar(
          title: const Text(
            'Support Room',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: 18,
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.people_alt_rounded, color: Colors.white54, size: 22),
              onPressed: _showRoomInfo,
            ),
            IconButton(
              icon: const Icon(Icons.more_vert_rounded, color: Colors.white54, size: 22),
              onPressed: _showRoomOptions,
            ),
          ],
        ),
      ),
      drawer: const AppDrawer(),
      body: Container(
        decoration: _currentBackground.imageUrl.isNotEmpty
            ? BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(_currentBackground.imageUrl),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    Colors.black.withOpacity(0.3),
                    BlendMode.darken,
                  ),
                ),
              )
            : null,
        child: Column(
          children: [
            RoomHeader(
              members: _members,
              onBackgroundChange: _showBackgroundMenu,
              hostLevel: host.level,
            ),
            
            Expanded(
              child: _buildRoomLayout(),
            ),
            
            ChatSection(
              chatMessages: _chatMessages,
              chatController: _chatController,
              onSendMessage: _sendChatMessage,
            ),
            
            BottomControls(
              isMuted: _isMuted,
              onToggleMicrophone: _toggleMicrophone,
              onShowGamesMenu: _showGamesMenu,
              onShowGiftMenu: _showGiftMenu,
              onShowBackgroundMenu: _showBackgroundMenu,
              onLeaveRoom: _leaveRoom,
              isHost: host.name == 'You',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoomLayout() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          HostSeat(host: _members.firstWhere((member) => member.isHost)),
          const SizedBox(height: 24),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.9,
              ),
              itemCount: 9,
              itemBuilder: (context, index) {
                if (index < _members.length - 1) {
                  final member = _members[index + 1];
                  return MemberSeat(
                    member: member,
                    onTap: () => _showMemberOptions(member),
                  );
                } else {
                  return EmptySeat(
                    seatNumber: index - _members.length + 2,
                    onTap: _joinSeat,
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}