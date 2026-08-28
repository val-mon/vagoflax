import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vagoflax/models/history_model.dart';
import 'package:vagoflax/models/review_model.dart';
import 'package:vagoflax/models/enum/user_role_model.dart';

class User {
  final String id;
  final String canton;
  final String city;
  final String description;
  final String email;
  final String? firstName;
  final String? lastName;
  final String? companyName; // Company name for employers
  final String? profilePictureUrl;
  final String? faceRecognitionUrl;
  final UserRole role;
  final List<String> skills;
  final List<Review> reviews;
  final List<HistoryEntry> history;
  final int? companySize;
  final DateTime? createdAt;
  User({
    required this.id,
    required this.canton,
    required this.city,
    required this.description,
    required this.email,
    this.firstName,
    this.lastName,
    this.profilePictureUrl,
    this.faceRecognitionUrl,
    required this.role,
    this.companySize,
    this.companyName = '',
    this.createdAt,
    this.skills = const [],
    this.reviews = const [],
    this.history = const [],
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
      companyName: data['companyName'] ?? '',
      profilePictureUrl: data['profilePictureUrl'] ?? '',
      faceRecognitionUrl: data['faceRecognitionUrl'] ?? '',
      role: UserRole.fromFirestore(data['role']),
      companySize: (data['companySize'] as num?)?.toInt(),
      skills: List<String>.from(data['skills'] ?? []),
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : null,
      reviews:
          (data['reviews'] as List<dynamic>?)
              ?.map(
                (reviewData) => Review(
                  createdAt: (reviewData['createdAt'] as Timestamp).toDate(),
                  from: reviewData['from'] ?? '',
                  message: reviewData['message'] ?? '',
                  rating: (reviewData['rating'] as num).toDouble(),
                ),
              )
              .toList() ??
          [],
      history:
          (data['history'] as List<dynamic>?)
              ?.map(
                (historyData) => HistoryEntry(
                  startedAt: (historyData['startedAt'] as Timestamp).toDate(),
                  endedAt: (historyData['endedAt'] as Timestamp).toDate(),
                  company: historyData['company'] ?? '',
                  jobTitle: historyData['jobTitle'] ?? '',
                ),
              )
              .toList() ??
          [],
    );
  }

  /// Converts the User object to a map for Firestore.
  Map<String, dynamic> toFirestore() {
    return {
      'canton': canton,
      'city': city,
      'description': description,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'profilePictureUrl': profilePictureUrl,
      'faceRecognitionUrl': faceRecognitionUrl,
      'role': role.toFirestore(),
      'skills': skills,
      'companySize': companySize,
      'companyName': companyName,
      'reviews': reviews
          .map(
            (review) => {
              'createdAt': review.createdAt,
              'from': review.from,
              'message': review.message,
              'rating': review.rating,
            },
          )
          .toList(),
      'history': history
          .map(
            (historyEntry) => {
              'startedAt': historyEntry.startedAt,
              'endedAt': historyEntry.endedAt,
              'company': historyEntry.company,
              'jobTitle': historyEntry.jobTitle,
            },
          )
          .toList(),
    };
  }

  User copyWith({
    String? firstName,
    String? lastName,
    String? city,
    String? canton,
    String? description,
    List<String>? skills,
    List<HistoryEntry>? history,
    String? profilePictureUrl,
  }) {
    return User(
      // id, email and role can't be changed (atleast for now)
      id: id,
      email: email,
      role: role,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      city: city ?? this.city,
      canton: canton ?? this.canton,
      description: description ?? this.description,
      skills: skills ?? this.skills,
      history: history ?? this.history,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
    );
  }
}
