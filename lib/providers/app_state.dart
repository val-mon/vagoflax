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
  String userProfilePicture = '';
  String? userEmail;

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
        _userId = user.uid;
        userEmail = user.email;

        try {
          final docSnapshot = await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();

          if (docSnapshot.exists) {
            final data = docSnapshot.data()!;
            _userRole = data['role'] ?? '';
            userProfilePicture = data['profilePictureUrl'] ?? '';
          } else {
            _userRole = '';
            userProfilePicture = '';
          }
        } catch (e) {
          // TODO: Handle error
          // print('Error fetching user data: $e');
          signOut();
        } finally {
          _accountLoading = false;
        }

        notifyListeners();
      } else {
        _loggedIn = false;
        _userId = "";
        _userRole = "";
        userProfilePicture = "";
        _accountLoading = false;

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
    userEmail = email.trim().toLowerCase();
    _userId = '';
    if (userEmail == "" || password == "") {
      throw Exception('Email or password is empty');
    }

    // add user to Firebase Auth
    UserCredential userCredential = await FirebaseAuth.instance
        .createUserWithEmailAndPassword(email: userEmail!, password: password);

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
                  'email': userEmail,
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
                  'email': userEmail,
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
}
