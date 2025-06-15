import 'package:flutter/material.dart';

class PatientHomePage extends StatefulWidget {
  const PatientHomePage({super.key});
  @override
  State<PatientHomePage> createState() => _PatientHomePageState();
}

class _PatientHomePageState extends State<PatientHomePage> {
  int _selectedIndex = 0;
  void _whenNavisTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Defining the color variables
    final orange = Colors.orange[600]!;
    final lightorange = Colors.orange[100]!;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
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
            icon: const Icon(
              Icons.notifications_none,
              color: Colors.black,
              size: 28,
            ),
            onPressed: () => Navigator.pushNamed(context, '/Notifications'),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(24, 36, 24, 0),
        child: Column(
      children: [
        //Mood Tracking
        GestureDetector(
          onTap: () {
            Navigator.pushNamed(context, '/mood_tracking');
          },
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            elevation: 5,
            color: orange,
            child: SizedBox(
              width: double.infinity,
              height: 120,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'MOOD TRACKING',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    ),
                    ),
                    const SizedBox(height: 8),
                    const Padding(padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text('Track your moods daily', textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 15 ),
                      ),)
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 32),
        // Journaling Card
        GestureDetector(
          onTap: () {
            Navigator.pushNamed(context, '/journal');
          },
          child: Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            elevation: 5,
            color: orange,
            child: SizedBox(
              width: double.infinity,
              height: 120,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    child: Column(
                      children: [
                        Container(
                          // For the color split like in the mockup, use a Stack or blend
                          padding: const EdgeInsets.symmetric(vertical: 0),
                          child: Column(
                            children: [
                              const Text("JOURNALING",
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18)),
                              const SizedBox(height: 8),
                              Container(
                                color: lightorange,
                                width: double.infinity,
                                padding: const EdgeInsets.only(bottom: 16, top: 8),
                                child: const Text(
                                  "Journal your daily experiences",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.black87,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    ),
  ),
  bottomNavigationBar: BottomNavigationBar(
    currentIndex: _selectedIndex,
    onTap: _whenNavisTapped,
    selectedItemColor: Colors.black,
    unselectedItemColor: Colors.black45,
    showSelectedLabels: false,
    showUnselectedLabels: false,
    items: const [
      BottomNavigationBarItem(
        icon: Icon(Icons.home, size: 30),
        label: 'Home',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.search, size: 30),
        label: 'Search',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.person, size: 30),
        label: 'Profile',
      ),
    ],
    backgroundColor: Colors.white,
    elevation: 10,
    type: BottomNavigationBarType.fixed,
  ),
);
}
}
