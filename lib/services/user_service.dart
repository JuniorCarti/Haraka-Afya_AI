import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:haraka_afya_ai/models/user_profile.dart';

class UserService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user profile from Firebase
  Future<UserProfile?> getCurrentUser() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final doc = await _firestore.collection('users').doc(user.uid).get();
        if (doc.exists) {
          return UserProfile.fromDocumentSnapshot(doc);
        } else {
          // Create user profile if it doesn't exist
          final newUserProfile = UserProfile(
            uid: user.uid,
            firstName: user.displayName?.split(' ').first ?? 'User',
            lastName: user.displayName?.split(' ').last ?? '',
            email: user.email ?? '',
            userType: 'Health Explorer', // Default type
            phoneNumber: user.phoneNumber ?? '',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            isProfileComplete: false,
            isVerified: false,
            verificationStatus: 'not_required',
          );
          await createUserProfile(newUserProfile);
          return newUserProfile;
        }
      }
      return null;
    } catch (e) {
      print('Error getting current user: $e');
      return null;
    }
  }

  // Create user profile in Firebase
  Future<void> createUserProfile(UserProfile userProfile) async {
    try {
      await _firestore
          .collection('users')
          .doc(userProfile.uid)
          .set(userProfile.toMap());
      
      print('User profile created for ${userProfile.uid}');
    } catch (e) {
      print('Error creating user profile: $e');
      throw Exception('Failed to create user profile: $e');
    }
  }

  // Update user profile in Firebase
  Future<void> updateUserProfile(String uid, Map<String, dynamic> updates) async {
    try {
      updates['updatedAt'] = Timestamp.now();
      await _firestore.collection('users').doc(uid).update(updates);
    } catch (e) {
      print('Error updating user profile: $e');
      throw Exception('Failed to update user profile: $e');
    }
  }

  // Update user type in Firebase
  Future<void> updateUserType(String uid, String userType) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'userType': userType,
        'updatedAt': Timestamp.now(),
      });
    } catch (e) {
      print('Error updating user type: $e');
      throw Exception('Failed to update user type: $e');
    }
  }

  // Complete profile in Firebase
  Future<void> completeProfile(String uid, Map<String, dynamic> updates) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        ...updates,
        'isProfileComplete': true,
        'updatedAt': Timestamp.now(),
      });
    } catch (e) {
      print('Error completing profile: $e');
      throw Exception('Failed to complete profile: $e');
    }
  }

  // Stream user profile changes from Firebase
  Stream<UserProfile?> streamUserProfile(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .snapshots()
        .map((snapshot) {
      if (snapshot.exists) {
        return UserProfile.fromDocumentSnapshot(snapshot);
      }
      return null;
    });
  }

  // Search users in Firebase
  Future<List<UserProfile>> searchUsers({
    String? userType,
    String? specialty,
    String? facilityType,
    bool? isVerified,
  }) async {
    try {
      Query query = _firestore.collection('users');

      if (userType != null) {
        query = query.where('userType', isEqualTo: userType);
      }

      if (specialty != null) {
        query = query.where('specialty', isEqualTo: specialty);
      }

      if (facilityType != null) {
        query = query.where('facilityType', isEqualTo: facilityType);
      }

      if (isVerified != null) {
        query = query.where('isVerified', isEqualTo: isVerified);
      }

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => UserProfile.fromDocumentSnapshot(doc))
          .toList();
    } catch (e) {
      print('Error searching users: $e');
      return [];
    }
  }

  // Update subscription in Firebase
  Future<void> updateSubscription(String uid, String subscriptionType) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'subscriptionType': subscriptionType,
        'updatedAt': Timestamp.now(),
      });
    } catch (e) {
      print('Error updating subscription: $e');
      throw Exception('Failed to update subscription: $e');
    }
  }

  // Delete user account from Firebase
  Future<void> deleteUserAccount(String uid) async {
    try {
      await _firestore.collection('users').doc(uid).delete();
      await _auth.currentUser?.delete();
    } catch (e) {
      print('Error deleting user account: $e');
      throw Exception('Failed to delete user account: $e');
    }
  }
}