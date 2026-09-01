import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:vagoflax/models/enum/user_role.dart';
import 'package:vagoflax/models/face_entry.dart';
import 'package:vagoflax/models/history.dart';
import 'package:vagoflax/services/cloudinary.dart';

import 'package:vagoflax/models/user.dart';
import 'package:vagoflax/repositories/user.dart';

class UserProvider with ChangeNotifier {
  final UserRepository _userRepository;
  StreamSubscription<List<User>>? _usersSubscription;
  StreamSubscription<List<FaceEntry>>? _faceIndexSubscription;
  List<User> _users = [];
  List<FaceEntry> _faceIndex = [];
  bool _isLoading = false;

  User? currentUser;

  List<User> get users => _users;
  List<FaceEntry> get faceIndex => _faceIndex;
  bool get isLoading => _isLoading;

  UserProvider(this._userRepository) {
    _subscribeToUsers();
    _subscribeToFaceIndex();
  }

  // Re-open the streams after a sign in or sign out to avoid stuck on cached data
  void restart() {
    _usersSubscription?.cancel();
    _faceIndexSubscription?.cancel();
    _subscribeToUsers();
    _subscribeToFaceIndex();
  }

  // Subscribe to the user stream from the repository to get real-time updates and notify listeners when the user list changes.
  void _subscribeToUsers() {
    // Notify listeners that the user list is loading before starting the subscription.
    _isLoading = true;
    notifyListeners();

    // Subscribe to the user stream from the repository and update the user list when new data is received.
    _usersSubscription = _userRepository.getUsers().listen(
      (users) {
        _users = users;
        _isLoading = false;
        notifyListeners();
      },
      onError: (error, stackTrace) {
        _users = [];
        _isLoading = false;
        notifyListeners();
        debugPrint('ERREUR STREAM USERS : $error');
        debugPrint('Stacktrace: $stackTrace');
      },
    );
  }

  void _subscribeToFaceIndex() {
    _faceIndexSubscription = _userRepository.getFaceIndex().listen(
      (entries) {
        _faceIndex = entries;
        notifyListeners();
      },
      onError: (error, stackTrace) {
        _faceIndex = [];
        notifyListeners();
        debugPrint('ERREUR STREAM FACE INDEX : $error');
        debugPrint('Stacktrace: $stackTrace');
      },
    );
  }

  @override
  void dispose() {
    _usersSubscription?.cancel();
    _faceIndexSubscription?.cancel();
    super.dispose();
  }

  Future<void> addUser(User user) async {
    await _userRepository.addUser(user);

    currentUser = user;
    notifyListeners();
  }

  Future<void> loadUserData(String uid) async {
    _isLoading = true;
    notifyListeners();

    try {
      currentUser = await _userRepository.getUserById(uid);
    } catch (e) {
      currentUser = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateUser({
    String? firstName,
    String? lastName,
    String? companyName,
    String? address,
    String? canton,
    String? description,
    List<String>? skills,
    List<HistoryEntry>? history,
    int? companySize,
    File? profilePicture,
  }) async {
    if (currentUser == null) return;

    String? profilePictureUrl = currentUser!.profilePictureUrl;

    if (profilePicture != null) {
      // Upload the new profile picture and get its URL
      profilePictureUrl =
          await CloudinaryService.uploadProfilePicture(
            profilePicture,
            currentUser!.id,
          ) ??
          profilePictureUrl;
    }

    final updatedUser = currentUser!.role == UserRole.student
        ? currentUser!.copyWith(
            firstName: firstName ?? currentUser!.firstName,
            lastName: lastName ?? currentUser!.lastName,
            address: address ?? currentUser!.address,
            canton: canton ?? currentUser!.canton,
            description: description ?? currentUser!.description,
            skills: skills ?? currentUser!.skills,
            history: history ?? currentUser!.history,
            profilePictureUrl: profilePictureUrl,
          )
        : currentUser!.copyWith(
            companyName: companyName ?? currentUser!.companyName,
            companySize: companySize ?? currentUser!.companySize,
            profilePictureUrl: profilePictureUrl,
          );

    await _userRepository.updateUser(updatedUser);
    notifyListeners();
  }

  User? getUserFromId(String userId) {
    User? user = _users.firstWhere(
      (user) => user.id == userId,
      orElse: () => User(
        id: "-1",
        email: '',
        role: UserRole.student,
        profilePictureUrl: '',
        createdAt: DateTime.now(),
        canton: "",
        address: "",
        description: "",
      ),
    );

    return user.id == "-1" ? null : user;
  }

  void clearUser() {
    currentUser = null;
    notifyListeners();
  }

  Future<void> addReview({
    required String targetUserId,
    required String reviewerId,
    required int rating,
    required String comment,
  }) async {
    assert(rating >= 1 && rating <= 5, 'Rating must be between 1 and 5');
    assert(comment.isNotEmpty, 'Comment cannot be empty');

    return await _userRepository.addReview(
      targetUserId: targetUserId,
      reviewerId: reviewerId,
      rating: rating,
      comment: comment,
    );
  }
}
