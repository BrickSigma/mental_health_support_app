import 'package:flutter/material.dart';
import 'package:mental_health_support_app/views/app/therapist/home.dart';

class TherapistApp extends StatefulWidget {
  const TherapistApp({super.key});

  @override
  State<TherapistApp> createState() => _TherapistAppState();
}

class _TherapistAppState extends State<TherapistApp> {
  final List<Widget> _pages = [TherapistHomeView()];
  int _pageIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: _pages[_pageIndex]);
  }
}