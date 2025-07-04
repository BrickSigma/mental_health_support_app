import 'package:mental_health_support_app/controllers/auth.dart';
import 'package:mental_health_support_app/models/login_provider.dart';
import 'package:mental_health_support_app/views/login/forgot_password.dart';
import 'package:mental_health_support_app/views/login/patient_signup.dart';
import 'package:mental_health_support_app/views/login/therapist_signup.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void signIn(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      try {
        LoginProvider loginProvider = Provider.of<LoginProvider>(
          context,
          listen: false,
        );

        final credentials = await FirebaseAuth.instance
            .signInWithEmailAndPassword(
              email: _emailController.text,
              password: _passwordController.text,
            );

        loginProvider.login(credentials.user!.emailVerified);
      } on FirebaseAuthException catch (e) {
        if (!context.mounted) {
          return;
        }
        if (e.code == 'user-not-found') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "No user found with that email.",
                textAlign: TextAlign.center,
              ),
            ),
          );
        } else if (e.code == 'wrong-password') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "Incorrect password entered.",
                textAlign: TextAlign.center,
              ),
            ),
          );
        } else if (e.code == 'invalid-credential') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "Invalid login details.",
                textAlign: TextAlign.center,
              ),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.account_circle_outlined, size: 160),
                Text(
                  "Login",
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                Divider(height: 24),
                Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: "Email",
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter an email';
                          } else if (!EmailValidator.validate(value)) {
                            return 'Please enter a valid email address';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 12),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        autocorrect: false,
                        enableSuggestions: false,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: "Password",
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 12),
                      FilledButton(
                        onPressed: () => signIn(context),
                        child: Text("Login"),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed:
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ForgotPasswordView(),
                        ),
                      ),
                  child: Text("Forgotten password?"),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Expanded(child: Divider()),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text("or"),
                    ),
                    Expanded(child: Divider()),
                  ],
                ),
                GestureDetector(
                  onTap: () => googleSignIn(context, null),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(3),
                      color: Theme.of(context).colorScheme.primaryContainer,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          FaIcon(FontAwesomeIcons.google, size: 20),
                          SizedBox(width: 12),
                          Text("Sign in with Google"),
                        ],
                      ),
                    ),
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Expanded(child: Divider()),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text("Create a new account"),
                    ),
                    Expanded(child: Divider()),
                  ],
                ),
                TextButton(
                  onPressed:
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PatientSignupView(),
                        ),
                      ),
                  child: Text("Create a patient account"),
                ),
                SizedBox(height: 6,),
                TextButton(
                  onPressed:
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TherapistSignupView(),
                        ),
                      ),
                  child: Text("Create a therapist account"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
