import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class Appointments extends StatefulWidget {
  const Appointments({super.key});

  @override
  State<Appointments> createState() => _AppointmentsState();
}

class _AppointmentsState extends State<Appointments> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Stream<QuerySnapshot> _getSessionsForPeriod(String period) {
    final therapistId = _auth.currentUser?.uid;
    if (therapistId == null) return const Stream.empty();

    DateTime startDate;
    DateTime endDate;
    final now = DateTime.now();

    switch (period) {
      case 'Today':
        startDate = DateTime(now.year, now.month, now.day);
        endDate = DateTime(now.year, now.month, now.day + 1);
        break;
      case 'This Week':
        startDate = now.subtract(Duration(days: now.weekday - 1));
        endDate = startDate.add(const Duration(days: 7));
        break;
      case 'This Month':
        startDate = DateTime(now.year, now.month, 1);
        endDate = DateTime(now.year, now.month + 1, 1);
        break;
      default:
        startDate = now;
        endDate = now.add(const Duration(days: 1));
    }

    return _firestore
        .collection('sessions')
        .where('therapistId', isEqualTo: therapistId)
        .where('dateTime', isGreaterThanOrEqualTo: startDate)
        .where('dateTime', isLessThan: endDate)
        .orderBy('dateTime')
        .snapshots();
  }

  Future<void> _cancelSession(String sessionId) async {
    try {
      await _firestore.collection('sessions').doc(sessionId).update({
        'status': 'cancelled',
        'cancelledAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Session cancelled successfully')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to cancel session: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Appointments', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Today'),
            Tab(text: 'This Week'),
            Tab(text: 'This Month'),
          ],
          labelColor: Theme.of(context).primaryColor,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Theme.of(context).primaryColor,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildSessionList('Today'),
          _buildSessionList('This Week'),
          _buildSessionList('This Month'),
        ],
      ),
    );
  }

  Widget _buildSessionList(String period) {
    return StreamBuilder<QuerySnapshot>(
      stream: _getSessionsForPeriod(period),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final sessions = snapshot.data?.docs ?? [];

        if (sessions.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.calendar_today, size: 48, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  'No sessions $period',
                  style: const TextStyle(fontSize: 18, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: sessions.length,
          itemBuilder: (context, index) {
            final session = sessions[index];
            final data = session.data() as Map<String, dynamic>;
            final dateTime = (data['dateTime'] as Timestamp).toDate();
            final status = data['status'] ?? 'pending';

            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          data['patientName'] ?? 'Patient',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        Chip(
                          label: Text(
                            status.toUpperCase(),
                            style: const TextStyle(fontSize: 12),
                          ),
                          backgroundColor: _getStatusColor(status),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Topic: ${data['topic'] ?? 'No topic specified'}',
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          DateFormat('MMM d, yyyy').format(dateTime),
                          style: const TextStyle(fontSize: 14),
                        ),
                        const SizedBox(width: 16),
                        const Icon(Icons.access_time, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          DateFormat('h:mm a').format(dateTime),
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.timer, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          'Duration: ${data['duration'] ?? '--'} minutes',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (status != 'cancelled')
                          TextButton(
                            onPressed: () => _showCancelConfirmation(
                              context,
                              session.id,
                              data['patientName'] ?? 'Patient',
                            ),
                            child: const Text(
                              'CANCEL',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () => _showSessionDetails(context, data),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                          ),
                          child: const Text('DETAILS'),
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
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return Colors.green[100]!;
      case 'pending':
        return Colors.orange[100]!;
      case 'cancelled':
        return Colors.red[100]!;
      default:
        return Colors.grey[100]!;
    }
  }

  Future<void> _showCancelConfirmation(
    BuildContext context,
    String sessionId,
    String patientName,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Session'),
        content: Text('Are you sure you want to cancel the session with $patientName?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('NO'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('YES', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _cancelSession(sessionId);
    }
  }

  Future<void> _showSessionDetails(
    BuildContext context,
    Map<String, dynamic> data,
  ) async {
    final dateTime = (data['dateTime'] as Timestamp).toDate();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Session Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Patient:', data['patientName'] ?? 'Patient'),
              _buildDetailRow('Email:', data['patientEmail'] ?? 'Not provided'),
              const Divider(),
              _buildDetailRow('Topic:', data['topic'] ?? 'No topic specified'),
              _buildDetailRow('Status:', data['status'] ?? 'pending'),
              const Divider(),
              _buildDetailRow(
                'Date:',
                DateFormat('MMMM d, yyyy').format(dateTime),
              ),
              _buildDetailRow(
                'Time:',
                DateFormat('h:mm a').format(dateTime),
              ),
              _buildDetailRow(
                'Duration:',
                '${data['duration'] ?? '--'} minutes'),
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