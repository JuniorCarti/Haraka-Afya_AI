class UserProfile {
  final String uid;
  final String firstName;
  final String lastName;
  final String email;
  final String phoneNumber;
  final int age;
  final String subscriptionType;

  UserProfile({
    required this.uid,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.phoneNumber = '',
    this.age = 0,
    this.subscriptionType = 'free',
  });

  // Add fromMap/toMap methods similar to HealthStats
}