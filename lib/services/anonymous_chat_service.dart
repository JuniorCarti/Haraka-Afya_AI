import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:haraka_afya_ai/models/message.dart';

class AnonymousChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<AnonymousMessage>> getMessages() {
    return _firestore
        .collection('anonymous_messages')
        .where('parentId', isNull: true) // Only top-level messages
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => AnonymousMessage.fromMap(doc.data()))
            .toList());
  }

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

  Future<void> postMessage(String content, {String? parentId}) async {
    final message = AnonymousMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content,
      parentId: parentId,
      timestamp: DateTime.now(),
    );
    await _firestore
        .collection('anonymous_messages')
        .doc(message.id)
        .set(message.toMap());
  }

  Future<void> likeMessage(String messageId, String userId) async {
    await _firestore.collection('anonymous_messages').doc(messageId).update({
      'likes': FieldValue.increment(1),
      'likedBy': FieldValue.arrayUnion([userId]),
    });
  }

  Future<void> reportMessage(String messageId) async {
    await _firestore.collection('anonymous_messages').doc(messageId).update({
      'reported': true,
    });
  }

  Future<void> deleteMessage(String messageId) async {
    await _firestore.collection('anonymous_messages').doc(messageId).delete();
  }
}