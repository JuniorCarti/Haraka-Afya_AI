import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_profile.dart';

class UserService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> updateProfile(UserProfile profile) async {
    await _db.collection('users').doc(profile.uid).update({
      'firstName': profile.firstName,
      'lastName': profile.lastName,
      'phoneNumber': profile.phoneNumber,
      'age': profile.age,
    });
  }
}

