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

  // Create or join room
  Future<String> createOrJoinRoom(String roomId, RoomMember member) async {
    try {
      final roomDoc = _roomsCollection.doc(roomId);
      final roomSnapshot = await roomDoc.get();

      if (!roomSnapshot.exists) {
        // Create new room
        await roomDoc.set({
          'id': roomId,
          'name': 'Support Room',
          'createdAt': FieldValue.serverTimestamp(),
          'hostId': member.userId,
          'currentBackground': RoomBackground.defaultBackgrounds.first.toMap(),
          'isActive': true,
          'memberCount': 1,
        });
      }

      // Add member to room
      await roomDoc.collection('members').doc(member.id).set(member.toMap());

      return roomId;
    } catch (e) {
      throw Exception('Failed to create/join room: $e');
    }
  }

  // Stream for room members
  Stream<List<RoomMember>> getRoomMembersStream(String roomId) {
    return _roomsCollection
        .doc(roomId)
        .collection('members')
        .orderBy('joinedAt')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => RoomMember.fromMap(doc.data()))
            .toList());
  }

  // Stream for chat messages
  Stream<List<ChatMessage>> getChatMessagesStream(String roomId) {
    return _roomsCollection
        .doc(roomId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ChatMessage.fromMap(doc.data()))
            .toList());
  }

  // Send chat message
  Future<void> sendChatMessage(String roomId, ChatMessage message) async {
    try {
      await _roomsCollection
          .doc(roomId)
          .collection('messages')
          .doc(message.id)
          .set(message.toMap());
    } catch (e) {
      throw Exception('Failed to send message: $e');
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
        .map((snapshot) {
          final data = snapshot.data();
          if (data != null && (data as Map<String, dynamic>)['currentBackground'] != null) {
            return RoomBackground.fromMap(data['currentBackground']);
          }
          return RoomBackground.defaultBackgrounds.first;
        });
  }

  // Leave room
  Future<void> leaveRoom(String roomId, String memberId) async {
    try {
      await _roomsCollection
          .doc(roomId)
          .collection('members')
          .doc(memberId)
          .delete();
    } catch (e) {
      throw Exception('Failed to leave room: $e');
    }
  }

  // Update member speaking status
  Future<void> updateSpeakingStatus(String roomId, String memberId, bool isSpeaking) async {
    try {
      await _roomsCollection
          .doc(roomId)
          .collection('members')
          .doc(memberId)
          .update({'isSpeaking': isSpeaking});
    } catch (e) {
      throw Exception('Failed to update speaking status: $e');
    }
  }

  // Check if user is room host
  Future<bool> isRoomHost(String roomId, String userId) async {
    try {
      final doc = await _roomsCollection.doc(roomId).get();
      return doc.exists && (doc.data() as Map<String, dynamic>)['hostId'] == userId;
    } catch (e) {
      return false;
    }
  }
}