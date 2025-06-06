/// Reusable functions for authentication with Firebase like creating a new user,
/// signing in with Google, etc...
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mental_health_support_app/models/login_provider.dart';
import 'package:mental_health_support_app/models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Signs in a user using the Google API.
Future<bool> googleSignIn(BuildContext context) async {
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

    // Check if the user has registered before.
    final db = FirebaseFirestore.instance;
    DocumentSnapshot<Map<String, dynamic>> data =
        await db.collection("users").doc(credentials.user!.uid).get();

    // If no data exists for the user, add it to the database.
    if (!data.exists) {
      await UserModel.createUserDocument(
        credentials.user!.uid,
        credentials.user!.displayName ?? credentials.user!.email ?? "",
        credentials.user!.email ?? "",
      );
    }

    loginState.login(credentials.user!.emailVerified);

    return true;
  } catch (e) {
    return false;
  }
}
