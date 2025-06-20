import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mental_health_support_app/models/therapist_model.dart';
import 'package:mental_health_support_app/views/app/therapist/notifications.dart';

class TherapistHomePage extends StatefulWidget {
  const TherapistHomePage({super.key});

  @override
  State<TherapistHomePage> createState() => _TherapistHomePageState();
}

class _TherapistHomePageState extends State<TherapistHomePage> {
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
      appBar: AppBar(
        title: const Text(
          'Home',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TherapistNotifications(),
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
              Consumer<TherapistModel>(
                builder:
                    (context, therapist, _) => Text(
                      _dailyMessage(therapist.userName),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
              ),
              const SizedBox(height: 40),
              const Text(
                'Welcome',
                style: TextStyle(fontSize: 18),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
