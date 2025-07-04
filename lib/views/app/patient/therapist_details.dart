import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mental_health_support_app/controllers/stream_api.dart';
import 'package:mental_health_support_app/models/patient_model.dart';
import 'package:mental_health_support_app/stream_options.dart';
import 'package:mental_health_support_app/views/app/patient/book_session.dart';
import 'package:mental_health_support_app/views/components/call_screen.dart';
import 'package:provider/provider.dart';
import 'package:stream_video/stream_video.dart' hide ConnectionState;

class TherapistDetails extends StatelessWidget {
  final String therapistId;
  final String callId;
  final String patientId;
  final VoidCallback? onTherapistChanged;

  const TherapistDetails({
    super.key,
    required this.therapistId,
    required this.callId,
    required this.patientId,
    this.onTherapistChanged,
  });

  Future<void> _deleteFutureSessions() async {
    final now = DateTime.now();
    final sessionsSnapshot =
        await FirebaseFirestore.instance
            .collection('sessions')
            .where('patientId', isEqualTo: patientId)
            .where('therapistId', isEqualTo: therapistId)
            .where('dateTime', isGreaterThan: now)
            .get();

    final batch = FirebaseFirestore.instance.batch();
    for (var doc in sessionsSnapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  Future<void> _changeTherapist(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Change Therapist'),
            content: const Text(
              'This will remove your current therapist and cancel any future sessions. You can request a new one.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Confirm'),
              ),
            ],
          ),
    );

    if (confirmed != true) return;

    try {
      if (context.mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder:
              (context) => const Center(child: CircularProgressIndicator()),
        );
      }

      await _deleteFutureSessions();

      await FirebaseFirestore.instance
          .collection('patients')
          .doc(patientId)
          .update({
            'assignedTherapistId': FieldValue.delete(),
            'callId': FieldValue.delete(),
          });

      await FirebaseFirestore.instance
          .collection('patients')
          .doc(patientId)
          .collection('sentRequests')
          .get()
          .then((snapshot) {
            for (var doc in snapshot.docs) {
              doc.reference.delete();
            }
          });

      if (context.mounted) {
        Navigator.pop(context);
        if (onTherapistChanged != null) {
          onTherapistChanged!();
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Therapist removed and future sessions cancelled'),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    PatientModel patientModel = Provider.of(context, listen: false);

    if (therapistId.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Therapist Details')),
        body: const Center(
          child: Text('No therapist selected', style: TextStyle(fontSize: 18)),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Therapist Details'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.swap_horiz),
            tooltip: 'Change Therapist',
            onPressed: () => _changeTherapist(context),
          ),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('therapists')
                .doc(therapistId)
                .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error loading therapist details'));
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.person_off, size: 48),
                  SizedBox(height: 16),
                  Text(
                    'No therapist available',
                    style: TextStyle(fontSize: 18),
                  ),
                  Text('Please request a new therapist'),
                ],
              ),
            );
          }

          final therapist = snapshot.data!.data() as Map<String, dynamic>;
          final username = therapist['username'] ?? 'No Name';
          final email = therapist['email'] ?? 'No Email';
          final specialty = therapist['specialty'] ?? 'General Therapy';

          return SingleChildScrollView(
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
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: Text(
                    username,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Center(child: Text(specialty, style: TextStyle(fontSize: 16))),
                const SizedBox(height: 30),
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInfoRow('Email', email),
                        const Divider(),
                        _buildInfoRow('Specialty', specialty),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.video_call),
                        label: const Text('Start Video Call'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () async {
                          await StreamVideo.reset();

                          String userToken = await getStreamUserToken(
                            patientModel.userInfo?.uid ?? patientModel.userName,
                          );

                          final client = StreamVideo(
                            streamApiKey,
                            user: User.regular(
                              userId:
                                  patientModel.userInfo?.uid ??
                                  patientModel.userName,
                              name: patientModel.userName,
                            ),
                            userToken: userToken,
                          );

                          await client.connect();

                          try {
                            var call = StreamVideo.instance.makeCall(
                              callType: StreamCallType.defaultType(),
                              id: callId,
                            );

                            await call.getOrCreate();

                            if (context.mounted) {
                              // Created ahead
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CallScreen(call: call),
                                ),
                              );
                            }
                          } catch (e) {
                            debugPrint('Error joining or creating call: $e');
                            debugPrint(e.toString());
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => BookSession(
                                    therapistId: therapistId,
                                    therapistName: username,
                                    patientId: patientId,
                                  ),
                            ),
                          );
                        },
                        child: const Text(
                          'Book Session',
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
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
}
