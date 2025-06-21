import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class TherapistNotifications extends StatefulWidget {
  const TherapistNotifications({super.key});

  @override
  State<TherapistNotifications> createState() => _TherapistNotificationsState();
}

class _TherapistNotificationsState extends State<TherapistNotifications> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isProcessing = false;
  final DateFormat _dateFormat = DateFormat('MMM d, y • h:mm a');

  Future<bool> _verifyDocumentsBeforeUpdate({
    required String therapistId,
    required String patientId,
  }) async {
    try {
      // Verify request exists and is pending
      final requestDoc = await _firestore
          .collection('therapists')
          .doc(therapistId)
          .collection('requests')
          .doc(patientId)
          .get();
          
      return requestDoc.exists && requestDoc['status'] == 'pending';
    } catch (e) {
      return false;
    }
  }

  Future<void> _handleRequest({
    required String patientId,
    required String status,
    required String therapistId,
    required String patientName,
    required String patientEmail,
  }) async {
    if (_isProcessing) return;
    if (therapistId != _auth.currentUser?.uid) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Authentication error')),
      );
      return;
    }

    setState(() => _isProcessing = true);

    try {
      final canProceed = await _verifyDocumentsBeforeUpdate(
        therapistId: therapistId,
        patientId: patientId,
      );
      
      if (!canProceed) {
        throw Exception('Request no longer exists or was already processed');
      }

      final batch = _firestore.batch();

      // Update request status
      final requestRef = _firestore
          .collection('therapists')
          .doc(therapistId)
          .collection('requests')
          .doc(patientId);
      batch.update(requestRef, {
        'status': status,
        'processedAt': FieldValue.serverTimestamp(),
      });

      // Create notification for patient
      final notificationRef = _firestore
          .collection('patients')
          .doc(patientId)
          .collection('notifications')
          .doc();
      batch.set(notificationRef, {
        'type': 'therapist_response',
        'title': 'Therapist Request $status',
        'message': 'Your request has been $status by the therapist',
        'therapistId': therapistId,
        'patientId': patientId,
        'status': status,
        'read': false,
        'timestamp': FieldValue.serverTimestamp(),
      });

      if (status == 'accepted') {
        // Add to therapist's patients
        final therapistPatientRef = _firestore
            .collection('therapists')
            .doc(therapistId)
            .collection('patients')
            .doc(patientId);
        batch.set(therapistPatientRef, {
          'patientName': patientName,
          'patientEmail': patientEmail,
          'acceptedAt': FieldValue.serverTimestamp(),
          'active': true,
        });

        // Add therapist to patient's therapists
        final patientTherapistRef = _firestore
            .collection('patients')
            .doc(patientId)
            .collection('therapists')
            .doc(therapistId);
        batch.set(patientTherapistRef, {
          'therapistId': therapistId,
          'acceptedAt': FieldValue.serverTimestamp(),
          'active': true,
        });

        // Update patient's assigned therapist
        final patientRef = _firestore.collection('patients').doc(patientId);
        batch.update(patientRef, {'assignedTherapistId': therapistId});
      }

      await batch.commit();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Request $status successfully'),
          backgroundColor: status == 'accepted' ? Colors.green : Colors.orange,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update: ${e.toString()}'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final therapistId = _auth.currentUser?.uid;
    if (therapistId == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              const Text('Not authenticated', style: TextStyle(fontSize: 18)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => _auth.signOut(),
                child: const Text('Sign out'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Patient Requests'),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('therapists')
            .doc(therapistId)
            .collection('requests')
            .where('status', isEqualTo: 'pending')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final requests = snapshot.data?.docs ?? [];

          if (requests.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inbox,
                    size: 64,
                    color: Theme.of(context).colorScheme.primary.withAlpha(75),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No pending requests',
                    style: TextStyle(
                      fontSize: 18,
                      color: Theme.of(context).colorScheme.onSurface.withAlpha(155),
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final request = requests[index];
              final data = request.data() as Map<String, dynamic>;
              final timestamp = data['timestamp']?.toDate();
              final patientId = data['patientId'] ?? '';
              final patientName = data['patientName'] ?? 'Unknown';
              final patientEmail = data['patientEmail'] ?? '';

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            child: Text(patientName.isNotEmpty 
                                ? patientName[0].toUpperCase() 
                                : '?'),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  patientName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  patientEmail,
                                  style: TextStyle(
                                    color: Theme.of(context).hintColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            timestamp != null 
                                ? _dateFormat.format(timestamp) 
                                : 'No timestamp',
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context).hintColor,
                            ),
                          ),
                          if (!_isProcessing)
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.check, color: Colors.green),
                                  onPressed: () => _showConfirmationDialog(
                                    context,
                                    patientId: patientId,
                                    therapistId: therapistId,
                                    patientName: patientName,
                                    patientEmail: patientEmail,
                                    action: 'accept',
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.close, color: Colors.red),
                                  onPressed: () => _showConfirmationDialog(
                                    context,
                                    patientId: patientId,
                                    therapistId: therapistId,
                                    patientName: patientName,
                                    patientEmail: patientEmail,
                                    action: 'reject',
                                  ),
                                ),
                              ],
                            )
                          else
                            const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _showConfirmationDialog(
    BuildContext context, {
    required String patientId,
    required String therapistId,
    required String patientName,
    required String patientEmail,
    required String action,
  }) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${action.capitalize()} Request?'),
        content: Text(
          'Are you sure you want to $action the request from $patientName?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              action.toUpperCase(),
              style: TextStyle(
                color: action == 'accept' ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _handleRequest(
        patientId: patientId,
        therapistId: therapistId,
        patientName: patientName,
        patientEmail: patientEmail,
        status: action == 'accept' ? 'accepted' : 'rejected',
      );
    }
  }
}

extension StringExtension on String {
  String capitalize() {
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}