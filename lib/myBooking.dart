import 'package:flutter/material.dart';
import 'package:ibooking/dashboard.dart';

// Use the same core color theme as the calendar page
const Color kPrimaryColorStart = Color.fromARGB(255, 24, 42, 94); // dark blue
const Color kPrimaryColorEnd = Color.fromARGB(255, 24, 42, 94);   // keep same for a solid look
const Color kBackgroundColor = Color(0xFFF2F3F7);

class MyBookingPage extends StatefulWidget {
  const MyBookingPage({super.key});

  @override
  State<MyBookingPage> createState() => _MyBookingPageState();
}

class _MyBookingPageState extends State<MyBookingPage> {
  // Dummy booking history data
  final List<Map<String, String>> _bookings = [
    {
      'id': '1',
      'vehicle': 'Car',
      'status': 'PENDING',
      'pickupDate': '2023-10-01 10:00',
      'returnDate': '2023-10-01 14:00',
    },
    {
      'id': '2',
      'vehicle': 'Van',
      'status': 'APPROVED',
      'pickupDate': '2023-10-10 08:00',
      'returnDate': '2023-10-10 17:00',
    },
    {
      'id': '3',
      'vehicle': 'MPV',
      'status': 'COMPLETED',
      'pickupDate': '2023-09-15 09:00',
      'returnDate': '2023-09-15 15:00',
    },
    {
      'id': '4',
      'vehicle': 'Bus',
      'status': 'CANCELLED',
      'pickupDate': '2023-10-20 07:30',
      'returnDate': '2023-10-20 12:30',
    },
  ];

  // For displaying the compact pop-up details
  void _showBookingDetails(Map<String, String> booking) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Booking ID: ${booking['id']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8.0),
              Text('Vehicle: ${booking['vehicle']}'),
              Text('Pickup Date: ${booking['pickupDate']}'),
              Text('Return Date: ${booking['returnDate']}'),
              const SizedBox(height: 8.0),
              Text('Status: ${booking['status']}'),
              if (booking['status'] == 'COMPLETED') ...[
                const SizedBox(height: 12),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: kPrimaryColorEnd),
                  onPressed: () {
                    // Navigate to feedback page (implement as needed)
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Navigating to feedback page')));
                    Navigator.of(ctx).pop();
                  },
                  child: const Text('Upload Feedback/Complaint', style: TextStyle(color: Colors.white)),
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }

  // Function to navigate to the DashboardScreen
  void _navigateToDashboard() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const DashboardScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kPrimaryColorEnd,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'My Booking History',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          // Home Icon in AppBar
          IconButton(
            icon: const Icon(Icons.home, color: Colors.white),
            onPressed: _navigateToDashboard, // Navigate to Dashboard
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Display each booking in a card with minimal information
              ..._bookings.map((booking) {
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: InkWell(
                    onTap: () => _showBookingDetails(booking),
                    child: Container(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Booking ID: ${booking['id']}',
                              style: const TextStyle(
                                  fontSize: 16.0, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8.0),
                          Text('Date: ${booking['pickupDate']} - ${booking['returnDate']}'),
                          const SizedBox(height: 8.0),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16.0, vertical: 8.0),
                            decoration: BoxDecoration(
                              color: _getStatusColor(booking['status']!),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            child: Text(
                              booking['status']!,
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'PENDING':
        return const Color(0xFFE1B12C); // mustard yellow
      case 'APPROVED':
        return const Color(0xFF2ECC71); // green
      case 'CANCELLED':
        return const Color(0xFFE74C3C); // red
      case 'COMPLETED':
        return const Color(0xFF8E44AD); // purple
      default:
        return Colors.grey;
    }
  }
}
