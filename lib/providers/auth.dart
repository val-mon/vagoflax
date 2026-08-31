import 'dart:async';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart'
    hide EmailAuthProvider, PhoneAuthProvider;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';

import 'package:vagoflax/models/enum/user_role.dart';
import 'package:vagoflax/providers/user.dart';
import 'package:vagoflax/models/history.dart';

import 'package:vagoflax/services/cloudinary.dart';
import 'package:vagoflax/models/user.dart' as usermodel;

import 'package:vagoflax/utils/firebase_options.dart';

class ApplicationState extends ChangeNotifier {
  final UserProvider userProvider;

  ApplicationState({required this.userProvider}) {
    init();
  }

  // use account loading to not load anything in the screen while account details are loading
  bool _accountLoading = true;
  bool get accountLoading => _accountLoading;

  bool _loggedIn = false;
  bool get loggedIn => _loggedIn;

  String _userId = '';
  String? _userEmail;

  String? tempRole;
  String? tempCanton;
  String? tempCity;
  File? tempProfilePicture;
  String? tempDescription;
  List<double> tempFaceSignature = const [];

  // student specific fields
  String? tempFirstName;
  String? tempLastName;

  // company specific fields
  String? tempCompanyName;
  int? tempCompanySize;

  void updateUserProvider(UserProvider newUserProvider) {
    userProvider.currentUser = newUserProvider.currentUser;
    notifyListeners();
  }

  Future<void> init() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    FirebaseUIAuth.configureProviders([EmailAuthProvider()]);

    FirebaseAuth.instance.userChanges().listen((user) async {
      if (user != null) {
        _accountLoading = true;
        _loggedIn = true;
        notifyListeners();
        _userId = user.uid;
        _userEmail = user.email;

        try {
          await userProvider.loadUserData(user.uid);
        } catch (e) {
          signOut();
        } finally {
          _accountLoading = false;
        }

        notifyListeners();
      } else {
        _loggedIn = false;
        _userId = "";
        _accountLoading = false;
        userProvider.currentUser = null;
        notifyListeners();
      }
    });
  }

  // log in function
  Future<void> logIn(String email, String password) async {
    await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email.trim().toLowerCase(),
      password: password,
    );
  }

  // sign up functions

  // step one creates the user's account in firebase without adding any data to the users collection in firestore.
  // This is done to ensure that the email is valid and not already in use.
  Future<void> signUpStep1(String email, String password) async {
    _userEmail = email.trim().toLowerCase();
    _userId = '';
    if (_userEmail == "" || password == "") {
      throw Exception('Email or password is empty');
    }

    // add user to Firebase Auth
    UserCredential userCredential = await FirebaseAuth.instance
        .createUserWithEmailAndPassword(email: email, password: password);

    _userId = userCredential.user?.uid ?? '';

    notifyListeners();
  }

  // step two keeps the face signature until the user document is created.
  void signUpStep2(List<double> faceSignature) {
    tempFaceSignature = faceSignature;
    notifyListeners();
  }

  // step three stores the chosen role until the profile form is submitted.
  void signUpStep3(String role) {
    tempRole = role;
    notifyListeners();
  }

  Future<void> signUpStep4Student(
    String firstname,
    String lastname,
    String description,
    String canton,
    String city /*, List<String> skills, List<String> history*/,
    File? profilePicture,
  ) async {
    // TODO: add skills and history
    tempFirstName = firstname;
    tempLastName = lastname;
    tempDescription = description;
    tempCanton = canton;
    tempCity = city;
    tempProfilePicture = profilePicture;

    return finalizeSignUp();
  }

  Future<void> signUpStep4Employer(
    String companyName,
    String description,
    String canton,
    String city,
    int companySize,
    File? profilePicture,
  ) async {
    tempCompanyName = companyName;
    tempDescription = description;
    tempCanton = canton;
    tempCity = city;
    tempCompanySize = companySize;
    tempProfilePicture = profilePicture;

    return finalizeSignUp();
  }

  Future<void> finalizeSignUp() async {
    // upload profile picture to Cloudinary and get the URL (for profilepictureURL)
    String? profilePictureUrl;

    if (tempProfilePicture != null) {
      profilePictureUrl =
          await CloudinaryService.uploadProfilePicture(
            tempProfilePicture!,
            _userId,
          ) ??
          "";
    }

    usermodel.User user = usermodel.User(
      id: _userId,
      email: _userEmail ?? FirebaseAuth.instance.currentUser?.email ?? '',
      role: tempRole == 'student' ? UserRole.student : UserRole.employer,
      profilePictureUrl: profilePictureUrl,
      faceSignature: tempFaceSignature,
      firstName: tempFirstName,
      lastName: tempLastName,
      description: tempDescription ?? '',
      canton: tempCanton ?? '',
      city: tempCity ?? '',
      companyName: tempCompanyName,
      companySize: tempCompanySize,
    );

    // then add his account to Firestore collection "users"
    await userProvider.addUser(user);

    notifyListeners();
  }

  // log out function
  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  Future<void> reloadUserData() async {
    if (_userId.isEmpty) return;
    await userProvider.loadUserData(_userId);
    notifyListeners();
  }

  Future<void> updateProfile({
    required String firstName,
    required String lastName,
    required String city,
    required String canton,
    required String description,
    required List<String> skills,
    required List<HistoryEntry> history,
    required File? profilePicture,
  }) async {
    await userProvider.updateUser(
      firstName: firstName,
      lastName: lastName,
      city: city,
      canton: canton,
      description: description,
      skills: skills,
      history: history,
      profilePicture: profilePicture,
    );
  }
}
