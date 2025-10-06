import 'dart:async';

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
import 'package:haraka_afya_ai/screens/voice_room/widgets/models/chat_message.dart';
import 'package:haraka_afya_ai/screens/voice_room/models/room_background.dart';
import 'package:haraka_afya_ai/screens/voice_room/services/firebase_room_service.dart';
import 'package:haraka_afya_ai/screens/voice_room/widgets/room_header.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:haraka_afya_ai/screens/voice_room/widgets/host_seat.dart';
import 'package:haraka_afya_ai/screens/voice_room/widgets/member_seat.dart';
import 'package:haraka_afya_ai/screens/voice_room/widgets/empty_seat.dart';
import 'package:haraka_afya_ai/screens/voice_room/widgets/chat_section/chat_section.dart';
import 'package:haraka_afya_ai/screens/voice_room/widgets/bottom_controls.dart';
import 'package:haraka_afya_ai/screens/voice_room/services/webrtc_service.dart';

class VoiceRoomScreen extends StatefulWidget {
  final String roomId;

  const VoiceRoomScreen({super.key, required this.roomId});

  @override
  State<VoiceRoomScreen> createState() => _VoiceRoomScreenState();
}

class _VoiceRoomScreenState extends State<VoiceRoomScreen> with WidgetsBindingObserver {
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
  final WebRTCService _webRTCService = WebRTCService();
  final FirebaseRoomService _roomService = FirebaseRoomService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // User data
  String _currentUserId = '';
  String _currentUsername = 'Loading...';
  int _currentUserLevel = 1;
  UserRole _currentUserRole = UserRole.user;
  bool _isMuted = true;
  int? _currentSeatNumber;
  
  // Room state
  String _roomName = 'Support Room';
  String _roomDescription = 'A safe space for support and conversation';
  String _welcomeMessage = 'Welcome to our support room!';
  
  // Background state
  RoomBackground _currentBackground = RoomBackground.defaultBackgrounds.first;
  final List<RoomBackground> _availableBackgrounds = RoomBackground.defaultBackgrounds;

  // Connection state
  bool _isInRoom = false;
  bool _isWebRTCConnected = false;
  bool _isLoading = true;
  String _connectionStatus = 'Initializing...';
  bool _permissionGranted = false;
  bool _showPermissionDialog = false;

  // Connection retry variables
  int _connectionRetryCount = 0;
  static const int _maxRetryCount = 3;
  Timer? _connectionRetryTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeApp();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _chatController.dispose();
    _webRTCService.dispose();
    _connectionRetryTimer?.cancel();
    if (_isInRoom) {
      _roomService.leaveRoom(widget.roomId, _currentUserId, _currentUsername);
    }
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Check permission again when app comes to foreground
      _checkMicrophonePermission();
    }
  }

  Future<void> _initializeApp() async {
    await _checkMicrophonePermission();
    if (_permissionGranted) {
      await _initializeUserAndRoom();
    } else {
      setState(() {
        _showPermissionDialog = true;
        _isLoading = false;
        _connectionStatus = 'Microphone permission required';
      });
    }
  }

  Future<void> _checkMicrophonePermission() async {
    try {
      final status = await Permission.microphone.status;
      
      if (status.isGranted) {
        setState(() {
          _permissionGranted = true;
          _showPermissionDialog = false;
        });
      } else if (status.isDenied) {
        setState(() {
          _permissionGranted = false;
        });
      } else if (status.isPermanentlyDenied) {
        setState(() {
          _permissionGranted = false;
          _showPermissionDialog = true;
        });
      }
    } catch (e) {
      print('❌ Error checking microphone permission: $e');
      setState(() {
        _permissionGranted = false;
        _showPermissionDialog = true;
      });
    }
  }

  Future<void> _requestMicrophonePermission() async {
    try {
      setState(() {
        _connectionStatus = 'Requesting microphone permission...';
        _isLoading = true;
      });

      final status = await Permission.microphone.request();
      
      if (status.isGranted) {
        setState(() {
          _permissionGranted = true;
          _showPermissionDialog = false;
        });
        await _initializeUserAndRoom();
      } else {
        setState(() {
          _permissionGranted = false;
          _showPermissionDialog = true;
          _isLoading = false;
          _connectionStatus = 'Microphone permission denied';
        });
        
        if (status.isPermanentlyDenied) {
          _showPermissionSettingsDialog();
        }
      }
    } catch (e) {
      print('❌ Error requesting microphone permission: $e');
      setState(() {
        _permissionGranted = false;
        _showPermissionDialog = true;
        _isLoading = false;
        _connectionStatus = 'Failed to request permission';
      });
    }
  }

  void _showPermissionSettingsDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Microphone Permission Required'),
        content: const Text(
          'Microphone access is required for voice chat. '
          'Please enable microphone permission in app settings to continue.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  Future<void> _initializeUserAndRoom() async {
    try {
      if (_connectionRetryCount >= _maxRetryCount) {
        _showErrorDialog('Connection Failed', 
            'Unable to connect after $_maxRetryCount attempts. Please check your internet connection.');
        return;
      }

      setState(() {
        _connectionStatus = 'Setting up user... (Attempt ${_connectionRetryCount + 1}/$_maxRetryCount)';
        _isLoading = true;
      });

      final user = _auth.currentUser;
      if (user != null) {
        _currentUserId = user.uid;
        _currentUsername = await _roomService.getOrCreateUsername(_currentUserId);
        
        final achievements = await _roomService.getUserAchievements(_currentUserId);
        _currentUserLevel = achievements['level'] ?? 1;
        
        final isHost = await _roomService.isRoomHost(widget.roomId, _currentUserId);
        _currentUserRole = isHost ? UserRole.admin : UserRole.user;
        
        final roomInfo = await _roomService.getRoomInfo(widget.roomId);
        _roomName = roomInfo['name'] ?? 'Support Room';
        _roomDescription = roomInfo['description'] ?? 'A safe space';
        _welcomeMessage = roomInfo['welcomeMessage'] ?? 'Welcome!';
      } else {
        _currentUsername = 'Guest';
        _currentUserId = 'guest_${DateTime.now().millisecondsSinceEpoch}';
        _currentUserRole = UserRole.user; // Guests are always listeners
      }

      setState(() {
        _connectionStatus = 'Connecting to voice server...';
      });

      _setupWebRTCEventListeners();
      await _webRTCService.initialize().timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw TimeoutException('WebRTC initialization timed out');
        },
      );

      // Log ICE server status for debugging
      final connectionStatus = _webRTCService.getConnectionStatus();
      print('🌐 WebRTC Connection Status: $connectionStatus');

      setState(() {
        _connectionStatus = 'Joining room...';
      });

      await _webRTCService.joinRoom(widget.roomId, _currentUserId, _currentUsername)
          .timeout(
        const Duration(seconds: 20),
        onTimeout: () {
          throw TimeoutException('Room join timed out');
        },
      );

      // Create member with proper role and no seat initially
      final member = RoomMember(
        id: _currentUserId,
        userId: _currentUserId,
        username: _currentUsername,
        role: _currentUserRole == UserRole.admin ? MemberRole.admin : MemberRole.listener,
        isSpeaking: !_isMuted,
        avatar: _currentUserRole == UserRole.admin ? '👑' : '😊',
        points: 0,
        level: _currentUserLevel,
        joinedAt: DateTime.now(),
        lastActive: DateTime.now(),
        isMuted: _isMuted,
        isHandRaised: false,
        achievements: [],
        title: 'Newcomer',
        messageColor: '#4A5568',
        totalMessages: 0,
        roomsJoined: 1,
        sessionId: 'current',
        seatNumber: _currentUserRole == UserRole.admin ? 0 : null, // Host has seat 0, listeners start without seat
      );

      await _roomService.createOrJoinRoom(widget.roomId, member);
      
      // Reset retry count on success
      _connectionRetryCount = 0;
      
      setState(() {
        _isInRoom = true;
        _isWebRTCConnected = true;
        _isLoading = false;
        _connectionStatus = 'Connected!';
      });

      print('✅ Voice room initialized successfully');
      
    } on TimeoutException catch (e) {
      print('❌ Connection timeout: $e');
      _handleConnectionError('Connection timeout: $e');
    } catch (e) {
      print('❌ Error initializing room: $e');
      _handleConnectionError('Failed to initialize room: $e');
    }
  }

  void _handleConnectionError(String error) {
    _connectionRetryCount++;
    
    if (_connectionRetryCount < _maxRetryCount) {
      // Auto-retry after delay
      setState(() {
        _connectionStatus = 'Retrying connection... (${_connectionRetryCount + 1}/$_maxRetryCount)';
        _isLoading = true;
      });
      
      _connectionRetryTimer = Timer(const Duration(seconds: 3), () {
        if (mounted) {
          _initializeUserAndRoom();
        }
      });
    } else {
      // Final failure
      _showErrorDialog('Connection Failed', 
          'Unable to establish voice connection after $_maxRetryCount attempts. '
          'This may be due to network restrictions. Please check your internet connection.');
      
      setState(() {
        _isLoading = false;
        _connectionStatus = 'Connection failed';
      });
    }
  }

  void _setupWebRTCEventListeners() {
    _webRTCService.onAddRemoteStream.add(_onAddRemoteStream);
    _webRTCService.onRemoveRemoteStream.add(_onRemoveRemoteStream);
    _webRTCService.onError.add(_onWebRTCError);
    _webRTCService.onUserJoined.add(_onUserJoined);
    _webRTCService.onUserLeft.add(_onUserLeft);
    _webRTCService.onUserAudioChanged.add(_onUserAudioChanged);
  }

  void _onAddRemoteStream(MediaStream stream) {
    print('🎧 Remote stream added - user is speaking');
    setState(() {
      _isWebRTCConnected = true;
    });
  }

  void _onRemoveRemoteStream(MediaStream stream) {
    print('🎧 Remote stream removed - user stopped speaking');
  }

  void _onUserJoined(String userId, String username) {
    print('👤 WebRTC User joined: $username ($userId)');
  }

  void _onUserLeft(String userId, String username) {
    print('👤 WebRTC User left: $username ($userId)');
  }

  void _onUserAudioChanged(String userId, bool isMuted) {
    print('🎤 User audio changed: $userId - muted: $isMuted');
  }

  void _onWebRTCError(String error) {
    print('❌ WebRTC error: $error');
    if (mounted) {
      _showErrorDialog('Voice Connection Error', error);
    }
    setState(() {
      _isWebRTCConnected = false;
    });
  }

  void _showErrorDialog(String title, String message) {
    if (!mounted) return;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
          if (title.contains('Connection Failed'))
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _connectionRetryCount = 0;
                _initializeUserAndRoom();
              },
              child: const Text('Retry'),
            ),
        ],
      ),
    );
  }

  void _showConnectionStatus() {
    final status = _webRTCService.getConnectionStatus();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('WebRTC Connection Status'),
        content: Text(
          'Socket Connected: ${status['socketConnected']}\n'
          'Peer Connections: ${status['peerConnections']}\n'
          'Remote Streams: ${status['remoteStreams']}\n'
          'Has Local Stream: ${status['hasLocalStream']}\n'
          'ICE Servers: ${status['iceServers']}\n'
          'Connection Status: $_connectionStatus'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _connectionRetryCount = 0;
              _initializeUserAndRoom();
            },
            child: const Text('Retry Connection'),
          ),
        ],
      ),
    );
  }

  void _sendChatMessage(ChatMessage message) {
    if (_isInRoom) {
      _roomService.sendChatMessage(widget.roomId, message);
    }
  }

  void _toggleMicrophone() async {
    if (!_isInRoom || !_isWebRTCConnected) return;
    
    setState(() {
      _isMuted = !_isMuted;
    });
    
    try {
      await _webRTCService.toggleMicrophone(_isMuted);
      await _roomService.updateSpeakingStatus(
        widget.roomId, 
        _currentUserId, 
        !_isMuted
      );
      print('🎤 Microphone ${_isMuted ? 'muted' : 'unmuted'}');
    } catch (e) {
      print('❌ Error toggling microphone: $e');
      setState(() {
        _isMuted = !_isMuted; // Revert on error
      });
    }
  }

  void _changeBackground(RoomBackground background) async {
    if (!_isInRoom) return;
    
    try {
      await _roomService.updateRoomBackground(widget.roomId, background);
      setState(() {
        _currentBackground = background;
      });
      Navigator.pop(context);
    } catch (e) {
      _showErrorDialog('Background Error', 'Failed to change background: $e');
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
    } catch (e) {
      _showErrorDialog('Update Error', 'Failed to update room info: $e');
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

  void _showGamesMenu() {
    if (!_isInRoom) return;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
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

  void _showGiftMenu() {
    if (!_isInRoom) return;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
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

  void _showMemberOptions(RoomMember member) {
    if (!_isInRoom || member.userId == _currentUserId) return;

    final isCurrentUserHost = _currentUserRole == UserRole.admin;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return MemberOptions(
          member: member,
          isCurrentUserHost: isCurrentUserHost,
          onSendGift: () {
            Navigator.pop(context);
            _showGiftMenu();
          },
          onRemoveMember: () {
            Navigator.pop(context);
            _removeMember(member);
          },
          onMuteMember: () {
            Navigator.pop(context);
            _muteMember(member);
          },
          onPromoteToSpeaker: () {
            if (isCurrentUserHost) {
              Navigator.pop(context);
              _promoteToSpeaker(member);
            }
          },
          onPromoteToModerator: () {
            if (isCurrentUserHost) {
              Navigator.pop(context);
              _promoteToModerator(member);
            }
          },
          onDemoteToListener: () {
            if (isCurrentUserHost) {
              Navigator.pop(context);
              _demoteToListener(member);
            }
          },
          onTransferHost: () {
            if (isCurrentUserHost) {
              Navigator.pop(context);
              _transferHost(member);
            }
          },
        );
      },
    );
  }

  void _transferHost(RoomMember member) async {
    if (!_isInRoom || _currentUserRole != UserRole.admin) return;

    try {
      await _roomService.transferHost(widget.roomId, member.userId);
      setState(() {
        _currentUserRole = UserRole.user;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Host role transferred to ${member.username}'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      _showErrorDialog('Transfer Host Error', 'Failed to transfer host role: $e');
    }
  }

  void _removeMember(RoomMember member) async {
    if (!_isInRoom) return;
    
    try {
      await _roomService.leaveRoom(widget.roomId, member.id, member.username);
    } catch (e) {
      _showErrorDialog('Remove Error', 'Failed to remove member: $e');
    }
  }

  void _muteMember(RoomMember member) async {
    if (!_isInRoom) return;
    
    try {
      await _roomService.updateSpeakingStatus(widget.roomId, member.id, false);
    } catch (e) {
      _showErrorDialog('Mute Error', 'Failed to mute member: $e');
    }
  }

  void _promoteToSpeaker(RoomMember member) async {
    if (!_isInRoom) return;
    
    try {
      await _roomService.updateMemberRole(widget.roomId, member.id, MemberRole.speaker);
    } catch (e) {
      _showErrorDialog('Promote Error', 'Failed to promote member: $e');
    }
  }

  void _promoteToModerator(RoomMember member) async {
    if (!_isInRoom) return;

    try {
      await _roomService.updateMemberRole(widget.roomId, member.id, MemberRole.moderator);
    } catch (e) {
      _showErrorDialog('Promote Error', 'Failed to promote member to moderator: $e');
    }
  }

  void _demoteToListener(RoomMember member) async {
    if (!_isInRoom) return;

    try {
      await _roomService.updateMemberRole(widget.roomId, member.id, MemberRole.listener);
    } catch (e) {
      _showErrorDialog('Demote Error', 'Failed to demote member to listener: $e');
    }
  }

  // Seat Management Methods
  void _assignSeat(int seatNumber) async {
    if (!_isInRoom) return;
    
    try {
      // Check if seat is available
      final isSeatAvailable = await _roomService.isSeatAvailable(widget.roomId, seatNumber);
      if (!isSeatAvailable) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Seat $seatNumber is already occupied!'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      
      // Leave current seat if any
      if (_currentSeatNumber != null) {
        await _roomService.leaveSeat(widget.roomId, _currentUserId);
      }
      
      // Assign new seat
      await _roomService.assignSeat(widget.roomId, _currentUserId, seatNumber);
      
      setState(() {
        _currentSeatNumber = seatNumber;
        _isMuted = false;
      });
      
      await _webRTCService.toggleMicrophone(false);
      await _roomService.updateSpeakingStatus(widget.roomId, _currentUserId, true);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Joined seat $seatNumber'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      _showErrorDialog('Seat Error', 'Failed to assign seat: $e');
    }
  }

  void _switchSeat(int newSeatNumber) async {
    if (!_isInRoom || _currentSeatNumber == null) return;
    
    try {
      // Check if new seat is available
      final isSeatAvailable = await _roomService.isSeatAvailable(widget.roomId, newSeatNumber);
      if (!isSeatAvailable) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Seat $newSeatNumber is already occupied!'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      
      // Leave current seat
      await _roomService.leaveSeat(widget.roomId, _currentUserId);
      
      // Assign new seat
      await _roomService.assignSeat(widget.roomId, _currentUserId, newSeatNumber);
      
      setState(() {
        _currentSeatNumber = newSeatNumber;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Switched from seat $_currentSeatNumber to seat $newSeatNumber'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      _showErrorDialog('Switch Error', 'Failed to switch seat: $e');
    }
  }

  void _leaveCurrentSeat() async {
    if (!_isInRoom || _currentSeatNumber == null) return;
    
    try {
      await _roomService.leaveSeat(widget.roomId, _currentUserId);
      
      // Update local state
      setState(() {
        _currentSeatNumber = null;
        _isMuted = true;
      });
      await _webRTCService.toggleMicrophone(true);
      await _roomService.updateSpeakingStatus(widget.roomId, _currentUserId, false);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Left your seat'),
          backgroundColor: Colors.blue,
        ),
      );
    } catch (e) {
      _showErrorDialog('Leave Seat Error', 'Failed to leave seat: $e');
    }
  }

  void _switchHostToSpeaker() async {
    if (!_isInRoom || _currentUserRole != UserRole.admin) return;
    
    try {
      await _roomService.switchHostToSpeaker(widget.roomId, _currentUserId);
      setState(() {
        _currentUserRole = UserRole.moderator;
        _isMuted = false;
      });
      await _webRTCService.toggleMicrophone(false);
    } catch (e) {
      _showErrorDialog('Switch Error', 'Failed to switch to speaker: $e');
    }
  }

  void _leaveRoom() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Leave Room'),
        content: const Text('Are you sure you want to leave this voice room?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _performLeaveRoom();
            },
            child: const Text('Leave', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _performLeaveRoom() async {
    try {
      setState(() {
        _isInRoom = false;
        _isWebRTCConnected = false;
        _currentSeatNumber = null;
      });
      
      await _webRTCService.leaveRoom(widget.roomId, _currentUserId);
      await _roomService.leaveRoom(widget.roomId, _currentUserId, _currentUsername);
      
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      _showErrorDialog('Leave Error', 'Error leaving room: $e');
      if (mounted) {
        setState(() {
          _isInRoom = true;
        });
      }
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
            _isInRoom ? _roomName : 'Left Room',
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
            IconButton(
              icon: const Icon(Icons.connected_tv_rounded, color: Colors.white54, size: 22),
              onPressed: _showConnectionStatus,
            ),
          ] : null,
        ),
      ),
      drawer: const AppDrawer(),
      body: SafeArea(
        child: _showPermissionDialog 
            ? _buildPermissionRequestScreen()
            : StreamBuilder<RoomBackground>(
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
                    child: _isLoading 
                        ? _buildLoadingScreen()
                        : _isInRoom 
                            ? _buildMainContent() 
                            : _buildLeftRoomState(),
                  );
                },
              ),
      ),
    );
  }

  Widget _buildPermissionRequestScreen() {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.8),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.mic_rounded,
              size: 64,
              color: Colors.blue,
            ),
            const SizedBox(height: 16),
            const Text(
              'Microphone Access Required',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            const Text(
              'This app needs microphone access for voice chat functionality. '
              'Please allow microphone permission to continue.',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _leaveRoom();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: _requestMicrophonePermission,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Allow Microphone'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: openAppSettings,
              child: const Text(
                'Open App Settings',
                style: TextStyle(color: Colors.blue),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4ECDC4)),
          ),
          const SizedBox(height: 20),
          Text(
            _connectionStatus,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 10),
          if (_connectionStatus.contains('Failed') || _connectionStatus.contains('Retrying'))
            ElevatedButton(
              onPressed: () {
                _connectionRetryCount = 0;
                _initializeUserAndRoom();
              },
              child: const Text('Retry Connection'),
            ),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    return Stack(
      children: [
        // Main room layout
        Column(
          children: [
            // Room Header
            StreamBuilder<List<RoomMember>>(
              stream: _roomService.getRoomMembersStream(widget.roomId),
              builder: (context, membersSnapshot) {
                final members = membersSnapshot.data ?? [];
                final activeSpeakersCount = members.where((member) => member.isSpeaking).length;
                
                RoomMember host;
                if (members.isNotEmpty) {
                  try {
                    host = members.firstWhere((member) => member.role == MemberRole.admin);
                  } catch (e) {
                    host = members.first;
                  }
                } else {
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
            
            // Seats layout
            Expanded(
              child: _buildRoomLayout(),
            ),
            
            // Spacer for chat section
            const SizedBox(height: 160),
          ],
        ),
        
        // Chat Section - Fixed position at bottom
        Positioned(
          bottom: 80,
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
                isAdmin: _currentUserRole == MemberRole.admin,
                onRoomInfoUpdate: (newName) {
                  _updateRoomInfo(name: newName);
                },
                currentRoomId: widget.roomId,
                currentUserId: _currentUserId,
                currentUsername: _currentUsername,
                currentUserRole: _currentUserRole,
                currentUserLevel: _currentUserLevel,
                onSwitchToSpeaker: _currentUserRole == MemberRole.admin ? _switchHostToSpeaker : null,
              );
            },
          ),
        ),
        
        // Bottom Controls - Fixed at very bottom
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
            isHost: _currentUserRole == MemberRole.admin,
            hasSeat: _currentSeatNumber != null,
            onLeaveSeat: _currentSeatNumber != null ? _leaveCurrentSeat : null,
          ),
        ),
      ],
    );
  }

  Widget _buildRoomLayout() {
    return StreamBuilder<List<RoomMember>>(
      stream: _roomService.getRoomMembersStream(widget.roomId),
      builder: (context, snapshot) {
        final members = snapshot.data ?? [];
        
        // Separate host and listeners
        RoomMember? host;
        final listeners = <RoomMember>[];
        
        for (final member in members) {
          if (member.role == MemberRole.admin) {
            host = member;
          } else {
            listeners.add(member);
          }
        }
        
        // Create fallback host if none exists
        host ??= RoomMember(
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

        return SingleChildScrollView(
          padding: const EdgeInsets.all(8),
          child: Column(
            children: [
              // Host seat - only show if user is host or host exists
              if (_currentUserRole == UserRole.admin || host.userId != 'fallback_host')
                HostSeat(
                  host: host,
                  isCurrentUser: host.userId == _currentUserId,
                  onTap: _currentUserRole == UserRole.admin 
                      ? () => _showMemberOptions(host!)
                      : null,
                ),
              const SizedBox(height: 12),
              
              // Listener seats
              _buildListenerSeats(listeners),
            ],
          ),
        );
      },
    );
  }

  Widget _buildListenerSeats(List<RoomMember> listeners) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 600 ? 3 : 2;
        final totalSeats = 6; // Fixed 6 listener seats
        final rows = (totalSeats / crossAxisCount).ceil();
        
        return SizedBox(
          height: rows * 140,
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 0.9,
            ),
            itemCount: totalSeats,
            itemBuilder: (context, index) {
              final seatNumber = index + 1;
              final occupant = listeners.firstWhere(
                (member) => member.seatNumber == seatNumber,
                orElse: () => RoomMember.empty(),
              );
              
              if (occupant.id.isNotEmpty) {
                // Seat is occupied
                return MemberSeat(
                  member: occupant,
                  onTap: () => _showMemberOptions(occupant),
                  isCurrentUser: occupant.userId == _currentUserId,
                  onLeaveSeat: occupant.userId == _currentUserId ? _leaveCurrentSeat : null,
                );
              } else {
                // Empty seat
                return EmptySeat(
                  seatNumber: seatNumber,
                  onTap: () => _assignSeat(seatNumber),
                  onSwitchSeat: _currentSeatNumber != null ? 
                      () => _switchSeat(seatNumber) : null,
                  canSwitch: _currentSeatNumber != null,
                );
              }
            },
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
          const Text(
            'You have left the room',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              _connectionRetryCount = 0;
              _initializeUserAndRoom();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            child: const Text('Rejoin Room'),
          ),
        ],
      ),
    );
  }
}

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
          style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold),
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