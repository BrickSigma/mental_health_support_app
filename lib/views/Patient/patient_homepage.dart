import 'package:flutter/material.dart';

class PatientHomepage extends StatefulWidget {
  const PatientHomepage({super.key});
  @override
  State<PatientHomepage> createState() => _PatientHomepageState();
}

class _PatientHomepageState extends State<PatientHomepage> {
  int _selectedIndex = 0;
  void _whenNavisTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
  @override
  Widget build(BuildContext context){
    
  }
}
