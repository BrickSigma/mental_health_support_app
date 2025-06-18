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
        title: Text('$username'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 40,
              child: Text(username[0].toUpperCase()),
            ),
            const SizedBox(height: 20),
            Text('Name: $username', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            Text('Email: $email', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            Text('Specialty: $specialty', style: const TextStyle(fontSize: 18)),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
              },
              child: const Text('Book Session'),
            ),
          ],
        ),
      ),
    );
  }
}