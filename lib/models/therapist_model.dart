import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mental_health_support_app/models/user_interface.dart';

class TherapistModel extends ChangeNotifier implements UserInterface {
  /// User data
  User? userInfo;
  String _userName = "";
  String email = "";
  String specialty = "";

  static final String _collection = "therapists";

  @override
  UserRole get userRole => UserRole.therapist;

  @override
  String get userName => _userName;

  //Creates a new document entry for the therapist
  static Future<void> createUserDocument(
    String uid,
    String userName,
    String email,
    String specialty,
  ) async {
    final db = FirebaseFirestore.instance;
    final therapistRef = db.collection(_collection).doc(uid);
    
    // Create main therapist document
    await therapistRef.set({
      "username": userName,
      "email": email,
      "specialty": specialty,
      "createdAt": FieldValue.serverTimestamp(),
    });
  }

  /// Retrieves the therapist data from firebase
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
    specialty = data["specialty"] ?? "";
    
    notifyListeners();
  }

  /// Saves the user account information after editing the user profile.
  Future<void> updateUserData(String userName) async {
    _userName = userName;

    Map<String, dynamic> data = {
      "username": _userName,
      "email": email,
      "specialty": specialty,
    };

    final db = FirebaseFirestore.instance;
    await db.collection(_collection).doc(userInfo!.uid).update(data);
    notifyListeners();
  }

  /// Delete therapist account data
  Future<void> deleteAccount() async {
    final db = FirebaseFirestore.instance;

    db.collection(_collection).doc(userInfo?.uid).delete();
  }

  /// Get patient requests for this therapist
  Future<List<Map<String, dynamic>>> getPatientRequests() async {
    if (userInfo == null) return [];
    
    final snapshot = await FirebaseFirestore.instance
        .collection(_collection)
        .doc(userInfo!.uid)
        .collection('patient_requests')
        .where('status', isNotEqualTo: 'empty')
        .orderBy('timestamp', descending: true)
        .get();

    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  /// Get accepted patients for this therapist
  Future<List<Map<String, dynamic>>> getAcceptedPatients() async {
    if (userInfo == null) return [];
    
    final snapshot = await FirebaseFirestore.instance
        .collection(_collection)
        .doc(userInfo!.uid)
        .collection('patients')
        .where('active', isEqualTo: true)
        .get();

    return snapshot.docs.map((doc) => doc.data()).toList();
  }
}
