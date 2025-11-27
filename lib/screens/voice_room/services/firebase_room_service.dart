import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/room_member.dart';
import '../widgets/models/chat_message.dart';
import '../models/room_background.dart';

class FirebaseRoomService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Collection references
  CollectionReference get _roomsCollection => _firestore.collection('voice_rooms');
  CollectionReference get _userUsernamesCollection => _firestore.collection('user_usernames');
  CollectionReference get _userAchievementsCollection => _firestore.collection('user_achievements');

  // Session management with audio state tracking
  final Map<String, Set<String>> _activeUsersInRooms = {};
  final Map<String, Map<String, bool>> _userAudioStates = {}; // roomId -> userId -> isSpeaking

  // Get or create username with better error handling
  Future<String> getOrCreateUsername(String userId) async {
    try {
      // Check if user already has a username
      final doc = await _userUsernamesCollection.doc(userId).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>?;
        if (data != null && data['username'] != null) {
          return data['username'] as String;
        }
      }

      // Generate random username
      final randomUsernames = [
        'CalmOcean', 'MindfulWalker', 'PeacefulSoul', 'SereneHeart', 'TranquilMind',
        'GentleBreeze', 'QuietStream', 'StillWater', 'BrightStar', 'WarmSun',
        'SoftRain', 'MountainView', 'ForestFriend', 'OceanWave', 'SkyWatcher',
        'DreamCatcher', 'HopeBringer', 'LightBearer', 'JoySeeker', 'PeaceMaker'
      ];
      
      final randomIndex = DateTime.now().millisecondsSinceEpoch % randomUsernames.length;
      final username = randomUsernames[randomIndex];

      // Save to Firestore
      await _userUsernamesCollection.doc(userId).set({
        'username': username,
        'createdAt': FieldValue.serverTimestamp(),
        'userId': userId,
        'lastActive': FieldValue.serverTimestamp(),
      });

      print('✅ Created new username: $username for user: $userId');
      return username;
    } catch (e) {
      print('❌ Error getting/creating username: $e');
      return 'Anonymous${DateTime.now().millisecondsSinceEpoch % 1000}';
    }
  }

  // Get user achievements with audio-specific tracking
  Future<Map<String, dynamic>> getUserAchievements(String userId) async {
    try {
      final doc = await _userAchievementsCollection.doc(userId).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>?;
        if (data != null) {
          return data;
        }
      }
      
      // Default achievements for new users with audio tracking
      return {
        'level': 1,
        'points': 0,
        'badges': [],
        'title': 'Newcomer',
        'totalMessages': 0,
        'roomsJoined': 1,
        'totalSpeakingTime': 0,
        'voiceSessions': 0,
        'lastVoiceSession': null,
        'audioQuality': 'good',
        'microphoneEnabled': false,
        'createdAt': FieldValue.serverTimestamp(),
      };
    } catch (e) {
      print('❌ Error getting user achievements: $e');
      return {
        'level': 1,
        'points': 0,
        'badges': [],
        'title': 'Newcomer',
        'totalMessages': 0,
        'roomsJoined': 1,
        'totalSpeakingTime': 0,
        'voiceSessions': 0,
      };
    }
  }

  // Create or join room with audio state initialization
  Future<void> createOrJoinRoom(String roomId, RoomMember member) async {
    try {
      final roomDoc = _roomsCollection.doc(roomId);
      final roomSnapshot = await roomDoc.get();

      // Initialize audio state tracking for this room
      if (!_activeUsersInRooms.containsKey(roomId)) {
        _activeUsersInRooms[roomId] = <String>{};
        _userAudioStates[roomId] = {};
      }
      _activeUsersInRooms[roomId]!.add(member.userId);
      _userAudioStates[roomId]![member.userId] = false; // Start muted

      if (!roomSnapshot.exists) {
        // Create new room with audio-specific settings
        await roomDoc.set({
          'id': roomId,
          'name': 'Support Room',
          'description': 'A safe space for support and conversation',
          'welcomeMessage': 'Welcome to our support room! Feel free to share and connect.',
          'createdAt': FieldValue.serverTimestamp(),
          'hostId': member.userId,
          'currentBackground': RoomBackground.defaultBackgrounds.first.toMap(),
          'isActive': true,
          'memberCount': 1,
          'currentSessionId': _generateSessionId(),
          'audioSettings': {
            'noiseSuppression': true,
            'echoCancellation': true,
            'autoGainControl': true,
            'maxSpeakers': 6,
            'allowBackgroundAudio': false,
          },
          'lastActivity': FieldValue.serverTimestamp(),
        });

        // Send welcome message
        final welcomeMessage = ChatMessage(
          id: 'welcome_${DateTime.now().millisecondsSinceEpoch}',
          roomId: roomId,
          userId: 'system',
          username: 'System',
          text: 'Welcome to our support room! Feel free to share and connect.',
          timestamp: DateTime.now(),
          userRole: UserRole.system,
          userLevel: 0,
          messageColor: '#4CAF50',
          isWelcomeMessage: true,
          sessionId: 'system',
        );
        await sendChatMessage(roomId, welcomeMessage);
      }

      // Add/update member with audio state
      final memberData = member.toMap();
      memberData['audioState'] = {
        'isSpeaking': false,
        'isMuted': true,
        'hasAudioPermission': true,
        'lastAudioUpdate': FieldValue.serverTimestamp(),
        'audioDevice': 'default',
      };

      await roomDoc.collection('members').doc(member.id).set(memberData);

      // Update room member count and last activity
      final membersSnapshot = await roomDoc.collection('members').get();
      await roomDoc.update({
        'memberCount': membersSnapshot.docs.length,
        'lastActivity': FieldValue.serverTimestamp(),
      });

      // Send join notification only if not the first user
      if (roomSnapshot.exists) {
        final joinMessage = ChatMessage(
          id: 'join_${DateTime.now().millisecondsSinceEpoch}',
          roomId: roomId,
          userId: 'system',
          username: 'System',
          text: '${member.username} joined the room',
          timestamp: DateTime.now(),
          userRole: UserRole.system,
          userLevel: 0,
          messageColor: '#2196F3',
          sessionId: 'system',
        );
        await sendChatMessage(roomId, joinMessage);
      }

      // Update user achievements for room join
      await _updateUserRoomJoin(member.userId);

      print('✅ Successfully joined room: $roomId with audio state initialized');
    } catch (e) {
      print('❌ Error creating/joining room: $e');
      throw Exception('Failed to create/join room: $e');
    }
  }

  // Update user achievements when joining room
  Future<void> _updateUserRoomJoin(String userId) async {
    try {
      final achievementsDoc = _userAchievementsCollection.doc(userId);
      final achievements = await getUserAchievements(userId);
      
      final currentRoomsJoined = (achievements['roomsJoined'] as int?) ?? 0;
      final currentVoiceSessions = (achievements['voiceSessions'] as int?) ?? 0;
      
      await achievementsDoc.set({
        'roomsJoined': currentRoomsJoined + 1,
        'voiceSessions': currentVoiceSessions + 1,
        'lastVoiceSession': FieldValue.serverTimestamp(),
        'lastActive': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      print('❌ Error updating user room join: $e');
    }
  }

  // Generate session ID with audio context
  String _generateSessionId() {
    return 'audio_${DateTime.now().millisecondsSinceEpoch}';
  }

  // Stream for room members with audio state
  Stream<List<RoomMember>> getRoomMembersStream(String roomId) {
    return _roomsCollection
        .doc(roomId)
        .collection('members')
        .orderBy('joinedAt')
        .snapshots()
        .handleError((error) {
          print('❌ Error in members stream: $error');
          return Stream.value([]);
        })
        .map((snapshot) {
          try {
            final members = snapshot.docs
                .map((doc) {
                  try {
                    final data = doc.data();
                    // Enhanced validation with audio state
                    if (data['userId'] == null || data['username'] == null) {
                      print('⚠️ Invalid member data: $data');
                      return null;
                    }
                    
                    // Merge real-time audio state with stored data
                    final member = RoomMember.fromMap(data);
                    
                    // Update with real-time audio state if available
                    if (_userAudioStates.containsKey(roomId) && 
                        _userAudioStates[roomId]!.containsKey(member.userId)) {
                      final isSpeaking = _userAudioStates[roomId]![member.userId] ?? false;
                      member.updateSpeakingStatus(isSpeaking);
                    }
                    
                    return member;
                  } catch (e) {
                    print('❌ Error parsing individual member: $e');
                    return null;
                  }
                })
                .where((member) => member != null && member.isValid)
                .cast<RoomMember>()
                .toList();

            print('📊 Loaded ${members.length} valid members with audio states');
            return members;
          } catch (e) {
            print('❌ Error parsing members list: $e');
            return [];
          }
        });
  }

  // Stream for chat messages with improved error handling
  Stream<List<ChatMessage>> getChatMessagesStream(String roomId) {
    return _roomsCollection
        .doc(roomId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .handleError((error) {
          print('❌ Error in messages stream: $error');
          return Stream.value([]);
        })
        .map((snapshot) {
          try {
            final messages = snapshot.docs
                .map((doc) {
                  try {
                    final data = doc.data();
                    // Validate required fields
                    if (data['id'] == null || data['text'] == null || data['userId'] == null) {
                      print('⚠️ Invalid message data: $data');
                      return null;
                    }
                    return ChatMessage.fromMap(data);
                  } catch (e) {
                    print('❌ Error parsing individual message: $e');
                    return null;
                  }
                })
                .where((message) => message != null && message.id.isNotEmpty)
                .cast<ChatMessage>()
                .toList();
            
            // Return all messages if there are active users in the room
            if (_isRoomActive(roomId)) {
              return messages;
            } else {
              // Return empty list if no active users (room is empty)
              return [];
            }
          } catch (e) {
            print('❌ Error parsing messages list: $e');
            return [];
          }
        });
  }

  // Check if room has active users
  bool _isRoomActive(String roomId) {
    return _activeUsersInRooms.containsKey(roomId) && 
           _activeUsersInRooms[roomId]!.isNotEmpty;
  }

  // Speaking status update with audio verification
  Future<void> updateSpeakingStatus(String roomId, String memberId, bool isSpeaking) async {
    try {
      print('🎤 Updating speaking status: $memberId -> $isSpeaking');
      
      // Update real-time audio state
      if (_userAudioStates.containsKey(roomId)) {
        _userAudioStates[roomId]![memberId] = isSpeaking;
      }

      // Update Firestore with enhanced audio data
      await _roomsCollection
          .doc(roomId)
          .collection('members')
          .doc(memberId)
          .update({
            'isSpeaking': isSpeaking,
            'lastActive': FieldValue.serverTimestamp(),
            'lastAudioActivity': FieldValue.serverTimestamp(),
            'audioState.isSpeaking': isSpeaking,
            'audioState.lastAudioUpdate': FieldValue.serverTimestamp(),
          });

      // Update room activity timestamp
      await _roomsCollection
          .doc(roomId)
          .update({
            'lastActivity': FieldValue.serverTimestamp(),
          });

      // Update user speaking time if they started speaking
      if (isSpeaking) {
        await _updateUserSpeakingTime(memberId);
      }

      print('✅ Speaking status updated for member: $isSpeaking');
    } catch (e) {
      print('❌ Error updating speaking status: $e');
      throw Exception('Failed to update speaking status: $e');
    }
  }

  // Track user speaking time for achievements
  Future<void> _updateUserSpeakingTime(String userId) async {
    try {
      final achievementsDoc = _userAchievementsCollection.doc(userId);
      final achievements = await getUserAchievements(userId);
      
      final currentSpeakingTime = (achievements['totalSpeakingTime'] as int?) ?? 0;
      await achievementsDoc.set({
        'totalSpeakingTime': currentSpeakingTime + 1, // Increment by 1 minute (approximate)
        'lastSpeakingActivity': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      print('❌ Error updating user speaking time: $e');
    }
  }

  // Leave room with audio state cleanup
  Future<void> leaveRoom(String roomId, String memberId, String username) async {
    try {
      print('🚪 Leaving room: $roomId, user: $username ($memberId)');
      
      // Clean up audio state tracking
      if (_activeUsersInRooms.containsKey(roomId)) {
        _activeUsersInRooms[roomId]!.remove(memberId);
      }
      if (_userAudioStates.containsKey(roomId)) {
        _userAudioStates[roomId]!.remove(memberId);
      }

      // Remove member from room
      await _roomsCollection
          .doc(roomId)
          .collection('members')
          .doc(memberId)
          .delete();

      // Update room member count and activity
      final membersSnapshot = await _roomsCollection
          .doc(roomId)
          .collection('members')
          .get();
      
      await _roomsCollection
          .doc(roomId)
          .update({
            'memberCount': membersSnapshot.docs.length,
            'lastActivity': FieldValue.serverTimestamp(),
          });

      // Send leave notification
      final leaveMessage = ChatMessage(
        id: 'leave_${DateTime.now().millisecondsSinceEpoch}',
        roomId: roomId,
        userId: 'system',
        username: 'System',
        text: '$username left the room',
        timestamp: DateTime.now(),
        userRole: UserRole.system,
        userLevel: 0,
        messageColor: '#FF5722',
        sessionId: 'system',
      );
      await sendChatMessage(roomId, leaveMessage);

      // If no more active users, clear room data
      if (_activeUsersInRooms.containsKey(roomId) && _activeUsersInRooms[roomId]!.isEmpty) {
        await _clearInactiveRoomData(roomId);
        _activeUsersInRooms.remove(roomId);
        _userAudioStates.remove(roomId);
        print('🗑️ Cleared inactive room data: $roomId');
      }

      print('✅ User $username successfully left room $roomId');
    } catch (e) {
      print('❌ Error leaving room: $e');
      throw Exception('Failed to leave room: $e');
    }
  }

  // Clear inactive room data (optimized)
  Future<void> _clearInactiveRoomData(String roomId) async {
    try {
      // Only clear messages, keep room structure
      final messagesSnapshot = await _roomsCollection
          .doc(roomId)
          .collection('messages')
          .where('userRole', isNotEqualTo: 'system')
          .get();

      final batch = _firestore.batch();
      for (final doc in messagesSnapshot.docs) {
        batch.delete(doc.reference);
      }
      
      if (messagesSnapshot.docs.isNotEmpty) {
        await batch.commit();
        print('🗑️ Cleared ${messagesSnapshot.docs.length} user messages from room: $roomId');
      }
    } catch (e) {
      print('❌ Error clearing inactive room data: $e');
    }
  }

  // Seat management with audio state integration
  Future<void> assignSeat(String roomId, String userId, int seatNumber) async {
    try {
      print('💺 Assigning seat $seatNumber to user $userId');
      
      await _firestore
          .collection('voice_rooms')
          .doc(roomId)
          .collection('members')
          .doc(userId)
          .update({
            'seatNumber': seatNumber,
            'isSpeaking': true, // Auto-unmute when taking a seat
            'role': _roleToString(MemberRole.speaker),
            'lastActive': FieldValue.serverTimestamp(),
            'audioState.isSpeaking': true,
            'audioState.isMuted': false,
            'audioState.lastAudioUpdate': FieldValue.serverTimestamp(),
          });

      // Update real-time audio state
      if (_userAudioStates.containsKey(roomId)) {
        _userAudioStates[roomId]![userId] = true;
      }

      // Send seat assignment notification
      final memberDoc = await _firestore
          .collection('voice_rooms')
          .doc(roomId)
          .collection('members')
          .doc(userId)
          .get();
      
      if (memberDoc.exists) {
        final memberData = memberDoc.data() as Map<String, dynamic>;
        final seatMessage = ChatMessage(
          id: 'seat_${DateTime.now().millisecondsSinceEpoch}',
          roomId: roomId,
          userId: 'system',
          username: 'System',
          text: '${memberData['username']} joined seat $seatNumber',
          timestamp: DateTime.now(),
          userRole: UserRole.system,
          userLevel: 0,
          messageColor: '#9C27B0',
          sessionId: 'system',
        );
        await sendChatMessage(roomId, seatMessage);
      }

      print('✅ Seat $seatNumber assigned to user $userId with audio enabled');
    } catch (e) {
      print('❌ Error assigning seat: $e');
      throw Exception('Failed to assign seat: $e');
    }
  }

  // Leave seat with proper audio state cleanup
  Future<void> leaveSeat(String roomId, String userId) async {
    try {
      print('💺 Leaving seat for user $userId');
      
      await _firestore
          .collection('voice_rooms')
          .doc(roomId)
          .collection('members')
          .doc(userId)
          .update({
            'seatNumber': FieldValue.delete(),
            'isSpeaking': false, // Auto-mute when leaving seat
            'role': _roleToString(MemberRole.listener),
            'lastActive': FieldValue.serverTimestamp(),
            'audioState.isSpeaking': false,
            'audioState.isMuted': true,
            'audioState.lastAudioUpdate': FieldValue.serverTimestamp(),
          });

      // Update real-time audio state
      if (_userAudioStates.containsKey(roomId)) {
        _userAudioStates[roomId]![userId] = false;
      }

      print('✅ User $userId left their seat with audio disabled');
    } catch (e) {
      print('❌ Error leaving seat: $e');
      throw Exception('Failed to leave seat: $e');
    }
  }

  // Switch host to speaker role when they take a seat
  Future<void> switchHostToSpeaker(String roomId, String hostId) async {
    try {
      print('🔄 Switching host $hostId to speaker role');
      
      // Update host's role to speaker but keep host privileges
      await _firestore
          .collection('voice_rooms')
          .doc(roomId)
          .collection('members')
          .doc(hostId)
          .update({
            'role': _roleToString(MemberRole.speaker),
            'isSpeaking': true,
            'lastActive': FieldValue.serverTimestamp(),
            'audioState.isSpeaking': true,
            'audioState.isMuted': false,
            'audioState.lastAudioUpdate': FieldValue.serverTimestamp(),
          });

      // Update real-time audio state
      if (_userAudioStates.containsKey(roomId)) {
        _userAudioStates[roomId]![hostId] = true;
      }

      // Send system notification
      final switchMessage = ChatMessage(
        id: 'switch_${DateTime.now().millisecondsSinceEpoch}',
        roomId: roomId,
        userId: 'system',
        username: 'System',
        text: 'Host joined as a speaker',
        timestamp: DateTime.now(),
        userRole: UserRole.system,
        userLevel: 0,
        messageColor: '#FF9800',
        sessionId: 'system',
      );
      await sendChatMessage(roomId, switchMessage);

      print('✅ Host $hostId switched to speaker role with audio enabled');
    } catch (e) {
      print('❌ Error switching host to speaker: $e');
      throw Exception('Failed to switch host to speaker: $e');
    }
  }

  // Get real-time audio state for a user
  bool? getUserAudioState(String roomId, String userId) {
    if (_userAudioStates.containsKey(roomId) && 
        _userAudioStates[roomId]!.containsKey(userId)) {
      return _userAudioStates[roomId]![userId];
    }
    return null;
  }

  // Get all speaking users in a room
  List<String> getSpeakingUsers(String roomId) {
    if (!_userAudioStates.containsKey(roomId)) return [];
    
    return _userAudioStates[roomId]!
        .entries
        .where((entry) => entry.value == true)
        .map((entry) => entry.key)
        .toList();
  }

  // Get active speakers count
  int getActiveSpeakersCount(String roomId) {
    return getSpeakingUsers(roomId).length;
  }

  // Update user microphone permission state
  Future<void> updateMicrophonePermission(String userId, bool hasPermission) async {
    try {
      await _userAchievementsCollection.doc(userId).set({
        'microphoneEnabled': hasPermission,
        'lastPermissionCheck': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      
      print('✅ Microphone permission updated: $hasPermission for user: $userId');
    } catch (e) {
      print('❌ Error updating microphone permission: $e');
    }
  }

  // Get room audio statistics
  Future<Map<String, dynamic>> getRoomAudioStats(String roomId) async {
    try {
      final speakingUsers = getSpeakingUsers(roomId);
      final activeUsers = _activeUsersInRooms[roomId]?.length ?? 0;
      
      return {
        'activeSpeakers': speakingUsers.length,
        'totalActiveUsers': activeUsers,
        'speakingPercentage': activeUsers > 0 ? (speakingUsers.length / activeUsers) * 100 : 0,
        'speakingUserIds': speakingUsers,
        'roomAudioEnabled': true,
        'lastAudioUpdate': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      print('❌ Error getting room audio stats: $e');
      return {
        'activeSpeakers': 0,
        'totalActiveUsers': 0,
        'speakingPercentage': 0,
        'speakingUserIds': [],
        'roomAudioEnabled': false,
        'error': e.toString(),
      };
    }
  }

  // Check if seat is available with audio state consideration
  Future<bool> isSeatAvailable(String roomId, int seatNumber) async {
    try {
      final seatOccupant = await _firestore
          .collection('voice_rooms')
          .doc(roomId)
          .collection('members')
          .where('seatNumber', isEqualTo: seatNumber)
          .limit(1)
          .get();

      final isAvailable = seatOccupant.docs.isEmpty;
      print('💺 Seat $seatNumber available: $isAvailable');
      return isAvailable;
    } catch (e) {
      print('❌ Error checking seat availability: $e');
      return false;
    }
  }

  // Get current seat with audio state
  Future<int?> getCurrentSeat(String roomId, String userId) async {
    try {
      final memberDoc = await _firestore
          .collection('voice_rooms')
          .doc(roomId)
          .collection('members')
          .doc(userId)
          .get();

      if (memberDoc.exists) {
        final data = memberDoc.data();
        final seatNumber = data?['seatNumber'] as int?;
        print('💺 User $userId current seat: $seatNumber');
        return seatNumber;
      }
      return null;
    } catch (e) {
      print('❌ Error getting current seat: $e');
      return null;
    }
  }

  // Send chat message
  Future<void> sendChatMessage(String roomId, ChatMessage message) async {
    try {
      // Enhanced validation with audio state check
      if (_isUserActiveInRoom(roomId, message.userId) || message.userRole == UserRole.system) {
        await _roomsCollection
            .doc(roomId)
            .collection('messages')
            .doc(message.id)
            .set(message.toMap());

        // Update user's message count and activity
        if (message.userRole == UserRole.user || message.userRole == UserRole.moderator || message.userRole == UserRole.admin) {
          await _updateUserMessageCount(message.userId);
        }
        
        // Update room activity
        await _roomsCollection
            .doc(roomId)
            .update({
              'lastActivity': FieldValue.serverTimestamp(),
            });

        print('✅ Message sent by ${message.username} with audio context');
      } else {
        print('❌ User not active in room, message not sent');
        throw Exception('User not active in room');
      }
    } catch (e) {
      print('❌ Error sending message: $e');
      throw Exception('Failed to send message: $e');
    }
  }

  // Check if user is active in room
  bool _isUserActiveInRoom(String roomId, String userId) {
    return _activeUsersInRooms.containsKey(roomId) && 
           _activeUsersInRooms[roomId]!.contains(userId);
  }

  // Update user's message count for achievements
  Future<void> _updateUserMessageCount(String userId) async {
    try {
      final achievementsDoc = _userAchievementsCollection.doc(userId);
      final achievements = await getUserAchievements(userId);
      
      final currentCount = (achievements['totalMessages'] as int?) ?? 0;
      await achievementsDoc.set({
        'totalMessages': currentCount + 1,
        'lastMessageAt': FieldValue.serverTimestamp(),
        'lastActive': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      print('❌ Error updating user message count: $e');
    }
  }

  // Update room information
  Future<void> updateRoomInfo({
    required String roomId,
    String? name,
    String? description,
    String? welcomeMessage,
  }) async {
    try {
      final updates = <String, dynamic>{};
      if (name != null) updates['name'] = name;
      if (description != null) updates['description'] = description;
      if (welcomeMessage != null) updates['welcomeMessage'] = welcomeMessage;

      if (updates.isNotEmpty) {
        await _roomsCollection.doc(roomId).update(updates);
        print('✅ Room info updated successfully');
      }
    } catch (e) {
      print('❌ Error updating room info: $e');
      throw Exception('Failed to update room info: $e');
    }
  }

  // Get room information
  Future<Map<String, dynamic>> getRoomInfo(String roomId) async {
    try {
      final doc = await _roomsCollection.doc(roomId).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>?;
        if (data != null) {
          return data;
        }
      }
      throw Exception('Room not found');
    } catch (e) {
      print('❌ Error getting room info: $e');
      throw Exception('Failed to get room info: $e');
    }
  }

  // Update room background
  Future<void> updateRoomBackground(String roomId, RoomBackground background) async {
    try {
      await _roomsCollection
          .doc(roomId)
          .update({'currentBackground': background.toMap()});
      print('✅ Room background updated');
    } catch (e) {
      print('❌ Error updating background: $e');
      throw Exception('Failed to update background: $e');
    }
  }

  // Get room background stream
  Stream<RoomBackground> getRoomBackgroundStream(String roomId) {
    return _roomsCollection
        .doc(roomId)
        .snapshots()
        .handleError((error) {
          print('❌ Error in background stream: $error');
          return Stream.value(RoomBackground.defaultBackgrounds.first);
        })
        .map((snapshot) {
          try {
            final data = snapshot.data();
            if (data != null) {
              final backgroundData = (data as Map<String, dynamic>)['currentBackground'];
              if (backgroundData != null) {
                return RoomBackground.fromMap(backgroundData);
              }
            }
            return RoomBackground.defaultBackgrounds.first;
          } catch (e) {
            print('❌ Error parsing background: $e');
            return RoomBackground.defaultBackgrounds.first;
          }
        });
  }

  // Check if user is room host
  Future<bool> isRoomHost(String roomId, String userId) async {
    try {
      final doc = await _roomsCollection.doc(roomId).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>?;
        if (data != null && data['hostId'] != null) {
          return data['hostId'] == userId;
        }
      }
      return false;
    } catch (e) {
      print('❌ Error checking room host: $e');
      return false;
    }
  }

  // Update member role
  Future<void> updateMemberRole(String roomId, String memberId, MemberRole role) async {
    try {
      await _roomsCollection
          .doc(roomId)
          .collection('members')
          .doc(memberId)
          .update({
            'role': _roleToString(role),
            'isHost': role == MemberRole.admin,
            'lastActive': FieldValue.serverTimestamp(),
          });
      print('✅ Member role updated to: ${_roleToString(role)}');
    } catch (e) {
      print('❌ Error updating member role: $e');
      throw Exception('Failed to update member role: $e');
    }
  }

  // Transfer host role to specific user
  Future<void> transferHost(String roomId, String newHostId) async {
    try {
      // Get the new host's member data
      final newHostDoc = await _firestore
          .collection('voice_rooms')
          .doc(roomId)
          .collection('members')
          .doc(newHostId)
          .get();

      if (!newHostDoc.exists) {
        throw Exception('New host member not found');
      }

      final newHostData = newHostDoc.data() as Map<String, dynamic>;

      // Update new host's role to admin
      await _firestore
          .collection('voice_rooms')
          .doc(roomId)
          .collection('members')
          .doc(newHostId)
          .update({
            'role': _roleToString(MemberRole.admin),
            'isHost': true,
            'updatedAt': FieldValue.serverTimestamp(),
          });

      // Update room host ID
      await _firestore
          .collection('voice_rooms')
          .doc(roomId)
          .update({
            'hostId': newHostId,
          });

      // Send system message about host transfer
      final transferMessage = ChatMessage(
        id: 'transfer_${DateTime.now().millisecondsSinceEpoch}',
        roomId: roomId,
        userId: 'system',
        username: 'System',
        text: '${newHostData['username']} is now the room host',
        timestamp: DateTime.now(),
        userRole: UserRole.system,
        userLevel: 0,
        messageColor: '#FFD700',
        sessionId: 'system',
      );
      await sendChatMessage(roomId, transferMessage);

      print('✅ Host role transferred to ${newHostData['username']}');
    } catch (e) {
      print('❌ Error transferring host role: $e');
      rethrow;
    }
  }

  // Get all occupied seats in a room
  Future<Map<int, String>> getOccupiedSeats(String roomId) async {
    try {
      final membersSnapshot = await _firestore
          .collection('voice_rooms')
          .doc(roomId)
          .collection('members')
          .where('seatNumber', isNotEqualTo: null)
          .get();

      final occupiedSeats = <int, String>{};
      for (final doc in membersSnapshot.docs) {
        final data = doc.data();
        final seatNumber = data['seatNumber'] as int?;
        final username = data['username'] as String?;
        if (seatNumber != null && username != null) {
          occupiedSeats[seatNumber] = username;
        }
      }

      return occupiedSeats;
    } catch (e) {
      print('❌ Error getting occupied seats: $e');
      return {};
    }
  }

  // Get all available seats (1-8)
  Future<List<int>> getAvailableSeats(String roomId) async {
    try {
      final occupiedSeats = await getOccupiedSeats(roomId);
      final allSeats = List.generate(8, (index) => index + 1); // Seats 1-8
      return allSeats.where((seat) => !occupiedSeats.containsKey(seat)).toList();
    } catch (e) {
      print('❌ Error getting available seats: $e');
      return List.generate(8, (index) => index + 1);
    }
  }

  // Check if user has a seat
  Future<bool> hasSeat(String roomId, String userId) async {
    try {
      final currentSeat = await getCurrentSeat(roomId, userId);
      return currentSeat != null;
    } catch (e) {
      print('❌ Error checking if user has seat: $e');
      return false;
    }
  }

  // Helper method to convert MemberRole to string
  String _roleToString(MemberRole role) {
    switch (role) {
      case MemberRole.admin:
        return 'admin';
      case MemberRole.moderator:
        return 'moderator';
      case MemberRole.speaker:
        return 'speaker';
      case MemberRole.listener:
        return 'listener';
      default:
        return 'listener';
    }
  }

  void dispose() {
    print('🧹 Cleaning up Firebase Room Service...');
    // Clear all tracking data
    _activeUsersInRooms.clear();
    _userAudioStates.clear();
    print('✅ Firebase Room Service disposed');
  }
}