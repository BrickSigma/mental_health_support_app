import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

enum UserRole { patient, therapist, nonExistent }

/// Check the role of the user in the database.
Future<UserRole> checkUserRole(String uid) async {
  // Check if the user has registered before.
  final db = FirebaseFirestore.instance;
  DocumentSnapshot<Map<String, dynamic>> patientData =
      await db.collection("patients").doc(uid).get();

  if (patientData.exists) {
    return UserRole.patient;
  }

  DocumentSnapshot<Map<String, dynamic>> therapistData =
      await db.collection("therapists").doc(uid).get();

  if (therapistData.exists) {
    return UserRole.therapist;
  } else {
    return UserRole.nonExistent;
  }
}

abstract class UserInterface extends ChangeNotifier {
  UserRole get userRole;
  String get userName;
}
