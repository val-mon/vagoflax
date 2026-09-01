import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:vagoflax/models/face_entry.dart';
import 'package:vagoflax/models/user.dart';
import 'package:vagoflax/repositories/user.dart';

class FirestoreUserRepository implements UserRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _usersRef() =>
      _db.collection('users');

  CollectionReference<Map<String, dynamic>> _faceIndexRef() =>
      _db.collection('faceIndex');

  @override
  Stream<List<FaceEntry>> getFaceIndex() {
    return _faceIndexRef().snapshots().map(
      (snapshot) => snapshot.docs
          .map((doc) => FaceEntry.fromFirestore(doc.data()))
          .toList(),
    );
  }

  @override
  Stream<List<User>> getUsers() {
    return _usersRef().snapshots().map(
      (snapshot) => snapshot.docs
          .map((doc) => User.fromFirestore(doc.data(), doc.id))
          .toList(),
    );
  }

  @override
  Future<void> addUser(User user) async {
    await _usersRef().doc(user.id).set(user.toFirestore());

    // mirror the signature into the public index so face login can read it
    if (user.faceSignature.isNotEmpty) {
      try {
        await _faceIndexRef()
            .doc(user.id)
            .set(
              FaceEntry(
                email: user.email,
                signature: user.faceSignature,
              ).toFirestore(),
            );
      } catch (e) {
        debugPrint('Could not write faceIndex/${user.id}: $e');
      }
    }
  }

  @override
  Future<User> getUserById(String uid) async {
    final docSnapshot = await _usersRef().doc(uid).get();

    if (!docSnapshot.exists) {
      throw Exception("User not found in Firestore");
    }

    return User.fromFirestore(docSnapshot.data()!, uid);
  }

  @override
  Future<void> updateUser(User user) async {
    return await _usersRef().doc(user.id).update(user.toFirestore());
  }

  @override
  Future<void> addReview({
    required String targetUserId,
    required String reviewerId,
    required int rating,
    required String comment,
  }) async {
    final reviewData = {
      'reviewerId': reviewerId,
      'rating': rating,
      'comment': comment,
      'createdAt': Timestamp.now(),
    };

    return await _usersRef().doc(targetUserId).update({
      'reviews': FieldValue.arrayUnion([reviewData]),
    });
  }
}
