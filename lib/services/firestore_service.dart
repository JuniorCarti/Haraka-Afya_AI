import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  /// -----------------------------
  /// USER PROFILE
  /// -----------------------------

  Future<Map<String, dynamic>?> getUserProfile() async {
    final uid = currentUserId;
    if (uid == null) return null;

    final doc = await _firestore.collection('users').doc(uid).get();
    return doc.exists ? doc.data() : null;
  }

  Future<void> updateUserProfile({required String phone, required int age}) async {
    final uid = currentUserId;
    if (uid == null) return;

    await _firestore.collection('users').doc(uid).update({
      'phoneNumber': phone,
      'age': age,
    });
  }

  /// -----------------------------
  /// HEALTH STATS
  /// -----------------------------

  Future<void> updateHealthStats(Map<String, dynamic> healthStats) async {
    final uid = currentUserId;
    if (uid == null) return;

    await _firestore.collection('users').doc(uid).update({
      'healthStats': healthStats,
    });
  }

  /// -----------------------------
  /// ACTIVITIES
  /// -----------------------------

  Future<void> logActivity(String title) async {
    final uid = currentUserId;
    if (uid == null) return;

    final timestamp = Timestamp.now();
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('activities')
        .add({
          'title': title,
          'timestamp': timestamp,
        });
  }

  Future<List<Map<String, dynamic>>> getRecentActivities({int limit = 5}) async {
    final uid = currentUserId;
    if (uid == null) return [];

    final snapshot = await _firestore
        .collection('users')
        .doc(uid)
        .collection('activities')
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .get();

    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  /// -----------------------------
  /// MEDICATION REMINDERS
  /// -----------------------------

  Future<void> addMedication({
    required String name,
    required Timestamp time,
  }) async {
    final uid = currentUserId;
    if (uid == null) return;

    await _firestore
        .collection('users')
        .doc(uid)
        .collection('medications')
        .add({
          'name': name,
          'time': time,
          'taken': false,
          'createdAt': Timestamp.now(),
        });
  }

  Future<void> updateMedication({
    required String docId,
    required String name,
    required Timestamp time,
  }) async {
    final uid = currentUserId;
    if (uid == null) return;

    await _firestore
        .collection('users')
        .doc(uid)
        .collection('medications')
        .doc(docId)
        .update({
          'name': name,
          'time': time,
        });
  }

  Future<void> deleteMedication(String docId) async {
    final uid = currentUserId;
    if (uid == null) return;

    await _firestore
        .collection('users')
        .doc(uid)
        .collection('medications')
        .doc(docId)
        .delete();
  }

  Future<void> markMedicationAsTaken({
    required String docId,
  }) async {
    final uid = currentUserId;
    if (uid == null) return;

    final takenAt = Timestamp.now();
    final docRef = _firestore
        .collection('users')
        .doc(uid)
        .collection('medications')
        .doc(docId);

    // Update taken status
    await docRef.update({
      'taken': true,
      'takenTime': takenAt,
    });

    // Log to medication_history
    final medData = await docRef.get();
    final name = medData['name'];

    await _firestore
        .collection('users')
        .doc(uid)
        .collection('medication_history')
        .add({
          'name': name,
          'takenAt': takenAt,
        });
  }

  Stream<QuerySnapshot> getMedicationsStream() {
    final uid = currentUserId;
    if (uid == null) {
      return const Stream.empty();
    }

    return _firestore
        .collection('users')
        .doc(uid)
        .collection('medications')
        .orderBy('time')
        .snapshots();
  }

  Stream<QuerySnapshot> getMedicationHistoryStream() {
    final uid = currentUserId;
    if (uid == null) {
      return const Stream.empty();
    }

    return _firestore
        .collection('users')
        .doc(uid)
        .collection('medication_history')
        .orderBy('takenAt', descending: true)
        .snapshots();
  }
}
