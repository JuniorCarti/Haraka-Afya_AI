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
  UserRole _currentUserRole = UserRole.user;
  bool _isMuted = false;
  
  // Room state
  String _roomName = 'Support Room';
  String _roomDescription = 'A safe space for support and conversation';
  String _welcomeMessage = 'Welcome to our support room! Feel free to share and connect.';
  
  // Background state
  RoomBackground _currentBackground = RoomBackground.defaultBackgrounds.first;
  final List<RoomBackground> _availableBackgrounds = RoomBackground.defaultBackgrounds;

  // Track if user is in room for chat behavior
  bool _isInRoom = true;

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
        
        // Get user achievements and level
        final achievements = await _roomService.getUserAchievements(_currentUserId);
        _currentUserLevel = achievements['level'] ?? 1;
        
        // Check if user is host (first user to join becomes host)
        final isHost = await _roomService.isRoomHost(widget.roomId, _currentUserId);
        _currentUserRole = isHost ? UserRole.admin : UserRole.user;
        
        // Get room information
        final roomInfo = await _roomService.getRoomInfo(widget.roomId);
        _roomName = roomInfo['name'] ?? 'Support Room';
        _roomDescription = roomInfo['description'] ?? 'A safe space for support and conversation';
        _welcomeMessage = roomInfo['welcomeMessage'] ?? 'Welcome to our support room!';

        // Get message color based on role and level
        final messageColor = await _roomService.getUserMessageColor(_currentUserId, _currentUserRole);

        // Create room member
        final member = RoomMember(
          id: _currentUserId,
          userId: _currentUserId,
          username: _currentUsername,
          role: isHost ? MemberRole.admin : MemberRole.listener,
          isSpeaking: isHost, // Host starts speaking by default
          avatar: isHost ? '👑' : '😊',
          points: achievements['points'] ?? 0,
          level: _currentUserLevel,
          joinedAt: DateTime.now(),
          lastActive: DateTime.now(),
          isMuted: false,
          isHandRaised: false,
          achievements: List<String>.from(achievements['badges'] ?? []),
          title: achievements['title'] ?? 'Newcomer',
          messageColor: messageColor,
          totalMessages: achievements['totalMessages'] ?? 0,
          roomsJoined: achievements['roomsJoined'] ?? 1,
          sessionId: 'current',
        );

        // Join room in Firebase
        await _roomService.createOrJoinRoom(widget.roomId, member);
        
        setState(() {
          _isInRoom = true;
        });
      } else {
        // Handle case where user is not authenticated
        _currentUsername = 'Guest';
        _currentUserId = 'guest_${DateTime.now().millisecondsSinceEpoch}';
        setState(() {
          _isInRoom = true;
        });
      }
    } catch (e) {
      print('Error initializing room: $e');
      // Fallback to guest mode
      _currentUsername = 'Guest';
      _currentUserId = 'guest_${DateTime.now().millisecondsSinceEpoch}';
      setState(() {
        _isInRoom = true;
      });
    }
  }

  void _sendChatMessage(ChatMessage message) {
    if (_isInRoom) {
      _roomService.sendChatMessage(widget.roomId, message);
    }
  }

  void _sendUserChatMessage() {
    if (_chatController.text.trim().isNotEmpty && _isInRoom) {
      final message = ChatMessage(
        id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
        roomId: widget.roomId,
        userId: _currentUserId,
        username: _currentUsername,
        text: _chatController.text.trim(),
        timestamp: DateTime.now(),
        userRole: _currentUserRole,
        userLevel: _currentUserLevel,
        messageColor: '', // Will be calculated by service
        isWelcomeMessage: false,
        sessionId: 'current',
      );
      
      _roomService.sendChatMessage(widget.roomId, message);
      _chatController.clear();
    }
  }

  void _toggleMicrophone() async {
    if (!_isInRoom) return;
    
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
    if (!_isInRoom) return;
    
    try {
      await _roomService.updateRoomBackground(widget.roomId, background);
      setState(() {
        _currentBackground = background;
      });
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

  void _updateRoomInfo({String? name, String? description, String? welcomeMessage}) async {
    if (!_isInRoom) return;
    
    try {
      await _roomService.updateRoomInfo(
        roomId: widget.roomId,
        name: name,
        description: description,
        welcomeMessage: welcomeMessage,
      );
      
      if (name != null) _roomName = name;
      if (description != null) _roomDescription = description;
      if (welcomeMessage != null) _welcomeMessage = welcomeMessage;
      
      setState(() {});
      Navigator.pop(context);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Room information updated successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update room info: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showBackgroundMenu() {
    if (!_isInRoom) return;
    
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

  void _showRoomInfoEdit() {
    if (!_isInRoom) return;
    
    showDialog(
      context: context,
      builder: (context) => RoomInfoEditDialog(
        roomName: _roomName,
        roomDescription: _roomDescription,
        welcomeMessage: _welcomeMessage,
        isHost: _currentUserRole == UserRole.admin,
        onSave: _updateRoomInfo,
      ),
    );
  }

  void _showGiftMenuForUser(RoomMember member) {
    if (!_isInRoom) return;
    _showGiftMenu();
  }

  void _removeMember(RoomMember member) async {
    if (!_isInRoom) return;
    
    try {
      await _roomService.leaveRoom(widget.roomId, member.id, member.username);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Removed ${member.username} from room'),
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
    if (!_isInRoom) return;
    
    try {
      await _roomService.updateSpeakingStatus(widget.roomId, member.id, false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${member.username} has been muted'),
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

  void _promoteToSpeaker(RoomMember member) async {
    if (!_isInRoom) return;
    
    try {
      await _roomService.updateMemberRole(widget.roomId, member.id, MemberRole.speaker);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Promoted ${member.username} to Speaker'),
          backgroundColor: Colors.blue,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to promote member: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _promoteToModerator(RoomMember member) async {
    if (!_isInRoom) return;
    
    try {
      await _roomService.updateMemberRole(widget.roomId, member.id, MemberRole.moderator);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Promoted ${member.username} to Moderator'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to promote member: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _demoteToListener(RoomMember member) async {
    if (!_isInRoom) return;
    
    try {
      await _roomService.updateMemberRole(widget.roomId, member.id, MemberRole.listener);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Demoted ${member.username} to Listener'),
          backgroundColor: Colors.grey,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to demote member: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _transferHostRole(RoomMember member) async {
    if (!_isInRoom) return;
    
    try {
      await _roomService.transferHostRole(widget.roomId, member.userId);
      setState(() {
        _currentUserRole = UserRole.moderator; // Current user becomes moderator
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Transferred host role to ${member.username}'),
          backgroundColor: Colors.yellow,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to transfer host role: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _joinSeat() async {
    if (!_isInRoom) return;
    
    // When joining a seat, user becomes a speaker
    try {
      await _roomService.updateSpeakingStatus(widget.roomId, _currentUserId, true);
      await _roomService.updateMemberRole(widget.roomId, _currentUserId, MemberRole.speaker);
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
    if (!_isInRoom) return;
    
    try {
      setState(() {
        _isInRoom = false;
      });
      
      await _roomService.leaveRoom(widget.roomId, _currentUserId, _currentUsername);
      
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
      // Revert state if leaving failed
      setState(() {
        _isInRoom = true;
      });
    }
  }

  void _startGame(RoomGame game) {
    if (!_isInRoom) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Starting ${game.name}...'),
        backgroundColor: Colors.green,
      ),
    );
    Navigator.pop(context);
  }

  void _sendGiftToRoom(Gift gift) {
    if (!_isInRoom) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Sent ${gift.emoji} ${gift.name} to the room!'),
        backgroundColor: Colors.pink,
      ),
    );
    Navigator.pop(context);
  }

  void _showGamesMenu() {
    if (!_isInRoom) return;
    
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
    if (!_isInRoom) return;
    
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
                      '1200', // This would come from user profile
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
    if (!_isInRoom) return;
    
    // Don't show options for yourself
    if (member.userId == _currentUserId) return;

    final isCurrentUserHost = _currentUserRole == UserRole.admin;
    final isCurrentUserModerator = _currentUserRole == UserRole.moderator || isCurrentUserHost;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return MemberOptions(
          member: member,
          isCurrentUserHost: isCurrentUserHost,
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
          onPromoteToSpeaker: isCurrentUserHost ? () {
            Navigator.pop(context);
            _promoteToSpeaker(member);
          } : () {},
          onPromoteToModerator: () {
            if (isCurrentUserHost) {
              Navigator.pop(context);
              _promoteToModerator(member);
            }
          },
          onDemoteToListener: (isCurrentUserHost || isCurrentUserModerator) ? () {
            Navigator.pop(context);
            _demoteToListener(member);
          } : () {},
          onTransferHost: isCurrentUserHost ? () {
            Navigator.pop(context);
            _transferHostRole(member);
          } : () {},
        );
      },
    );
  }

  // Add host switching functionality
  void _switchHostToSpeaker() async {
    if (!_isInRoom || _currentUserRole != UserRole.admin) return;
    
    try {
      await _roomService.switchHostToSpeaker(widget.roomId, _currentUserId);
      setState(() {
        _currentUserRole = UserRole.moderator;
        _isMuted = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Switched to speaker seat successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to switch to speaker: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _currentBackground.primaryColor,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: AppBar(
          title: Text(
            _isInRoom ? 'Support Room' : 'Left Room',
            style: const TextStyle(
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
          actions: _isInRoom ? [
            IconButton(
              icon: const Icon(Icons.info_outline_rounded, color: Colors.white54, size: 22),
              onPressed: _showRoomInfoEdit,
            ),
          ] : null,
        ),
      ),
      drawer: const AppDrawer(),
      body: SafeArea(
        child: StreamBuilder<RoomBackground>(
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
              child: Stack(
                children: [
                  // Main content area - seats take full screen
                  Positioned.fill(
                    child: _isInRoom ? _buildMainContent() : _buildLeftRoomState(),
                  ),
                  
                  // Chat Section - overlays at bottom without covering seats
                  Positioned(
                    bottom: 80, // Position above bottom controls
                    left: 0,
                    right: 0,
                    child: StreamBuilder<List<ChatMessage>>(
                      stream: _roomService.getChatMessagesStream(widget.roomId),
                      builder: (context, messagesSnapshot) {
                        final messages = messagesSnapshot.data ?? [];
                        return ChatSection(
                          chatMessages: messages,
                          chatController: _chatController,
                          onSendMessage: _sendChatMessage,
                          isAdmin: _currentUserRole == UserRole.admin,
                          onRoomInfoUpdate: (newName) {
                            _updateRoomInfo(name: newName);
                          },
                          currentRoomId: widget.roomId,
                          currentUserId: _currentUserId,
                          currentUsername: _currentUsername,
                          currentUserRole: _currentUserRole,
                          currentUserLevel: _currentUserLevel,
                          onSwitchToSpeaker: _currentUserRole == UserRole.admin ? _switchHostToSpeaker : null,
                        );
                      },
                    ),
                  ),
                  
                  // Bottom Controls - fixed at bottom
                  if (_isInRoom)
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: BottomControls(
                        isMuted: _isMuted,
                        onToggleMicrophone: _toggleMicrophone,
                        onShowGamesMenu: _showGamesMenu,
                        onShowGiftMenu: _showGiftMenu,
                        onShowBackgroundMenu: _showBackgroundMenu,
                        onLeaveRoom: _leaveRoom,
                        isHost: _currentUserRole == UserRole.admin,
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    return Column(
      children: [
        // Room Header with real-time members
        StreamBuilder<List<RoomMember>>(
          stream: _roomService.getRoomMembersStream(widget.roomId),
          builder: (context, membersSnapshot) {
            final members = membersSnapshot.data ?? [];
            
            // Handle empty members list safely
            if (members.isEmpty) {
              return RoomHeader(
                members: [],
                onBackgroundChange: _showBackgroundMenu,
                onRoomInfoEdit: _showRoomInfoEdit,
                roomName: _roomName,
                roomDescription: _roomDescription,
                isCurrentUserHost: _currentUserRole == UserRole.admin,
                activeSpeakersCount: 0,
              );
            }
            
            final activeSpeakersCount = members.where((member) => member.isSpeaking).length;
            
            // Safe host finding
            RoomMember host;
            try {
              host = members.firstWhere((member) => member.isHost);
            } catch (e) {
              // If no host found, use first member as fallback
              host = members.first;
            }

            return RoomHeader(
              members: members,
              onBackgroundChange: _showBackgroundMenu,
              onRoomInfoEdit: _showRoomInfoEdit,
              roomName: _roomName,
              roomDescription: _roomDescription,
              isCurrentUserHost: _currentUserRole == UserRole.admin,
              activeSpeakersCount: activeSpeakersCount,
            );
          },
        ),
        
        // Seats layout - takes remaining space
        Expanded(
          child: _buildRoomLayout(),
        ),
      ],
    );
  }

  Widget _buildRoomLayout() {
    return StreamBuilder<List<RoomMember>>(
      stream: _roomService.getRoomMembersStream(widget.roomId),
      builder: (context, snapshot) {
        final members = snapshot.data ?? [];
        
        // Safe host finding with proper error handling
        RoomMember host;
        if (members.isNotEmpty) {
          try {
            host = members.firstWhere((member) => member.isHost);
          } catch (e) {
            // If no host found, use first member
            host = members.first;
          }
        } else {
          // Create fallback host when no members exist
          host = RoomMember(
            id: 'fallback_host',
            userId: 'fallback_host',
            username: 'No Host',
            role: MemberRole.admin,
            isSpeaking: false,
            avatar: '👑',
            points: 0,
            level: 1,
            joinedAt: DateTime.now(),
            lastActive: DateTime.now(),
            isMuted: false,
            isHandRaised: false,
            achievements: [],
            title: 'Host',
            messageColor: '#FFD700',
            totalMessages: 0,
            roomsJoined: 1,
            sessionId: 'fallback',
          );
        }

        // Filter out host from member seats
        final nonHostMembers = members.where((member) => !member.isHost).toList();

        return Container(
          padding: const EdgeInsets.all(8), // Reduced padding
          child: Column(
            children: [
              HostSeat(
                host: host,
                isCurrentUser: host.userId == _currentUserId,
              ),
              const SizedBox(height: 12), // Reduced spacing
              Expanded(
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(), // Disable scrolling
                  shrinkWrap: true,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 4, // Reduced from 16 to 4
                    mainAxisSpacing: 4,  // Reduced from 16 to 4
                    childAspectRatio: 0.8, // Slightly adjusted for tighter layout
                  ),
                  itemCount: 9, // 9 total seats
                  itemBuilder: (context, index) {
                    if (index < nonHostMembers.length) {
                      final member = nonHostMembers[index];
                      return MemberSeat(
                        member: member,
                        onTap: () => _showMemberOptions(member),
                        isCurrentUser: member.userId == _currentUserId,
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

  Widget _buildLeftRoomState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.meeting_room_outlined,
            size: 64,
            color: Colors.white.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'You have left the room',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Chat history has been cleared',
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              // Option to rejoin room
              _initializeUserAndRoom();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text('Rejoin Room'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _chatController.dispose();
    // Ensure user leaves room when screen is disposed
    if (_isInRoom) {
      _roomService.leaveRoom(widget.roomId, _currentUserId, _currentUsername);
    }
    super.dispose();
  }
}

// Room Info Edit Dialog
class RoomInfoEditDialog extends StatefulWidget {
  final String roomName;
  final String roomDescription;
  final String welcomeMessage;
  final bool isHost;
  final Function({String? name, String? description, String? welcomeMessage}) onSave;

  const RoomInfoEditDialog({
    super.key,
    required this.roomName,
    required this.roomDescription,
    required this.welcomeMessage,
    required this.isHost,
    required this.onSave,
  });

  @override
  State<RoomInfoEditDialog> createState() => _RoomInfoEditDialogState();
}

class _RoomInfoEditDialogState extends State<RoomInfoEditDialog> {
  late TextEditingController _nameController;
  late TextEditingController _descController;
  late TextEditingController _welcomeController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.roomName);
    _descController = TextEditingController(text: widget.roomDescription);
    _welcomeController = TextEditingController(text: widget.welcomeMessage);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.grey[900],
      title: const Text(
        'Room Settings',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.isHost) ...[
              _buildTextField(
                controller: _nameController,
                label: 'Room Name',
                hint: 'Enter room name...',
              ),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _descController,
                label: 'Description',
                hint: 'Enter room description...',
                maxLines: 2,
              ),
              const SizedBox(height: 12),
            ],
            _buildTextField(
              controller: _welcomeController,
              label: 'Welcome Message',
              hint: 'Enter welcome message for new users...',
              maxLines: 3,
            ),
            if (!widget.isHost)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Only room admins can change room name and description',
                  style: TextStyle(color: Colors.white54, fontSize: 10),
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
        ),
        TextButton(
          onPressed: () {
            widget.onSave(
              name: widget.isHost ? _nameController.text : null,
              description: widget.isHost ? _descController.text : null,
              welcomeMessage: _welcomeController.text,
            );
          },
          child: const Text('Save', style: TextStyle(color: Colors.blue)),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextField(
            controller: controller,
            style: const TextStyle(color: Colors.white, fontSize: 14),
            maxLines: maxLines,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(12),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _welcomeController.dispose();
    super.dispose();
  }
}