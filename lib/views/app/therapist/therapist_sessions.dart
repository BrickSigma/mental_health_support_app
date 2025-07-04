import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class TherapistSessionsScreen extends StatefulWidget {
  const TherapistSessionsScreen({super.key});

  @override
  State<TherapistSessionsScreen> createState() =>
      _TherapistSessionsScreenState();
}

class _TherapistSessionsScreenState extends State<TherapistSessionsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String _selectedFilter = 'upcoming'; // 'upcoming', 'past', 'all'

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
            itemBuilder:
                (context) => [
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
                      Text('With: ${data['patientName']}'),
                      Text(
                        'Date: ${DateFormat('MMM dd, yyyy').format(dateTime)}',
                      ),
                      Text('Time: ${DateFormat('h:mm a').format(dateTime)}'),
                      Text('Duration: $duration minutes'),
                      Text('Status: ${status.toUpperCase()}'),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => _showEditDialog(context, session.id, data),
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
    final therapistId = _auth.currentUser?.uid;

    if (therapistId == null) {
      return const Stream.empty();
    }

    Query query = _firestore
        .collection('sessions')
        .where('therapistId', isEqualTo: therapistId)
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

  Future<void> _showEditDialog(
    BuildContext context,
    String sessionId,
    Map<String, dynamic> sessionData,
  ) async {
    final dateTime = (sessionData['dateTime'] as Timestamp).toDate();
    final duration = sessionData['duration'] as int;
    final topic = sessionData['topic'] as String;

    DateTime newDate = dateTime;
    TimeOfDay newTime = TimeOfDay.fromDateTime(dateTime);
    int newDuration = duration;
    final topicController = TextEditingController(text: topic);

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Edit Session'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Date Picker
                    ListTile(
                      title: Text(
                        'Date: ${DateFormat('MMM dd, yyyy').format(newDate)}',
                      ),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () async {
                        final selectedDate = await showDatePicker(
                          context: context,
                          initialDate: newDate,
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(
                            const Duration(days: 365),
                          ),
                        );
                        if (selectedDate != null) {
                          setState(() => newDate = selectedDate);
                        }
                      },
                    ),

                    // Time Picker
                    ListTile(
                      title: Text('Time: ${newTime.format(context)}'),
                      trailing: const Icon(Icons.access_time),
                      onTap: () async {
                        final selectedTime = await showTimePicker(
                          context: context,
                          initialTime: newTime,
                        );
                        if (selectedTime != null) {
                          setState(() => newTime = selectedTime);
                        }
                      },
                    ),

                    // Duration
                    DropdownButtonFormField<int>(
                      value: newDuration,
                      items: const [
                        DropdownMenuItem(value: 30, child: Text('30 minutes')),
                        DropdownMenuItem(value: 45, child: Text('45 minutes')),
                        DropdownMenuItem(value: 60, child: Text('60 minutes')),
                        DropdownMenuItem(value: 90, child: Text('90 minutes')),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => newDuration = value);
                        }
                      },
                      decoration: const InputDecoration(labelText: 'Duration'),
                    ),

                    // Topic
                    TextField(
                      controller: topicController,
                      decoration: const InputDecoration(
                        labelText: 'Session Topic',
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final updatedDateTime = DateTime(
                      newDate.year,
                      newDate.month,
                      newDate.day,
                      newTime.hour,
                      newTime.minute,
                    );

                    try {
                      await _firestore
                          .collection('sessions')
                          .doc(sessionId)
                          .update({
                            'dateTime': updatedDateTime,
                            'duration': newDuration,
                            'topic': topicController.text,
                            'updatedAt': FieldValue.serverTimestamp(),
                          });

                      if (context.mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Session updated successfully'),
                          ),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Failed to update session: ${e.toString()}',
                            ),
                          ),
                        );
                      }
                    }
                  },
                  child: const Text('Save Changes'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
