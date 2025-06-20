import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TherapistNotifications extends StatelessWidget {
  const TherapistNotifications({super.key});

  Future<void> _handleRequest(
    BuildContext context, 
    String patientId, 
    String status,
    String therapistId,
  ) async {
    try {
      final firestore = FirebaseFirestore.instance;
      final batch = firestore.batch();

      //Update request status
      final requestRef = firestore.collection('therapists')
        .doc(therapistId)
        .collection('requests')
        .doc(patientId);
      batch.update(requestRef, {
        'status': status,
        'processedAt': FieldValue.serverTimestamp()
      });

      //If accepted, create two-way relationship
      if (status == 'accepted') {
        // Add to therapist's patients
        final therapistPatientRef = firestore.collection('therapists')
          .doc(therapistId)
          .collection('patients')
          .doc(patientId);
        batch.set(therapistPatientRef, {
          'acceptedAt': FieldValue.serverTimestamp(),
          'active': true
        });

        // Add therapist to patient's therapists
        final patientTherapistRef = firestore.collection('patients')
          .doc(patientId)
          .collection('therapists')
          .doc(therapistId);
        batch.set(patientTherapistRef, {
          'acceptedAt': FieldValue.serverTimestamp(),
          'active': true
        });

        // Update patient's assigned therapist
        final patientRef = firestore.collection('patients').doc(patientId);
        batch.update(patientRef, {
          'assignedTherapistId': therapistId
        });
      }

      await batch.commit();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Request $status successfully')),
      );
    } catch (e, stack) {
      debugPrint('Error handling request: $e\n$stack');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final therapistId = FirebaseAuth.instance.currentUser?.uid;
    if (therapistId == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Not authenticated'),
              TextButton(
                onPressed: () => FirebaseAuth.instance.signOut(),
                child: const Text('Sign out'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Session Requests'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {},
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
          .collection('therapists')
          .doc(therapistId)
          .collection('requests')
          .where('status', isEqualTo: 'pending')
          .orderBy('timestamp', descending: true)
          .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            debugPrint('Stream error: ${snapshot.error}');
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Error loading requests'),
                  Text(
                    snapshot.error.toString(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final requests = snapshot.data?.docs ?? [];

          if (requests.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No pending requests'),
                ],
              ),
            );
          }

          return ListView.separated(
            itemCount: requests.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final request = requests[index];
              final data = request.data() as Map<String, dynamic>;
              final timestamp = data['timestamp']?.toDate();

              return ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                leading: CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                  child: Text(
                    data['patientName']?[0] ?? '?',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
                title: Text(
                  data['patientName'] ?? 'Unknown',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (data['patientEmail'] != null)
                      Text(data['patientEmail']),
                    if (timestamp != null)
                      Text(
                        'Requested ${_formatDate(timestamp)}',
                        style: const TextStyle(fontSize: 12),
                      ),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.check_circle, color: Colors.green),
                      onPressed: () => _showConfirmationDialog(
                        context,
                        patientId: data['patientId'],
                        therapistId: therapistId,
                        action: 'accept',
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.cancel, color: Colors.red),
                      onPressed: () => _showConfirmationDialog(
                        context,
                        patientId: data['patientId'],
                        therapistId: therapistId,
                        action: 'reject',
                      ),
                    ),
                  ],
                ),
                onTap: () {
                },
              );
            },
          );
        },
      ),
    );
  }

  void _showConfirmationDialog(
    BuildContext context, {
    required String patientId,
    required String therapistId,
    required String action,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm $action'),
        content: Text('Are you sure you want to $action this request?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _handleRequest(
                context,
                patientId,
                action == 'accept' ? 'accepted' : 'rejected',
                therapistId,
              );
            },
            child: Text(action.toUpperCase()),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}