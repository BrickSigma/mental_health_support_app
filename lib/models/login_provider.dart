import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginProvider extends ChangeNotifier {
  bool _loggedIn = false;
  bool _isVerified = false;
  User? _currentUser;

  bool get loggedIn => _loggedIn;
  bool get isVerified => _isVerified;
  User? get currentUser => _currentUser;

  /// Initialize auth state listener
  LoginProvider() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      _currentUser = user;
      _loggedIn = user != null;
      _isVerified = user?.emailVerified ?? false;
      notifyListeners();
    });
  }

  /// Get current auth state and update provider
  Future<User?> checkAuthState() async {
    _currentUser = FirebaseAuth.instance.currentUser;
    _loggedIn = _currentUser != null;
    _isVerified = _currentUser?.emailVerified ?? false;
    notifyListeners();
    return _currentUser;
  }

  /// Handle user login
  Future<void> login() async {
    try {
      _currentUser = FirebaseAuth.instance.currentUser;
      if (_currentUser != null) {
        _loggedIn = true;
        _isVerified = _currentUser!.emailVerified;
        notifyListeners();
      }
    } catch (e) {
      _loggedIn = false;
      _isVerified = false;
      notifyListeners();
      rethrow;
    }
  }

  /// Handle user logout
  Future<void> logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      _loggedIn = false;
      _isVerified = false;
      _currentUser = null;
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  /// Check and update email verification status
  Future<void> checkEmailVerification() async {
    await _currentUser?.reload();
    _isVerified = _currentUser?.emailVerified ?? false;
    notifyListeners();
  }
}