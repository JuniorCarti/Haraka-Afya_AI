import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/room_member.dart';
import '../models/chat_message.dart';
import '../models/room_background.dart';

class FirebaseRoomService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Collection references
  CollectionReference get _roomsCollection => _firestore.collection('voice_rooms');
  CollectionReference get _userUsernamesCollection => _firestore.collection('user_usernames');
  CollectionReference get _userAchievementsCollection => _firestore.collection('user_achievements');

  // Session management - Track which users are in which rooms
  final Map<String, Set<String>> _activeUsersInRooms = {}; // roomId -> Set<userId>

  // Get or create random username
  Future<String> getOrCreateUsername(String userId) async {
    try {
      // Check if user already has a username
      final doc = await _userUsernamesCollection.doc(userId).get();
      if (doc.exists) {
        return (doc.data() as Map<String, dynamic>)['username'] as String;
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
      });

      return username;
    } catch (e) {
      return 'Anonymous';
    }
  }

  // Get user achievements/level
  Future<Map<String, dynamic>> getUserAchievements(String userId) async {
    try {
      final doc = await _userAchievementsCollection.doc(userId).get();
      if (doc.exists) {
        return doc.data() as Map<String, dynamic>;
      }
      
      // Default achievements for new users
      return {
        'level': 1,
        'points': 0,
        'badges': [],
        'title': 'Newcomer',
        'totalMessages': 0,
        'roomsJoined': 1,
      };
    } catch (e) {
      return {
        'level': 1,
        'points': 0,
        'badges': [],
        'title': 'Newcomer',
        'totalMessages': 0,
        'roomsJoined': 1,
      };
    }
  }

  // Create or join room
  Future<String> createOrJoinRoom(String roomId, RoomMember member) async {
    try {
      final roomDoc = _roomsCollection.doc(roomId);
      final roomSnapshot = await roomDoc.get();

      // Track user as active in this room
      if (!_activeUsersInRooms.containsKey(roomId)) {
        _activeUsersInRooms[roomId] = <String>{};
      }
      _activeUsersInRooms[roomId]!.add(member.userId);

      if (!roomSnapshot.exists) {
        // Create new room
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

      // Add/update member in room
      await roomDoc.collection('members').doc(member.id).set(member.toMap());

      // Update room member count
      final membersSnapshot = await roomDoc.collection('members').get();
      await roomDoc.update({'memberCount': membersSnapshot.docs.length});

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

      return roomId;
    } catch (e) {
      throw Exception('Failed to create/join room: $e');
    }
  }

  // Generate session ID
  String _generateSessionId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  // Stream for room members with improved error handling
  Stream<List<RoomMember>> getRoomMembersStream(String roomId) {
    return _roomsCollection
        .doc(roomId)
        .collection('members')
        .orderBy('joinedAt')
        .snapshots()
        .handleError((error) {
          print('Error in members stream: $error');
          return Stream.value([]); // Return empty list on error
        })
        .map((snapshot) {
          try {
            return snapshot.docs
                .map((doc) => RoomMember.fromMap(doc.data()))
                .where((member) => member.id.isNotEmpty) // Filter invalid members
                .toList();
          } catch (e) {
            print('Error parsing members: $e');
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
          print('Error in messages stream: $error');
          return Stream.value([]); // Return empty list on error
        })
        .map((snapshot) {
          try {
            final messages = snapshot.docs
                .map((doc) => ChatMessage.fromMap(doc.data()))
                .where((message) => message.id.isNotEmpty) // Filter invalid messages
                .toList();
            
            // Return all messages if there are active users in the room
            if (_isRoomActive(roomId)) {
              return messages;
            } else {
              // Return empty list if no active users (room is empty)
              return [];
            }
          } catch (e) {
            print('Error parsing messages: $e');
            return [];
          }
        });
  }

  // Check if room has active users
  bool _isRoomActive(String roomId) {
    return _activeUsersInRooms.containsKey(roomId) && 
           _activeUsersInRooms[roomId]!.isNotEmpty;
  }

  // Send chat message
  Future<void> sendChatMessage(String roomId, ChatMessage message) async {
    try {
      // Only allow sending messages if user is active in the room
      if (_isUserActiveInRoom(roomId, message.userId) || message.userRole == UserRole.system) {
        await _roomsCollection
            .doc(roomId)
            .collection('messages')
            .doc(message.id)
            .set(message.toMap());

        // Update user's message count if it's a user message
        if (message.userRole == UserRole.user || message.userRole == UserRole.moderator || message.userRole == UserRole.admin) {
          await _updateUserMessageCount(message.userId);
        }
      }
    } catch (e) {
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
      
      final currentCount = achievements['totalMessages'] ?? 0;
      await achievementsDoc.set({
        'totalMessages': currentCount + 1,
        'lastMessageAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      print('Error updating user message count: $e');
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
      }
    } catch (e) {
      throw Exception('Failed to update room info: $e');
    }
  }

  // Get room information
  Future<Map<String, dynamic>> getRoomInfo(String roomId) async {
    try {
      final doc = await _roomsCollection.doc(roomId).get();
      if (doc.exists) {
        return doc.data() as Map<String, dynamic>;
      }
      throw Exception('Room not found');
    } catch (e) {
      throw Exception('Failed to get room info: $e');
    }
  }

  // Update room background
  Future<void> updateRoomBackground(String roomId, RoomBackground background) async {
    try {
      await _roomsCollection
          .doc(roomId)
          .update({'currentBackground': background.toMap()});
    } catch (e) {
      throw Exception('Failed to update background: $e');
    }
  }

  // Get room background stream
  Stream<RoomBackground> getRoomBackgroundStream(String roomId) {
    return _roomsCollection
        .doc(roomId)
        .snapshots()
        .handleError((error) {
          print('Error in background stream: $error');
          return Stream.value(RoomBackground.defaultBackgrounds.first);
        })
        .map((snapshot) {
          try {
            final data = snapshot.data();
            if (data != null && (data as Map<String, dynamic>)['currentBackground'] != null) {
              return RoomBackground.fromMap(data['currentBackground']);
            }
            return RoomBackground.defaultBackgrounds.first;
          } catch (e) {
            print('Error parsing background: $e');
            return RoomBackground.defaultBackgrounds.first;
          }
        });
  }

  // NEW: Switch host to speaker seat
  Future<void> switchHostToSpeaker(String roomId, String userId) async {
    try {
      final roomRef = _roomsCollection.doc(roomId);
      
      // Update the user's role to speaker
      await roomRef.collection('members').doc(userId).update({
        'role': _roleToString(MemberRole.speaker),
        'isSpeaking': true,
        'isHost': false,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Try to transfer host role to another member
      await _transferHostToAnotherMember(roomId, userId);
      
    } catch (e) {
      print('Error switching host to speaker: $e');
      rethrow;
    }
  }

  // NEW: Transfer host role to another member
  Future<void> _transferHostToAnotherMember(String roomId, String currentHostId) async {
    try {
      final membersSnapshot = await _firestore
          .collection('voice_rooms')
          .doc(roomId)
          .collection('members')
          .where('userId', isNotEqualTo: currentHostId)
          .where('role', whereIn: ['moderator', 'speaker', 'listener'])
          .orderBy('joinedAt')
          .limit(1)
          .get();
      
      if (membersSnapshot.docs.isNotEmpty) {
        final newHost = membersSnapshot.docs.first;
        final newHostData = newHost.data();
        
        await _firestore
            .collection('voice_rooms')
            .doc(roomId)
            .collection('members')
            .doc(newHost.id)
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
              'hostId': newHostData['userId'],
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
      } else {
        // No other members to transfer to, room continues without host
        await _firestore
            .collection('voice_rooms')
            .doc(roomId)
            .update({
              'hostId': null,
            });
      }
    } catch (e) {
      print('Error transferring host role: $e');
      // Continue without host if transfer fails
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

  // Leave room - CLEARS MESSAGES when user leaves
  Future<void> leaveRoom(String roomId, String memberId, String username) async {
    try {
      // Remove user from active users tracking
      if (_activeUsersInRooms.containsKey(roomId)) {
        _activeUsersInRooms[roomId]!.remove(memberId);
        
        // If no more active users, clear all messages
        if (_activeUsersInRooms[roomId]!.isEmpty) {
          await _clearAllRoomMessages(roomId);
          _activeUsersInRooms.remove(roomId);
        }
      }

      // Remove member from room
      await _roomsCollection
          .doc(roomId)
          .collection('members')
          .doc(memberId)
          .delete();

      // Update room member count
      final membersSnapshot = await _roomsCollection
          .doc(roomId)
          .collection('members')
          .get();
      
      await _roomsCollection
          .doc(roomId)
          .update({'memberCount': membersSnapshot.docs.length});

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

    } catch (e) {
      throw Exception('Failed to leave room: $e');
    }
  }

  // Clear all messages in room (when room becomes empty)
  Future<void> _clearAllRoomMessages(String roomId) async {
    try {
      final messagesSnapshot = await _roomsCollection
          .doc(roomId)
          .collection('messages')
          .get();

      final batch = _firestore.batch();
      for (final doc in messagesSnapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
      
      print('Cleared all messages for room: $roomId');
    } catch (e) {
      print('Error clearing room messages: $e');
    }
  }

  // Update member speaking status
  Future<void> updateSpeakingStatus(String roomId, String memberId, bool isSpeaking) async {
    try {
      await _roomsCollection
          .doc(roomId)
          .collection('members')
          .doc(memberId)
          .update({
            'isSpeaking': isSpeaking,
            'lastActive': FieldValue.serverTimestamp(),
          });
    } catch (e) {
      throw Exception('Failed to update speaking status: $e');
    }
  }

  // Update member role with improved error handling
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
    } catch (e) {
      throw Exception('Failed to update member role: $e');
    }
  }

  // Check if user is room host
  Future<bool> isRoomHost(String roomId, String userId) async {
    try {
      final doc = await _roomsCollection.doc(roomId).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        return data['hostId'] == userId;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Get current session ID
  String? getCurrentSessionId(String roomId) {
    return 'current';
  }

  // Transfer host role
  Future<void> transferHostRole(String roomId, String newHostId) async {
    try {
      await _roomsCollection
          .doc(roomId)
          .update({'hostId': newHostId});
    } catch (e) {
      throw Exception('Failed to transfer host role: $e');
    }
  }

  // Get user level
  Future<int> getUserLevel(String userId) async {
    final achievements = await getUserAchievements(userId);
    return achievements['level'] ?? 1;
  }

  // Get message color based on user level and role
  Future<String> getUserMessageColor(String userId, UserRole role) async {
    if (role == UserRole.admin) {
      return '#FFD700'; // Gold for admin
    } else if (role == UserRole.moderator) {
      return '#4CAF50'; // Green for moderator
    }

    final level = await getUserLevel(userId);
    
    if (level >= 10) return '#FF6B6B'; // Bright red for high level
    if (level >= 5) return '#48DBFB'; // Bright blue for medium level
    if (level >= 3) return '#FFA500'; // Orange for low-medium level
    
    return '#4A5568'; // Default gray for new users
  }

  // Get room host safely
  Future<RoomMember?> getRoomHost(String roomId) async {
    try {
      final hostSnapshot = await _firestore
          .collection('voice_rooms')
          .doc(roomId)
          .collection('members')
          .where('isHost', isEqualTo: true)
          .limit(1)
          .get();
      
      if (hostSnapshot.docs.isNotEmpty) {
        return RoomMember.fromMap(hostSnapshot.docs.first.data());
      }
      
      // Fallback: get first member if no host found
      final membersSnapshot = await _firestore
          .collection('voice_rooms')
          .doc(roomId)
          .collection('members')
          .limit(1)
          .get();
      
      if (membersSnapshot.docs.isNotEmpty) {
        return RoomMember.fromMap(membersSnapshot.docs.first.data());
      }
      
      return null;
    } catch (e) {
      print('Error getting room host: $e');
      return null;
    }
  }

  // Get active users count for a room
  int getActiveUsersCount(String roomId) {
    return _activeUsersInRooms.containsKey(roomId) ? _activeUsersInRooms[roomId]!.length : 0;
  }

  // Check if user is active in any room
  bool isUserActive(String userId) {
    return _activeUsersInRooms.values.any((users) => users.contains(userId));
  }

  // Force clear all messages (admin function)
  Future<void> adminClearAllMessages(String roomId) async {
    await _clearAllRoomMessages(roomId);
  }
}