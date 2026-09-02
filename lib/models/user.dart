import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vagoflax/models/history.dart';
import 'package:vagoflax/models/review.dart';
import 'package:vagoflax/models/enum/user_role.dart';

class User {
  final String id;
  final String canton;
  final String address;
  final String description;
  final String email;
  final String? firstName;
  final String? lastName;
  final String? companyName; // Company name for employers
  final String? profilePictureUrl;
  final List<double> faceSignature;
  final UserRole role;
  final List<String> skills;
  final List<Review> reviews;
  final List<HistoryEntry> history;
  final int? companySize;
  final List<String> savedSearches;
  final DateTime? createdAt;
  User({
    required this.id,
    required this.canton,
    required this.address,
    required this.description,
    required this.email,
    this.firstName,
    this.lastName,
    this.profilePictureUrl,
    this.faceSignature = const [],
    required this.role,
    this.companySize,
    this.companyName = '',
    this.createdAt,
    this.savedSearches = const [],
    this.skills = const [],
    this.reviews = const [],
    this.history = const [],
  });

  /// Builds a User object from a Firestore document.
  factory User.fromFirestore(Map<String, dynamic> data, String documentId) {
    return User(
      id: documentId,
      canton: data['canton'] ?? '',
      address: data['address'] ?? '',
      description: data['description'] ?? '',
      email: data['email'] ?? '',
      firstName: data['firstName'] ?? '',
      lastName: data['lastName'] ?? '',
      companyName: data['companyName'] ?? '',
      profilePictureUrl: data['profilePictureUrl'] ?? '',
      faceSignature: ((data['faceSignature'] as List<dynamic>?) ?? [])
          .map((value) => (value as num).toDouble())
          .toList(),
      role: UserRole.fromFirestore(data['role']),
      companySize: (data['companySize'] as num?)?.toInt(),
      skills: List<String>.from(data['skills'] ?? []),
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : null,
      savedSearches: List<String>.from(data['savedSearches'] ?? []),
      reviews:
          (data['reviews'] as List<dynamic>?)
              ?.map(
                (reviewData) => Review(
                  createdAt: (reviewData['createdAt'] as Timestamp).toDate(),
                  reviewerId: reviewData['reviewerId'] ?? '',
                  comment: reviewData['comment'] ?? '',
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
      'address': address,
      'description': description,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'profilePictureUrl': profilePictureUrl,
      'faceSignature': faceSignature,
      'role': role.toFirestore(),
      'skills': skills,
      'savedSearches': savedSearches,
      'companySize': companySize,
      'companyName': companyName,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
      'reviews': reviews
          .map(
            (review) => {
              'createdAt': review.createdAt,
              'reviewerId': review.reviewerId,
              'comment': review.comment,
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
    String? companyName,
    int? companySize,
    String? address,
    String? canton,
    String? description,
    List<String>? skills,
    List<HistoryEntry>? history,
    String? profilePictureUrl,
  }) {
    return role == UserRole.student
        ? User(
            // id, email and role can't be changed (atleast for now)
            id: id,
            email: email,
            role: role,
            createdAt: createdAt,
            firstName: firstName ?? this.firstName,
            lastName: lastName ?? this.lastName,
            address: address ?? this.address,
            canton: canton ?? this.canton,
            description: description ?? this.description,
            skills: skills ?? this.skills,
            history: history ?? this.history,
            savedSearches: savedSearches,
            profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
            faceSignature: faceSignature,
          )
        : User(
            id: id,
            email: email,
            role: role,
            createdAt: createdAt,
            companyName: companyName ?? this.companyName,
            companySize: companySize ?? this.companySize,
            address: address ?? this.address,
            canton: canton ?? this.canton,
            savedSearches: savedSearches,
            description: description ?? this.description,
            profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
            faceSignature: faceSignature,
          );
  }

  bool get hasProfilePicture =>
      profilePictureUrl != null && profilePictureUrl!.trim().isNotEmpty;

  bool hasUserBeenReviewedBy(String reviewerId) {
    if (reviewerId.isEmpty) return false;
    return reviews.any((review) => review.reviewerId == reviewerId);
  }

  double get averageRating {
    if (reviews.isEmpty) return 0.0;
    final total = reviews.fold<double>(0, (s, item) => s + item.rating);
    return total / reviews.length;
  }

  /// Total review count
  int get reviewCount => reviews.length;

  bool hasBookmarkedSearch(String search) {
    return savedSearches.isNotEmpty && savedSearches.contains(search);
  }
}
