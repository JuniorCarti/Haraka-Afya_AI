import 'package:flutter/material.dart';
import 'package:haraka_afya_ai/models/message.dart';
import 'package:haraka_afya_ai/services/anonymous_chat_service.dart';
import 'package:haraka_afya_ai/widgets/app_drawer.dart';
import 'package:haraka_afya_ai/screens/voice_room_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AnonymousChatScreen extends StatefulWidget {
  const AnonymousChatScreen({super.key});

  @override
  State<AnonymousChatScreen> createState() => _AnonymousChatScreenState();
}

class _AnonymousChatScreenState extends State<AnonymousChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final AnonymousChatService _chatService = AnonymousChatService();
  final User? _user = FirebaseAuth.instance.currentUser;
  final _scrollController = ScrollController();
  Color _chatBackgroundColor = const Color(0xFFFDFDFD);
  String? _chatBackgroundImage;
  String? _replyingToMessageId;
  final TextEditingController _replyController = TextEditingController();
  final Map<String, bool> _expandedReplies = {};
  final Set<String> _likedMessages = {};
  final _prefsKey = 'chat_background_preference';
  final _usernameKey = 'anonymous_username';
  String? _anonymousUsername;
  bool _isSelectingUsername = false;
  final TextEditingController _usernameController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Live rooms state
  List<Map<String, dynamic>> _liveRooms = [];
  bool _isLoadingRooms = false;

  // Predefined background options
  final List<Map<String, dynamic>> _backgroundOptions = [
    {'name': 'Default', 'color': const Color(0xFFFDFDFD)},
    {'name': 'Light Green', 'color': const Color(0xFFE8F5E9)},
    {'name': 'Light Blue', 'color': const Color(0xFFE3F2FD)},
    {'name': 'Light Grey', 'color': const Color(0xFFEEEEEE)},
    {
      'name': 'Nature Green',
      'image': 'https://images.unsplash.com/photo-1731331215550-1c1f6b82daaa',
    },
    {
      'name': 'Blue Pattern',
      'image': 'https://images.unsplash.com/photo-1731141028975-3eb6b91cef4c',
    },
    {
      'name': 'Dark Texture',
      'image': 'https://images.unsplash.com/photo-1731331323996-7ff41939ddf3',
    },
    {
      'name': 'Colorful Abstract',
      'image': 'https://images.unsplash.com/photo-1731462385471-90cf5aa51848',
    },
    {
      'name': 'Misty Mountains',
      'image': 'https://plus.unsplash.com/premium_photo-1667579006165-16b6f04ccc78',
    },
    {
      'name': 'Serene Beach',
      'image': 'https://images.unsplash.com/photo-1653504207307-4a40248cf73b',
    }
  ];

  @override
  void initState() {
    super.initState();
    _loadBackgroundPreference();
    _loadUsername();
    _loadLikedMessages();
    _loadLiveRooms();
    
    // Initialize all replies as expanded by default
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _chatService.getMessages().first.then((messages) {
        for (var message in messages) {
          _expandedReplies[message.id] = true;
        }
        if (mounted) setState(() {});
      });
    });
  }

  Future<void> _loadLiveRooms() async {
    setState(() {
      _isLoadingRooms = true;
    });

    try {
      final snapshot = await _firestore
          .collection('voice_rooms')
          .where('isActive', isEqualTo: true)
          .get();

      final rooms = snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'name': data['name'] ?? 'Support Room',
          'topic': data['description'] ?? 'Anonymous support session',
          'members': (data['members'] as List? ?? []).length,
          'hostId': data['hostId'],
          'isActive': data['isActive'] ?? false,
        };
      }).toList();

      setState(() {
        _liveRooms = rooms;
        _isLoadingRooms = false;
      });
    } catch (e) {
      print('Error loading rooms: $e');
      setState(() {
        _isLoadingRooms = false;
      });
    }
  }

 Future<void> _createNewRoom() async {
  if (_user == null) return;

  try {
    // Generate a unique room ID
    final roomId = 'room_${DateTime.now().millisecondsSinceEpoch}_${_user!.uid}';
    
    // Create room in Firestore
    await _firestore.collection('voice_rooms').doc(roomId).set({
      'id': roomId,
      'name': 'Support Room by ${_anonymousUsername ?? 'Anonymous'}',
      'description': 'A safe space for support and conversation',
      'hostId': _user!.uid,
      'hostName': _anonymousUsername ?? 'Anonymous',
      'isActive': true,
      'members': [],
      'createdAt': FieldValue.serverTimestamp(),
      'background': {
        'primaryColor': '#1A1A2E',
        'secondaryColor': '#16213E',
        'imageUrl': '',
        'name': 'Default Dark',
        'isPremium': false,
        'requiredLevel': 1,
      },
    });

    // Navigate to the new room
    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VoiceRoomScreen(roomId: roomId),
        ),
      );
    }
  } catch (e) {
    print('Error creating room: $e');
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to create room: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
  Future<void> _joinRoom(String roomId) async {
    if (_user == null) return;

    try {
      // Verify room exists and is active
      final roomDoc = await _firestore.collection('voice_rooms').doc(roomId).get();
      if (!roomDoc.exists || !(roomDoc.data()?['isActive'] ?? false)) {
        throw Exception('Room not available');
      }

      // Navigate to the room
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VoiceRoomScreen(roomId: roomId),
          ),
        );
      }
    } catch (e) {
      print('Error joining room: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to join room: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _loadBackgroundPreference() async {
    final prefs = await SharedPreferences.getInstance();
    final savedPref = prefs.getString(_prefsKey);
    
    if (savedPref != null) {
      final parts = savedPref.split('|');
      if (parts.length == 2) {
        setState(() {
          if (parts[0] == 'color') {
            _chatBackgroundColor = Color(int.parse(parts[1]));
            _chatBackgroundImage = null;
          } else if (parts[0] == 'image') {
            _chatBackgroundImage = parts[1];
            _chatBackgroundColor = const Color(0xFFFDFDFD);
          }
        });
      }
    }
  }

  Future<void> _loadUsername() async {
    final prefs = await SharedPreferences.getInstance();
    final savedUsername = prefs.getString(_usernameKey);
    
    if (savedUsername != null) {
      setState(() {
        _anonymousUsername = savedUsername;
      });
    } else if (_user != null) {
      final username = await _chatService.getOrCreateUsername(_user.uid);
      setState(() {
        _anonymousUsername = username;
      });
      await prefs.setString(_usernameKey, username);
    } else {
      _generateRandomUsername();
    }
  }

  Future<void> _loadLikedMessages() async {
    if (_user == null) return;
    
    final likedMessages = await _firestore
        .collection('anonymous_messages')
        .where('likedBy', arrayContains: _user.uid)
        .get();
    
    setState(() {
      _likedMessages.addAll(likedMessages.docs.map((doc) => doc.id));
    });
  }

  Future<void> _saveUsername(String username) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_usernameKey, username);
    
    if (_user != null) {
      await _firestore
          .collection('user_usernames')
          .doc(_user.uid)
          .set({
            'username': username,
            'createdAt': FieldValue.serverTimestamp(),
          });
    }
  }

  void _generateRandomUsername() {
    if (_user != null) {
      _chatService.getOrCreateUsername(_user.uid).then((username) {
        setState(() {
          _anonymousUsername = username;
        });
        _saveUsername(username);
      });
    } else {
      final randomIndex = DateTime.now().millisecondsSinceEpoch % 
          AnonymousChatService.randomUsernames.length;
      final username = AnonymousChatService.randomUsernames[randomIndex];
      setState(() {
        _anonymousUsername = username;
      });
      _saveUsername(username);
    }
  }

  Future<void> _saveBackgroundPreference(bool isImage, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _prefsKey,
      isImage ? 'image|$value' : 'color|${_chatBackgroundColor.value}'
    );
  }

  void _showLiveRooms() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.8,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF269A51),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Live Support Rooms',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Join existing rooms or create your own',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),

              // Refresh button
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${_liveRooms.length} active room${_liveRooms.length == 1 ? '' : 's'} available',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh, size: 20),
                      onPressed: _loadLiveRooms,
                      tooltip: 'Refresh rooms',
                    ),
                  ],
                ),
              ),

              // Live rooms list or empty state
              Expanded(
                child: _isLoadingRooms
                    ? const Center(child: CircularProgressIndicator())
                    : _liveRooms.isEmpty
                        ? _buildEmptyRoomsState()
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: _liveRooms.length,
                            itemBuilder: (context, index) {
                              return _buildLiveRoomCard(_liveRooms[index]);
                            },
                          ),
              ),

              // Create room button
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _createNewRoom,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF269A51),
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Create New Room',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyRoomsState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.record_voice_over_outlined,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            const Text(
              'No Active Rooms',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Be the first to create a support room\nand start a conversation',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _createNewRoom,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF269A51),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text('Create First Room'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLiveRoomCard(Map<String, dynamic> room) {
    final isHost = room['hostId'] == _user?.uid;
    final memberCount = room['members'] ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: isHost 
                ? const Color(0xFFFFD700).withOpacity(0.2)
                : const Color(0xFFD8FBE5),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            isHost ? Icons.workspace_premium : Icons.record_voice_over,
            color: isHost ? const Color(0xFFFFD700) : const Color(0xFF269A51),
            size: 24,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                room['name'] ?? 'Support Room',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (isHost)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD700).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFFFD700)),
                ),
                child: const Text(
                  'HOST',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFB8860B),
                  ),
                ),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              room['topic'] ?? 'Anonymous support session',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Row(
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
                Text(
                  '$memberCount ${memberCount == 1 ? 'member' : 'members'} • Live',
                  style: const TextStyle(
                    color: Colors.green,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: ElevatedButton(
          onPressed: () => _joinRoom(room['id']),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF269A51),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          child: Text(
            isHost ? 'Your Room' : 'Join',
            style: const TextStyle(fontSize: 12),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _replyController.dispose();
    _usernameController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_anonymousUsername == null || _isSelectingUsername) {
      return _buildUsernameSelectionScreen();
    }
    
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: AppBar(
          title: const Text(
            'Anonymous Support Space',
            style: TextStyle(
              fontWeight: FontWeight.bold, 
              color: Colors.black,
            ),
          ),
          centerTitle: true,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              color: Color(0xFFD8FBE5),
            ),
          ),
          elevation: 2,
          actions: [
            // Live Rooms Button with badge
            Stack(
              children: [
                IconButton(
                  icon: const Icon(Icons.record_voice_over, color: Colors.black),
                  onPressed: _showLiveRooms,
                  tooltip: 'Live Support Rooms',
                ),
                if (_liveRooms.isNotEmpty)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${_liveRooms.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            IconButton(
              icon: const Icon(Icons.info_outline, color: Colors.black),
              onPressed: _showPrivacyInfo,
            ),
            IconButton(
              icon: const Icon(Icons.wallpaper, color: Colors.black),
              onPressed: _showBackgroundOptions,
            ),
            IconButton(
              icon: const Icon(Icons.person_outline, color: Colors.black),
              onPressed: () {
                setState(() {
                  _isSelectingUsername = true;
                });
              },
            ),
          ],
        ),
      ),
      drawer: const AppDrawer(),
      body: Container(
        decoration: _buildBackgroundDecoration(),
        child: Column(
          children: [
            // Quick Access Banner
            _buildQuickAccessBanner(),
            
            Expanded(
              child: StreamBuilder<List<AnonymousMessage>>(
                stream: _chatService.getMessages(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          'Error loading messages: ${snapshot.error}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    );
                  }
                  
                  if (!snapshot.hasData) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  
                  final messages = snapshot.data!;
                  
                  // Initialize expanded state for new messages
                  for (var message in messages) {
                    _expandedReplies.putIfAbsent(message.id, () => true);
                  }
                  
                  return messages.isEmpty
                      ? _buildEmptyChatState()
                      : ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.all(8),
                          reverse: true,
                          itemCount: messages.length,
                          itemBuilder: (context, index) {
                            return _buildMessageWithReplies(messages[index]);
                          },
                        );
                },
              ),
            ),
            if (_replyingToMessageId != null) _buildReplyInput(),
            _buildMessageInput(),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyChatState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.forum_outlined,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            const Text(
              'No Messages Yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Be the first to start a conversation\nin the anonymous support space',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAccessBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF269A51), Color(0xFF34C759)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.record_voice_over, color: Colors.white, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Live Voice Rooms Available',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  _liveRooms.isEmpty
                      ? 'Create the first support room and start a conversation'
                      : '${_liveRooms.length} active room${_liveRooms.length == 1 ? '' : 's'} - join now!',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 11,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: _showLiveRooms,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF269A51),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: Text(
              _liveRooms.isEmpty ? 'Create Room' : 'Find Rooms',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUsernameSelectionScreen() {
    return Scaffold(
      body: Container(
        decoration: _buildBackgroundDecoration(),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Choose Your Anonymous Identity',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Text(
                          'Your current name:',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          _anonymousUsername ?? 'Generating...',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 30),
                        ElevatedButton(
                          onPressed: _generateRandomUsername,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF269A51),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 30, vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            'Generate Random Name',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        const SizedBox(height: 15),
                        const Text('OR', style: TextStyle(fontSize: 16)),
                        const SizedBox(height: 15),
                        TextField(
                          controller: _usernameController,
                          decoration: InputDecoration(
                            labelText: 'Choose your own name',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 15, vertical: 15),
                          ),
                          maxLength: 20,
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: () {
                            if (_usernameController.text.trim().isNotEmpty) {
                              setState(() {
                                _anonymousUsername = _usernameController.text.trim();
                                _isSelectingUsername = false;
                              });
                              _saveUsername(_usernameController.text.trim());
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF269A51),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 30, vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            'Use This Name',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _isSelectingUsername = false;
                            });
                          },
                          child: const Text('Continue with current name'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  BoxDecoration? _buildBackgroundDecoration() {
    if (_chatBackgroundImage != null) {
      return BoxDecoration(
        image: DecorationImage(
          image: NetworkImage(_chatBackgroundImage!),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            Colors.black.withOpacity(0.1),
            BlendMode.darken,
          ),
        ),
      );
    }
    return BoxDecoration(
      gradient: LinearGradient(
        colors: [
          _chatBackgroundColor,
          Colors.white,
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ),
    );
  }

  Widget _buildMessageWithReplies(AnonymousMessage message) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildMessageBubble(message),
        // Replies section - now always visible but collapsible
        _buildRepliesSection(message),
      ],
    );
  }

  Widget _buildRepliesSection(AnonymousMessage message) {
    return Column(
      children: [
        // Collapse/expand button
        GestureDetector(
          onTap: () {
            setState(() {
              _expandedReplies[message.id] = !_expandedReplies[message.id]!;
            });
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Row(
              children: [
                const SizedBox(width: 40),
                Icon(
                  _expandedReplies[message.id]! 
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  size: 20,
                  color: Colors.grey,
                ),
                const SizedBox(width: 8),
                Text(
                  _expandedReplies[message.id]! ? 'Hide replies' : 'Show replies',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
        
        // Replies list
        if (_expandedReplies[message.id]!)
          StreamBuilder<List<AnonymousMessage>>(
            stream: _chatService.getReplies(message.id),
            builder: (context, snapshot) {
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const SizedBox.shrink();
              }
              final replies = snapshot.data!;
              return Container(
                margin: const EdgeInsets.only(left: 40.0),
                decoration: BoxDecoration(
                  border: Border(
                    left: BorderSide(
                      color: Colors.grey.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                ),
                child: Column(
                  children: replies.map((reply) => Padding(
                    padding: const EdgeInsets.only(left: 8.0, bottom: 4),
                    child: _buildMessageBubble(reply, isReply: true),
                  )).toList(),
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _buildMessageBubble(AnonymousMessage message, {bool isReply = false}) {
    final bubbleColor = isReply
        ? const Color(0xFFF1F5FF)
        : const Color(0xFFEAFBF1);
    final hasLiked = _likedMessages.contains(message.id) || 
                    (_user != null && message.likedBy.contains(_user.uid));

    final iconColor = _chatBackgroundImage != null 
        ? Colors.white 
        : Colors.blueGrey.shade700;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.78,
            ),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: bubbleColor,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.15),
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 12,
                      backgroundColor: Colors.blueAccent.shade100,
                      child: const Icon(Icons.person_outline,
                          size: 14, color: Colors.white),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      message.senderName ?? 'Anonymous',
                      style: TextStyle(
                        color: Colors.blueGrey.shade700,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  message.content,
                  style: const TextStyle(fontSize: 15, height: 1.4),
                ),
                const SizedBox(height: 6),
                Text(
                  DateFormat('h:mm a').format(message.timestamp),
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: _chatBackgroundImage != null 
                  ? Colors.black.withOpacity(0.2) 
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(
                      hasLiked ? Icons.favorite : Icons.favorite_border,
                      color: hasLiked ? Colors.pink : iconColor,
                      size: 18,
                    ),
                    onPressed: () {
                      if (_user != null) {
                        if (hasLiked) {
                          // Unlike functionality can be added here
                        } else {
                          _chatService.likeMessage(message.id, _user.uid);
                          setState(() {
                            _likedMessages.add(message.id);
                          });
                        }
                      }
                    },
                  ),
                  Text(
                    '${message.likes}', 
                    style: TextStyle(
                      fontSize: 12,
                      color: iconColor,
                      shadows: _chatBackgroundImage != null
                          ? [const Shadow(color: Colors.black, blurRadius: 2)]
                          : null,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: Icon(
                      Icons.reply,
                      size: 18,
                      color: _replyingToMessageId == message.id 
                          ? Colors.blue 
                          : iconColor,
                    ),
                    onPressed: () {
                      setState(() {
                        _replyingToMessageId = _replyingToMessageId == message.id 
                            ? null 
                            : message.id;
                        if (_replyingToMessageId != null) {
                          _replyController.clear();
                        }
                      });
                    },
                  ),
                  PopupMenuButton<String>(
                    icon: Icon(
                      Icons.more_vert, 
                      size: 18,
                      color: iconColor,
                    ),
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'report',
                        child: Text(
                          'Report',
                          style: TextStyle(color: Colors.grey.shade800),
                        ),
                      ),
                    ],
                    onSelected: (value) {
                      if (value == 'report') {
                        _chatService.reportMessage(message.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Message reported to moderators'),
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).padding.bottom,
        left: 8,
        right: 8,
        top: 4),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.15),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, -1),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            IconButton(
              icon: const Icon(Icons.emoji_emotions_outlined, 
                color: Colors.blueGrey,
                size: 22),
              onPressed: () {},
              padding: const EdgeInsets.all(8),
            ),
            Expanded(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxHeight: 80,
                  minHeight: 40,
                ),
                child: SingleChildScrollView(
                  reverse: true,
                  child: TextField(
                    controller: _messageController,
                    maxLines: null,
                    keyboardType: TextInputType.multiline,
                    textInputAction: TextInputAction.newline,
                    decoration: const InputDecoration(
                      hintText: 'Type a message...',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      isDense: true,
                    ),
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.attach_file, 
                color: Colors.blueGrey,
                size: 22),
              onPressed: () {},
              padding: const EdgeInsets.all(8),
            ),
            IconButton(
              icon: const Icon(Icons.camera_alt, 
                color: Colors.blueGrey,
                size: 22),
              onPressed: () {},
              padding: const EdgeInsets.all(8),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 6, bottom: 4),
              child: CircleAvatar(
                backgroundColor: const Color(0xFF269A51),
                radius: 20,
                child: IconButton(
                  icon: const Icon(Icons.send, 
                    color: Colors.white,
                    size: 18),
                  onPressed: () {
                    if (_messageController.text.trim().isNotEmpty && _user != null) {
                      _chatService.postMessage(
                        content: _messageController.text.trim(),
                        userId: _user.uid,
                        senderName: _anonymousUsername,
                      );
                      _messageController.clear();
                      _scrollController.animateTo(
                        0,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOut,
                      );
                    }
                  },
                  padding: EdgeInsets.zero,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReplyInput() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.15),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxHeight: 80,
                  minHeight: 40,
                ),
                child: SingleChildScrollView(
                  reverse: true,
                  child: TextField(
                    controller: _replyController,
                    maxLines: null,
                    keyboardType: TextInputType.multiline,
                    decoration: InputDecoration(
                      hintText: 'Replying...',
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      isDense: true,
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.close, size: 20),
                        onPressed: () {
                          setState(() {
                            _replyingToMessageId = null;
                          });
                        },
                        padding: EdgeInsets.zero,
                      ),
                    ),
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 6, bottom: 4),
              child: CircleAvatar(
                backgroundColor: const Color(0xFF269A51),
                radius: 20,
                child: IconButton(
                  icon: const Icon(Icons.send, size: 18, color: Colors.white),
                  onPressed: () {
                    if (_replyController.text.trim().isNotEmpty && 
                        _replyingToMessageId != null && 
                        _user != null) {
                      _chatService.postMessage(
                        content: _replyController.text.trim(),
                        parentId: _replyingToMessageId,
                        userId: _user.uid,
                        senderName: _anonymousUsername,
                      );
                      _replyController.clear();
                      setState(() {
                        _replyingToMessageId = null;
                      });
                      _scrollController.animateTo(
                        0,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOut,
                      );
                    }
                  },
                  padding: EdgeInsets.zero,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPrivacyInfo() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('Privacy Information'),
          content: const SingleChildScrollView(
            child: Text(
              'This is a completely anonymous space:\n\n'
              '• Your identity is never revealed\n'
              '• Messages are not linked to your account\n'
              '• Be kind and respectful to others\n'
              '• Report any inappropriate content\n\n'
              'Moderators may remove harmful content, but cannot identify who posted it.',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showBackgroundOptions() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.7,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const Text(
                'Choose Chat Background',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: 1.2,
                  ),
                  itemCount: _backgroundOptions.length,
                  itemBuilder: (context, index) {
                    final option = _backgroundOptions[index];
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          if (option.containsKey('image')) {
                            _chatBackgroundImage = option['image'];
                            _chatBackgroundColor = const Color(0xFFFDFDFD);
                            _saveBackgroundPreference(true, option['image']);
                          } else {
                            _chatBackgroundColor = option['color'] as Color;
                            _chatBackgroundImage = null;
                            _saveBackgroundPreference(false, '');
                          }
                        });
                        Navigator.pop(context);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: option['color'] as Color?,
                          image: option.containsKey('image')
                              ? DecorationImage(
                                  image: NetworkImage(option['image'] as String),
                                  fit: BoxFit.cover,
                                )
                              : null,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Center(
                          child: Text(
                            option['name'] as String,
                            style: TextStyle(
                              color: option.containsKey('image') 
                                  ? Colors.white 
                                  : Colors.black,
                              fontWeight: FontWeight.bold,
                              shadows: option.containsKey('image')
                                  ? [const Shadow(color: Colors.black, blurRadius: 4)]
                                  : null,
                            ),
                          ),
                        ),
                      ),
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
}