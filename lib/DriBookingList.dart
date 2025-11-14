import 'package:flutter/material.dart';
import 'package:ibooking/DriBookingDetail.dart'; // [FIX] Navigate to the driver-specific detail page
import 'package:ibooking/DriDash.dart'; // For Home navigation (assuming this is the driver's home)
import 'package:url_launcher/url_launcher.dart'; // To open phone dialer
import 'package:ibooking/DriHistory.dart'; // FIX: Import the Driver History Page

// --- Brand Guideline Colors (from DriDash.dart / approval.dart) ---
const Color kPrimaryColor = Color(0xFF007DC5);
const Color kBackgroundColor = Color(0xFFF5F5F5); 
const Color kAssignedColor = Color(0xFF007DC5); // Using Primary Color for Assigned status
const Color kCompletedColor = Color(0xFF28a745);

// --- DUMMY DATA: Driver's Assigned Trips (Used for this page) ---
final List<Map<String, dynamic>> driverTrips = [
  {
    'id': 1, 'bookingId': 'T1001', 'requester': 'Siti Aisyah', 'department': 'Human Resources', 
    'model': 'Honda HRV', 'plate': 'HRV 2023', 'pickupDate': '28 Oct 2025 (Tue) • 02:00 PM', 
    'returnDate': '28 Oct 2025 (Tue) • 04:00 PM', 'destination': 'Putrajaya Convention Centre', 
    'pickupLocation': 'PERKESO HQ, Jalan Ampang', 'returnLocation': 'PERKESO HQ, Jalan Ampang',
    'requesterPhone': '0123456789', 
    'purpose': 'Official Meeting', 'status': 'Assigned', 
    'approvedBy': 'Encik Amir', 'approvalDateTime': '25 Oct 2025 10:30 AM', 'driverName': 'Bala'
  },
  {
    'id': 2, 'bookingId': 'T1002', 'requester': 'Razak Bin Ali', 'department': 'Administration', 
    'model': 'Scania Touring Bus', 'plate': 'BUS 1122', 'pickupDate': '25 Oct 2025 (Sat) • 08:00 AM', 
    'returnDate': '25 Oct 2025 (Sat) • 06:00 PM', 'destination': 'Melaka Heritage Trip', 
    'pickupLocation': 'Main Depot, Admin Building', 'returnLocation': 'Main Depot, Admin Building',
    'requesterPhone': '0198765432', 
    'purpose': 'Company Outing', 'status': 'Assigned', 
    'approvedBy': 'Encik Amir', 'approvalDateTime': '22 Oct 2025 04:00 PM', 'driverName': 'Bala'
  },
  {
    'id': 3, 'bookingId': 'T1003', 'requester': 'Lina Teoh', 'department': 'Marketing', 
    'model': 'Proton X70', 'plate': 'X70 8899', 'pickupDate': '29 Oct 2025 (Wed) • 09:00 AM', 
    'returnDate': '29 Oct 2025 (Wed) • 01:00 PM', 'destination': 'Petaling Jaya Client Office', 
    'pickupLocation': 'PERKESO HQ, Jalan Ampang', 'returnLocation': 'PERKESO HQ, Jalan Ampang',
    'requesterPhone': '01155554444', 
    'purpose': 'Client Visit', 'status': 'Completed', // This trip is here for testing, but won't show on Assigned List
    'approvedBy': 'Encik Razak', 'approvalDateTime': '27 Oct 2025 09:00 AM', 'driverName': 'Bala'
  },
  {
    'id': 4, 'bookingId': 'T1004', 'requester': 'Ahmad Fauzi', 'department': 'IT Support', 
    'model': 'Perodua Myvi', 'plate': 'MYV 5555', 'pickupDate': '10 Nov 2025 (Mon) • 11:00 AM', 
    'returnDate': '10 Nov 2025 (Mon) • 01:00 PM', 'destination': 'Local Vendor Office', 
    'pickupLocation': 'IT Department Hub', 'returnLocation': 'IT Department Hub',
    'requesterPhone': '01677778888', 
    'purpose': 'Equipment Pickup', 'status': 'Assigned', 
    'approvedBy': 'Encik Amir', 'approvalDateTime': '05 Nov 2025 10:00 AM', 'driverName': 'Bala'
  },
  {
    'id': 5, 'bookingId': 'T0901', 'requester': 'Dr. Chong', 'department': 'R&D', 
    'model': 'Toyota Camry', 'plate': 'CAM 7777', 'pickupDate': '15 Oct 2025 (Wed) • 08:30 AM', 
    'returnDate': '15 Oct 2025 (Wed) • 12:30 PM', 'destination': 'University Lab', 
    'pickupLocation': 'PERKESO HQ, Jalan Ampang', 'returnLocation': 'PERKESO HQ, Jalan Ampang',
    'requesterPhone': '0101112222', 
    'purpose': 'Research Collaboration', 'status': 'Completed', 
    'approvedBy': 'Encik Razak', 'approvalDateTime': '10 Oct 2025 04:00 PM', 'driverName': 'Bala'
  },
];

// Utility class for common driver actions (like calling)
class DriverActions {
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
      // ignore: avoid_print
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

    switch (index) {
      case 0: // Assigned Trip (Current Page)
        break;
      case 1: // Home
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const DriDash()));
        break;
      case 2: // History (The required change)
        // FIX: Navigate to DriHistoryPage without passing the data list
        Navigator.pushReplacement(
            context, 
            MaterialPageRoute(
                builder: (context) => const DriHistoryPage() // No arguments passed
            )
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Separate trips by status for stat cards
    final List<Map<String, dynamic>> todayTrips = assignedTrips.where((trip) {
      // Simple check for 'today' (MOCK: check for the 28th and 10th for demonstration)
      // In a real app, you would use DateTime.now() to check the date.
      return trip['pickupDate']?.contains('28 Oct 2025') == true || trip['pickupDate']?.contains('10 Nov 2025') == true;
    }).toList();

    return Scaffold(
      backgroundColor: kBackgroundColor, // Ensures the SCaffold background is kBackgroundColor
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

// Enum to define the menu options
enum CallOption { requester, admin }

// Widget for displaying an individual trip assignment
class _TripAssignmentCard extends StatelessWidget {
  final Map<String, dynamic> trip;
  const _TripAssignmentCard({required this.trip});

  // Function to handle the menu selection
  void _onCallOptionSelected(BuildContext context, CallOption result, String requesterPhone) {
    switch (result) {
      case CallOption.requester:
        DriverActions.callRequester(requesterPhone);
        break;
      case CallOption.admin:
        DriverActions.callAdmin();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    // --- Data extraction for display ---
    final String plate = trip['plate'] ?? 'N/A';
    final String model = trip['model'] ?? 'N/A';
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
      // Removing ':' for time range display (as per original logic)
      timeRange = '${pickupTime.replaceAll(':', '')} - ${returnTime.replaceAll(':', '')}'; 
    }
    
    final String destination = trip['destination'] ?? 'N/A';
    final String pickupLocation = trip['pickupLocation'] ?? 'N/A';
    final String status = trip['status'] ?? 'N/A';
    final Color statusColor = status == 'Assigned' ? kAssignedColor : kCompletedColor;
    
    // Check if both the status is Assigned AND the phone is available
    final bool canCallRequester = status == 'Assigned' && requesterPhone != 'N/A';
    
    // Define the color for the call button
    final Color callButtonColor = canCallRequester ? Colors.green.shade600 : Colors.grey.shade400;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white, // Card background remains WHITE
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
                      // Vehicle Info Header (Kept for basic card identification)
                      Text('$model ($plate)', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: kPrimaryColor)),
                      const SizedBox(height: 8), 

                      // --- REQUIRED FIELDS (5 items in order) ---
                      
                      // 1. date
                      Row(
                        children: [
                          const Icon(Icons.calendar_today, size: 14, color: Colors.black54),
                          const SizedBox(width: 6),
                          Text(pickupDate, style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w500)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      
                      // 2. time
                      Row(
                        children: [
                          const Icon(Icons.access_time_filled, size: 14, color: Colors.black54),
                          const SizedBox(width: 6),
                          // Use timeRange which is already formatted without ':'
                          Text(timeRange, style: const TextStyle(color: Colors.black87)), 
                        ],
                      ),
                      const SizedBox(height: 4),
                      
                      // 3. destination
                       Row(
                        children: [
                          const Icon(Icons.location_on, size: 14, color: Colors.black54),
                          const SizedBox(width: 6),
                          Expanded(child: Text('Destination: $destination', style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      
                      // 4. pickup location
                       Row(
                        children: [
                          const Icon(Icons.outbound, size: 14, color: Colors.black54), 
                          const SizedBox(width: 6),
                          Expanded(child: Text('Pickup: $pickupLocation', style: const TextStyle(color: Colors.black87), overflow: TextOverflow.ellipsis)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      
                      // 5. plate number
                       Row(
                        children: [
                          const Icon(Icons.directions_car, size: 14, color: Colors.black54),
                          const SizedBox(width: 6),
                          Text('Plate No: $plate', style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w600)),
                        ],
                      ),
                      // --- END REQUIRED FIELDS ---
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
              crossAxisAlignment: CrossAxisAlignment.center, 
              children: [
                // 1. View Details Button (Expanded to take up all remaining space)
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.info_outline),
                    label: const Text('View Details', style: TextStyle(fontSize: 14)), 
                    onPressed: () {
                      // Navigate to the driver-specific detail page
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DriBookingDetailPage(
                            bookingDetails: trip, 
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimaryColor,
                      foregroundColor: Colors.white,
                      // Ensures button height matches circular button
                      padding: const EdgeInsets.symmetric(vertical: 14), 
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
                
                // Small gap between buttons
                const SizedBox(width: 12),
                
                // 2. Call Options Menu Button (Fixed size circular icon)
                SizedBox(
                  width: 56, // Fixed width for a standard-sized circular button
                  height: 56, // Fixed height for a standard-sized circular button
                  child: PopupMenuButton<CallOption>(
                    onSelected: (result) => _onCallOptionSelected(context, result, requesterPhone),
                    itemBuilder: (BuildContext context) => <PopupMenuEntry<CallOption>>[
                      // Option 1: Call Requester (only if phone is available)
                      if (canCallRequester) 
                        PopupMenuItem<CallOption>(
                          value: CallOption.requester,
                          child: ListTile(
                            leading: const Icon(Icons.phone, color: kPrimaryColor),
                            title: const Text('Call Requester'),
                            subtitle: Text(requesterPhone),
                            contentPadding: EdgeInsets.zero,
                            dense: true,
                          ),
                        ),
                      // Option 2: Call Admin (always available)
                      PopupMenuItem<CallOption>(
                        value: CallOption.admin,
                        child: ListTile(
                          leading: const Icon(Icons.support_agent, color: Colors.red),
                          title: const Text('Call Admin'),
                          subtitle: const Text(DriverActions.adminPhoneNumber),
                          contentPadding: EdgeInsets.zero,
                          dense: true,
                        ),
                      ),
                    ],
                    // Child is the circular button itself
                    child: Container(
                      decoration: BoxDecoration(
                        color: callButtonColor,
                        shape: BoxShape.circle, // Make it circular
                        boxShadow: [BoxShadow(color: callButtonColor.withOpacity(0.4), blurRadius: 8)],
                      ),
                      child: Center(
                        child: Icon(
                          canCallRequester ? Icons.phone : Icons.phone_disabled,
                          color: Colors.white,
                          size: 24, // Slightly larger icon
                        ),
                      ),
                    ),
                    // Position the menu above the button
                    offset: const Offset(0, -110), 
                    color: Colors.white,
                    elevation: 8,
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