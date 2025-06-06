/// This view is used to verify a user's email before they can use the application.
library;

import 'dart:async';
import 'package:mental_health_support_app/models/login_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class VerifyAccountView extends StatefulWidget {
  const VerifyAccountView({super.key});

  @override
  State<VerifyAccountView> createState() => _VerifyAccountViewState();
}

class _VerifyAccountViewState extends State<VerifyAccountView> {
  bool _waitingVerification = false;

  /// Sends a verification email
  Future<void> sendVerificationEmail(BuildContext context) async {
    // Used to show the loading indicator
    setState(() {
      _waitingVerification = true;
    });

    // Send the email.
    await FirebaseAuth.instance.currentUser!.sendEmailVerification();
  }

  @override
  Widget build(BuildContext context) {
    String msg;
    if (_waitingVerification) {
      msg =
          "You can return back to the login page after verifying your account.";
    } else {
      msg =
          "Before continuing, you need to verify your account via email. Please click the button bellow to continue.";
    }

    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(24),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Verify your account",
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              SizedBox(height: 12),
              Text(msg, maxLines: 2, textAlign: TextAlign.center),
              SizedBox(height: 12),
              if (_waitingVerification)
                Padding(
                  padding: EdgeInsets.fromLTRB(0, 0, 0, 12),
                  child: Text(
                    "Didn't get the email? Click bellow to resend it.",
                  ),
                ),
              FilledButton(
                onPressed: () => sendVerificationEmail(context),
                child: Text(
                  _waitingVerification ? "Resend email" : "Verify email",
                ),
              ),
              SizedBox(height: 12),
              FilledButton(
                onPressed: () {
                  setState(() {
                    _waitingVerification = false;
                  });
                  Provider.of<LoginProvider>(context, listen: false).logout();
                },
                child: Text("Return to login"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
