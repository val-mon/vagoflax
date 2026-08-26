import 'dart:async';
import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'
    hide EmailAuthProvider, PhoneAuthProvider;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';

import '../utils/firebase_options.dart';

class ApplicationState extends ChangeNotifier {
  ApplicationState() {
    init();
  }

  bool _loggedIn = false;
  bool get loggedIn => _loggedIn;

  String? tempEmail;
  String? tempPassword;
  String? tempRole;
  String? tempName;
  String? tempCanton;
  String? tempCity;
  String? tempProfilePictureUrl;
  String? tempDescription;

  // company specific fields
  int? tempCompanySize;

  Future<void> init() async {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);

    FirebaseUIAuth.configureProviders([
      EmailAuthProvider(),
    ]);

    FirebaseAuth.instance.userChanges().listen((user) {
      if (user != null) {
        _loggedIn = true;

          notifyListeners();
      } else {
        _loggedIn = false;
      }
      notifyListeners();
    });
  }

  // log in function
  Future<void> logIn(String email, String password) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      // Handle login error
      print('Login error: $e');
    }
  }

  // sign up functions
  void saveSignUpStep1Data(String email, String password) {
    tempEmail = email;
    tempPassword = password;
  }
  void saveSignUpStep2Data(String role) {
    tempRole = role;
  }
  void saveSignUpStep3Student(String name, String description, String canton, String city/*, List<String> skills, List<String> history*/) {
    // TODO: add profile picture, skills and history
    tempName = name;
    tempDescription = description;
    tempCanton = canton;
    tempCity = city;
  }
  void saveSignUpStep3Employer(String name, String description, String canton, String city, int companySize) {
    // TODO: add profile picture
    tempName = name;
    tempDescription = description;
    tempCanton = canton;
    tempCity = city;
    tempCompanySize = companySize;
  }
  Future<void> finalizeSignUp() async {
    try {
      if (tempEmail == null || tempPassword == null) {
        // shouldn't arrive here, but just in case
        throw Exception('Email or password is null');
      }

      // add user to Firebase Auth
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: tempEmail!,
        password: tempPassword!,
      );

      // then add his account to Firestore collection "users"
      final String uid = userCredential.user!.uid;

      await FirebaseFirestore.instance.collection('users').doc(uid).set(tempRole == 'student'
          ? {
        'email': tempEmail,
        'role': tempRole,
        'name': tempName,
        'description': tempDescription,
        'canton': tempCanton,
        'city': tempCity,
        'profilePictureUrl': tempProfilePictureUrl
      } : {
        'email': tempEmail,
        'role': tempRole,
        'name': tempName,
        'description': tempDescription,
        'canton': tempCanton,
        'city': tempCity,
        'profilePictureUrl': tempProfilePictureUrl,
        'companySize': tempCompanySize,
      });

    } catch (e) {
      // Handle sign up error
      print('Sign up error: $e');
    }
  }

  // log out function
  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
  }
}