import 'package:flutter/material.dart';
import 'package:mental_health_support_app/views/app/patient/notifications.dart';
import 'package:mental_health_support_app/views/app/patient/patient_sessions.dart';
import 'package:mental_health_support_app/views/app/patient/sentiment_analysis/sentiment_analysis_form.dart';
import 'package:mental_health_support_app/views/app/patient/sentiment_analysis/sentiment_form_report.dart';
import 'package:provider/provider.dart';
import 'package:mental_health_support_app/models/patient_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class PatientHomePage extends StatefulWidget {
  const PatientHomePage({super.key});

  @override
  State<PatientHomePage> createState() => _PatientHomePageState();
}

class _PatientHomePageState extends State<PatientHomePage> {
  String _dailyMessage(String? username) {
    final hour = DateTime.now().hour;
    return hour < 12
        ? "Good morning, ${username ?? ""}"
        : hour < 18
            ? "Good afternoon, ${username ?? ""}"
            : "Good evening, ${username ?? ""}";
  }

  Stream<QuerySnapshot> _getUpcomingSessions() {
    try {
      final patientId = FirebaseAuth.instance.currentUser?.uid;
      if (patientId == null) {
        debugPrint('No patient ID found');
        return const Stream.empty();
      }

      debugPrint('Fetching sessions for patient: $patientId');
      return FirebaseFirestore.instance
          .collection('sessions')
          .where('patientId', isEqualTo: patientId)
          .where('dateTime', isGreaterThanOrEqualTo: DateTime.now())
          .orderBy('dateTime')
          .snapshots();
    } catch (e) {
      debugPrint('Error in _getUpcomingSessions: $e');
      return const Stream.empty();
    }
  }

  @override
  Widget build(BuildContext context) {
    PatientModel patientModel = Provider.of(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text(_dailyMessage(patientModel.userName)),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PatientsNotification(),
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
              // Sentiment Analysis Section
              const SentimentAnalysisSection(),
              const SizedBox(height: 30),

              // Upcoming Sessions
              const Text(
                'Upcoming Sessions',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              // Upcoming Sessions List
              StreamBuilder<QuerySnapshot>(
                stream: _getUpcomingSessions(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    debugPrint('Session stream error: ${snapshot.error}');
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
                    children: sessions.take(3).map((doc) {
                      try {
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
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                          fontSize: 12,
                                        ),
                                      ),
                                      backgroundColor: _getStatusColor(
                                        data['status'] ?? 'pending',
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'With: ${data['therapistName'] ?? 'Therapist'}',
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
                                      context,
                                      doc.id,
                                      data,
                                    ),
                                    child: const Text('VIEW DETAILS'),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      } catch (e) {
                        debugPrint('Error rendering session ${doc.id}: $e');
                        return const Card(
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Text('Invalid session data'),
                          ),
                        );
                      }
                    }).toList(),
                  );
                },
              ),
              const SizedBox(height: 20),

              // View All Sessions button
              Center(
                child: ElevatedButton(
                  onPressed: () => _navigateToAllSessions(context),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
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
      MaterialPageRoute(builder: (context) => const PatientSessionsScreen()),
    );
  }

  Future<void> _showSessionDetails(
    BuildContext context,
    String sessionId,
    Map<String, dynamic> data,
  ) async {
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
              _buildDetailRow('Therapist:', data['therapistName'] ?? 'Therapist'),
              _buildDetailRow(
                'Date:',
                DateFormat('MMMM d, yyyy').format(dateTime),
              ),
              _buildDetailRow(
                'Time:',
                DateFormat('h:mm a').format(dateTime),
              ),
              _buildDetailRow('Duration:', '$duration minutes'),
              _buildDetailRow('Status:', data['status'] ?? 'pending'),
              if (data['notes'] != null)
                _buildDetailRow('Notes:', data['notes']),
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

class SentimentAnalysisSection extends StatelessWidget {
  const SentimentAnalysisSection({super.key});

  @override
  Widget build(BuildContext context) {
    PatientModel patientModel = Provider.of(context, listen: false);

    return ListenableBuilder(
      listenable: patientModel.dassModel,
      builder: (context, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Sentiment Analysis",
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 12),
            if (patientModel.dassModel.value == null)
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(12),
                  child: Text(
                    "You haven't filled in a form yet.",
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            if (patientModel.dassModel.value != null)
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Total score: ${patientModel.dassModel.value!.totalScore}",
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "Depression score: ${patientModel.dassModel.value!.getDepressionStatus()} (${patientModel.dassModel.value!.depressionScore})",
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "Anxiety score: ${patientModel.dassModel.value!.getAnxietyStatus()} (${patientModel.dassModel.value!.anxietyScore})",
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "Stress score: ${patientModel.dassModel.value!.getStressStatus()} (${patientModel.dassModel.value!.stressScore})",
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                FilledButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SentimentAnalysisForm(patientModel),
                    ),
                  ),
                  child: const Text("Fill in a new form"),
                ),
                if (patientModel.dassModel.value != null)
                  FilledButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SentimentFormReportPage(
                          patientModel.userInfo!.uid,
                        ),
                      ),
                    ),
                    child: const Text("View form history"),
                  ),
              ],
            ),
          ],
        );
      },
    );
  }
}