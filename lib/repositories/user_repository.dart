import '../models/user_model.dart';

abstract class UserRepository {
  Stream<List<User>> getUsers();
}
