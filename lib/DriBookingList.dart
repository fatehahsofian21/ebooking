// DriBookingList.dart

import 'package:flutter/material.dart';
import 'package:ibooking/AppBookingDetail.dart'; // To navigate to trip details (reusing this for simplicity)
import 'package:ibooking/DriDash.dart'; // For Home navigation (assuming this is the driver's home)
import 'package:url_launcher/url_launcher.dart'; // To open phone dialer

// --- Brand Guideline Colors (from DriDash.dart / approval.dart) ---
const Color kPrimaryColor = Color(0xFF007DC5);
const Color kBackgroundColor = Color(0xFFF5F5F5);
const Color kAssignedColor = Color(0xFF007DC5); // Using Primary Color for Assigned status
const Color kCompletedColor = Color(0xFF28a745);

// --- DUMMY DATA: Driver's Assigned Trips ---
final List<Map<String, dynamic>> driverTrips = [
  {
    'id': 1, 'bookingId': 'T1001', 'requester': 'Siti Aisyah', 'department': 'Human Resources', 
    'model': 'Honda HRV', 'plate': 'HRV 2023', 'pickupDate': '28 Oct 2025 (Tue) • 02:00 PM', 
    'returnDate': '28 Oct 2025 (Tue) • 04:00 PM', 'destination': 'Putrajaya Convention Centre', 
    'pickupLocation': 'PERKESO HQ, Jalan Ampang', 'returnLocation': 'PERKESO HQ, Jalan Ampang',
    'requesterPhone': '0123456789', // Added for call function
    'purpose': 'Official Meeting', 'status': 'Assigned', 
  },
  {
    'id': 2, 'bookingId': 'T1002', 'requester': 'Razak Bin Ali', 'department': 'Administration', 
    'model': 'Scania Touring Bus', 'plate': 'BUS 1122', 'pickupDate': '25 Oct 2025 (Sat) • 08:00 AM', 
    'returnDate': '25 Oct 2025 (Sat) • 06:00 PM', 'destination': 'Melaka Heritage Trip', 
    'pickupLocation': 'Main Depot, Admin Building', 'returnLocation': 'Main Depot, Admin Building',
    'requesterPhone': '0198765432', // Added for call function
    'purpose': 'Company Outing', 'status': 'Assigned', 
  },
  {
    'id': 3, 'bookingId': 'T1003', 'requester': 'Lina Teoh', 'department': 'Marketing', 
    'model': 'Proton X70', 'plate': 'X70 8899', 'pickupDate': '29 Oct 2025 (Wed) • 09:00 AM', 
    'returnDate': '29 Oct 2025 (Wed) • 01:00 PM', 'destination': 'Petaling Jaya Client Office', 
    'pickupLocation': 'PERKESO HQ, Jalan Ampang', 'returnLocation': 'PERKESO HQ, Jalan Ampang',
    'requesterPhone': '01155554444', // Added for call function
    'purpose': 'Client Visit', 'status': 'Completed', 
  },
  {
    'id': 4, 'bookingId': 'T1004', 'requester': 'Ahmad Fauzi', 'department': 'IT Support', 
    'model': 'Perodua Myvi', 'plate': 'MYV 5555', 'pickupDate': '10 Nov 2025 (Mon) • 11:00 AM', 
    'returnDate': '10 Nov 2025 (Mon) • 01:00 PM', 'destination': 'Local Vendor Office', 
    'pickupLocation': 'IT Department Hub', 'returnLocation': 'IT Department Hub',
    'requesterPhone': '01677778888', // Added for call function
    'purpose': 'Equipment Pickup', 'status': 'Assigned', 
  },
];

// Utility class for common driver actions (like calling)
class DriverActions {
  // Mock Admin Phone Number (In a real app, this would come from a backend config)
  static const String adminPhoneNumber = '0322221111';

  static Future<void> callNumber(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    
    // FIX: Use named argument 'url' for canLaunchUrl and launchUrl
    if (await canLaunchUrl(launchUri)) { 
      await launchUrl(launchUri);
    } else {
      // Fallback for environments where the dialer cannot be opened (e.g., web/desktop)
      print('Could not launch $phoneNumber');
    }
  }

  static Future<void> callRequester(String phoneNumber) async {
    await callNumber(phoneNumber);
  }

  static Future<void> callAdmin() async {
    await callNumber(adminPhoneNumber);
  }
}

class DriBookingListPage extends StatefulWidget {
  const DriBookingListPage({super.key});

  @override
  State<DriBookingListPage> createState() => _DriBookingListPageState();
}

class _DriBookingListPageState extends State<DriBookingListPage> {
  int _currentIndex = 0;
  
  // Filter the list to only include 'Assigned' trips
  final List<Map<String, dynamic>> assignedTrips = driverTrips.where((trip) => trip['status'] == 'Assigned').toList();

  void _onTabTapped(int index) {
    if (index == _currentIndex) return;
    setState(() { _currentIndex = index; });

    switch (index) {
      case 1: // Home
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const DriDash()));
        break;
      case 2: // History (Placeholder for future page)
        // Placeholder action for now
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Navigate to Driver History Page (Not implemented yet)')),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Separate trips by status for stat cards
    final List<Map<String, dynamic>> todayTrips = assignedTrips.where((trip) {
      // Simple check for 'today' (MOCK: just check if it's the 28th for testing)
      return trip['pickupDate']?.contains('28 Oct 2025') == true;
    }).toList();

    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        title: const Text('My Assigned Trips'),
        backgroundColor: kPrimaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      // Use ListView instead of Column + Expanded to make everything scrollable
      body: ListView(
        physics: const BouncingScrollPhysics(), // For smoother scroll effect
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Expanded(child: _StatCard(count: todayTrips.length, label: 'Trips Today', color: kAssignedColor)),
                const SizedBox(width: 16),
                Expanded(child: _StatCard(count: assignedTrips.length, label: 'Upcoming Trips', color: Colors.orange.shade700)),
              ],
            ),
          ),
          // List of Assigned Trips
          assignedTrips.isEmpty
              ? Container(
                  padding: const EdgeInsets.all(32),
                  alignment: Alignment.center,
                  child: const Text('No assigned trips found.', style: TextStyle(color: Colors.grey, fontSize: 16)),
                )
              : ListView.builder(
                  shrinkWrap: true, // Crucial for nesting ListView inside a single scrollable parent
                  physics: const NeverScrollableScrollPhysics(), // Let the parent ListView handle scrolling
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  itemCount: assignedTrips.length,
                  itemBuilder: (context, index) {
                    final trip = assignedTrips[index];
                    return _TripAssignmentCard(trip: trip);
                  },
                ),
          const SizedBox(height: 16), // Extra spacing at the bottom
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        backgroundColor: kPrimaryColor,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.navigation_rounded), label: 'Assigned Trip'),
          BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.history_rounded), label: 'History'),
        ],
      ),
    );
  }
}

// Reusing _StatCard from the example (ApprovalPage)
class _StatCard extends StatelessWidget {
  final int count;
  final String label;
  final Color color;
  const _StatCard({required this.count, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(count.toString(), style: TextStyle(color: color, fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(color: Colors.grey[700], fontSize: 14, fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}

// Widget for displaying an individual trip assignment
class _TripAssignmentCard extends StatelessWidget {
  final Map<String, dynamic> trip;
  const _TripAssignmentCard({required this.trip});

  @override
  Widget build(BuildContext context) {
    // --- Data extraction for display ---
    final String plate = trip['plate'] ?? 'N/A';
    final String model = trip['model'] ?? 'N/A';
    final String requester = trip['requester'] ?? 'N/A';
    final String department = trip['department'] ?? 'N/A';
    final String requesterPhone = trip['requesterPhone'] ?? 'N/A';

    // Splitting the date/time string "Date • Time"
    final pickupDateParts = trip['pickupDate']?.split('•');
    final pickupDate = pickupDateParts != null && pickupDateParts.isNotEmpty ? pickupDateParts[0].trim() : 'N/A';
    
    // Logic for time range extraction
    String timeRange = 'N/A';
    if (trip['pickupDate'] != null && trip['returnDate'] != null) {
      final pickupTime = pickupDateParts != null && pickupDateParts.length > 1 ? pickupDateParts[1].trim() : 'N/A';
      final returnTimeParts = trip['returnDate'].split('•');
      final returnTime = returnTimeParts.length > 1 ? returnTimeParts[1].trim() : 'N/A';
      timeRange = '$pickupTime - $returnTime';
    }
    
    final String destination = trip['destination'] ?? 'N/A';
    final String status = trip['status'] ?? 'N/A';
    final Color statusColor = status == 'Assigned' ? kAssignedColor : kCompletedColor;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.08), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Vehicle Info
                      Text('$model ($plate)', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: kPrimaryColor)),
                      const SizedBox(height: 6),
                      // Requester Info
                      Text(requester, style: const TextStyle(fontWeight: FontWeight.w600)),
                      Text(department, style: const TextStyle(color: Colors.black54, fontSize: 13)),
                      const SizedBox(height: 8),
                      // Date and Time
                      Row(
                        children: [
                          const Icon(Icons.calendar_today, size: 14, color: Colors.black54),
                          const SizedBox(width: 6),
                          Text(pickupDate, style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w500)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.access_time_filled, size: 14, color: Colors.black54),
                          const SizedBox(width: 6),
                          Text(timeRange.replaceAll(':', ''), style: const TextStyle(color: Colors.black87)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      // Destination
                       Row(
                        children: [
                          const Icon(Icons.location_on, size: 14, color: Colors.black54),
                          const SizedBox(width: 6),
                          Expanded(child: Text('To: $destination', style: const TextStyle(color: Colors.black87), overflow: TextOverflow.ellipsis)),
                        ],
                      ),
                    ],
                  ),
                ),
                // Status Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: statusColor, width: 1.0),
                  ),
                  child: Text(
                    status.toUpperCase(),
                    style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.info_outline),
                    label: const Text('View Details', style: TextStyle(fontSize: 12)),
                    onPressed: () {
                      // Navigate to the detail page, passing the trip data
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AppBookingDetailPage(
                            bookingDetails: trip, 
                            userRole: 'driver', // Pass the driver role for specific logic on details page
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // NEW: Call Requester Button
                if (status == 'Assigned' && requesterPhone != 'N/A')
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.phone, size: 20),
                      label: const Text('Call Requester', style: TextStyle(fontSize: 12)),
                      onPressed: () => DriverActions.callRequester(requesterPhone),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade600,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ),
                if (status == 'Assigned' && requesterPhone != 'N/A')
                  const SizedBox(width: 8),
                // Call Admin Button (Always available for support)
                SizedBox(
                  width: 50,
                  child: ElevatedButton(
                    onPressed: () => DriverActions.callAdmin(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade600,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Icon(Icons.support_agent, size: 20),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}