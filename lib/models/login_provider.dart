/// Used to indicate the authenication/login state of the user and application
library;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginProvider extends ChangeNotifier {
  bool _loggedIn = false;
  bool? _isVerified = false;

  bool get loggedIn => _loggedIn;

  bool? get isVerified => _isVerified;

  /// Get the current authentication state of the app.
  User? getAuthState() {
    User? user = FirebaseAuth.instance.currentUser;
    _loggedIn = user != null;
    _isVerified = user?.emailVerified;
    return user;
  }

  set isVerified(bool? value) {
    _isVerified = value;
    notifyListeners();
  }

  /// Logs in a user.
  void login(bool isVerified) {
    _loggedIn = true;
    _isVerified = isVerified;
    notifyListeners();
  }

  /// Logs out a user.
  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
    _loggedIn = false;
    notifyListeners();
  }
}