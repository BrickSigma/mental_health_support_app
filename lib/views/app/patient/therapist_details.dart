import 'package:flutter/material.dart';

class TherapistDetails extends StatelessWidget {
  final String username;
  final String email;
  final String specialty;

  const TherapistDetails({
    super.key,
    required this.username,
    required this.email,
    required this.specialty,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Therapist Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Name: $username', style: TextStyle(fontSize: 20)),
            SizedBox(height: 10),
            Text('Email: $email', style: TextStyle(fontSize: 20)),
            SizedBox(height: 10),
            Text('Specialty: $specialty', style: TextStyle(fontSize: 20)),
          ],
        ),
      ),
    );
  }
}