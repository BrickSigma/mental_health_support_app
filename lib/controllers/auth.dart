import 'package:flutter/material.dart';
import 'package:mental_health_support_app/models/login_provider.dart';
import 'package:mental_health_support_app/models/patient_model.dart';
import 'package:mental_health_support_app/models/therapist_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:prompt_dialog/prompt_dialog.dart';
import 'package:mental_health_support_app/models/user_interface.dart';
import 'package:provider/provider.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Signs up a user using the Google API.
Future<bool> googleSignIn(BuildContext context, bool? isTherapist) async {
  try {
    LoginProvider loginState = Provider.of<LoginProvider>(
      context,
      listen: false,
    );

    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication? googleAuth =
        await googleUser?.authentication;

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    // Once signed in, return the UserCredential
    UserCredential credentials = await FirebaseAuth.instance
        .signInWithCredential(credential);

    UserRole userRole = await checkUserRole(credentials.user!.uid);

    // If no data exists for the user, add it to the database.
    if (userRole == UserRole.nonExistent) {
      if (isTherapist == null) {
        if (!context.mounted) {
          throw Exception("Context not mounted to show alert dialog!");
        }
        isTherapist = await showDialog<bool>(
          context: context,
          builder:
              (context) => AlertDialog(
                title: Text(
                  "You have not created an account yet!",
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                content: Text("Create either a patient or therapist account:"),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(null),
                    child: Text("Cancel"),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: Text("Patient Account"),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: Text("Therapist Account"),
                  ),
                ],
              ),
        );

        if (isTherapist == null) {
          credentials.user?.delete();
          return false;
        }
      }

      if (isTherapist) {
        String specialty = "";
        if (!context.mounted) {
          throw Exception("Context not mounted to show alert dialog!");
        }

        String? input = await prompt(
          context,
          title: Text("What is your specialty?"),
          hintText: "Enter specialty (e.g. Depression/Anxiety)",
          textOK: const Text("Continue"),
          textCancel: const Text("Cancel sign up"),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return "Please enter a value";
            }
            return null;
          },
        );

        if (input == null || input.isEmpty) {
          credentials.user?.delete();
          return false;
        }

        specialty = input;

        await TherapistModel.createUserDocument(
          credentials.user!.uid,
          credentials.user!.displayName ?? credentials.user!.email ?? "",
          credentials.user!.email ?? "",
          specialty,
        );
      } else {
        await PatientModel.createUserDocument(
          credentials.user!.uid,
          credentials.user!.displayName ?? credentials.user!.email ?? "",
          credentials.user!.email ?? "",
        );
      }
    }

    loginState.login(credentials.user!.emailVerified);

    return true;
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Could not signup with Google!",
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    return false;
  }
}

/// Checks if a user exists in either patients or therapists collection
Future<UserRole> checkUserRole(String uid) async {
  final db = FirebaseFirestore.instance;

  // Check if user exists as patient
  final patientDoc = await db.collection('patients').doc(uid).get();
  if (patientDoc.exists) return UserRole.patient;

  // Check if user exists as therapist
  final therapistDoc = await db.collection('therapists').doc(uid).get();
  if (therapistDoc.exists) return UserRole.therapist;

  return UserRole.nonExistent;
}
