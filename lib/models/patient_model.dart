import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mental_health_support_app/models/dass_model.dart';
import 'package:mental_health_support_app/models/user_interface.dart';

class PatientModel extends ChangeNotifier implements UserInterface {
  /// User data
  User? userInfo;
  String _userName = "";
  String email = "";
  String assignedTherapistId = "";
  String callId = "";

  /// Store the most recent DASS-21 form.
  ValueNotifier<DASSModel?> dassModel = ValueNotifier(null);

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
      "assignedTherapistId": null,
      "callId": null,
      "createdAt": FieldValue.serverTimestamp(),
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
    callId = data["callId"] ?? "";

    QuerySnapshot<Map<String, dynamic>> querySnapshot =
        await db
            .collection(_collection)
            .doc(currentUser.uid)
            .collection("sentimentForms")
            .orderBy("timeFilledIn", descending: true)
            .get();

    if (querySnapshot.docs.isNotEmpty) {
      dassModel.value = DASSModel.loadFromDocument(querySnapshot.docs[0]);
    } else {
      dassModel.value = null;
    }

    notifyListeners();
  }

  /// Saves the user account information after editing the user profile.
  Future<void> updateUserData(String userName) async {
    _userName = userName;

    Map<String, dynamic> data = {"username": _userName, "email": email};

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

    final snapshot =
        await FirebaseFirestore.instance
            .collection(_collection)
            .doc(userInfo!.uid)
            .collection('notifications')
            .orderBy('timestamp', descending: true)
            .get();

    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  Future<List<Map<String, dynamic>>> getTherapistRequests() async {
    if (userInfo == null) return [];

    final snapshot =
        await FirebaseFirestore.instance
            .collection(_collection)
            .doc(userInfo!.uid)
            .collection('therapists')
            .where('status', isNotEqualTo: 'empty')
            .get();

    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  /// Update the DASS Model.
  void setDASSModel(DASSModel? model) {
    dassModel.value = model;
    notifyListeners();
  }
}
