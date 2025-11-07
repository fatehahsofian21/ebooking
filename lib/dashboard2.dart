import 'package:flutter/material.dart';
import 'package:ibooking/Vbooking.dart';
import 'package:ibooking/myBooking2.dart';

// --- COLORS UPDATED TO FOLLOW GUIDELINES ---
const Color kPrimaryBlue = Color(0xFF007DC5);
const Color kAccentColor = Color(0xFF8DC63E);

class Dashboard2Screen extends StatefulWidget {
  const Dashboard2Screen({super.key});

  @override
  _Dashboard2ScreenState createState() => _Dashboard2ScreenState();
}

class _Dashboard2ScreenState extends State<Dashboard2Screen> {
  int _selectedIndex = 0;

  // --- Vehicle Data with specific asset names and details ---
  final List<Map<String, String>> vehicleData = [
    {
      'name': 'Toyota Vellfire',
      'image': 'assets/car1.jpg',
      'color': 'Metallic Black',
      'pax': '7 Seater',
    },
    {
      'name': 'Perodua Bezza',
      'image': 'assets/car2.jpg',
      'color': 'Glittering Brown',
      'pax': '5 Seater',
    },
    {
      'name': 'Toyota Hiace',
      'image': 'assets/van1.jpg',
      'color': 'Solid White',
      'pax': '10 Seater',
    },
    {
      'name': 'Nissan Urvan',
      'image': 'assets/van2.jpg',
      'color': 'Diamond White',
      'pax': '14 Seater',
    },
    {
      'name': 'Scania Touring',
      'image': 'assets/bus.jpg',
      'color': 'Pearl White',
      'pax': '44 Seater',
    },
  ];

  // Function to show the vehicle details pop-up
  void _showVehicleDetailsDialog(BuildContext context, Map<String, String> vehicle) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
          contentPadding: EdgeInsets.zero,
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20.0),
                    topRight: Radius.circular(20.0),
                  ),
                  child: Image.asset(
                    vehicle['image']!,
                    height: 180,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const SizedBox(
                        height: 180,
                        child: Icon(Icons.directions_car_filled, size: 80, color: Colors.grey),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        vehicle['name']!,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildDetailRow(Icons.directions_car, 'Model', vehicle['name']!),
                      const SizedBox(height: 10),
                      _buildDetailRow(Icons.color_lens, 'Color', vehicle['color']!),
                      const SizedBox(height: 10),
                      _buildDetailRow(Icons.people, 'Capacity', vehicle['pax']!),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close', style: TextStyle(color: kPrimaryBlue, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  // Helper widget for a single row of detail in the dialog
  Widget _buildDetailRow(IconData icon, String title, String value) {
    return Row(
      children: [
        Icon(icon, color: kPrimaryBlue, size: 20),
        const SizedBox(width: 12),
        Text(
          '$title: ',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[700]),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(color: Colors.grey[700]),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  // Bottom navigation bar handling
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const VBookingPage()),
      );
    } else if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const MyBooking2Page()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kPrimaryBlue,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text("Vehicle List", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: vehicleData.length,
        // --- MODIFIED: GridDelegate settings for a 2-column layout ---
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 1, // Two cards per row
          crossAxisSpacing: 16.0, // Horizontal space between cards
          mainAxisSpacing: 16.0, // Vertical space between cards
          childAspectRatio: 2.0, // Makes the cards square
        ),
        itemBuilder: (context, index) {
          final vehicle = vehicleData[index];
          return GestureDetector(
            onTap: () {
              _showVehicleDetailsDialog(context, vehicle);
            },
            child: Card(
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
              elevation: 5,
              child: Image.asset(
                vehicle['image']!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Center(
                    child: Icon(Icons.directions_car_filled, size: 60, color: Colors.grey),
                  );
                },
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
        backgroundColor: kPrimaryBlue,
      ),
    );
  }
}