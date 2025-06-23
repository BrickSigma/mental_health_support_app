import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class PatientSessionsScreen extends StatefulWidget {
  const PatientSessionsScreen({super.key});

  @override
  State<PatientSessionsScreen> createState() => _PatientSessionsScreenState();
}

class _PatientSessionsScreenState extends State<PatientSessionsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String _selectedFilter = 'upcoming';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Sessions'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                _selectedFilter = value;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'upcoming',
                child: Text('Upcoming Sessions'),
              ),
              const PopupMenuItem(
                value: 'past',
                child: Text('Past Sessions'),
              ),
              const PopupMenuItem(
                value: 'all',
                child: Text('All Sessions'),
              ),
            ],
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _getSessionsStream(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final sessions = snapshot.data!.docs;

          if (sessions.isEmpty) {
            return const Center(child: Text('No sessions found'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: sessions.length,
            itemBuilder: (context, index) {
              final session = sessions[index];
              final data = session.data() as Map<String, dynamic>;
              final dateTime = (data['dateTime'] as Timestamp).toDate();
              final duration = data['duration'] as int;
              final status = data['status'] as String? ?? 'pending';

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 4),
                child: ListTile(
                  title: Text(data['topic'] ?? 'No topic specified'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('With: ${data['therapistName'] ?? 'Therapist'}'),
                      Text(
                        'Date: ${DateFormat('MMM dd, yyyy').format(dateTime)}',
                      ),
                      Text('Time: ${DateFormat('h:mm a').format(dateTime)}'),
                      Text('Duration: $duration minutes'),
                      Text('Status: ${status.toUpperCase()}'),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.info_outline),
                    onPressed: () => _showSessionDetails(context, data),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Stream<QuerySnapshot> _getSessionsStream() {
    final now = DateTime.now();
    final patientId = _auth.currentUser?.uid;

    if (patientId == null) {
      return const Stream.empty();
    }

    Query query = _firestore
        .collection('sessions')
        .where('patientId', isEqualTo: patientId)
        .orderBy('dateTime');

    switch (_selectedFilter) {
      case 'upcoming':
        query = query.where('dateTime', isGreaterThanOrEqualTo: now);
        break;
      case 'past':
        query = query.where('dateTime', isLessThan: now);
        break;
      case 'all':
      default:
        break;
    }

    return query.snapshots();
  }

  Future<void> _showSessionDetails(
    BuildContext context,
    Map<String, dynamic> sessionData,
  ) async {
    final dateTime = (sessionData['dateTime'] as Timestamp).toDate();
    final duration = sessionData['duration'] as int;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Session Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                sessionData['topic'] ?? 'No topic specified',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 16),
              _buildDetailRow('Therapist:', sessionData['therapistName'] ?? 'Therapist'),
              _buildDetailRow(
                'Date:',
                DateFormat('MMMM d, yyyy').format(dateTime),
              ),
              _buildDetailRow(
                'Time:',
                DateFormat('h:mm a').format(dateTime),
              ),
              _buildDetailRow('Duration:', '$duration minutes'),
              _buildDetailRow('Status:', sessionData['status'] ?? 'pending'),
              if (sessionData['notes'] != null)
                _buildDetailRow('Notes:', sessionData['notes']),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CLOSE'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}