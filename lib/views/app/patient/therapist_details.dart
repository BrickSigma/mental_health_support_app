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
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Theme.of(context).primaryColor,
                child: Text(
                  username.isNotEmpty ? username[0].toUpperCase() : '?',
                  style: const TextStyle(
                    fontSize: 36,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),

            Center(
              child: Column(
                children: [
                  Text(
                    'Name: $username',
                    style: const TextStyle(fontSize: 20),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    'Email: $email',
                    style: const TextStyle(fontSize: 20),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    'Specialty: $specialty',
                    style: const TextStyle(fontSize: 20),
                  ),
                ],
              ),
            ),
            
            const Spacer(),
        
            SizedBox(
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                  },
                  child: const Text(
                    'Book Session',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}