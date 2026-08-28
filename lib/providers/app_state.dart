import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'
    hide EmailAuthProvider, PhoneAuthProvider;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:vagoflax/services/cloudinary.dart';

import '../utils/firebase_options.dart';

class ApplicationState extends ChangeNotifier {
  ApplicationState() {
    init();
  }

  // use account loading to not load anything in the screen while account details are loading
  bool _accountLoading = true;
  bool get accountLoading => _accountLoading;

  bool _loggedIn = false;
  bool get loggedIn => _loggedIn;

  String _userId = '';
  String get userId => _userId;
  String _userRole = '';
  String get userRole => _userRole;
  String _userProfilePicture = '';
  String get profilePicture => _userProfilePicture;
  String? _userEmail;
  String get email => _userEmail ?? '';

  String _firstName = '';
  String get firstName => _firstName;
  String _lastName = '';
  String get lastName => _lastName;
  String _city = '';
  String get city => _city;
  String _canton = '';
  String get canton => _canton;
  String _description = '';
  String get description => _description;
  List<String> _skills = [];
  List<String> get skills => _skills;

  List<String> _history = [];
  List<String> get history => _history;

  String _name = '';
  String get name => _name;
  int? _companySize;
  int? get companySize => _companySize;

  String? tempRole;
  String? tempCanton;
  String? tempCity;
  File? tempProfilePicture;
  String? tempDescription;

  // student specific fields
  String? tempFirstName;
  String? tempLastName;

  // company specific fields
  String? tempName;
  int? tempCompanySize;

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
          await _loadUserData(user.uid);
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
        _resetUserData();
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
  }

  void signUpStep2(String role) {
    tempRole = role;
  }

  Future<void> signUpStep3Student(
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

  Future<void> signUpStep3Employer(
    String name,
    String description,
    String canton,
    String city,
    int companySize,
    File? profilePicture,
  ) async {
    tempName = name;
    tempDescription = description;
    tempCanton = canton;
    tempCity = city;
    tempCompanySize = companySize;
    tempProfilePicture = profilePicture;

    return finalizeSignUp();
  }

  Future<void> finalizeSignUp() async {
    // upload profile picture to Cloudinary and get the URL (for profilepictureURL)
    String profilePictureUrl = "";

    if (tempProfilePicture != null) {
      profilePictureUrl =
          await CloudinaryService.uploadProfilePicture(
            tempProfilePicture!,
            _userId,
          ) ??
          "";
    }

    // then add his account to Firestore collection "users"
    await FirebaseFirestore.instance
        .collection('users')
        .doc(_userId)
        .set(
          tempRole == 'student'
              ? {
                  'email': email,
                  'role': tempRole,
                  'firstName': tempFirstName,
                  'lastName': tempLastName,
                  'description': tempDescription,
                  'canton': tempCanton,
                  'city': tempCity,
                  'profilePictureUrl': profilePictureUrl == ""
                      ? null
                      : profilePictureUrl,
                  'createdAt': FieldValue.serverTimestamp(),
                }
              : {
                  'email': email,
                  'role': tempRole,
                  'name': tempName,
                  'description': tempDescription,
                  'canton': tempCanton,
                  'city': tempCity,
                  'profilePictureUrl': profilePictureUrl == ""
                      ? null
                      : profilePictureUrl,
                  'companySize': tempCompanySize,
                  'createdAt': FieldValue.serverTimestamp(),
                },
        );

    _userRole = tempRole ?? '';

    notifyListeners();
  }

  // log out function
  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  Future<void> _loadUserData(String uid) async {
    final docSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();

    if (docSnapshot.exists) {
      final data = docSnapshot.data()!;
      _userRole = data['role'] ?? '';
      _userProfilePicture = data['profilePictureUrl'] ?? '';
      _userEmail = data['email'] ?? '';
      _firstName = data['firstName'] ?? '';
      _lastName = data['lastName'] ?? '';
      _city = data['city'] ?? '';
      _canton = data['canton'] ?? '';
      _description = data['description'] ?? '';
      _skills = List<String>.from(data['skills'] ?? []);
      _name = data['name'] ?? '';
      _companySize = (data['companySize'] as num?)?.toInt();
      _history = List<String>.from(data['history'] ?? []);
    } else {
      _resetUserData();
    }
  }

  void _resetUserData() {
    _userRole = '';
    _userProfilePicture = '';
    _userEmail = '';
    _firstName = '';
    _lastName = '';
    _city = '';
    _canton = '';
    _description = '';
    _skills = [];
    _name = '';
    _companySize = null;
    _history = [];
  }

  Future<void> reloadUserData() async {
    if (_userId.isEmpty) return;
    await _loadUserData(_userId);
    notifyListeners();
  }

  Future<void> updateProfile({
    required String firstName,
    required String lastName,
    required String city,
    required String canton,
    required String description,
    required List<String> skills,
    required List<String> history,
    required File? profilePicture,
  }) async {
    await FirebaseFirestore.instance.collection('users').doc(_userId).update({
      'firstName': firstName,
      'lastName': lastName,
      'city': city,
      'canton': canton,
      'description': description,
      'skills': skills,
      'history': history,
      if (profilePicture != null)
        'profilePictureUrl': await CloudinaryService.uploadProfilePicture(
              profilePicture,
              _userId,
            ) ??
            '',
    });
  }
}
