import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mental_health_support_app/models/user_model.dart';
import 'package:mental_health_support_app/views/Patient/find_therapist.dart';
import 'package:mental_health_support_app/views/Patient/journal.dart';
import 'package:mental_health_support_app/views/Patient/profile_page.dart';
import 'package:mental_health_support_app/views/Patient/mood_tracking.dart';
import 'package:mental_health_support_app/views/Patient/notifications.dart';

class PatientHomePage extends StatefulWidget {
  const PatientHomePage({Key? key}) : super(key: key);

  @override
  State<PatientHomePage> createState() => _PatientHomePageState();
}

class _PatientHomePageState extends State<PatientHomePage> {
  int _selectedIndex = 0;

  void _onNavTapped(int index) {
    setState(() => _selectedIndex = index);
    switch (index) {
      case 0:
        // Already on home
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => MoodTracking()),
        );
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => FindTherapist()),
        );
        break;
      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Journal()),
        );
        break;
      case 4:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ProfilePage()),
        );
        break;
    }
  }

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
            fontSize: 22
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.black),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => PatientsNotification()),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
        child: Column(
          children: [
            Consumer<UserModel>(
              builder: (context, user, _) => Text(
                _dailyMessage(user.userName),
                style: const TextStyle(
                  fontSize: 20, 
                  color: Colors.black87, 
                  fontWeight: FontWeight.bold
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
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onNavTapped,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.black45,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'HOME',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.emoji_emotions_outlined),
            label: 'MOOD',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'THERAPISTS',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'JOURNAL',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'PROFILE',
          ),
        ],
      ),
    );
  }
}