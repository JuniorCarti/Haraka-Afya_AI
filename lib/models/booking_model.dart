import 'package:cloud_firestore/cloud_firestore.dart';

class Booking {
  String id;
  final String hospitalId;
  final String hospitalName;
  final String userId;
  final String userName;
  final String userEmail;
  final String userPhone;
  final String specialistId;
  final String specialistName;
  final String specialty;
  final DateTime bookingDate;
  final String timeSlot;
  final String status; // 'pending', 'confirmed', 'cancelled', 'completed'
  final String notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  Booking({
    required this.id,
    required this.hospitalId,
    required this.hospitalName,
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.userPhone,
    required this.specialistId,
    required this.specialistName,
    required this.specialty,
    required this.bookingDate,
    required this.timeSlot,
    this.status = 'pending',
    this.notes = '',
    required this.createdAt,
    required this.updatedAt,
  });

  // Convert to Map for Firestore (using Timestamps)
  Map<String, dynamic> toMap() {
    return {
      'hospitalId': hospitalId,
      'hospitalName': hospitalName,
      'userId': userId,
      'userName': userName,
      'userEmail': userEmail,
      'userPhone': userPhone,
      'specialistId': specialistId,
      'specialistName': specialistName,
      'specialty': specialty,
      'bookingDate': Timestamp.fromDate(bookingDate), // Use Timestamp
      'timeSlot': timeSlot,
      'status': status,
      'notes': notes,
      'createdAt': Timestamp.fromDate(createdAt), // Use Timestamp
      'updatedAt': Timestamp.fromDate(updatedAt), // Use Timestamp
    };
  }

  // Create from Map (handles both milliseconds and timestamps)
  factory Booking.fromMap(Map<String, dynamic> map) {
    return Booking(
      id: map['id'] ?? '',
      hospitalId: map['hospitalId'] ?? '',
      hospitalName: map['hospitalName'] ?? '',
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      userEmail: map['userEmail'] ?? '',
      userPhone: map['userPhone'] ?? '',
      specialistId: map['specialistId'] ?? '',
      specialistName: map['specialistName'] ?? '',
      specialty: map['specialty'] ?? '',
      bookingDate: _parseDate(map['bookingDate']),
      timeSlot: map['timeSlot'] ?? '',
      status: map['status'] ?? 'pending',
      notes: map['notes'] ?? '',
      createdAt: _parseDate(map['createdAt']),
      updatedAt: _parseDate(map['updatedAt']),
    );
  }

  // Create from Firestore Document (includes document ID)
  factory Booking.fromFirestore(DocumentSnapshot doc) {
    final map = doc.data() as Map<String, dynamic>;
    return Booking(
      id: doc.id, // Use Firestore document ID
      hospitalId: map['hospitalId'] ?? '',
      hospitalName: map['hospitalName'] ?? '',
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      userEmail: map['userEmail'] ?? '',
      userPhone: map['userPhone'] ?? '',
      specialistId: map['specialistId'] ?? '',
      specialistName: map['specialistName'] ?? '',
      specialty: map['specialty'] ?? '',
      bookingDate: _parseDate(map['bookingDate']),
      timeSlot: map['timeSlot'] ?? '',
      status: map['status'] ?? 'pending',
      notes: map['notes'] ?? '',
      createdAt: _parseDate(map['createdAt']),
      updatedAt: _parseDate(map['updatedAt']),
    );
  }

  // Helper method to parse dates from various formats
  static DateTime _parseDate(dynamic dateField) {
    if (dateField == null) return DateTime.now();
    
    if (dateField is Timestamp) {
      return dateField.toDate();
    } else if (dateField is int) {
      return DateTime.fromMillisecondsSinceEpoch(dateField);
    } else if (dateField is String) {
      return DateTime.parse(dateField);
    } else {
      return DateTime.now();
    }
  }

  // Copy with method for updates
  Booking copyWith({
    String? id,
    String? hospitalId,
    String? hospitalName,
    String? userId,
    String? userName,
    String? userEmail,
    String? userPhone,
    String? specialistId,
    String? specialistName,
    String? specialty,
    DateTime? bookingDate,
    String? timeSlot,
    String? status,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Booking(
      id: id ?? this.id,
      hospitalId: hospitalId ?? this.hospitalId,
      hospitalName: hospitalName ?? this.hospitalName,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userEmail: userEmail ?? this.userEmail,
      userPhone: userPhone ?? this.userPhone,
      specialistId: specialistId ?? this.specialistId,
      specialistName: specialistName ?? this.specialistName,
      specialty: specialty ?? this.specialty,
      bookingDate: bookingDate ?? this.bookingDate,
      timeSlot: timeSlot ?? this.timeSlot,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'Booking(id: $id, hospital: $hospitalName, specialist: $specialistName, date: $bookingDate, status: $status)';
  }
}