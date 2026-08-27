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

  bool _loggedIn = false;
  bool get loggedIn => _loggedIn;

  String userId = '';
  String userRole = '';
  String userProfilePicture = '';

  String? tempEmail;
  String? tempPassword;
  String? tempRole;
  String? tempName;
  String? tempCanton;
  String? tempCity;
  File? tempProfilePicture;
  String? tempDescription;

  // company specific fields
  int? tempCompanySize;

  Future<void> init() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    FirebaseUIAuth.configureProviders([EmailAuthProvider()]);

    FirebaseAuth.instance.userChanges().listen((user) async {
      if (user != null) {
        _loggedIn = true;
        userId = user.uid;

        try {
          final docSnapshot = await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();

          if (docSnapshot.exists) {
            final data = docSnapshot.data()!;
            userRole = data['role'];
            userProfilePicture = data['profilePictureUrl'];
          }
        } catch (e) {
          // TODO: Handle error
          // print('Error fetching user data: $e');
        }

        notifyListeners();
      } else {
        _loggedIn = false;
        userId = "";
        userRole = "";
        userProfilePicture = "";

        notifyListeners();
      }
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
      // print('Login error: $e');
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

  void saveSignUpStep3Student(
    String name,
    String description,
    String canton,
    String city /*, List<String> skills, List<String> history*/,
    File? profilePicture,
  ) {
    // TODO: add skills and history
    tempName = name;
    tempDescription = description;
    tempCanton = canton;
    tempCity = city;
    tempProfilePicture = profilePicture;
  }

  void saveSignUpStep3Employer(
    String name,
    String description,
    String canton,
    String city,
    int companySize,
    File? profilePicture,
  ) {
    tempName = name;
    tempDescription = description;
    tempCanton = canton;
    tempCity = city;
    tempCompanySize = companySize;
    tempProfilePicture = profilePicture;
  }

  Future<void> finalizeSignUp() async {
    try {
      if (tempEmail == null || tempPassword == null) {
        // shouldn't arrive here, but just in case
        throw Exception('Email or password is null');
      }

      // add user to Firebase Auth
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: tempEmail!,
            password: tempPassword!,
          );

      // get new user id
      final String uid = userCredential.user!.uid;

      // upload profile picture to Cloudinary and get the URL (for profilepictureURL)
      String profilePictureUrl = "";

      if (tempProfilePicture != null) {
        profilePictureUrl =
            await CloudinaryService.uploadProfilePicture(
              tempProfilePicture!,
              uid,
            ) ??
            "";
      }

      // then add his account to Firestore collection "users"
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .set(
            tempRole == 'student'
                ? {
                    'email': tempEmail,
                    'role': tempRole,
                    'name': tempName,
                    'description': tempDescription,
                    'canton': tempCanton,
                    'city': tempCity,
                    'profilePictureUrl': profilePictureUrl == ""
                        ? null
                        : profilePictureUrl,
                  }
                : {
                    'email': tempEmail,
                    'role': tempRole,
                    'name': tempName,
                    'description': tempDescription,
                    'canton': tempCanton,
                    'city': tempCity,
                    'profilePictureUrl': profilePictureUrl == ""
                        ? null
                        : profilePictureUrl,
                    'companySize': tempCompanySize,
                  },
          );
    } catch (e) {
      // Handle sign up error
      // print('Sign up error: $e');
    }
  }

  // log out function
  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
  }
}
