import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mental_health_support_app/views/app/patient/book_session.dart';

class TherapistDetails extends StatelessWidget {
  final String therapistId;
  final String patientId;

  const TherapistDetails({
    super.key,
    required this.therapistId,
    required this.patientId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Therapist Details'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.swap_horiz),
            tooltip: 'Change Therapist',
            onPressed: () {
              //TODO:Changetherapist
            },
          ),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('therapists')
                .doc(therapistId)
                .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Therapist not found'));
          }

          final therapist = snapshot.data!.data() as Map<String, dynamic>;
          final username = therapist['username'] ?? 'No Name';
          final email = therapist['email'] ?? 'No Email';
          final specialty = therapist['specialty'] ?? 'General Therapy';

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: Theme.of(context).primaryColor,
                    child: Text(
                      username.isNotEmpty ? username[0].toUpperCase() : '?',
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                // Therapist Information
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInfoRow('Name', username),
                        const Divider(),
                        _buildInfoRow('Email', email),
                        const Divider(),
                        _buildInfoRow('Specialty', specialty),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                const Spacer(),

                // Book Session Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => BookSession(
                                therapistId: therapistId,
                                therapistName: username,
                                patientId: patientId,
                              ),
                        ),
                      );
                    },
                    child: const Text(
                      'Book Session',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
