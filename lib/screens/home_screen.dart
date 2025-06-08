import 'package:flutter/material.dart';
import 'donations_screen.dart';
import 'coverages_screen.dart';
import 'user_profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0; // DonationsScreen is the default screen

  // Method to handle navigation
  void _navigateToIndex(int index) {
    if (index < _screens().length) { // Check bounds against the dynamic list
      setState(() {
        _currentIndex = index;
      });
    }
  }

  // Make _screens a getter
  List<Widget> _screens() => [
    const DonationsScreen(),
    const CoveragesScreen(),
    const UserProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    // Access _screens via the getter
    final currentScreens = _screens();

    return Scaffold(
      body: SafeArea(
        child: currentScreens[_currentIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          _navigateToIndex(index);
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.red, // Change selected item's icon color to red
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.bloodtype),
            label: 'Donations',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_hospital),
            label: 'Coverages',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
