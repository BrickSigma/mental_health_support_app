import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mental_health_support_app/models/user_interface.dart';

class PatientModel extends ChangeNotifier implements UserInterface {
  /// User data
  User? userInfo;
  String _userName = "";
  String email = "";
  String assignedTherapistId = "";

  static final String _collection = "patients";

  @override
  UserRole get userRole => UserRole.patient;

  @override
  String get userName => _userName;

  /// Creates a new document entry for the user with subcollections
  static Future<void> createUserDocument(
    String uid,
    String userName,
    String email,
  ) async {
    final db = FirebaseFirestore.instance;
    final patientRef = db.collection(_collection).doc(uid);
    
    // Create main patient document
    await patientRef.set({
      "username": userName,
      "email": email,
      "assignedTherapistId": "",
      "createdAt": FieldValue.serverTimestamp(),
    });

    // Create notifications subcollection
    await patientRef.collection('notifications').add({
      "patientId": uid,
      "read": true,
      "status": "delivered",
      "therapistId": "",
      "timestamp": FieldValue.serverTimestamp(),
      "title": "Notifications",
      "type": "system",
    });

    // Create therapists subcollection
    await patientRef.collection('therapists').doc('initial').set({
      'status': 'empty',
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  /// Retrieves the user data from firebase.
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
    assignedTherapistId = data["assignedTherapistId"] ?? "";
    
    notifyListeners();
  }

  /// Saves the user account information after editing the user profile.
  Future<void> updateUserData(String userName) async {
    _userName = userName;

    Map<String, dynamic> data = {
      "username": _userName,
      "email": email,
    };

    final db = FirebaseFirestore.instance;
    await db.collection(_collection).doc(userInfo!.uid).update(data);
    notifyListeners();
  }

  /// Delete patient account data
  Future<void> deleteAccount() async {
    final db = FirebaseFirestore.instance;

    db.collection(_collection).doc(userInfo?.uid).delete();
  }


  /// Load notifications for this patient
  Future<List<Map<String, dynamic>>> getNotifications() async {
    if (userInfo == null) return [];
    
    final snapshot = await FirebaseFirestore.instance
        .collection(_collection)
        .doc(userInfo!.uid)
        .collection('notifications')
        .orderBy('timestamp', descending: true)
        .get();

    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  Future<List<Map<String, dynamic>>> getTherapistRequests() async {
    if (userInfo == null) return [];
    
    final snapshot = await FirebaseFirestore.instance
        .collection(_collection)
        .doc(userInfo!.uid)
        .collection('therapists')
        .where('status', isNotEqualTo: 'empty')
        .get();

    return snapshot.docs.map((doc) => doc.data()).toList();
  }
}
