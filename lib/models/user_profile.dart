import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  final String uid;
  final String firstName;
  final String lastName;
  final String email;
  final String userType;
  final String phoneNumber;
  final int age;
  final String subscriptionType;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isProfileComplete;
  final bool isVerified;
  final String verificationStatus;
  final Map<String, dynamic>? verificationData;
  final String? professionalLicense;
  final String? specialty;
  final String? facilityName;
  final String? facilityType;
  final String? supportedPatientId;

  UserProfile({
    required this.uid,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.userType,
    this.phoneNumber = '',
    this.age = 0,
    this.subscriptionType = 'free',
    required this.createdAt,
    required this.updatedAt,
    this.isProfileComplete = false,
    this.isVerified = false,
    this.verificationStatus = 'pending',
    this.verificationData,
    this.professionalLicense,
    this.specialty,
    this.facilityName,
    this.facilityType,
    this.supportedPatientId,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'userType': userType,
      'phoneNumber': phoneNumber,
      'age': age,
      'subscriptionType': subscriptionType,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'isProfileComplete': isProfileComplete,
      'isVerified': isVerified,
      'verificationStatus': verificationStatus,
      'verificationData': verificationData,
      'professionalLicense': professionalLicense,
      'specialty': specialty,
      'facilityName': facilityName,
      'facilityType': facilityType,
      'supportedPatientId': supportedPatientId,
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      uid: map['uid'] ?? '',
      firstName: map['firstName'] ?? '',
      lastName: map['lastName'] ?? '',
      email: map['email'] ?? '',
      userType: map['userType'] ?? 'Health Explorer',
      phoneNumber: map['phoneNumber'] ?? '',
      age: map['age'] ?? 0,
      subscriptionType: map['subscriptionType'] ?? 'free',
      createdAt: map['createdAt'] != null 
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null 
          ? (map['updatedAt'] as Timestamp).toDate()
          : DateTime.now(),
      isProfileComplete: map['isProfileComplete'] ?? false,
      isVerified: map['isVerified'] ?? false,
      verificationStatus: map['verificationStatus'] ?? 'pending',
      verificationData: map['verificationData'] != null 
          ? Map<String, dynamic>.from(map['verificationData'])
          : null,
      professionalLicense: map['professionalLicense'],
      specialty: map['specialty'],
      facilityName: map['facilityName'],
      facilityType: map['facilityType'],
      supportedPatientId: map['supportedPatientId'],
    );
  }

  factory UserProfile.fromDocumentSnapshot(DocumentSnapshot doc) {
    final map = doc.data() as Map<String, dynamic>? ?? {};
    return UserProfile.fromMap(map);
  }

  UserProfile copyWith({
    String? uid,
    String? firstName,
    String? lastName,
    String? email,
    String? userType,
    String? phoneNumber,
    int? age,
    String? subscriptionType,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isProfileComplete,
    bool? isVerified,
    String? verificationStatus,
    Map<String, dynamic>? verificationData,
    String? professionalLicense,
    String? specialty,
    String? facilityName,
    String? facilityType,
    String? supportedPatientId,
  }) {
    return UserProfile(
      uid: uid ?? this.uid,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      userType: userType ?? this.userType,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      age: age ?? this.age,
      subscriptionType: subscriptionType ?? this.subscriptionType,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isProfileComplete: isProfileComplete ?? this.isProfileComplete,
      isVerified: isVerified ?? this.isVerified,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      verificationData: verificationData ?? this.verificationData,
      professionalLicense: professionalLicense ?? this.professionalLicense,
      specialty: specialty ?? this.specialty,
      facilityName: facilityName ?? this.facilityName,
      facilityType: facilityType ?? this.facilityType,
      supportedPatientId: supportedPatientId ?? this.supportedPatientId,
    );
  }

  bool get isHealthProfessional => userType == 'Health Professional';
  bool get isPartnerFacility => userType == 'Partner Facility';
  bool get isInCareMember => userType == 'In-Care Member';
  bool get isSupportPartner => userType == 'Support Partner';
  bool get isHealthExplorer => userType == 'Health Explorer';
  bool get requiresVerification => isHealthProfessional || isPartnerFacility || isSupportPartner;
  bool get isFullyVerified => isVerified && verificationStatus == 'verified';
  bool get isVerificationPending => verificationStatus == 'pending';
  bool get isVerificationRejected => verificationStatus == 'rejected';

  String get displayName {
    if (firstName.isNotEmpty && lastName.isNotEmpty) {
      return '$firstName $lastName';
    } else if (firstName.isNotEmpty) {
      return firstName;
    } else {
      return 'User';
    }
  }

  String get professionalDisplayName {
    if (isHealthProfessional && specialty != null) {
      return '$displayName - $specialty';
    }
    return displayName;
  }

  String get facilityDisplayName {
    if (isPartnerFacility && facilityName != null) {
      return facilityName!;
    }
    return displayName;
  }

  @override
  String toString() {
    return 'UserProfile(uid: $uid, firstName: $firstName, lastName: $lastName, email: $email, userType: $userType, isVerified: $isVerified, verificationStatus: $verificationStatus)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserProfile &&
        other.uid == uid &&
        other.firstName == firstName &&
        other.lastName == lastName &&
        other.email == email &&
        other.userType == userType &&
        other.phoneNumber == phoneNumber &&
        other.age == age &&
        other.subscriptionType == subscriptionType &&
        other.isProfileComplete == isProfileComplete &&
        other.isVerified == isVerified &&
        other.verificationStatus == verificationStatus;
  }

  @override
  int get hashCode {
    return Object.hash(
      uid,
      firstName,
      lastName,
      email,
      userType,
      phoneNumber,
      age,
      subscriptionType,
      isProfileComplete,
      isVerified,
      verificationStatus,
    );
  }
}