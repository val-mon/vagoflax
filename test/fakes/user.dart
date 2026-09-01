import 'dart:async';

import 'package:vagoflax/models/face_entry.dart';
import 'package:vagoflax/models/user.dart';
import 'package:vagoflax/models/enum/user_role.dart';
import 'package:vagoflax/repositories/user.dart';

class FakeUserRepository implements UserRepository {
  final _controller = StreamController<List<User>>.broadcast();
  final _faceController = StreamController<List<FaceEntry>>.broadcast();
  User? added;
  User? updated;

  void emit(List<User> users) => _controller.add(users);

  void emitFaceIndex(List<FaceEntry> entries) => _faceController.add(entries);

  @override
  Stream<List<User>> getUsers() => _controller.stream;

  @override
  Stream<List<FaceEntry>> getFaceIndex() => _faceController.stream;

  @override
  Future<void> addUser(User user) async => added = user;

  @override
  Future<User> getUserById(String uid) async => _user(uid);

  @override
  Future<void> updateUser(User user) async => updated = user;

  @override
  Future<void> addReview({
    required String targetUserId,
    required String reviewerId,
    required int rating,
    required String comment,
  }) async {}

  @override
  noSuchMethod(Invocation i) => super.noSuchMethod(i);
}

User _user(String id) => User(
  id: id,
  email: '$id@test.ch',
  role: UserRole.student,
  profilePictureUrl: '',
  createdAt: DateTime(2026, 1, 1),
  canton: 'VS',
  city: 'Sion',
  description: '',
);
