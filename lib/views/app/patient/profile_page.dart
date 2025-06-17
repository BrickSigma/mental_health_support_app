import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mental_health_support_app/models/login_provider.dart';
import 'package:mental_health_support_app/models/patient_model.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<PatientModel>(context, listen: false);
    LoginProvider loginProvider = Provider.of(context, listen: false);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Profile', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.grey[200],
                  child: const Icon(Icons.person, size: 60, color: Colors.grey),
                ),
                const SizedBox(height: 15),
                Text(
                  user.userName,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(user.email, style: const TextStyle(color: Colors.grey)),
              ],
            ),
            const SizedBox(height: 30),
            ProfileSection(
              title: 'Account Settings',
              children: [
                ProfileSectionTile(
                  icon: Icon(Icons.person),
                  title: 'Edit Profile',
                ),
                ProfileSectionTile(
                  icon: Icon(Icons.email),
                  title: 'Change Email',
                ),
                ProfileSectionTile(
                  icon: Icon(Icons.lock),
                  title: 'Change Password',
                ),
              ],
            ),
            const SizedBox(height: 20),
            ProfileSection(
              title: 'Actions',
              children: [
                ProfileSectionTile(
                  icon: Icon(Icons.logout, color: Colors.orange),
                  title: 'Log Out',
                  onTap: () => loginProvider.logout(),
                ),
                ProfileSectionTile(
                  icon: Icon(Icons.delete, color: Colors.red),
                  title: 'Delete Account',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ProfileSection extends StatelessWidget {
  const ProfileSection({
    super.key,
    required this.title,
    required this.children,
  });

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
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
}

class ProfileSectionTile extends StatelessWidget {
  const ProfileSectionTile({
    super.key,
    required this.title,
    required this.icon,
    this.onTap,
  });

  final Icon icon;
  final String title;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: icon,
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
