import 'package:flutter/material.dart';
import 'chat/chatScreen.dart';
import 'ritual/routinelistscreen.dart'; // Import your Routinelistscreen
import 'journeys/journeyscreen.dart'; // Import your Journeyscreen
import 'discover/discoverscreen.dart'; // Import your Discoverscreen

class MainScreen extends StatefulWidget {
  final String email;

  const MainScreen({super.key, required this.email});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    // Initialize the pages
    _pages = [
      ChatScreen(email: widget.email),
      Routinelistscreen(email: widget.email),
      Journeyscreen(email: widget.email),
      Discoverscreen(email: widget.email),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex], // Display the selected screen
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (int index) {
          setState(() {
            _currentIndex = index; // Update the selected tab
          });
        },
        backgroundColor: _currentIndex == 0
            ? Colors.transparent
            : Colors.white, // Set background color
        selectedItemColor: _currentIndex == 0
            ? Colors.black
            : Colors.blue, // Active icon/text color
        unselectedItemColor: _currentIndex == 0
            ? Colors.black54
            : Colors.grey, // Inactive icon/text color
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.schedule),
            label: 'Routine',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.directions_walk),
            label: 'Journey',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Discover',
          ),
        ],
      ),
    );
  }
}
