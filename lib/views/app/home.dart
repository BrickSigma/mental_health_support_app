import 'package:mental_health_support_app/models/login_provider.dart';
import 'package:flutter/material.dart';
import 'package:mental_health_support_app/models/user_interface.dart';
import 'package:provider/provider.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  String _dailyMessage(String? username) {
    final currentTime = DateTime.now();
    if (currentTime.hour < 12) {
      return "Good morning ${username ?? ""}";
    } else if (currentTime.hour < 18) {
      return "Good afternoon ${username ?? ""}";
    } else {
      return "Good evening ${username ?? ""}";
    }
  }

  @override
  Widget build(BuildContext context) {
    UserInterface user = Provider.of<UserInterface>(context, listen: false);
    LoginProvider loginProvider = Provider.of(context, listen: false);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _dailyMessage(user.userName),
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                SizedBox(height: 12),
                Text(
                  user.userRole == UserRole.patient ? "Patient" : "Therapist",
                ),
                SizedBox(height: 12),
                Text(
                  "Upcomming sessions",
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                SizedBox(height: 12),
                SizedBox(width: double.infinity, child: UpcommingSessionCard()),
                SizedBox(height: 12),
                FilledButton(
                  onPressed: () => loginProvider.logout(),
                  child: Text("Log out"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class UpcommingSessionCard extends StatelessWidget {
  const UpcommingSessionCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Text("No sessions planned for today"),
      ),
    );
  }
}
