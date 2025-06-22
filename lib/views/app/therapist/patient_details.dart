import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mental_health_support_app/views/app/patient/sentiment_analysis/sentiment_form_report.dart';

class PatientDetails extends StatelessWidget {
  final String patientId;
  final String therapistId;

  const PatientDetails({
    super.key,
    required this.patientId,
    required this.therapistId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Patient Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.chat),
            onPressed: () {
              // TODO: Implement chat functionality
            },
          ),
        ],
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future:
            FirebaseFirestore.instance
                .collection('patients')
                .doc(patientId)
                .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Patient not found'));
          }

          final patientData = snapshot.data!.data() as Map<String, dynamic>;
          final username = patientData['username'] ?? 'No Name';
          final email = patientData['email'] ?? 'No Email';
          final assignedTherapistId = patientData['assignedTherapistId'] ?? '';

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
                      style: const TextStyle(fontSize: 36, color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _buildDetailCard(context, username, email, assignedTherapistId),
                const SizedBox(height: 30),
                _buildActionButtons(context, patientId, therapistId),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailCard(
    BuildContext context,
    String username,
    String email,
    String assignedTherapistId,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Name', username),
            const Divider(),
            _buildDetailRow('Email', email),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          SizedBox(
            width: 120,
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

  Widget _buildActionButtons(
    BuildContext context,
    String patientId,
    String therapistId,
  ) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            child: const Text('View Sentiment Analysis Report'),
            onPressed:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SentimentFormReportPage(patientId),
                  ),
                ),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            icon: const Icon(Icons.video_call),
            label: const Text('Start Video Session'),
            onPressed: () {
              //TODO
            },
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            icon: const Icon(Icons.note_add),
            label: const Text('Add Session Notes'),
            onPressed: () {
              // TODO: Implement session notes functionality
            },
          ),
        ),
      ],
    );
  }
}
