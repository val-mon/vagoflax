import 'package:vagoflax/models/user_model.dart';

abstract class UserRepository {
  Stream<List<User>> getUsers();
  Future<void> addUser(User user);
  Future<User> getUserById(String uid);
  Future<void> updateUser(User user);
  Future<void> addReview({
    required String targetUserId,
    required String reviewerId,
    required int rating,
    required String comment,
  });
}
