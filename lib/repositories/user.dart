import 'package:vagoflax/models/face_entry.dart';
import 'package:vagoflax/models/user.dart';

abstract class UserRepository {
  Stream<List<User>> getUsers();
  Stream<List<FaceEntry>> getFaceIndex();
  Future<void> addUser(User user);
  Future<User> getUserById(String uid);
  Future<void> updateUser(User user);
  Future<void> addReview({
    required String targetUserId,
    required String reviewerId,
    required int rating,
    required String comment,
  });
  Future<void> addSavedSearch(String userId, String search);
  Future<void> removeSavedSearch(String userId, String search);
}
