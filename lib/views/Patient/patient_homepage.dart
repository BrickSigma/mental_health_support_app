import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mental_health_support_app/models/user_model.dart';

class PatientHomePage extends StatefulWidget {
  const PatientHomePage({Key? key}) : super(key: key);

  @override
  State<PatientHomePage> createState() => _PatientHomePageState();
}

class _PatientHomePageState extends State<PatientHomePage> with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;

  void _onNavTapped(int index) {
    if (index == 0) {
      // Already on home
    } else if (index == 1) {
      Navigator.pushNamed(context, '/find_therapist');
    } else if (index == 2) {
      Navigator.pushNamed(context, '/profile');
    }
    setState(() {
      _selectedIndex = index;
    });
  }

  String _dailyMessage(String? username) {
    final currentTime = DateTime.now();
    if (currentTime.hour < 12) {
      return "Good morning, ${username ?? ""}";
    } else if (currentTime.hour < 18) {
      return "Good afternoon, ${username ?? ""}";
    } else {
      return "Good evening, ${username ?? ""}";
    }
  }

  @override
  Widget build(BuildContext context) {
    final orange = Colors.orange[600]!;
    final softShade = Colors.orange[50]!; // Use a soft color rather than orange for the card bottom

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        title: const Text('HOME',
            style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 22)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none,
                color: Colors.black, size: 28),
            onPressed: () => Navigator.pushNamed(context, '/Notifications'),
            tooltip: 'Notifications',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Greeting under HOME
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child : Consumer<UserModel>(
                builder: (context, user, child) => Text(
                  _dailyMessage(user.userName),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                  ),
                ) ,)
               
              ),
            const SizedBox(height: 20),

            //cards
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _AnimatedCard(
                        onTap: () => Navigator.pushNamed(context, '/mood_tracking'),
                        imageUrl: 'https://images.unsplash.com/photo-1649972904349-6e44c42644a7?auto=format&fit=crop&w=600&q=80',
                        title: "MOOD TRACKING",
                        subtitle: "Track your moods daily",
                        colorTop: orange,
                        colorBottom: softShade,
                      ),
                      const SizedBox(height: 32),
                      _AnimatedCard(
                        onTap: () => Navigator.pushNamed(context, '/journal'),
                        imageUrl: 'https://images.unsplash.com/photo-1518495973542-4542c06a5843?auto=format&fit=crop&w=600&q=80',
                        title: "JOURNALING",
                        subtitle: "Journal your daily experiences",
                        colorTop: Colors.deepPurple[400]!,
                        colorBottom: Colors.deepPurple[50]!,
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
        onTap: _onNavTapped,
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

// Custom animated card widget with image and text
class _AnimatedCard extends StatefulWidget {
  final void Function() onTap;
  final String imageUrl;
  final String title;
  final String subtitle;
  final Color colorTop;
  final Color colorBottom;

  const _AnimatedCard({
    required this.onTap,
    required this.imageUrl,
    required this.title,
    required this.subtitle,
    required this.colorTop,
    required this.colorBottom,
    Key? key,
  }) : super(key: key);

  @override
  State<_AnimatedCard> createState() => _AnimatedCardState();
}

class _AnimatedCardState extends State<_AnimatedCard> with SingleTickerProviderStateMixin {
  double _scale = 1.0;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      lowerBound: 0.97,
      upperBound: 1.0,
      duration: const Duration(milliseconds: 120),
      value: 1.0,
    );
    _controller.addListener(() {
      setState(() {
        _scale = _controller.value;
      });
    });
  }

  void _onTapDown(TapDownDetails details) {
    _controller.reverse();
  }

  void _onTapUp(TapUpDetails details) {
    _controller.forward();
  }

  void _onTapCancel() {
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: Transform.scale(
        scale: _scale,
        child: SizedBox(
          width: 360, // Larger card width
          height: 240, // Larger card height
          child: Card(
            elevation: 12,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
            margin: EdgeInsets.zero,
            child: Column(
              children: [
                // Top 3/4 - image
                Expanded(
                  flex: 3,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(28),
                      topRight: Radius.circular(28),
                    ),
                    child: Container(
                      width: double.infinity,
                      color: widget.colorTop,
                      child: Image.network(
                        widget.imageUrl,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        loadingBuilder: (ctx, child, progress) {
                          if (progress == null) return child;
                          return Center(child: CircularProgressIndicator(value: progress.expectedTotalBytes != null
                            ? progress.cumulativeBytesLoaded / (progress.expectedTotalBytes ?? 1)
                            : null));
                        },
                        errorBuilder: (context, error, stackTrace) => Center(child: Icon(Icons.broken_image, size: 64, color: Colors.grey[300])),
                      ),
                    ),
                  ),
                ),
                // Bottom 1/4 - text
                Expanded(
                  flex: 1,
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: widget.colorBottom,
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(28),
                        bottomRight: Radius.circular(28),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          widget.title,
                          style: const TextStyle(
                            color: Colors.black87,
                            fontWeight: FontWeight.bold,
                            fontSize: 21,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.subtitle,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.black54,
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}