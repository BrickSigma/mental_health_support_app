import 'package:flutter/material.dart';
import 'package:mental_health_support_app/views/app/patient/find_therapist.dart';
import 'package:mental_health_support_app/views/app/patient/homepage.dart';
import 'package:mental_health_support_app/views/app/patient/journal.dart';
import 'package:mental_health_support_app/views/app/patient/mood_tracking.dart';
import 'package:provider/provider.dart';
//import 'package:firebase_auth/firebase_auth.dart';
import 'package:mental_health_support_app/models/login_provider.dart';
import 'package:mental_health_support_app/models/patient_model.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int _selectedIndex = 4;

  void _onNavTapped(int index) {
    if (index == _selectedIndex) return;
    
    setState(() => _selectedIndex = index);
    
    switch (index) {
      case 0:
        _navigateTo(const PatientHomePage());
        break;
      case 1:
        _navigateTo(const MoodTracking());
        break;
      case 2:
        _navigateTo(const FindTherapist());
        break;
      case 3:
        _navigateTo(const Journal());
        break;
    }
  }

  void _navigateTo(Widget page) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }

  Future<void> _logout(BuildContext context) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Log Out', style: TextStyle(color: Colors.red)),
      )],
      ),
    );

    if (shouldLogout == true) {
      await _performLogout();
    }
  }

  Future<void> _performLogout() async {
    try {
      final loginProvider = Provider.of<LoginProvider>(context, listen: false);
      await loginProvider.logout();
      _navigateToLogin();
    } catch (e) {
      _showErrorSnackbar('Logout failed: ${e.toString()}');
    }
  }

  void _navigateToLogin() {
    Navigator.pushNamedAndRemoveUntil(
      context, 
      '/login', 
      (route) => false,
    );
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<PatientModel>(context, listen: false);
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: _buildBody(user),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: const Text('Profile', style: TextStyle(color: Colors.black)),
      backgroundColor: Colors.white,
      elevation: 0,
      iconTheme: const IconThemeData(color: Colors.black),
    );
  }

  Widget _buildBody(PatientModel user) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildProfileHeader(user),
          const SizedBox(height: 30),
          _buildSection('Account Settings', _buildAccountSettings()),
          const SizedBox(height: 20),
          _buildSection('Actions', _buildActionItems()),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(PatientModel user) {
    return Column(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundColor: Colors.grey[200],
          child: const Icon(Icons.person, size: 60, color: Colors.grey),
        ),
        const SizedBox(height: 15),
        Text(
          user.userName,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        Text(
          user.email,
          style: const TextStyle(color: Colors.grey),
        ),
      ],
    );
  }

  List<Widget> _buildAccountSettings() {
    return [
      _buildListTile(Icons.person, 'Edit Profile', () {}),
      _buildListTile(Icons.email, 'Change Email', () {}),
      _buildListTile(Icons.lock, 'Change Password', () {}),
    ];
  }

  List<Widget> _buildActionItems() {
    return [
      _buildListTile(Icons.logout, 'Log Out', () => _logout(context), 
        iconColor: Colors.orange),
      _buildListTile(Icons.delete, 'Delete Account', () {}, 
        iconColor: Colors.red),
    ];
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 15, bottom: 10),
          child: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildListTile(IconData icon, String text, VoidCallback onTap, 
      {Color? iconColor}) {
    return ListTile(
      leading: Icon(icon, color: iconColor ?? Colors.black),
      title: Text(text),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  BottomNavigationBar _buildBottomNavBar() {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: _onNavTapped,
      selectedItemColor: Colors.black,
      unselectedItemColor: Colors.black45,
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.emoji_emotions), label: 'Mood'),
        BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Therapists'),
        BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Journal'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
      ],
    );
  }
}