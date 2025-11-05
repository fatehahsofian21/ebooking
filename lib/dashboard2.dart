import 'package:flutter/material.dart';
import 'package:ibooking/Vbooking.dart'; // Assuming these pages are defined elsewhere
import 'package:ibooking/MyBooking.dart'; // Import your MyBooking.dart
import 'package:ibooking/myBooking2.dart'; // Import the file containing MyBooking2Page

// --- COLORS UPDATED TO FOLLOW GUIDELINES ---
const Color kPrimaryBlue = Color(0xFF007DC5); // The official primary blue from your guideline
const Color kAccentColor = Color(0xFF8DC63E); // The official accent green

class Dashboard2Screen extends StatefulWidget {
  const Dashboard2Screen({super.key});

  @override
  _Dashboard2ScreenState createState() => _Dashboard2ScreenState();
}

class _Dashboard2ScreenState extends State<Dashboard2Screen> {
  int _selectedIndex = 0;

  // Function to handle the photo button click and show the image
  void _showImage(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Image.asset('assets/vehicle1.jpg'), // Same image used for all vehicles
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  // Bottom navigation bar handling
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // Redirect based on selected tab
    if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const VBookingPage()), // Redirect to VBookingPage
      );
    } else if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const MyBooking2Page()), // Redirect to MyBooking2Page
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // CHANGED: Using the guideline color
        backgroundColor: kPrimaryBlue,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () {
            Navigator.pop(context); // Navigate back to the previous screen
          },
        ),
        title: const Text("Vehicle List", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: ListView.builder(
        itemCount: 5, // Example for 5 vehicles
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.all(8.0),
            elevation: 5,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Displaying only the number plate and model name
                            Text('Plate Number: ABC${1000 + index}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            const SizedBox(height: 4),
                            Text('Car Model: Toyota Vellfire'),
                          ],
                        ),
                      ),
                      // Place the photo icon at the right of the "Show More Details"
                      IconButton(
                        // CHANGED: Using the guideline color for the icon
                        icon: const Icon(Icons.image, color: kPrimaryBlue), // Image icon
                        onPressed: () => _showImage(context), // Show image popup on button click
                      ),
                    ],
                  ),
                  // Show More / Show Less functionality with text on the arrow
                  ExpansionTile(
                    title: const Text("Show More Details"),
                    trailing: const Icon(Icons.keyboard_arrow_down), // Arrow icon for show more
                    children: <Widget>[
                      ListTile(
                        title: const Text("Color: Black\nCapacity: 5 seats\nDate of Service: 10/01/2025"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.grid_view_outlined),
            label: 'Summary',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: 'Booked Vehicle',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_outlined),
            label: 'My Booking',
          ),
        ],
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        // CHANGED: Using the guideline color
        backgroundColor: kPrimaryBlue,
      ),
    );
  }
}