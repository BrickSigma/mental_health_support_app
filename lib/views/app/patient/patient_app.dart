import 'package:flutter/material.dart';
import 'package:mental_health_support_app/views/app/patient/find_therapist.dart';
import 'package:mental_health_support_app/views/app/patient/homepage.dart';
import 'package:mental_health_support_app/views/app/patient/journal.dart';
import 'package:mental_health_support_app/views/app/patient/mood_tracking.dart';
import 'package:mental_health_support_app/views/app/patient/meditation.dart';
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
    MeditationPage(),
    PatientHomePage(),
    MoodTracking(),
    FindTherapist(),
    Journal(),
    ProfilePage(),
  ];
  int _pageIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pageIndex == 2 ? _getTherapyPage() : _pages[_pageIndex],
      bottomNavigationBar: BottomNavigationBar(
        useLegacyColorScheme: true,
        currentIndex: _pageIndex,
        onTap:
            (value) => setState(() {
              _pageIndex = value;
            }),
        showSelectedLabels: true,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.emoji_emotions_outlined),
            label: 'Mood',
          ),
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
