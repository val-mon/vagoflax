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
  Future<void> addUser(User user) {
    return _usersRef().add({...user.toFirestore()});
  }
}
