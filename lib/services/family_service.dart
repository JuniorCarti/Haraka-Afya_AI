import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:haraka_afya_ai/models/family.dart';

class FamilyService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Create a new family - UPDATED to include expirationSettings
  Future<Family> createFamily({
    required String name,
    required String description,
    required String creatorId,
    required String creatorName,
    bool isPublic = true,
    MessageExpirationSettings? expirationSettings, // NEW: Optional expiration settings
  }) async {
    final familyId = 'family_${DateTime.now().millisecondsSinceEpoch}';
    final joinCode = isPublic ? null : _generateJoinCode();
    
    // Use provided expiration settings or default to never expire
    final messageExpirationSettings = expirationSettings ?? MessageExpirationSettings.never;
    
    final family = Family(
      id: familyId,
      name: name,
      description: description,
      creatorId: creatorId,
      members: [creatorId],
      moderators: [creatorId],
      followers: [], // Initialize empty followers list
      createdAt: DateTime.now(),
      memberCount: 1,
      isPublic: isPublic,
      joinCode: joinCode,
      expirationSettings: messageExpirationSettings, // NEW: Added expiration settings
    );

    await _firestore.collection('families').doc(familyId).set(family.toMap());
    return family;
  }

  // NEW: Update family expiration settings
  Future<void> updateFamilyExpirationSettings({
    required String familyId,
    required MessageExpirationSettings expirationSettings,
  }) async {
    await _firestore.collection('families').doc(familyId).update({
      'expirationSettings': expirationSettings.toMap(),
    });
  }

  // NEW: Get family expiration settings
  Future<MessageExpirationSettings> getFamilyExpirationSettings(String familyId) async {
    final familyDoc = await _firestore.collection('families').doc(familyId).get();
    if (!familyDoc.exists) {
      return MessageExpirationSettings.never;
    }
    
    final family = Family.fromMap(familyDoc.data()!);
    return family.expirationSettings;
  }

  // Follow a family
  Future<void> followFamily(String familyId, String userId) async {
    try {
      final familyRef = _firestore.collection('families').doc(familyId);
      
      await _firestore.runTransaction((transaction) async {
        final familyDoc = await transaction.get(familyRef);
        if (!familyDoc.exists) {
          throw Exception('Family not found');
        }

        final family = Family.fromMap(familyDoc.data()!);
        
        // Check if user is already following
        if (family.followers.contains(userId)) {
          throw Exception('Already following this family');
        }

        // Add user to followers and update member count
        final updatedFollowers = List<String>.from(family.followers)..add(userId);
        final updatedMemberCount = family.memberCount + 1;

        transaction.update(familyRef, {
          'followers': updatedFollowers,
          'memberCount': updatedMemberCount,
        });
      });
    } catch (e) {
      print('Error following family: $e');
      rethrow;
    }
  }

  // Unfollow a family
  Future<void> unfollowFamily(String familyId, String userId) async {
    try {
      final familyRef = _firestore.collection('families').doc(familyId);
      
      await _firestore.runTransaction((transaction) async {
        final familyDoc = await transaction.get(familyRef);
        if (!familyDoc.exists) {
          throw Exception('Family not found');
        }

        final family = Family.fromMap(familyDoc.data()!);
        
        // Check if user is following
        if (!family.followers.contains(userId)) {
          throw Exception('Not following this family');
        }

        // Remove user from followers and update member count
        final updatedFollowers = List<String>.from(family.followers)..remove(userId);
        final updatedMemberCount = family.memberCount - 1;

        transaction.update(familyRef, {
          'followers': updatedFollowers,
          'memberCount': updatedMemberCount >= 0 ? updatedMemberCount : 0,
        });
      });
    } catch (e) {
      print('Error unfollowing family: $e');
      rethrow;
    }
  }

  // Check if user is following a family
  Future<bool> isUserFollowing(String familyId, String userId) async {
    try {
      final familyDoc = await _firestore.collection('families').doc(familyId).get();
      if (!familyDoc.exists) return false;
      
      final family = Family.fromMap(familyDoc.data()!);
      return family.followers.contains(userId);
    } catch (e) {
      print('Error checking follow status: $e');
      return false;
    }
  }

  // Get families user is following
  Stream<List<Family>> getFollowedFamilies(String userId) {
    return _firestore
        .collection('families')
        .where('followers', arrayContains: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Family.fromMap(doc.data()))
            .toList());
  }

  // Toggle follow/unfollow
  Future<void> toggleFollowFamily(String familyId, String userId, bool isCurrentlyFollowing) async {
    if (isCurrentlyFollowing) {
      await unfollowFamily(familyId, userId);
    } else {
      await followFamily(familyId, userId);
    }
  }

  // Join a family
  Future<void> joinFamily(String familyId, String userId) async {
    await _firestore.collection('families').doc(familyId).update({
      'members': FieldValue.arrayUnion([userId]),
      'memberCount': FieldValue.increment(1),
    });
  }

  // Get all public families
  Stream<List<Family>> getPublicFamilies() {
    return _firestore
        .collection('families')
        .where('isPublic', isEqualTo: true)
        .orderBy('memberCount', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Family.fromMap(doc.data()))
            .toList());
  }

  // Get user's families
  Stream<List<Family>> getUserFamilies(String userId) {
    return _firestore
        .collection('families')
        .where('members', arrayContains: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Family.fromMap(doc.data()))
            .toList());
  }

  // Get family by ID
  Future<Family?> getFamilyById(String familyId) async {
    try {
      final familyDoc = await _firestore.collection('families').doc(familyId).get();
      if (familyDoc.exists) {
        return Family.fromMap(familyDoc.data()!);
      }
      return null;
    } catch (e) {
      print('Error getting family: $e');
      return null;
    }
  }

  // Search families by name
  Stream<List<Family>> searchFamilies(String query) {
    return _firestore
        .collection('families')
        .where('name', isGreaterThanOrEqualTo: query)
        .where('name', isLessThanOrEqualTo: '${query}z')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Family.fromMap(doc.data()))
            .toList());
  }

  // NEW: Get families with specific expiration settings (for admin purposes)
  Stream<List<Family>> getFamiliesWithExpiration(ExpirationType expirationType) {
    return _firestore
        .collection('families')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Family.fromMap(doc.data()))
            .where((family) => family.expirationSettings.type == expirationType)
            .toList());
  }

  // NEW: Update multiple families' expiration settings (admin functionality)
  Future<void> bulkUpdateExpirationSettings({
    required List<String> familyIds,
    required MessageExpirationSettings expirationSettings,
  }) async {
    final batch = _firestore.batch();
    
    for (final familyId in familyIds) {
      final familyRef = _firestore.collection('families').doc(familyId);
      batch.update(familyRef, {
        'expirationSettings': expirationSettings.toMap(),
      });
    }
    
    await batch.commit();
  }

  // NEW: Get families that need expiration cleanup
  Future<List<Family>> getFamiliesNeedingCleanup() async {
    final familiesSnapshot = await _firestore.collection('families').get();
    
    return familiesSnapshot.docs
        .map((doc) => Family.fromMap(doc.data()))
        .where((family) => family.shouldMessagesExpire)
        .toList();
  }

  String _generateJoinCode() {
    return DateTime.now().millisecondsSinceEpoch.toString().substring(7);
  }
}