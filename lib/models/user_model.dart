class User {
  final String id;
  final String canton;
  final String city;
  final String description;
  final String email;
  final String firstName;
  final String lastName;
  final String profilePictureUrl;
  final String role;

  User({
    required this.id,
    required this.canton,
    required this.city,
    required this.description,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.profilePictureUrl,
    required this.role,
  });

  /// Builds a User object from a Firestore document.
  factory User.fromFirestore(Map<String, dynamic> data, String documentId) {
    return User(
      id: documentId,
      canton: data['canton'] ?? '',
      city: data['city'] ?? '',
      description: data['description'] ?? '',
      email: data['email'] ?? '',
      firstName: data['firstName'] ?? '',
      lastName: data['lastName'] ?? '',
      profilePictureUrl: data['profilePictureUrl'] ?? '',
      role: data['role'] ?? '',
    );
  }
}
