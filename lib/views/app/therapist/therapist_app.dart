import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mental_health_support_app/views/app/therapist/home.dart';
import 'package:mental_health_support_app/views/app/therapist/appointments.dart';
import 'package:mental_health_support_app/views/app/therapist/profile.dart';
import 'package:mental_health_support_app/views/app/therapist/therapist_patients.dart';
import 'package:mental_health_support_app/models/therapist_model.dart';

class TherapistApp extends StatefulWidget {
  const TherapistApp({super.key});

  @override
  State<TherapistApp> createState() => _TherapistAppState();
}

class _TherapistAppState extends State<TherapistApp> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final therapistModel = Provider.of<TherapistModel>(context);
    final therapistId = therapistModel.userInfo?.uid ?? '';

    final List<Widget> pages = [
      const TherapistHomePage(),
      TherapistPatients(therapistId: therapistId),
      const Appointments(),
      const ProfilePage(),
    ];

    return Scaffold(
      body: pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_outlined),
            activeIcon: Icon(Icons.people),
            label: 'Patients',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_outlined),
            activeIcon: Icon(Icons.calendar_today),
            label: 'Appointments',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outlined),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
