import 'package:flutter/material.dart';
import 'package:mental_health_support_app/views/app/therapist/home.dart';
import 'package:mental_health_support_app/views/app/therapist/appointments.dart';
import 'package:mental_health_support_app/views/app/therapist/profile.dart';

class TherapistApp extends StatefulWidget {
  const TherapistApp({super.key});

  @override
  State<TherapistApp> createState() => _TherapistAppState();
}

class _TherapistAppState extends State<TherapistApp> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const TherapistHomePage(),
    const Appointments(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
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
