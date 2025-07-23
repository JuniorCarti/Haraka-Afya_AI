import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import '../models/health_stats.dart';

class HealthService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> updateHealthStats(String userId, HealthStats stats) async {
    await _db.collection('users').doc(userId).set({
      'healthStats': stats.toMap(),
    }, SetOptions(merge: true)); // ✅ Will create doc if it doesn’t exist
  }

  Future<HealthStats> getHealthStats(String userId) async {
    final doc = await _db.collection('users').doc(userId).get();
    
    final data = doc.data();
    if (data == null || data['healthStats'] == null) {
      throw Exception('No health stats found for user');
    }

    return HealthStats.fromMap(data['healthStats']);
  }
}
