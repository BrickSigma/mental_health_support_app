import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class PatientsNotification extends StatefulWidget {
  const PatientsNotification({super.key});

  @override
  State<PatientsNotification> createState() => _PatientsNotificationState();
}

class _PatientsNotificationState extends State<PatientsNotification> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DateFormat _dateFormat = DateFormat('MMM d, y • h:mm a');

  Future<void> _markAsRead(String notificationId) async {
    final patientId = _auth.currentUser?.uid;
    if (patientId == null) return;

    await _firestore
        .collection('patients')
        .doc(patientId)
        .collection('notifications')
        .doc(notificationId)
        .update({'read': true});
  }

  Future<void> _markAllAsRead() async {
    final patientId = _auth.currentUser?.uid;
    if (patientId == null) return;

    final querySnapshot =
        await _firestore
            .collection('patients')
            .doc(patientId)
            .collection('notifications')
            .where('read', isEqualTo: false)
            .get();

    final batch = _firestore.batch();
    for (final doc in querySnapshot.docs) {
      batch.update(doc.reference, {'read': true});
    }
    await batch.commit();
  }

  Widget _buildNotificationIcon(String type) {
    switch (type) {
      case 'therapist_response':
        return const Icon(Icons.person, color: Colors.blue);
      case 'appointment':
        return const Icon(Icons.calendar_today, color: Colors.green);
      case 'message':
        return const Icon(Icons.message, color: Colors.purple);
      default:
        return const Icon(Icons.notifications, color: Colors.orange);
    }
  }

  void _handleNotificationTap(
    DocumentSnapshot notification,
    BuildContext context,
  ) {
    final data = notification.data() as Map<String, dynamic>;
    _markAsRead(notification.id);

    switch (data['type']) {
      case 'therapist_response':
        if (data['status'] == 'accepted') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Therapist has accepted your request'),
              backgroundColor: Colors.green,
            ),
          );
        }
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final patientId = _auth.currentUser?.uid;
    if (patientId == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              const Text('Not authenticated', style: TextStyle(fontSize: 18)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => _auth.signOut(),
                child: const Text('Sign out'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all),
            tooltip: 'Mark all as read',
            onPressed: _markAllAsRead,
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            _firestore
                .collection('patients')
                .doc(patientId)
                .collection('notifications')
                .orderBy('timestamp', descending: true)
                .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.warning_amber,
                    size: 48,
                    color: Colors.orange,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Error loading notifications',
                    style: TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      snapshot.error.toString(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => setState(() {}),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final notifications = snapshot.data?.docs ?? [];

          if (notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_off,
                    size: 64,
                    color: Theme.of(context).colorScheme.primary.withAlpha(75),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No notifications yet',
                    style: TextStyle(
                      fontSize: 18,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withAlpha(155),
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.only(top: 8),
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification = notifications[index];
              final data = notification.data() as Map<String, dynamic>;
              final timestamp = data['timestamp']?.toDate();
              final isRead = data['read'] ?? false;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(
                    color: Theme.of(context).dividerColor.withAlpha(25),
                    width: 1,
                  ),
                ),
                color:
                    isRead
                        ? null
                        : Theme.of(context).colorScheme.primary.withAlpha(15),
                child: ListTile(
                  leading: _buildNotificationIcon(data['type']),
                  title: Text(
                    data['title'] ?? 'Notification',
                    style: TextStyle(
                      fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(data['message'] ?? ''),
                      if (timestamp != null)
                        Text(
                          _dateFormat.format(timestamp),
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).hintColor,
                          ),
                        ),
                    ],
                  ),
                  trailing:
                      !isRead
                          ? const Icon(
                            Icons.circle,
                            size: 10,
                            color: Colors.blue,
                          )
                          : null,
                  onTap: () => _handleNotificationTap(notification, context),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
