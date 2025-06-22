import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mental_health_support_app/models/patient_model.dart';
import 'package:mental_health_support_app/views/app/therapist/patient_details.dart';

class TherapistPatients extends StatelessWidget {
  final String therapistId;

  const TherapistPatients({super.key, required this.therapistId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Patients'),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('patients')
            .where('assignedTherapistId', isEqualTo: therapistId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No patients assigned yet'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final patientDoc = snapshot.data!.docs[index];
              final patientData = patientDoc.data() as Map<String, dynamic>;
              final patientId = patientDoc.id;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text(patientData['username']?[0].toUpperCase() ?? '?'),
                  ),
                  title: Text(patientData['username'] ?? 'No Name'),
                  subtitle: Text(patientData['email'] ?? 'No Email'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PatientDetails(
                          patientId: patientId,
                          therapistId: therapistId,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}