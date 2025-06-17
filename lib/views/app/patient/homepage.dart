import 'package:flutter/material.dart';
import 'package:mental_health_support_app/views/app/patient/notifications.dart';
import 'package:provider/provider.dart';
import 'package:mental_health_support_app/models/patient_model.dart';

class PatientHomePage extends StatefulWidget {
  const PatientHomePage({super.key});

  @override
  State<PatientHomePage> createState() => _PatientHomePageState();
}

class _PatientHomePageState extends State<PatientHomePage> {
  String _dailyMessage(String? username) {
    final hour = DateTime.now().hour;
    return hour < 12
        ? "Good morning, ${username ?? ""}"
        : hour < 18
        ? "Good afternoon, ${username ?? ""}"
        : "Good evening, ${username ?? ""}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          'HOME',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.black),
            onPressed:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PatientsNotification(),
                  ),
                ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Consumer<PatientModel>(
                builder:
                    (context, user, _) => Text(
                      _dailyMessage(user.userName),
                      style: const TextStyle(
                        fontSize: 20,
                        color: Colors.black87,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
              ),
              const SizedBox(height: 40),
              const Text(
                'Welcome to Akili Bora',
                style: TextStyle(fontSize: 18),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
