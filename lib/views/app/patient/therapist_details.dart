import 'package:flutter/material.dart';

class TherapistDetails extends StatefulWidget {
  const TherapistDetails({super.key});
  @override
  State<TherapistDetails> createState() => _TherapistDetailsState();
}

class _TherapistDetailsState extends State<TherapistDetails> {
  @override
  Widget build(Object context) {
    return Scaffold(
      appBar: AppBar(title: Text("Therapist Details")),
      body: Placeholder(),
    );
  }
}
