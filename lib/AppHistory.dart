// AppHistory.dart

import 'package:flutter/material.dart';
import 'package:ibooking/AppBookingDetail.dart';
import 'package:ibooking/AppDash.dart';
import 'package:ibooking/approval.dart';

// --- Brand Guideline Colors ---
const Color kPrimaryColor = Color(0xFF007DC5);
const Color kBackgroundColor = Color(0xFFF5F5F5);
const Color kApproved = Color(0xFF007DC5);
const Color kPending = Color(0xFFF39F21);
const Color kWarning = Color(0xFFA82525); // For Rejected
const Color kComplete = Color(0xFF2ECC71); // For Completed

// --- Dummy Booking Data for History ---
final List<Map<String, dynamic>> allBookings = [
  {'requester': 'Nor Fatehah Binti Sofian', 'department': 'ICT Department', 'plate': 'WPC1234', 'model': 'Toyota Vellfire', 'pickupDate': '02 Nov 2025 09:00 AM', 'returnDate': '02 Nov 2025 11:00 AM', 'destination': 'Menara TM, Kuala Lumpur', 'status': 'PENDING'},
  {'requester': 'Ahmad Bin Hassan', 'department': 'Management', 'plate': 'BOS 1', 'model': 'Mercedes S-Class', 'pickupDate': '01 Nov 2025 10:00 AM', 'returnDate': '01 Nov 2025 05:00 PM', 'destination': 'Prime Minister\'s Office', 'status': 'APPROVED'},
  {'requester': 'Siti Aisyah', 'department': 'Human Resources', 'plate': 'HRV 2023', 'model': 'Honda HRV', 'pickupDate': '28 Oct 2025 02:00 PM', 'returnDate': '28 Oct 2025 04:00 PM', 'destination': 'Putrajaya Convention Centre', 'status': 'COMPLETE'},
  {'requester': 'Razak Bin Ali', 'department': 'Administration', 'plate': 'BUS 1122', 'model': 'Scania Touring Bus', 'pickupDate': '25 Oct 2025 08:00 AM', 'returnDate': '25 Oct 2025 06:00 PM', 'destination': 'Melaka Heritage Trip', 'status': 'COMPLETE'},
  {'requester': 'John Doe', 'department': 'Sales', 'plate': 'VEE 5566', 'model': 'Toyota Vios', 'pickupDate': '29 Oct 2025 11:00 AM', 'returnDate': '29 Oct 2025 01:00 PM', 'destination': 'Client Office - Damansara', 'status': 'REJECTED'},
];

class AppHistoryPage extends StatefulWidget {
  const AppHistoryPage({super.key});

  @override
  State<AppHistoryPage> createState() => _AppHistoryPageState();
}

class _AppHistoryPageState extends State<AppHistoryPage> {
  int _currentIndex = 2;
  String _selectedStatus = 'All';
  List<Map<String, dynamic>> _filteredBookings = [];

  final List<String> _filterCategories = ['All', 'PENDING', 'APPROVED', 'COMPLETE', 'REJECTED'];

  @override
  void initState() {
    super.initState();
    _filteredBookings = allBookings;
  }

  void _filterBookings(String status) {
    setState(() {
      _selectedStatus = status;
      if (status == 'All') {
        _filteredBookings = allBookings;
      } else {
        _filteredBookings = allBookings.where((booking) => booking['status'] == status).toList();
      }
    });
  }

  void _onTabTapped(int index) {
    if (index == _currentIndex) return;
    setState(() { _currentIndex = index; });

    switch (index) {
      case 0:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const ApprovalPage()));
        break;
      case 1:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const AppDash()));
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
        // ======================= THIS IS THE ADDED BACK BUTTON =======================
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          tooltip: 'Back to Approvals',
          onPressed: () {
            // Navigate back to the ApprovalPage
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const ApprovalPage()),
            );
          },
        ),
        // ===========================================================================
      ),
      body: Column(
        children: [
          // --- Filter Bar ---
          Container(
            height: 50,
            color: Colors.white,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _filterCategories.length,
              itemBuilder: (context, index) {
                final category = _filterCategories[index];
                return _FilterButton(
                  label: category == 'All' ? 'All' : category.toLowerCase().replaceFirst(category[0].toLowerCase(), category[0]),
                  isSelected: _selectedStatus == category,
                  onTap: () => _filterBookings(category),
                );
              },
            ),
          ),
          // --- Booking List ---
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _filteredBookings.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      key: ValueKey(_selectedStatus),
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      itemCount: _filteredBookings.length,
                      itemBuilder: (context, index) {
                        final booking = _filteredBookings[index];
                        return _HistoryCard(booking: booking);
                      },
                    ),
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

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded, size: 60, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'No bookings found',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

class _FilterButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterButton({required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? kPrimaryColor : Colors.transparent,
              width: 3.0,
            ),
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? kPrimaryColor : Colors.grey[700],
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            fontSize: 15,
          ),
        ),
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final Map<String, dynamic> booking;
  const _HistoryCard({required this.booking});

  Color _getStatusColor(String status) {
    switch (status) {
      case 'PENDING':
        return kPending;
      case 'APPROVED':
        return kApproved;
      case 'COMPLETE':
        return kComplete;
      case 'REJECTED':
      case 'CANCELED':
        return kWarning;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final String plate = booking['plate'] ?? 'N/A';
    final String requester = booking['requester'] ?? 'N/A';
    final String department = booking['department'] ?? 'N/A';
    final String date = booking['pickupDate']?.split(' ')[0] ?? 'N/A';
    final String time = (booking['pickupDate'] != null && booking['returnDate'] != null)
        ? '${booking['pickupDate'].split(' ')[1]} ${booking['pickupDate'].split(' ')[2]} - ${booking['returnDate'].split(' ')[1]} ${booking['returnDate'].split(' ')[2]}'
        : 'N/A';
    final String status = booking['status'] ?? 'N/A';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.08), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(plate, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.black87)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getStatusColor(status).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          status,
                          style: TextStyle(color: _getStatusColor(status), fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(requester, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                  const SizedBox(height: 4),
                  Text(department, style: const TextStyle(color: Colors.black54, fontSize: 14)),
                  const SizedBox(height: 8),
                  Text('$date • $time', style: const TextStyle(color: Colors.black87, fontSize: 14)),
                ],
              ),
            ),
            const Divider(height: 1),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AppBookingDetailPage(
                        bookingDetails: booking,
                        sourcePage: 'history',
                      ),
                    ),
                  );
                },
                style: TextButton.styleFrom(
                  foregroundColor: kPrimaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(14),
                      bottomRight: Radius.circular(14),
                    ),
                  ),
                ),
                child: const Text('See More', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}