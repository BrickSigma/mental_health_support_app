import 'package:flutter/material.dart';
import 'package:mental_health_support_app/views/app/patient/find_therapist.dart';
import 'package:mental_health_support_app/views/app/patient/homepage.dart';
import 'package:mental_health_support_app/views/app/patient/journal.dart';
import 'package:mental_health_support_app/views/app/patient/mood_tracking.dart';
import 'package:mental_health_support_app/views/app/patient/profile_page.dart';
import 'package:mental_health_support_app/views/app/patient/therapist_details.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PatientApp extends StatefulWidget {
  const PatientApp({super.key});

  @override
  State<PatientApp> createState() => _PatientAppState();
}

class _PatientAppState extends State<PatientApp> {
  int _pageIndex = 0;
  final List<Widget> _pages = [
    const PatientHomePage(),
    const MoodTracking(),
    const SizedBox(),
    const Journal(),
    const ProfilePage(),
  ];

  Widget _getTherapyPage() {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('patients')
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return const Center(child: Text('Error loading therapist data'));
        }

        final assignedTherapistId = snapshot.data?['assignedTherapistId'];
        
        if (assignedTherapistId != null && assignedTherapistId.isNotEmpty) {
          return TherapistDetails(therapistId: assignedTherapistId);
        } else {
          return const FindTherapist();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pageIndex == 2 
          ? _getTherapyPage()
          : _pages[_pageIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _pageIndex,
        onTap: (value) => setState(() {
          _pageIndex = value;
        }),
        showSelectedLabels: true,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.emoji_emotions_outlined),
            label: 'Mood',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Therapists',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'Journal',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}