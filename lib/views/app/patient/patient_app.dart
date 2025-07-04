import 'package:flutter/material.dart';
import 'package:mental_health_support_app/views/app/patient/find_therapist.dart';
import 'package:mental_health_support_app/views/app/patient/homepage.dart';
import 'package:mental_health_support_app/views/app/patient/journaling/journal.dart';
import 'package:mental_health_support_app/views/app/patient/meditation.dart';
import 'package:mental_health_support_app/views/app/patient/profile_page.dart';
import 'package:mental_health_support_app/views/app/patient/therapist_details.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PatientApp extends StatefulWidget {
  final int initialIndex;

  const PatientApp({super.key, this.initialIndex = 0});

  @override
  State<PatientApp> createState() => _PatientAppState();
}

class _PatientAppState extends State<PatientApp> {
  int _pageIndex = 0;
  String? _assignedTherapistId;
  String _callId = "";
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _pageIndex = widget.initialIndex;
    _checkAssignedTherapist();
  }

  Future<void> _checkAssignedTherapist() async {
    setState(() => _isLoading = true);
    final patient = _auth.currentUser;
    if (patient == null) return;

    try {
      final patientDoc =
          await _firestore.collection('patients').doc(patient.uid).get();
      if (patientDoc.exists) {
        final data = patientDoc.data() as Map<String, dynamic>;
        setState(() {
          _assignedTherapistId = data['assignedTherapistId'];
          _callId = data["callId"];
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error checking assigned therapist: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : IndexedStack(
                index: _pageIndex,
                children: [
                  const PatientHomePage(),
                  const MeditationPage(),
                  _assignedTherapistId != null
                      ? TherapistDetails(
                        therapistId: _assignedTherapistId!,
                        callId: _callId,
                        patientId: _auth.currentUser?.uid ?? '',
                        onTherapistChanged: () {
                          setState(() {
                            _assignedTherapistId = null;
                          });
                          _checkAssignedTherapist();
                        },
                      )
                      : FindTherapist(
                        onTherapistChanged: () {
                          _checkAssignedTherapist();
                        },
                      ),
                  const Journal(),
                  const ProfilePage(),
                ],
              ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _pageIndex,
        onTap:
            (value) => setState(() {
              _pageIndex = value;
            }),
        showSelectedLabels: true,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.music_note),
            label: 'Meditate',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Therapists',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Journal'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
