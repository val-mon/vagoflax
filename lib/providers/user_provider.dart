import 'dart:async';

import 'package:flutter/material.dart';

import '../models/user_model.dart';
import '../repositories/user_repository.dart';

class UserProvider with ChangeNotifier {
  final UserRepository _userRepository;
  StreamSubscription<List<User>>? _usersSubscription;
  List<User> _users = [];
  bool _isLoading = false;

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

  void addUser(User user) {
    _userRepository.addUser(user);
  }
}
