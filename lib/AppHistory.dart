// AppHistory.dart

import 'package:flutter/material.dart';
import 'package:ibooking/AppBookingDetail.dart';
import 'package:ibooking/AppDash.dart';
import 'package:ibooking/approval.dart';
import 'package:intl/intl.dart';

// --- Brand Guideline Colors ---
const Color kPrimaryColor = Color(0xFF007DC5);
const Color kBackgroundColor = Color(0xFFF5F5F5);
const Color kApproved = Color(0xFF007DC5);
const Color kPending = Color(0xFFF39F21);
const Color kWarning = Color(0xFFA82525); // For Rejected
const Color kComplete = Color(0xFF2ECC71); // For Completed

// Booking Model and Dummy Data (No changes needed here)
class Booking {
  final String requester;
  final String department;
  final String plate;
  final String model;
  final String pickupDate;
  final String returnDate;
  final String destination;
  final String status;
  final bool requireDriver;
  final String? driverName;
  final String? rejectionReason;

  Booking({
    required this.requester,
    required this.department,
    required this.plate,
    required this.model,
    required this.pickupDate,
    required this.returnDate,
    required this.destination,
    required this.status,
    this.requireDriver = false,
    this.driverName,
    this.rejectionReason,
  });

  DateTime? get _pickupDateTime => DateFormat("dd MMM yyyy hh:mm a").tryParse(pickupDate);
  DateTime? get _returnDateTime => DateFormat("dd MMM yyyy hh:mm a").tryParse(returnDate);

  String get displayDate {
    final dt = _pickupDateTime;
    return dt != null ? DateFormat('dd MMM yyyy').format(dt) : 'Invalid Date';
  }

  String get displayTime {
    final pdt = _pickupDateTime;
    final rdt = _returnDateTime;
    if (pdt != null && rdt != null) {
      return '${DateFormat('hh:mm a').format(pdt)} - ${DateFormat('hh:mm a').format(rdt)}';
    }
    return 'Invalid Time';
  }

  factory Booking.fromMap(Map<String, dynamic> map) {
    return Booking(
      requester: map['requester'] ?? 'N/A',
      department: map['department'] ?? 'N/A',
      plate: map['plate'] ?? 'N/A',
      model: map['model'] ?? 'N/A',
      pickupDate: map['pickupDate'] ?? 'N/A',
      returnDate: map['returnDate'] ?? 'N/A',
      destination: map['destination'] ?? 'N/A',
      status: map['status'] ?? 'UNKNOWN',
      requireDriver: map['requireDriver'] ?? false,
      driverName: map['driverName'],
      rejectionReason: map['rejectionReason'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'requester': requester,
      'department': department,
      'plate': plate,
      'model': model,
      'pickupDate': pickupDate,
      'returnDate': returnDate,
      'destination': destination,
      'status': status,
      'requireDriver': requireDriver,
      'driverName': driverName,
      'rejectionReason': rejectionReason,
    };
  }
}

final List<Booking> allBookings = [
  Booking.fromMap({'requester': 'Nor Fatehah Binti Sofian', 'department': 'ICT Department', 'plate': 'WPC1234', 'model': 'Toyota Vellfire', 'pickupDate': '02 Nov 2025 09:00 AM', 'returnDate': '02 Nov 2025 11:00 AM', 'destination': 'Menara TM, Kuala Lumpur', 'status': 'PENDING', 'requireDriver': true}),
  Booking.fromMap({'requester': 'Ahmad Bin Hassan', 'department': 'Management', 'plate': 'BOS 1', 'model': 'Mercedes S-Class', 'pickupDate': '01 Nov 2025 10:00 AM', 'returnDate': '01 Nov 2025 05:00 PM', 'destination': 'Prime Minister\'s Office', 'status': 'APPROVED', 'requireDriver': true, 'driverName': 'Ismail Bin Sabri'}),
  Booking.fromMap({'requester': 'Siti Aisyah', 'department': 'Human Resources', 'plate': 'HRV 2023', 'model': 'Honda HRV', 'pickupDate': '28 Oct 2025 02:00 PM', 'returnDate': '28 Oct 2025 04:00 PM', 'destination': 'Putrajaya Convention Centre', 'status': 'COMPLETE', 'requireDriver': false}),
  Booking.fromMap({'requester': 'Razak Bin Ali', 'department': 'Administration', 'plate': 'BUS 1122', 'model': 'Scania Touring Bus', 'pickupDate': '25 Oct 2025 08:00 AM', 'returnDate': '25 Oct 2025 06:00 PM', 'destination': 'Melaka Heritage Trip', 'status': 'COMPLETE', 'requireDriver': true, 'driverName': 'Chan Wei'}),
  Booking.fromMap({'requester': 'John Doe', 'department': 'Sales', 'plate': 'VEE 5566', 'model': 'Toyota Vios', 'pickupDate': '29 Oct 2025 11:00 AM', 'returnDate': '29 Oct 2025 01:00 PM', 'destination': 'Client Office - Damansara', 'status': 'REJECTED', 'rejectionReason': 'Vehicle is currently at the workshop for maintenance.'}),
];


class AppHistoryPage extends StatefulWidget {
  const AppHistoryPage({super.key});

  @override
  State<AppHistoryPage> createState() => _AppHistoryPageState();
}

// ======================= REFINED STATE FOR SWIPEABLE TABS =======================
class _AppHistoryPageState extends State<AppHistoryPage> with SingleTickerProviderStateMixin {
  int _bottomNavIndex = 2; // For the bottom navigation bar
  late TabController _tabController;

  final List<String> _filterCategories = ['All', 'PENDING', 'APPROVED', 'COMPLETE', 'REJECTED'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _filterCategories.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onBottomNavTapped(int index) {
    if (index == _bottomNavIndex) return;
    setState(() { _bottomNavIndex = index; });

    switch (index) {
      case 0:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const ApprovalPage()));
        break;
      case 1:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const AppDash()));
        break;
    }
  }

  List<Booking> _getFilteredBookings(String status) {
    if (status == 'All') {
      return allBookings;
    }
    return allBookings.where((booking) => booking.status == status).toList();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        title: const Text('Booking History'),
        backgroundColor: kPrimaryColor,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          tooltip: 'Back to Home',
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const AppDash()),
            );
          },
        ),
        // The TabBar is placed at the bottom of the AppBar.
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white.withOpacity(0.7),
          indicatorColor: Colors.white,
          indicatorWeight: 3.0,
          tabs: _filterCategories.map((category) => Tab(text: category)).toList(),
        ),
      ),
      // The body is now a TabBarView, which handles the swiping.
      body: TabBarView(
        controller: _tabController,
        children: _filterCategories.map((status) {
          final filteredList = _getFilteredBookings(status);
          return _BookingList(key: ValueKey(status), bookings: filteredList);
        }).toList(),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _bottomNavIndex,
        onTap: _onBottomNavTapped,
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
// ====================================================================

/// A reusable widget to display a list of bookings or an empty state message.
class _BookingList extends StatelessWidget {
  final List<Booking> bookings;

  const _BookingList({super.key, required this.bookings});

  @override
  Widget build(BuildContext context) {
    if (bookings.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off_rounded, size: 60, color: Colors.grey),
            SizedBox(height: 16),
            Text('No bookings found', style: TextStyle(fontSize: 18, color: Colors.grey)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: bookings.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: _HistoryCard(booking: bookings[index]),
        );
      },
    );
  }
}

// --- History Card and Info Row Widgets (No changes needed) ---
class _HistoryCard extends StatelessWidget {
  final Booking booking;
  const _HistoryCard({required this.booking});

  Color _getStatusColor(String status) {
    switch (status) {
      case 'PENDING': return kPending;
      case 'APPROVED': return kApproved;
      case 'COMPLETE': return kComplete;
      case 'REJECTED': return kWarning;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AppBookingDetailPage(bookingDetails: booking.toMap(), sourcePage: 'history'),
            ),
          );
        },
        borderRadius: BorderRadius.circular(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text('${booking.model} (${booking.plate})', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.black87), overflow: TextOverflow.ellipsis),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: _getStatusColor(booking.status).withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                        child: Text(booking.status, style: TextStyle(color: _getStatusColor(booking.status), fontWeight: FontWeight.bold, fontSize: 12)),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  _InfoRowWithIcon(icon: Icons.person_outline_rounded, text: booking.requester),
                  const SizedBox(height: 8),
                  _InfoRowWithIcon(icon: Icons.business_rounded, text: booking.department),
                  const SizedBox(height: 8),
                  _InfoRowWithIcon(icon: Icons.calendar_today_rounded, text: '${booking.displayDate} • ${booking.displayTime}'),
                  if (booking.driverName != null) ...[
                    const SizedBox(height: 8),
                    _InfoRowWithIcon(icon: Icons.person_pin_circle_outlined, text: 'Driver: ${booking.driverName}', iconColor: Colors.blueGrey),
                  ],
                  if (booking.rejectionReason != null) ...[
                    const SizedBox(height: 8),
                    _InfoRowWithIcon(icon: Icons.info_outline_rounded, text: 'Reason: ${booking.rejectionReason}', iconColor: kWarning, textColor: kWarning),
                  ]
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.05),
                borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(14), bottomRight: Radius.circular(14)),
              ),
              child: const Center(
                child: Text('See More', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: kPrimaryColor)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRowWithIcon extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color iconColor;
  final Color textColor;

  const _InfoRowWithIcon({
    required this.icon,
    required this.text,
    this.iconColor = Colors.grey,
    this.textColor = Colors.black54,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: iconColor),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(color: textColor, fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }
}