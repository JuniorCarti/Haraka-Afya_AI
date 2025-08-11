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

  /// Posts a new message to the chat
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

  /// Gets replies for a specific message
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

  /// Likes a message
  Future<void> likeMessage(String messageId, String userId) async {
    await _firestore.collection('anonymous_messages').doc(messageId).update({
      'likes': FieldValue.increment(1),
      'likedBy': FieldValue.arrayUnion([userId]),
    });
  }

  /// Reports a message
  Future<void> reportMessage(String messageId) async {
    await _firestore.collection('anonymous_messages').doc(messageId).update({
      'reported': true,
      'reportCount': FieldValue.increment(1),
    });
  }

  /// Deletes a message (admin functionality)
  Future<void> deleteMessage(String messageId) async {
    await _firestore.collection('anonymous_messages').doc(messageId).delete();
  }

  /// Allows user to change their username
  Future<String> changeUsername(String userId) async {
    final newUsername = await _generateUniqueUsername();
    await _firestore.collection('user_usernames').doc(userId).update({
      'username': newUsername,
    });
    return newUsername;
  }
}