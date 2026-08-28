import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:vagoflax/models/history_model.dart';
import 'package:vagoflax/services/cloudinary.dart';

import '../models/user_model.dart';
import '../repositories/user_repository.dart';

class UserProvider with ChangeNotifier {
  final UserRepository _userRepository;
  StreamSubscription<List<User>>? _usersSubscription;
  List<User> _users = [];
  bool _isLoading = false;

  User? currentUser;

  bool get hasProfilePicture =>
      currentUser?.profilePictureUrl != null &&
      currentUser?.profilePictureUrl!.isNotEmpty == true;

  List<User> get users => _users;
  bool get isLoading => _isLoading;

  UserProvider(this._userRepository) {
    _subscribeToUsers();
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
      onError: (error) {
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  @override
  void dispose() {
    _usersSubscription?.cancel();
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
    String? city,
    String? canton,
    String? description,
    List<String>? skills,
    List<HistoryEntry>? history,
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

    final updatedUser = currentUser!.copyWith(
      firstName: firstName ?? currentUser!.firstName,
      lastName: lastName ?? currentUser!.lastName,
      city: city ?? currentUser!.city,
      canton: canton ?? currentUser!.canton,
      description: description ?? currentUser!.description,
      skills: skills ?? currentUser!.skills,
      history: history ?? currentUser!.history,
      profilePictureUrl: profilePictureUrl,
    );

    await _userRepository.updateUser(updatedUser);
    notifyListeners();
  }

  void clearUser() {
    currentUser = null;
    notifyListeners();
  }
}
