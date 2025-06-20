import 'package:flutter/material.dart';

class Appointments extends StatefulWidget {
  const Appointments({super.key});
  @override
  State<Appointments> createState() => _AppointmentsState();
}

class _AppointmentsState extends State<Appointments> {
  @override
  Widget build(Object context) {
    return Scaffold(
      appBar: AppBar(title: Text("Apoointments")),
      body: Placeholder(),
    );
  }
}
