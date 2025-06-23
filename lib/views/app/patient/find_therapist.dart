import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mental_health_support_app/views/app/patient/therapist_details.dart';

class FindTherapist extends StatefulWidget {
  final VoidCallback? onTherapistChanged;

  const FindTherapist({super.key, this.onTherapistChanged});

  @override
  State<FindTherapist> createState() => _FindTherapistState();
}

class _FindTherapistState extends State<FindTherapist> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String _searchQuery = '';
  final Map<String, String> _requestStatus = {};
  bool _isLoading = false;

  Future<void> _sendRequest(
    BuildContext context,
    String therapistId,
    String therapistName,
  ) async {
    final patient = _auth.currentUser;
    if (patient == null) return;

    setState(() {
      _requestStatus[therapistId] = 'pending';
    });

    try {
      final patientDoc = await _firestore.collection('patients').doc(patient.uid).get();
      final patientData = patientDoc.data() as Map<String, dynamic>;

      await _firestore
          .collection('therapists')
          .doc(therapistId)
          .collection('requests')
          .doc(patient.uid)
          .set({
            'patientId': patient.uid,
            'patientName': patientData['username'] ?? 'Unknown',
            'patientEmail': patient.email,
            'status': 'pending',
            'timestamp': FieldValue.serverTimestamp(),
            'therapistName': therapistName,
          });

      await _firestore
          .collection('patients')
          .doc(patient.uid)
          .collection('sentRequests')
          .doc(therapistId)
          .set({
            'therapistId': therapistId,
            'therapistName': therapistName,
            'status': 'pending',
            'timestamp': FieldValue.serverTimestamp(),
          });

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Request sent to $therapistName')),
        );
      }
    } catch (e) {
      setState(() {
        _requestStatus.remove(therapistId);
      });
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send request: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _checkExistingRequests() async {
    setState(() => _isLoading = true);
    final patient = _auth.currentUser;
    if (patient == null) return;

    try {
      final sentRequests = await _firestore
          .collection('patients')
          .doc(patient.uid)
          .collection('sentRequests')
          .get();

      for (var doc in sentRequests.docs) {
        _requestStatus[doc.id] = doc['status'];
      }
    } catch (e) {
      debugPrint('Error checking existing requests: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _checkExistingRequests();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Find Therapist", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search by name or specialty',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                filled: true,
                fillColor: Colors.grey[200],
              ),
              onChanged: (value) => setState(() => _searchQuery = value.toLowerCase()),
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('therapists').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text('Error loading therapists'));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No therapists available'));
                }

                final therapists = snapshot.data!.docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final name = data['username']?.toString().toLowerCase() ?? '';
                  final specialty = data['specialty']?.toString().toLowerCase() ?? '';
                  return name.contains(_searchQuery) || specialty.contains(_searchQuery);
                }).toList();

                if (therapists.isEmpty) {
                  return const Center(child: Text('No matching therapists found'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.only(bottom: 16),
                  itemCount: therapists.length,
                  itemBuilder: (context, index) {
                    final therapist = therapists[index];
                    final data = therapist.data() as Map<String, dynamic>;
                    final username = data['username'] ?? 'No name';
                    final specialty = data['specialty'] ?? 'No specialty';
                    final therapistId = therapist.id;
                    final requestStatus = _requestStatus[therapistId];

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TherapistDetails(
                                therapistId: therapistId,
                                patientId: _auth.currentUser?.uid ?? '',
                                onTherapistChanged: widget.onTherapistChanged,
                              ),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 28,
                                backgroundColor: Colors.grey[300],
                                child: Icon(Icons.person, color: Colors.grey[700], size: 28),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(username, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                    Text(specialty, style: TextStyle(color: Colors.grey[600])),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              if (requestStatus != null)
                                Text(
                                  requestStatus == 'pending' ? 'Pending' : 'Requested',
                                  style: TextStyle(
                                    color: requestStatus == 'pending' ? Colors.orange : Colors.green,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              else
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(horizontal: 16),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                  ),
                                  onPressed: () => _sendRequest(context, therapistId, username),
                                  child: const Text('Request'),
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}