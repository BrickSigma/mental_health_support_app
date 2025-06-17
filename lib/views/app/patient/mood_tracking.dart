import 'package:flutter/material.dart';

class MoodTracking extends StatefulWidget {
  const MoodTracking({super.key});
  @override
  State<MoodTracking> createState() => _MoodTrackingState();
}

class _MoodTrackingState extends State<MoodTracking> {
  @override
  Widget build(Object context) {
    return Scaffold(
      appBar: AppBar(title: Text("Mood tracking")),
      body: Placeholder(),
    );
  }
}
