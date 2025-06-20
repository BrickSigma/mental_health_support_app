import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mental_health_support_app/views/app/patient/therapist_details.dart';

class FindTherapist extends StatefulWidget {
  const FindTherapist({super.key});

  @override
  State<FindTherapist> createState() => _FindTherapistState();
}

class _FindTherapistState extends State<FindTherapist> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String _searchQuery = '';
  final Map<String, bool> _requestStatus = {};

  Future<void> _sendRequest(String therapistId, String therapistName) async {
    final patient = _auth.currentUser;
    if (patient == null) return;

    setState(() {
      _requestStatus[therapistId] = true;
    });

    try {
      // Get patient data
      final patientDoc =
          await _firestore.collection('patients').doc(patient.uid).get();
      final patientData = patientDoc.data() as Map<String, dynamic>;

      // Create request document
      await _firestore
          .collection('therapists')
          .doc(therapistId)
          .collection('requests')
          .doc(patient.uid)
          .set({
            'patientId': patient.uid,
            'patientName': patientData['username'] ?? 'Unknown',
            'patientEmail': patient.email,
            'status': 'pending', // pending, accepted, rejected
            'timestamp': FieldValue.serverTimestamp(),
            'therapistName': therapistName,
          });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Request sent to $therapistName')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send request: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _requestStatus[therapistId] = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Find Therapist",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search by name or specialty...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              onChanged:
                  (value) => setState(() => _searchQuery = value.toLowerCase()),
            ),
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('therapists').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError)
            return const Center(child: Text('Error loading therapists'));
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No therapists found'));
          }

          final therapists =
              snapshot.data!.docs.where((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final name = data['username']?.toString().toLowerCase() ?? '';
                final specialty =
                    data['specialty']?.toString().toLowerCase() ?? '';
                return name.contains(_searchQuery) ||
                    specialty.contains(_searchQuery);
              }).toList();

          if (therapists.isEmpty) {
            return const Center(child: Text('No matching therapists found'));
          }

          return ListView.builder(
            itemCount: therapists.length,
            itemBuilder: (context, index) {
              final therapist = therapists[index];
              final data = therapist.data() as Map<String, dynamic>;
              final username = data['username'] ?? 'No name';
              final specialty = data['specialty'] ?? 'No specialty';
              final therapistId = therapist.id;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor:
                        Theme.of(context).colorScheme.primaryContainer,
                    child: Text(
                      username.isNotEmpty ? username[0].toUpperCase() : '?',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                  title: Text(username),
                  subtitle: Text(specialty),
                  trailing:
                      _requestStatus[therapistId] == true
                          ? const CircularProgressIndicator()
                          : ElevatedButton(
                            child: const Text('Request'),
                            onPressed:
                                () => _sendRequest(therapistId, username),
                          ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => TherapistDetails(
                              username: username,
                              email: data['email'] ?? '',
                              specialty: specialty,
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
