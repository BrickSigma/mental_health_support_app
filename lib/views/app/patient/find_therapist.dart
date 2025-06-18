import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mental_health_support_app/models/therapist_model.dart';

class FindTherapist extends StatefulWidget {
  const FindTherapist({super.key});
  @override
  State<FindTherapist> createState() => _FindTherapistState();
}

class _FindTherapistState extends State<FindTherapist> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _searchQuery = '';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
    )
  }
}
