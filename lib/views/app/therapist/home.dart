import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mental_health_support_app/models/therapist_model.dart';
import 'package:mental_health_support_app/views/app/therapist/notifications.dart';
import 'package:mental_health_support_app/views/app/therapist/therapist_sessions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class TherapistHomePage extends StatefulWidget {
  const TherapistHomePage({super.key});

  @override
  State<TherapistHomePage> createState() => _TherapistHomePageState();
}

class _TherapistHomePageState extends State<TherapistHomePage> {
  String _dailyMessage(String? username) {
    final hour = DateTime.now().hour;
    return hour < 12
        ? "Good morning, ${username ?? ""}"
        : hour < 18
            ? "Good afternoon, ${username ?? ""}"
            : "Good evening, ${username ?? ""}";
  }

  Stream<QuerySnapshot> _getUpcomingSessions() {
    final therapistId = FirebaseAuth.instance.currentUser?.uid;
    if (therapistId == null) return const Stream.empty();

    return FirebaseFirestore.instance
        .collection('sessions')
        .where('therapistId', isEqualTo: therapistId)
        .where('dateTime', isGreaterThanOrEqualTo: DateTime.now())
        .orderBy('dateTime')
        .limit(3)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Home',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const TherapistNotifications(),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Greeting
              Consumer<TherapistModel>(
                builder: (context, therapist, _) => Text(
                  _dailyMessage(therapist.userName),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // Upcoming Sessions
              const Text(
                'Upcoming Sessions',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // Upcoming Sessions List
              StreamBuilder<QuerySnapshot>(
                stream: _getUpcomingSessions(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Text('Error loading sessions');
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final sessions = snapshot.data?.docs ?? [];

                  if (sessions.isEmpty) {
                    return const Card(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Text('No upcoming sessions'),
                      ),
                    );
                  }

                  return Column(
                    children: sessions.map((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      final dateTime = (data['dateTime'] as Timestamp).toDate();
                      final duration = data['duration'] as int;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    data['topic'] ?? 'No topic specified',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Chip(
                                    label: Text(
                                      data['status'] ?? 'pending',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                      ),
                                    ),
                                    backgroundColor: _getStatusColor(
                                        data['status'] ?? 'pending'),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'With: ${data['patientName'] ?? 'Patient'}',
                                style: const TextStyle(fontSize: 14),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${DateFormat('EEEE, MMM d').format(dateTime)} • ${DateFormat('h:mm a').format(dateTime)}',
                                style: const TextStyle(fontSize: 14),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Duration: $duration minutes',
                                style: const TextStyle(fontSize: 14),
                              ),
                              const SizedBox(height: 8),
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: () => _showSessionDetails(
                                      context, doc.id, data),
                                  child: const Text('VIEW DETAILS'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
              const SizedBox(height: 20),

            // View All Sessions
              Center(
                child: ElevatedButton(
                  onPressed: () => _navigateToAllSessions(context),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                  ),
                  child: const Text('View All Sessions'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _navigateToAllSessions(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const TherapistSessionsScreen(),
      ),
    );
  }

  Future<void> _showSessionDetails(
      BuildContext context, String sessionId, Map<String, dynamic> data) async {
    final dateTime = (data['dateTime'] as Timestamp).toDate();
    final duration = data['duration'] as int;

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
                data['topic'] ?? 'No topic specified',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 16),
              _buildDetailRow('Patient:', data['patientName'] ?? 'Patient'),
              _buildDetailRow('Date:', DateFormat('MMMM d, yyyy').format(dateTime)),
              _buildDetailRow('Time:', DateFormat('h:mm a').format(dateTime)),
              _buildDetailRow('Duration:', '$duration minutes'),
              _buildDetailRow('Status:', data['status'] ?? 'pending'),
              if (data['patientEmail'] != null)
                _buildDetailRow('Email:', data['patientEmail']),
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