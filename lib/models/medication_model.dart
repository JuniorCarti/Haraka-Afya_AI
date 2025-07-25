import 'package:cloud_firestore/cloud_firestore.dart';

class Medication {
  final String id;
  final String name;
  final DateTime time;
  final bool taken;
  final DateTime timestamp;
  final DateTime? takenTime;

  Medication({
    required this.id,
    required this.name,
    required this.time,
    required this.taken,
    required this.timestamp,
    this.takenTime,
  });

  // Factory constructor to create Medication from Firestore document
  factory Medication.fromMap(String id, Map<String, dynamic> data) {
    return Medication(
      id: id,
      name: data['name'],
      time: (data['time'] as Timestamp).toDate(),
      taken: data['taken'] ?? false,
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      takenTime: data['takenTime'] != null ? (data['takenTime'] as Timestamp).toDate() : null,
    );
  }

  // Convert Medication to Firestore-compatible map
  Map<String, dynamic> toMap(String userId) {
    return {
      'name': name,
      'time': Timestamp.fromDate(time),
      'taken': taken,
      'userId': userId,
      'timestamp': Timestamp.fromDate(timestamp),
      if (takenTime != null) 'takenTime': Timestamp.fromDate(takenTime!),
    };
  }

  // Clone medication object with new values
  Medication copyWith({
    String? id,
    String? name,
    DateTime? time,
    bool? taken,
    DateTime? timestamp,
    DateTime? takenTime,
  }) {
    return Medication(
      id: id ?? this.id,
      name: name ?? this.name,
      time: time ?? this.time,
      taken: taken ?? this.taken,
      timestamp: timestamp ?? this.timestamp,
      takenTime: takenTime ?? this.takenTime,
    );
  }
}
