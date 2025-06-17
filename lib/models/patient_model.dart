import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mental_health_support_app/models/user_interface.dart';

class PatientModel extends ChangeNotifier implements UserInterface {
  /// User data

  User? userInfo;
  String _userName = "";
  String email = "";

  static final String _collection = "patients";

  @override
  UserRole get userRole => UserRole.patient;

  @override
  String get userName => _userName;

  /// Creates a new document entry for the user.
  static Future<void> createUserDocument(
    String uid,
    String userName,
    String email,
  ) async {
    final db = FirebaseFirestore.instance;
    Map<String, dynamic> data = {"username": userName, "email": email};

    await db.collection(_collection).doc(uid).set(data);
  }

  /// Retrieves the user data from firebase.
  ///
  /// `currentUser` - FirebaseAuth User instance
  Future<void> loadUserData(User currentUser) async {
    final db = FirebaseFirestore.instance;
    DocumentSnapshot<Map<String, dynamic>> document =
        await db.collection(_collection).doc(currentUser.uid).get();

    if (!document.exists) {
      return;
    }

    Map<String, dynamic> data = document.data()!;

    userInfo = currentUser;
    _userName = data["username"] ?? currentUser.email ?? "";
    email = data["email"] ?? currentUser.email ?? "";
  }

  /// Saves the user account information after editing the user profile.
  Future<void> updateUserData(
    String userName,
    String bio,
    List<Map<String, String>> links,
  ) async {
    _userName = userName;

    Map<String, dynamic> data = {"username": _userName, "email": email};

    final db = FirebaseFirestore.instance;
    await db.collection(_collection).doc(userInfo!.uid).set(data);
    notifyListeners();
  }
}
