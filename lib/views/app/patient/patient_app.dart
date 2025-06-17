import 'package:flutter/material.dart';
import 'package:mental_health_support_app/views/app/home.dart';

class PatientApp extends StatefulWidget {
  const PatientApp({super.key});

  @override
  State<PatientApp> createState() => _PatientAppState();
}

class _PatientAppState extends State<PatientApp> {
  final List<Widget> _pages = [HomeView()];
  int _pageIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: _pages[_pageIndex]);
  }
}