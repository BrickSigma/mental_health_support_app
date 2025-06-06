import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserModel extends ChangeNotifier {
  /// User data

  User? userInfo;
  String userName = "";
  String email = "";

  /// Creates a new document entry for the user.
  static Future<void> createUserDocument(
    String uid,
    String userName,
    String email,
  ) async {
    final db = FirebaseFirestore.instance;
    Map<String, dynamic> data = {
      "username": userName,
      "email": email,
    };

    await db.collection("users").doc(uid).set(data);
  }

  /// Retrieves the user data from firebase.
  ///
  /// `currentUser` - FirebaseAuth User instance
  Future<void> loadUserData(User currentUser) async {
    final db = FirebaseFirestore.instance;
    DocumentSnapshot<Map<String, dynamic>> document =
        await db.collection("users").doc(currentUser.uid).get();

    if (!document.exists) {
      return;
    }

    Map<String, dynamic> data = document.data()!;

    userInfo = currentUser;
    userName = data["username"] ?? currentUser.email ?? "";
    email = data["email"] ?? currentUser.email ?? "";
  }

  /// Copy user data from one object to this one.
  void copyFrom(UserModel user) {
    userInfo = user.userInfo;
    userName = user.userName;
    email = user.email;
  }

  /// Saves the user account information after editing the user profile.
  Future<void> updateUserData(
    String userName,
    String bio,
    List<Map<String, String>> links,
  ) async {
    this.userName = userName;

    Map<String, dynamic> data = {
      "username": this.userName,
      "email": email,
    };

    final db = FirebaseFirestore.instance;
    await db.collection("users").doc(userInfo!.uid).set(data);
    notifyListeners();
  }
}
