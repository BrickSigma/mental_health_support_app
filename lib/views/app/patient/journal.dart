import 'package:flutter/material.dart';

class Journal extends StatefulWidget {
  const Journal({super.key});
  @override
  State<Journal> createState() => _JournalState();
}

class _JournalState extends State<Journal> {
  @override
  Widget build(Object context) {
    return Scaffold(
      appBar: AppBar(title: Text("Journaling")),
      body: Placeholder(),
    );
  }
}
