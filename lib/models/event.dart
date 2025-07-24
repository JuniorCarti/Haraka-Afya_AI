import 'package:cloud_firestore/cloud_firestore.dart';

class Event {
  final String id;
  final String organizerId;
  final String organizerName;
  final String organizerImage;
  final String title;
  final String description;
  final String eventType;
  final DateTime dateTime;
  final int maxParticipants;
  final List<String> participants;
  final DateTime createdAt;
  final String? location;
  final String? meetingLink;
  final bool isOnline;

  Event({
    required this.id,
    required this.organizerId,
    required this.organizerName,
    required this.organizerImage,
    required this.title,
    required this.description,
    required this.eventType,
    required this.dateTime,
    required this.maxParticipants,
    required this.participants,
    required this.createdAt,
    this.location,
    this.meetingLink,
    this.isOnline = false,
  });

  // Convert Event to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'organizerId': organizerId,
      'organizerName': organizerName,
      'organizerImage': organizerImage,
      'title': title,
      'description': description,
      'eventType': eventType,
      'dateTime': dateTime,
      'maxParticipants': maxParticipants,
      'participants': participants,
      'createdAt': createdAt,
      'location': location,
      'meetingLink': meetingLink,
      'isOnline': isOnline,
    };
  }

  // Create Event from Firestore document
  factory Event.fromMap(String id, Map<String, dynamic> map) {
    return Event(
      id: id,
      organizerId: map['organizerId'] ?? '',
      organizerName: map['organizerName'] ?? '',
      organizerImage: map['organizerImage'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      eventType: map['eventType'] ?? 'General',
      dateTime: (map['dateTime'] as Timestamp).toDate(),
      maxParticipants: map['maxParticipants'] ?? 0,
      participants: List<String>.from(map['participants'] ?? []),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      location: map['location'],
      meetingLink: map['meetingLink'],
      isOnline: map['isOnline'] ?? false,
    );
  }

  // Helper method to check if event is full
  bool get isFull {
    return maxParticipants > 0 && participants.length >= maxParticipants;
  }

  // Helper method to check if user is attending
  bool isAttending(String userId) {
    return participants.contains(userId);
  }

  // Copy with method for updates
  Event copyWith({
    String? title,
    String? description,
    String? eventType,
    DateTime? dateTime,
    int? maxParticipants,
    List<String>? participants,
    String? location,
    String? meetingLink,
    bool? isOnline,
  }) {
    return Event(
      id: id,
      organizerId: organizerId,
      organizerName: organizerName,
      organizerImage: organizerImage,
      title: title ?? this.title,
      description: description ?? this.description,
      eventType: eventType ?? this.eventType,
      dateTime: dateTime ?? this.dateTime,
      maxParticipants: maxParticipants ?? this.maxParticipants,
      participants: participants ?? this.participants,
      createdAt: createdAt,
      location: location ?? this.location,
      meetingLink: meetingLink ?? this.meetingLink,
      isOnline: isOnline ?? this.isOnline,
    );
  }
}