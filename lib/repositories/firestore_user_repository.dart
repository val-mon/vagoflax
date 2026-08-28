import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vagoflax/models/user_model.dart';
import 'package:vagoflax/repositories/user_repository.dart';

class FirestoreUserRepository implements UserRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _usersRef() =>
      _db.collection('users');

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
    return await _usersRef().doc(user.id).set(user.toFirestore());
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
    await _usersRef().doc(user.id).update(user.toFirestore());
  }
}
