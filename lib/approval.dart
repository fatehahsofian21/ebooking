// approval.dart

import 'package:flutter/material.dart'; 
import 'package:ibooking/AppBookingDetail.dart';
import 'package:ibooking/AppDash.dart';
import 'package:ibooking/AppHistory.dart';

// --- Brand Guideline Colors ---
const Color kPrimaryColor = Color(0xFF007DC5);
const Color kBackgroundColor = Color(0xFFF5F5F5);
const Color kApproveColor = Color(0xFF28a745);
const Color kRejectColor = Color(0xFFdc3545);

// --- Dummy data with 'department' included ---
final List<Map<String, dynamic>> pendingVehicleBookings = [
  {'requester': 'Nor Fatehah Binti Sofian', 'department': 'ICT Department', 'plate': 'WPC1234', 'model': 'Toyota Vellfire', 'pickupDate': '02 Nov 2025 09:00 AM', 'returnDate': '02 Nov 2025 11:00 AM', 'destination': 'Menara TM, Kuala Lumpur', 'pickupLocation': 'PERKESO HQ, Jalan Ampang', 'returnLocation': 'PERKESO HQ, Jalan Ampang', 'pax': 3, 'requireDriver': true, 'purpose': 'Official meeting with Telekom Malaysia.', 'uploadedDocName': 'meeting_invitation.pdf'},
  {'requester': 'John Doe', 'department': 'Human Resources', 'plate': 'VAN9988', 'model': 'Honda CRV', 'pickupDate': '03 Nov 2025 02:00 PM', 'returnDate': '03 Nov 2025 04:00 PM', 'destination': 'Putrajaya International Convention Centre', 'pickupLocation': 'PERKESO HQ, Jalan Ampang', 'returnLocation': 'PERKESO HQ, Jalan Ampang', 'pax': 1, 'requireDriver': false, 'purpose': 'Attend the annual tech conference.', 'uploadedDocName': 'N/A'},
  {'requester': 'Jane Smith', 'department': 'Administration', 'plate': 'BUS1122', 'model': 'Perodua Myvi', 'pickupDate': '03 Nov 2025 10:00 AM', 'returnDate': '03 Nov 2025 01:00 PM', 'destination': 'Sunway Pyramid', 'pickupLocation': 'PERKESO HQ, Jalan Ampang', 'returnLocation': 'PERKESO HQ, Jalan Ampang', 'pax': 2, 'requireDriver': true, 'purpose': 'To collect event materials.', 'uploadedDocName': 'event_agenda.pdf'},
];

class ApprovalPage extends StatefulWidget {
  const ApprovalPage({super.key});

  @override
  State<ApprovalPage> createState() => _ApprovalPageState();
}

class _ApprovalPageState extends State<ApprovalPage> {
  int _currentIndex = 0;

  void _onTabTapped(int index) {
    if (index == _currentIndex) return;
    setState(() { _currentIndex = index; });

    switch (index) {
      case 1:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const AppDash()));
        break;
      case 2:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const AppHistoryPage()));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        title: const Text('Pending Approvals'),
        backgroundColor: kPrimaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const AppDash())),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Expanded(child: _StatCard(count: pendingVehicleBookings.length, label: 'Pending Today', color: Colors.orange.shade700)),
                const SizedBox(width: 16),
                const Expanded(child: _StatCard(count: 12, label: 'Approved This Week', color: kApproveColor)),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              itemCount: pendingVehicleBookings.length,
              itemBuilder: (context, index) {
                final booking = pendingVehicleBookings[index];
                return _BookingApprovalCard(booking: booking);
              },
            ),
          ),
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
          BottomNavigationBarItem(icon: Icon(Icons.list_alt_rounded), label: 'List Booking'),
          BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.history_rounded), label: 'History'),
        ],
      ),
    );
  }
}

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

// --- WIDGET: Approval Card (REFINED) ---
// This widget now displays the full details as requested.
class _BookingApprovalCard extends StatelessWidget {
  final Map<String, dynamic> booking;
  const _BookingApprovalCard({required this.booking});

  @override
  Widget build(BuildContext context) {
    // --- Data extraction for display ---
    final String plate = booking['plate'] ?? 'N/A';
    final String requester = booking['requester'] ?? 'N/A';
    final String department = booking['department'] ?? 'N/A';
    final String time = (booking['pickupDate'] != null && booking['returnDate'] != null)
        ? '${booking['pickupDate'].split(' ').sublist(1).join(' ')} - ${booking['returnDate'].split(' ').sublist(1).join(' ')}'
        : 'N/A';

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
            // --- MODIFIED: This Row contains the detailed layout ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(plate, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 6),
                      Text(requester, style: const TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      Text(department, style: const TextStyle(color: Colors.black54)),
                      const SizedBox(height: 6),
                      Text(time, style: const TextStyle(color: Colors.black87)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AppBookingDetailPage(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('See More'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}