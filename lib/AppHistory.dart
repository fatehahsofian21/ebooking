// AppHistory.dart

import 'package:flutter/material.dart';
import 'package:ibooking/AppDash.dart'; // Assuming AppDash is the home page
import 'package:ibooking/approval.dart'; // Assuming approval is the list page

// --- Brand Guideline Colors ---
const Color kPrimaryColor = Color(0xFF007DC5);
const Color kBackgroundColor = Color(0xFFF5F5F5);

class AppHistoryPage extends StatefulWidget {
  const AppHistoryPage({super.key});

  @override
  State<AppHistoryPage> createState() => _AppHistoryPageState();
}

class _AppHistoryPageState extends State<AppHistoryPage> {
  int _currentIndex = 2; // This page is the 3rd item (index 2)

  void _onTabTapped(int index) {
    if (index == _currentIndex) return; // Do nothing if tapping the current tab

    setState(() {
      _currentIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ApprovalPage()),
        );
        break;
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AppDash()),
        );
        break;
      case 2:
        // Already on this page
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        title: const Text('Booking History'),
        backgroundColor: kPrimaryColor,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false, // Hide back button
      ),
      body: const Center(
        child: Text(
          'History Page - Content Goes Here',
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        backgroundColor: Colors.white,
        selectedItemColor: kPrimaryColor,
        unselectedItemColor: Colors.grey[600],
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt_rounded),
            label: 'List Booking',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history_rounded),
            label: 'History',
          ),
        ],
      ),
    );
  }
}