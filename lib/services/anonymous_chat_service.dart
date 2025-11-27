import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:haraka_afya_ai/models/message.dart';

class AnonymousChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Predefined list of random usernames (now public)
  static const List<String> randomUsernames = [
    'MysticTraveler',
    'SilentObserver',
    'WhisperingWind',
    'HiddenGem',
    'QuietThinker',
    'AnonymousFriend',
    'SecretAdmirer',
    'GentleSoul',
    'MysteryGuest',
    'QuietListener',
    'SupportiveStranger',
    'KindredSpirit',
    'ThoughtfulOne',
    'PeacefulMind',
    'CaringCompanion'
  ];

  /// Gets or creates a unique username for the user
  Future<String> getOrCreateUsername(String userId) async {
    // Check if user already has a username
    final userDoc = await _firestore.collection('user_usernames').doc(userId).get();
    
    if (userDoc.exists) {
      return userDoc.data()!['username'] as String;
    }

    // Generate a new unique username
    final username = await _generateUniqueUsername();
    
    // Save to Firestore
    await _firestore.collection('user_usernames').doc(userId).set({
      'username': username,
      'userId': userId,
      'createdAt': FieldValue.serverTimestamp(),
    });
    
    return username;
  }

  /// Generates a new unique username that isn't already taken
  Future<String> _generateUniqueUsername() async {
    // Get all existing usernames
    final usernamesSnapshot = await _firestore.collection('user_usernames').get();
    final existingUsernames = usernamesSnapshot.docs
        .map((doc) => doc.data()['username'] as String)
        .toSet();

    // Try to find an available username from our predefined list
    for (final username in randomUsernames..shuffle()) {
      if (!existingUsernames.contains(username)) {
        return username;
      }
    }

    // If all predefined usernames are taken, generate a unique one
    return 'AnonymousUser${DateTime.now().millisecondsSinceEpoch % 10000}';
  }

  /// Posts a new message to the main anonymous chat
  Future<void> postMessage({
    required String content,
    String? parentId,
    required String userId,
    String? senderName,
  }) async {
    final username = senderName ?? await getOrCreateUsername(userId);
    
    final message = AnonymousMessage(
      id: _firestore.collection('anonymous_messages').doc().id,
      content: content,
      parentId: parentId,
      timestamp: DateTime.now(),
      senderName: username,
      likes: 0,
      likedBy: [],
    );

    await _firestore
        .collection('anonymous_messages')
        .doc(message.id)
        .set(message.toMap());
  }

  /// Posts a message to a specific family chat
  Future<void> postFamilyMessage({
    required String familyId,
    required String content,
    required String userId,
    String? senderName,
    String? parentId,
  }) async {
    final username = senderName ?? await getOrCreateUsername(userId);
    
    final message = AnonymousMessage(
      id: _firestore.collection('family_messages').doc().id,
      content: content,
      parentId: parentId,
      timestamp: DateTime.now(),
      senderName: username,
      likes: 0,
      likedBy: [],
    );

    await _firestore
        .collection('family_messages')
        .doc(familyId)
        .collection('messages')
        .doc(message.id)
        .set(message.toMap());
  }

  /// Gets the main chat messages (not replies)
  Stream<List<AnonymousMessage>> getMessages() {
    return _firestore
        .collection('anonymous_messages')
        .where('parentId', isNull: true)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => AnonymousMessage.fromMap(doc.data()))
            .toList());
  }

  /// Gets messages for a specific family
  Stream<List<AnonymousMessage>> getFamilyMessages(String familyId) {
    return _firestore
        .collection('family_messages')
        .doc(familyId)
        .collection('messages')
        .where('parentId', isNull: true)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => AnonymousMessage.fromMap(doc.data()))
            .toList());
  }

  /// Gets replies for a specific message in main chat
  Stream<List<AnonymousMessage>> getReplies(String parentId) {
    return _firestore
        .collection('anonymous_messages')
        .where('parentId', isEqualTo: parentId)
        .orderBy('timestamp')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => AnonymousMessage.fromMap(doc.data()))
            .toList());
  }

  /// Gets replies for a specific message in family chat
  Stream<List<AnonymousMessage>> getFamilyReplies(String familyId, String parentId) {
    return _firestore
        .collection('family_messages')
        .doc(familyId)
        .collection('messages')
        .where('parentId', isEqualTo: parentId)
        .orderBy('timestamp')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => AnonymousMessage.fromMap(doc.data()))
            .toList());
  }

  /// Likes a message in main chat
  Future<void> likeMessage(String messageId, String userId) async {
    await _firestore.collection('anonymous_messages').doc(messageId).update({
      'likes': FieldValue.increment(1),
      'likedBy': FieldValue.arrayUnion([userId]),
    });
  }

  /// Likes a message in family chat
  Future<void> likeFamilyMessage(String familyId, String messageId, String userId) async {
    await _firestore
        .collection('family_messages')
        .doc(familyId)
        .collection('messages')
        .doc(messageId)
        .update({
      'likes': FieldValue.increment(1),
      'likedBy': FieldValue.arrayUnion([userId]),
    });
  }

  /// Reports a message in main chat
  Future<void> reportMessage(String messageId) async {
    await _firestore.collection('anonymous_messages').doc(messageId).update({
      'reported': true,
      'reportCount': FieldValue.increment(1),
    });
  }

  /// Reports a message in family chat
  Future<void> reportFamilyMessage(String familyId, String messageId) async {
    await _firestore
        .collection('family_messages')
        .doc(familyId)
        .collection('messages')
        .doc(messageId)
        .update({
      'reported': true,
      'reportCount': FieldValue.increment(1),
    });
  }

  /// Deletes a message from main chat (admin functionality)
  Future<void> deleteMessage(String messageId) async {
    await _firestore.collection('anonymous_messages').doc(messageId).delete();
  }

  /// Deletes a message from family chat (admin/moderator functionality)
  Future<void> deleteFamilyMessage(String familyId, String messageId) async {
    await _firestore
        .collection('family_messages')
        .doc(familyId)
        .collection('messages')
        .doc(messageId)
        .delete();
  }

  /// Allows user to change their username
  Future<String> changeUsername(String userId) async {
    final newUsername = await _generateUniqueUsername();
    await _firestore.collection('user_usernames').doc(userId).update({
      'username': newUsername,
    });
    return newUsername;
  }

  /// Checks if user is member of a family
  Future<bool> isUserMemberOfFamily(String familyId, String userId) async {
    final familyDoc = await _firestore.collection('families').doc(familyId).get();
    if (!familyDoc.exists) return false;
    
    final members = List<String>.from(familyDoc.data()!['members'] ?? []);
    return members.contains(userId);
  }

  /// Gets user's recent activity across all families
  Stream<List<AnonymousMessage>> getUserRecentActivity(String userId) async* {
    // Since collectionGroup queries might be complex, we'll use a simpler approach
    final userDoc = await _firestore.collection('user_usernames').doc(userId).get();
    if (!userDoc.exists) return;
    
    final username = userDoc.data()!['username'] as String;
    
    // Get recent messages from main chat
    final mainMessagesSnapshot = await _firestore
        .collection('anonymous_messages')
        .where('senderName', isEqualTo: username)
        .orderBy('timestamp', descending: true)
        .limit(5)
        .get();

    final mainMessages = mainMessagesSnapshot.docs
        .map((doc) => AnonymousMessage.fromMap(doc.data()))
        .toList();

    // For family messages, we'd need to query all families the user is in
    // This is a simplified version - in production you'd want to optimize this
    yield mainMessages;
  }

  /// Search messages in a family
  Stream<List<AnonymousMessage>> searchFamilyMessages(String familyId, String query) {
    return _firestore
        .collection('family_messages')
        .doc(familyId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => AnonymousMessage.fromMap(doc.data()))
            .where((message) => message.content.toLowerCase().contains(query.toLowerCase()))
            .toList());
  }

  /// Get family message statistics
  Future<Map<String, dynamic>> getFamilyMessageStats(String familyId) async {
    final messagesSnapshot = await _firestore
        .collection('family_messages')
        .doc(familyId)
        .collection('messages')
        .get();

    final messages = messagesSnapshot.docs
        .map((doc) => AnonymousMessage.fromMap(doc.data()))
        .toList();

    final totalMessages = messages.length;
    final today = DateTime.now();
    final todayMessages = messages
        .where((message) => 
            message.timestamp.year == today.year &&
            message.timestamp.month == today.month &&
            message.timestamp.day == today.day)
        .length;

    // Count unique users based on sender names (since we don't store userId in messages)
    final activeUsers = messages.map((message) => message.senderName).toSet().length;

    return {
      'totalMessages': totalMessages,
      'todayMessages': todayMessages,
      'activeUsers': activeUsers,
    };
  }
}