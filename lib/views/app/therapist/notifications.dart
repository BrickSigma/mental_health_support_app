
import 'package:flutter/material.dart';

class TherapistNotifications extends StatefulWidget {
  const TherapistNotifications({super.key});
  @override
  State<TherapistNotifications> createState() => _TherapistNotificationsState();
}

class _TherapistNotificationsState extends State<TherapistNotifications> {
  @override
  Widget build(Object context) {
    return Scaffold(
      appBar: AppBar(title: Text("Notifications")),
      body: Placeholder(),
    );
  }
}
