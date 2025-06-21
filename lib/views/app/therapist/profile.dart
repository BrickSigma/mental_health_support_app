import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mental_health_support_app/models/login_provider.dart';
import 'package:mental_health_support_app/models/therapist_model.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  void deleteAccount(
    BuildContext context,
    TherapistModel therapistModel,
    LoginProvider loginProvider,
  ) async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              "Confirm account deletion.",
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
            content: Text("Are you sure you want to delete your account?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text("Cancel"),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text("Confirm"),
              ),
            ],
          ),
    );

    if (confirm == true) {
      try {
        await loginProvider.getAuthState()?.delete();
      } on FirebaseAuthException {
        if (context.mounted) {
          int? status = await showDialog<int>(
            context: context,
            builder:
                (context) => AlertDialog(
                  title: Text(
                    "Login Again",
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                  content: Text(
                    "You need to logout and login again to delete your account.",
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, 1),
                      child: Text("Cancel"),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, 0),
                      child: Text("Logout"),
                    ),
                  ],
                ),
          );

          if (status == 0) {
            loginProvider.logout();
            if (context.mounted) Navigator.pop(context);
            return;
          }
        }
      }

      // Only delete the use account data if the account was succesfully deleted.
      therapistModel.deleteAccount();
      loginProvider.logout();
    }
  }

  @override
  Widget build(BuildContext context) {
    LoginProvider loginProvider = Provider.of(context, listen: false);

    return Scaffold(
      appBar: AppBar(title: const Text('Profile'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Consumer<TherapistModel>(
          builder: (context, user, child) {
            return Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  child: const Icon(Icons.person, size: 60),
                ),
                const SizedBox(height: 15),
                Text(
                  user.userName,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(user.email),
                const SizedBox(height: 30),
                ProfileSection(
                  title: 'Account Actions',
                  children: [
                    ProfileSectionTile(
                      icon: Icon(Icons.person),
                      title: 'Edit Username',
                      onTap:
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditUsernamePage(user),
                            ),
                          ),
                    ),
                    ProfileSectionTile(
                      icon: Icon(Icons.logout, color: Colors.orange),
                      title: 'Log Out',
                      onTap: () => loginProvider.logout(),
                    ),
                    ProfileSectionTile(
                      icon: Icon(Icons.delete, color: Colors.red),
                      title: 'Delete Account',
                      onTap: () => deleteAccount(context, user, loginProvider),
                    ),
                  ],
                ),
              ],
            );
          },
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

class EditUsernamePage extends StatefulWidget {
  const EditUsernamePage(this.therapistModel, {super.key});

  final TherapistModel therapistModel;

  @override
  State<EditUsernamePage> createState() => _EditUsernamePageState();
}

class _EditUsernamePageState extends State<EditUsernamePage> {
  final TextEditingController _usernameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  void _onSave(BuildContext context) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    await widget.therapistModel.updateUserData(_usernameController.text);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Username updated!", textAlign: TextAlign.center),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    _usernameController.text = widget.therapistModel.userName;

    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Username"),
        centerTitle: true,
        actions: [
          TextButton(onPressed: () => _onSave(context), child: Text("Save")),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Form(
          key: _formKey,
          child: TextFormField(
            controller: _usernameController,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              hintText: "Username",
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Please enter a username";
              }
              return null;
            },
          ),
        ),
      ),
    );
  }
}
