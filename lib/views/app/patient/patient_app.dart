import 'package:flutter/material.dart';
import 'package:mental_health_support_app/views/app/patient/find_therapist.dart';
import 'package:mental_health_support_app/views/app/patient/homepage.dart';
import 'package:mental_health_support_app/views/app/patient/journaling/journal.dart';
import 'package:mental_health_support_app/views/app/patient/meditation.dart';
import 'package:mental_health_support_app/views/app/patient/profile_page.dart';
<<<<<<< HEAD
import 'package:mental_health_support_app/views/app/patient/therapist_details.dart';
import 'package:firebase_auth/firebase_auth.dart';
=======
>>>>>>> 2e839cf9652601803eb79f7902fc89c8d5a7a1a0

class PatientApp extends StatefulWidget {
  const PatientApp({super.key});

  @override
  State<PatientApp> createState() => _PatientAppState();
}

class _PatientAppState extends State<PatientApp> {
  int _pageIndex = 0;
  final List<Widget> _pages = [
    PatientHomePage(),
    MeditationPage(),
    FindTherapist(),
    Journal(),
    ProfilePage(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_pageIndex],
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
