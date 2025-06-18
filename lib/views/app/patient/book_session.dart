import 'package:flutter/material.dart';

class BookSession extends StatefulWidget {
  const BookSession({super.key});
  @override
  State<BookSession> createState() => _BookSessionState();
}

class _BookSessionState extends State<BookSession> {
  @override
  Widget build(Object context) {
    return Scaffold(
      appBar: AppBar(title: Text("Book a Session")),
      body: Placeholder(),
    );
  }
}
