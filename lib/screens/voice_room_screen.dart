import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
import 'package:haraka_afya_ai/screens/voice_room/services/firebase_room_service.dart';
import 'package:haraka_afya_ai/screens/voice_room/widgets/room_header.dart';
import 'package:haraka_afya_ai/screens/voice_room/widgets/host_seat.dart';
import 'package:haraka_afya_ai/screens/voice_room/widgets/member_seat.dart';
import 'package:haraka_afya_ai/screens/voice_room/widgets/empty_seat.dart';
import 'package:haraka_afya_ai/screens/voice_room/widgets/chat_section.dart';
import 'package:haraka_afya_ai/screens/voice_room/widgets/bottom_controls.dart';

class VoiceRoomScreen extends StatefulWidget {
  final String roomId;

  const VoiceRoomScreen({super.key, required this.roomId});

  @override
  State<VoiceRoomScreen> createState() => _VoiceRoomScreenState();
}

class _VoiceRoomScreenState extends State<VoiceRoomScreen> {
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
  
  // Firebase service and state
  final FirebaseRoomService _roomService = FirebaseRoomService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // User data
  String _currentUserId = '';
  String _currentUsername = 'Loading...';
  int _currentUserLevel = 1;
  bool _isHost = false;
  bool _isMuted = false;
  
  // Background state
  RoomBackground _currentBackground = RoomBackground.defaultBackgrounds.first;
  final List<RoomBackground> _availableBackgrounds = RoomBackground.defaultBackgrounds;

  @override
  void initState() {
    super.initState();
    _initializeUserAndRoom();
  }

  void _initializeUserAndRoom() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        _currentUserId = user.uid;
        
        // Get or create random username
        _currentUsername = await _roomService.getOrCreateUsername(_currentUserId);
        
        // Check if user is host (first user to join becomes host)
        _isHost = await _roomService.isRoomHost(widget.roomId, _currentUserId);
        
        // Create room member with random username
        final member = RoomMember(
          id: _currentUserId,
          name: _currentUsername,
          role: _isHost ? 'Host' : 'Listener',
          isSpeaking: _isHost, // Host starts speaking by default
          avatar: _isHost ? '👑' : '😊',
          points: 1200, // This would come from user profile in real app
          isHost: _isHost,
          level: _currentUserLevel,
          joinedAt: DateTime.now(),
          userId: _currentUserId,
        );

        // Join room in Firebase
        await _roomService.createOrJoinRoom(widget.roomId, member);
        
        setState(() {});
      } else {
        // Handle case where user is not authenticated
        _currentUsername = 'Guest';
      }
    } catch (e) {
      print('Error initializing room: $e');
      // Fallback to guest mode
      _currentUsername = 'Guest';
      _currentUserId = 'guest_${DateTime.now().millisecondsSinceEpoch}';
    }
  }

  void _sendChatMessage() {
    if (_chatController.text.trim().isNotEmpty) {
      final message = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        user: _currentUsername,
        userId: _currentUserId,
        message: _chatController.text.trim(),
        timestamp: DateTime.now(),
      );
      
      _roomService.sendChatMessage(widget.roomId, message);
      _chatController.clear();
    }
  }

  void _toggleMicrophone() async {
    setState(() {
      _isMuted = !_isMuted;
    });
    
    // Update speaking status in Firebase
    await _roomService.updateSpeakingStatus(
      widget.roomId, 
      _currentUserId, 
      !_isMuted
    );
  }

  void _changeBackground(RoomBackground background) async {
    try {
      await _roomService.updateRoomBackground(widget.roomId, background);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Room background changed to ${background.name}'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to change background: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showBackgroundMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return BackgroundSelector(
          backgrounds: _availableBackgrounds,
          currentBackground: _currentBackground,
          userLevel: _currentUserLevel,
          onBackgroundSelected: _changeBackground,
          onClose: () => Navigator.pop(context),
        );
      },
    );
  }

  void _showGiftMenuForUser(RoomMember member) {
    _showGiftMenu();
  }

  void _removeMember(RoomMember member) async {
    try {
      await _roomService.leaveRoom(widget.roomId, member.id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Removed ${member.name} from room'),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to remove member: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _muteMember(RoomMember member) async {
    try {
      await _roomService.updateSpeakingStatus(widget.roomId, member.id, false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${member.name} has been muted'),
          backgroundColor: Colors.orange,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to mute member: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Placeholder methods
  void _showRoomInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Room Information'),
        content: const Text('This is a support room for mental health discussions. Be kind and respectful to all members.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showRoomOptions() {
    // TODO: Implement room options menu
  }

  void _joinSeat() async {
    // When joining a seat, user becomes a speaker
    try {
      await _roomService.updateSpeakingStatus(widget.roomId, _currentUserId, true);
      setState(() {
        _isMuted = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to join seat: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _leaveRoom() async {
    try {
      await _roomService.leaveRoom(widget.roomId, _currentUserId);
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error leaving room: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
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
    // Don't show options for yourself
    if (member.userId == _currentUserId) return;

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
            onPressed: _leaveRoom,
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
      body: StreamBuilder<RoomBackground>(
        stream: _roomService.getRoomBackgroundStream(widget.roomId),
        builder: (context, backgroundSnapshot) {
          final currentBackground = backgroundSnapshot.data ?? _currentBackground;
          _currentBackground = currentBackground;

          return Container(
            decoration: currentBackground.imageUrl.isNotEmpty
                ? BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(currentBackground.imageUrl),
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
                // Room Header with real-time members
                StreamBuilder<List<RoomMember>>(
                  stream: _roomService.getRoomMembersStream(widget.roomId),
                  builder: (context, membersSnapshot) {
                    final members = membersSnapshot.data ?? [];
                    return RoomHeader(
                      members: members,
                      onBackgroundChange: _showBackgroundMenu,
                      hostLevel: _currentUserLevel,
                    );
                  },
                ),
                
                // Room Layout with real-time members
                Expanded(
                  child: _buildRoomLayout(),
                ),
                
                // Chat Section with real-time messages
                StreamBuilder<List<ChatMessage>>(
                  stream: _roomService.getChatMessagesStream(widget.roomId),
                  builder: (context, messagesSnapshot) {
                    final messages = messagesSnapshot.data ?? [];
                    return ChatSection(
                      chatMessages: messages,
                      chatController: _chatController,
                      onSendMessage: _sendChatMessage,
                    );
                  },
                ),
                
                // Bottom Controls
                BottomControls(
                  isMuted: _isMuted,
                  onToggleMicrophone: _toggleMicrophone,
                  onShowGamesMenu: _showGamesMenu,
                  onShowGiftMenu: _showGiftMenu,
                  onShowBackgroundMenu: _showBackgroundMenu,
                  onLeaveRoom: _leaveRoom,
                  isHost: _isHost,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildRoomLayout() {
    return StreamBuilder<List<RoomMember>>(
      stream: _roomService.getRoomMembersStream(widget.roomId),
      builder: (context, snapshot) {
        final members = snapshot.data ?? [];
        
        // Find host or use first member as fallback
        final host = members.firstWhere(
          (member) => member.isHost, 
          orElse: () => members.isNotEmpty ? members.first : RoomMember(
            id: '',
            name: 'Loading...',
            role: 'Host',
            isSpeaking: false,
            avatar: '👑',
            points: 0,
            isHost: true,
            level: 1,
            joinedAt: DateTime.now(),
            userId: '',
          )
        );

        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              HostSeat(host: host),
              const SizedBox(height: 24),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.9,
                  ),
                  itemCount: 9, // 9 total seats
                  itemBuilder: (context, index) {
                    if (index < members.length) {
                      final member = members[index];
                      return MemberSeat(
                        member: member,
                        onTap: () => _showMemberOptions(member),
                      );
                    } else {
                      return EmptySeat(
                        seatNumber: index + 1,
                        onTap: _joinSeat,
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _chatController.dispose();
    super.dispose();
  }
}