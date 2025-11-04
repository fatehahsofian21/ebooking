import 'package:flutter/material.dart';
import 'package:ibooking/Vbooking.dart';
import 'package:ibooking/Vcalendar';
import 'package:ibooking/dashboard.dart'; // Needed for MyCalendar's home navigation


// =========================================================================
// SHARED CONSTANTS AND HELPERS
// =========================================================================

const Color kPrimaryDark = Color.fromARGB(255, 24, 42, 94); // dark blue
const Color kApproved = Color(0xFF2ECC71); // green
const Color kPending = Color(0xFFF39F21); // mustard yellow from MyBooking
const Color kHoliday = Color(0xFFE74C3C); // red
const Color kBorder = Color(0xFFCFD6DE);
const Color kGreyBg = Color(0xFFF2F3F7);

// More colors from MyBooking.dart
const Color kMyBookingApproved = Color(0xFF007DC5); // blue
const Color kWarning = Color(0xFFA82525); // red (for rejected/canceled)
const Color kComplete = Color(0xFF2ECC71); // green for complete status

// Helper function to format DateTime object for display
String _formatDateTime(String? dt) {
  if (dt == null || dt.isEmpty) return 'N/A';
  try {
    final d = DateTime.parse(dt);
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year} ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  } catch (_) {
    return dt ?? 'N/A';
  }
}

// Helper function to format time only
String _formatTime(String? dt) {
  if (dt == null || dt.isEmpty) return '';
  try {
    final d = DateTime.parse(dt);
    return '${d.hour.toString().padLeft(2, "0")}:${d.minute.toString().padLeft(2, "0")}';
  } catch (_) {
    return dt ?? '';
  }
}

// Helper function to determine status color for MyCalendar
Color _statusColorMyCalendar(String status) {
  switch (status) {
    case 'PENDING':
      return kPending;
    case 'APPROVED':
      return kMyBookingApproved;
    case 'HOLIDAY':
      return kWarning;
    case 'COMPLETE':
      return kComplete;
    case 'REJECTED':
    case 'CANCELED':
      return kWarning;
    default:
      return Colors.grey;
  }
}

// =========================================================================
// BOOKING DETAILS PAGE (from MyBooking.dart)
// =========================================================================
class BookingDetailsPage extends StatelessWidget {
  final Map<String, dynamic> booking;
  const BookingDetailsPage({super.key, required this.booking});

  Widget _buildInfoRow(String title, String? value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF8B97A6),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value ?? 'N/A',
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF2E3A59),
            ),
          ),
          const Divider(height: 16),
        ],
      ),
    );
  }

  Widget _buildStatusTag(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: _statusColorMyCalendar(status),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        status,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 16,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Future<void> _showCancelDialog(BuildContext context, String bookingId) async {
    String cancelReason = '';
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Cancel Booking'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                const Text('Please provide a reason for cancellation:'),
                const SizedBox(height: 10),
                TextField(
                  onChanged: (value) => cancelReason = value,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText: 'Reason for cancellation',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('No'),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            TextButton(
              child: const Text('Yes, Cancel'),
              onPressed: () {
                if (cancelReason.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Cancellation reason is required.')),
                  );
                  return;
                }
                Navigator.of(dialogContext).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Booking $bookingId canceled with reason: $cancelReason')),
                );
                Navigator.of(context).pop(); // Go back to MyBookingPage
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    final status = booking['status'] ?? 'UNKNOWN';
    final bookingId = booking['id'] ?? '';

    if (status == 'PENDING' || status == 'APPROVED') {
      return ElevatedButton.icon(
        onPressed: () => _showCancelDialog(context, bookingId),
        icon: const Icon(Icons.cancel_outlined, color: Colors.white),
        label: const Text('Cancel Booking', style: TextStyle(color: Colors.white)),
        style: ElevatedButton.styleFrom(
          backgroundColor: kWarning,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kGreyBg,
      appBar: AppBar(
        backgroundColor: kPrimaryDark,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Booking Details', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: _buildStatusTag(booking['status'] ?? 'UNKNOWN'),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, 3))
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Vehicle Booking Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: kPrimaryDark)),
                    const SizedBox(height: 16),
                    _buildInfoRow('Vehicle Type', '${booking['vehicle'] ?? 'N/A'} (${booking['model'] ?? 'N/A'})'),
                    _buildInfoRow('Plate Number', booking['plate'] ?? 'N/A'),
                    _buildInfoRow('Pick-Up Date & Time', _formatDateTime(booking['pickupDate'])),
                    _buildInfoRow('Return Date & Time', _formatDateTime(booking['returnDate'])),
                    _buildInfoRow('Number of Pax', (booking['pax'] ?? 0).toString()),
                    _buildInfoRow('Require Driver', (booking['requireDriver'] == true ? 'Yes' : 'No')),
                    _buildInfoRow('Destination', booking['destination']),
                    _buildInfoRow('Pick-Up Location', booking['pickupLocation']),
                    _buildInfoRow('Return Location', booking['returnLocation']),
                    _buildInfoRow('Purpose of Booking', booking['purpose']),
                    _buildInfoRow('Supported Document', booking['uploadedDocName'] ?? 'No document uploaded'),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              _buildActionButtons(context),
            ],
          ),
        ),
      ),
    );
  }
}

// =========================================================================
// MAIN PAGE: MyBookingPage (previously MyBooking2Page)
// =========================================================================

class MyBooking2Page extends StatefulWidget {
  const MyBooking2Page({super.key});

  @override
  State<MyBooking2Page> createState() => _MyBooking2PageState();
}

class _MyBooking2PageState extends State<MyBooking2Page> {
  // Common state
  bool _isMyCalendarActive = false; // Toggle state for calendars
  final PageController _pageController = PageController(initialPage: 120);
  final DateTime _baseMonth = DateTime(DateTime.now().year, DateTime.now().month, 1);
  static const _monthNames = <String>[
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];

  // --- State for Super Calendar ---
  DateTime? _selectedDateSuper;
  List<Map<String, String>>? _bookingsForSelectedDateSuper;
  final Map<int, List<Map<String, String>>> bookingsByDaySuper = {
    5: [{'plate': 'WPC1234', 'name': 'SHERA', 'department': 'Engineering', 'time': '10:00 AM – 3:00 PM', 'status': 'APPROVED', 'vehicle': 'Car'}],
    9: [{'plate': 'VAN9988', 'name': 'SAMIR', 'department': 'HR', 'time': '2:00 PM – 5:00 PM', 'status': 'PENDING', 'vehicle': 'Van'}],
    14: [
      {'plate': 'BUS1122', 'name': 'AMIRUL', 'department': 'Admin', 'time': '9:00 AM – 1:00 PM', 'status': 'APPROVED', 'vehicle': 'Bus'},
      {'plate': 'CAR7788', 'name': 'RIZAL', 'department': 'Admin', 'time': '2:00 PM – 4:00 PM', 'status': 'PENDING', 'vehicle': 'Car'}
    ],
    22: [{'plate': 'VAN4455', 'name': 'JASON', 'department': 'Engineering', 'time': '11:00 AM – 2:00 PM', 'status': 'APPROVED', 'vehicle': 'Van'}],
    25: [{'name': 'PUBLIC HOLIDAY', 'department': '', 'time': '', 'status': 'HOLIDAY', 'vehicle': ''}],
  };
  
  // --- State for My Calendar ---
  DateTime? _selectedDateMy;
  List<Map<String, dynamic>>? _bookingsForSelectedDateMy;
  final Map<int, List<Map<String, dynamic>>> bookingsByDayMy = {};
  final List<Map<String, dynamic>> _allMyBookings = [
    {'id': '1', 'vehicle': 'Car', 'plate': 'WPC1234', 'status': 'PENDING', 'pickupDate': '2025-10-05 10:00', 'returnDate': '2025-10-05 14:00', 'model': 'Toyota Vios', 'pax': 2, 'requireDriver': true, 'destination': 'Kuala Lumpur Convention Centre', 'pickupLocation': 'PERKESO JALAN AMPANG', 'returnLocation': 'PERKESO JALAN AMPANG', 'purpose': 'Official meeting.', 'uploadedDocName': 'meeting_req.pdf'},
    {'id': '2', 'vehicle': 'Van', 'plate': 'VAN9988', 'status': 'APPROVED', 'pickupDate': '2025-10-09 14:00', 'returnDate': '2025-10-09 17:00', 'model': 'Toyota Hiace', 'pax': 5, 'requireDriver': false, 'destination': 'Klang Valley Site A', 'pickupLocation': 'PERKESO JALAN AMPANG', 'returnLocation': 'Klang Valley Site A', 'purpose': 'Site inspection.', 'uploadedDocName': null},
    {'id': '3', 'vehicle': 'Bus', 'plate': 'BUS1122', 'status': 'APPROVED', 'pickupDate': '2025-10-14 09:00', 'returnDate': '2025-10-14 13:00', 'model': 'Isuzu Bus', 'pax': 20, 'requireDriver': true, 'destination': 'Penang Bridge', 'pickupLocation': 'PERKESO JALAN AMPANG', 'returnLocation': 'PERKESO JALAN AMPANG', 'purpose': 'Outstation trip.', 'uploadedDocName': 'approval_letter.pdf'},
    {'id': '4', 'vehicle': 'Car', 'plate': 'CAR7788', 'status': 'PENDING', 'pickupDate': '2025-10-14 14:00', 'returnDate': '2025-10-14 16:00', 'model': 'Proton Persona', 'pax': 1, 'requireDriver': false, 'destination': 'Putrajaya Office', 'pickupLocation': 'Putrajaya Office', 'returnLocation': 'Putrajaya Office', 'purpose': 'Document delivery.', 'uploadedDocName': null},
    {'id': '5', 'vehicle': '', 'plate': '', 'status': 'HOLIDAY', 'pickupDate': '2025-10-25 00:00', 'returnDate': '2025-10-25 00:00', 'name': 'PUBLIC HOLIDAY', 'model': null, 'pax': 0, 'requireDriver': false, 'destination': null, 'pickupLocation': null, 'returnLocation': null, 'purpose': null, 'uploadedDocName': null},
    {'id': '6', 'vehicle': 'Car', 'plate': 'CAR1234', 'status': 'COMPLETE', 'pickupDate': '2025-10-20 09:00', 'returnDate': '2025-10-20 12:00', 'model': 'Toyota Vios', 'pax': 3, 'requireDriver': false, 'destination': 'Bandar Sunway', 'pickupLocation': 'PERKESO JALAN AMPANG', 'returnLocation': 'PERKESO JALAN AMPANG', 'purpose': 'Client visit.', 'uploadedDocName': null},
    {'id': '7', 'vehicle': 'Car', 'plate': 'CAR6677', 'status': 'REJECTED', 'pickupDate': '2025-10-22 10:00', 'returnDate': '2025-10-22 14:00', 'model': 'Proton Persona', 'pax': 2, 'requireDriver': true, 'destination': 'Shah Alam Factory', 'pickupLocation': 'PERKESO JALAN AMPANG', 'returnLocation': 'PERKESO JALAN AMPANG', 'purpose': 'Machine inspection.', 'uploadedDocName': 'inspection_list.pdf'},
  ];

  @override
  void initState() {
    super.initState();
    _rebuildMyCalendarBookingsMap();
  }

  void _rebuildMyCalendarBookingsMap() {
    bookingsByDayMy.clear();
    for (final b in _allMyBookings) {
      try {
        final pickup = DateTime.parse(b['pickupDate']!);
        final day = pickup.day;
        bookingsByDayMy.putIfAbsent(day, () => []).add(b);
      } catch (_) {
        // Ignore parse errors for demo data
      }
    }
  }

  DateTime _monthForPage(int page) => DateTime(_baseMonth.year, _baseMonth.month + (page - 120), 1);

  void _onDateTappedSuper(DateTime month, int day) {
    setState(() {
      _selectedDateSuper = DateTime(month.year, month.month, day);
      _bookingsForSelectedDateSuper = bookingsByDaySuper[day];
    });
  }

  void _onDateTappedMy(DateTime month, int day) {
    setState(() {
      _selectedDateMy = DateTime(month.year, month.month, day);
      _bookingsForSelectedDateMy = bookingsByDayMy[day];
    });
  }

  void _navigateToBookingDetails(Map<String, dynamic> booking) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => BookingDetailsPage(booking: booking)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kGreyBg,
      appBar: AppBar(
        backgroundColor: kPrimaryDark,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('My Booking', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildCalendarToggle(), // The new toggle switch
              
              // Calendar Card
              Container(
                margin: const EdgeInsets.all(12),
                padding: const EdgeInsets.fromLTRB(12, 16, 12, 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, 3)),
                  ],
                ),
                child: SizedBox(
                  height: 420, // Adjusted for consistency
                  child: PageView.builder(
                    controller: _pageController,
                    itemBuilder: (context, page) {
                      final month = _monthForPage(page);
                      return Column(
                        children: [
                          _monthHeader(month),
                          _weekHeader(),
                          const SizedBox(height: 8),
                          _isMyCalendarActive ? _monthGridMy(month) : _monthGridSuper(month),
                        ],
                      );
                    },
                  ),
                ),
              ),
              
              // Location Banner
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(color: const Color(0xFFE9EDF3), borderRadius: BorderRadius.circular(8)),
                alignment: Alignment.center,
                child: const Text('MENARA 1 DUTAMAS', style: TextStyle(color: Color(0xFF2E3A59), fontWeight: FontWeight.bold, letterSpacing: 0.7)),
              ),
              
              // Conditional Details View
              _isMyCalendarActive ? _buildMyCalendarDetails() : _buildSuperCalendarDetails(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2,
        onTap: (i) {
          if (i == 0) {
            // Summary -> navigate to calendar (VCalendarPage)
            Navigator.of(context).push(MaterialPageRoute(builder: (_) => const VCalendarPage()));
          } else if (i == 1) {
            // Booked Vehicle -> booking form
            Navigator.of(context).push(MaterialPageRoute(builder: (_) => const VBookingPage()));
          }
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: kPrimaryDark,
        selectedItemColor: kPending,
        unselectedItemColor: Colors.white70,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.grid_view_outlined), label: 'Summary'),
          BottomNavigationBarItem(icon: Icon(Icons.add), label: 'Booked Vehicle'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today_outlined), label: 'My Booking'),
        ],
      ),
    );
  }

  // --- UI WIDGETS ---

  Widget _buildCalendarToggle() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: kGreyBg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _isMyCalendarActive = false),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: !_isMyCalendarActive ? kPrimaryDark : Colors.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(10),
                    bottomLeft: Radius.circular(10),
                  ),
                ),
                child: Center(
                  child: Text(
                    'Super Calendar',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: !_isMyCalendarActive ? Colors.white : kPrimaryDark,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _isMyCalendarActive = true),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _isMyCalendarActive ? kPrimaryDark : Colors.white,
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(10),
                    bottomRight: Radius.circular(10),
                  ),
                ),
                child: Center(
                  child: Text(
                    'My Calendar',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: _isMyCalendarActive ? Colors.white : kPrimaryDark,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _monthHeader(DateTime month) {
    final title = '${_monthNames[month.month - 1]} ${month.year}';
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          color: kPrimaryDark,
          onPressed: () {
            if (_pageController.hasClients) {
              _pageController.previousPage(duration: const Duration(milliseconds: 200), curve: Curves.easeOut);
            }
          },
        ),
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2E3A59))),
        IconButton(
          icon: const Icon(Icons.arrow_forward_ios_rounded, size: 18),
          color: kPrimaryDark,
          onPressed: () {
            if (_pageController.hasClients) {
              _pageController.nextPage(duration: const Duration(milliseconds: 200), curve: Curves.easeOut);
            }
          },
        ),
      ],
    );
  }

  Widget _weekHeader() {
    const days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: days.map((d) => Text(d, style: const TextStyle(color: Color(0xFF8B97A6), fontWeight: FontWeight.bold, fontSize: 13))).toList(),
    );
  }
  
  // --- SUPER CALENDAR SPECIFIC WIDGETS ---

  Widget _monthGridSuper(DateTime month) {
    final daysInMonth = DateUtils.getDaysInMonth(month.year, month.month);
    final firstWeekday = DateTime(month.year, month.month, 1).weekday % 7;
    final totalCells = ((firstWeekday + daysInMonth + 6) ~/ 7) * 7;
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: totalCells,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7, crossAxisSpacing: 8, mainAxisSpacing: 8),
      itemBuilder: (_, i) {
        final day = i - firstWeekday + 1;
        if (day < 1 || day > daysInMonth) return const SizedBox();

        final isSelected = _selectedDateSuper != null &&
            _selectedDateSuper!.year == month.year &&
            _selectedDateSuper!.month == month.month &&
            _selectedDateSuper!.day == day;

        final bookingsForDay = bookingsByDaySuper[day];
        final isHoliday = bookingsForDay?.any((b) => b['status'] == 'HOLIDAY') ?? false;
        final isApproved = bookingsForDay?.any((b) => b['status'] == 'APPROVED') ?? false;
        final isPending = bookingsForDay?.any((b) => b['status'] == 'PENDING') ?? false;

        Color borderColor = isSelected ? kPrimaryDark : isHoliday ? kHoliday : (isApproved || isPending) ? (isApproved ? kApproved : kPending) : kBorder;
        double borderWidth = (isSelected || isHoliday || isApproved || isPending) ? 2.0 : 1.25;

        return GestureDetector(
          onTap: () => _onDateTappedSuper(month, day),
          child: Container(
            decoration: BoxDecoration(
              color: isSelected ? kPrimaryDark : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: borderColor, width: borderWidth),
            ),
            alignment: Alignment.center,
            child: Text('$day', style: TextStyle(color: isSelected ? Colors.white : const Color(0xFF2E3A59), fontWeight: FontWeight.w700)),
          ),
        );
      },
    );
  }

  Widget _buildSuperCalendarDetails() {
    if (_selectedDateSuper == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Column(
        children: [
          Text(
            '${_selectedDateSuper?.day}/${_selectedDateSuper?.month}/${_selectedDateSuper?.year}',
            style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2E3A59), fontSize: 16),
          ),
          const SizedBox(height: 10),
          if (_bookingsForSelectedDateSuper != null)
            ..._bookingsForSelectedDateSuper!.map((b) {
              final status = b['status'] ?? '';
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: kBorder),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if ((b['plate'] ?? '').isNotEmpty) Text(b['plate']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          const SizedBox(height: 6),
                          Text(b['name']!, style: const TextStyle(fontWeight: FontWeight.w600)),
                          const SizedBox(height: 4),
                          if ((b['department'] ?? '').isNotEmpty) Text(b['department']!, style: const TextStyle(color: Colors.black54)),
                          if ((b['time'] ?? '').isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Text(b['time']!, style: const TextStyle(color: Colors.black87)),
                          ]
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: status == 'APPROVED' ? kApproved : status == 'PENDING' ? kPending : kHoliday,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(status, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    )
                  ],
                ),
              );
            })
          else
            const Text('No bookings for this date', style: TextStyle(color: Colors.black54)),
        ],
      ),
    );
  }

  // --- MY CALENDAR SPECIFIC WIDGETS ---

  Widget _monthGridMy(DateTime month) {
    final daysInMonth = DateUtils.getDaysInMonth(month.year, month.month);
    final firstWeekday = DateTime(month.year, month.month, 1).weekday % 7;
    final totalCells = ((firstWeekday + daysInMonth + 6) ~/ 7) * 7;
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: totalCells,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7, crossAxisSpacing: 8, mainAxisSpacing: 8),
      itemBuilder: (_, i) {
        final day = i - firstWeekday + 1;
        if (day < 1 || day > daysInMonth) return const SizedBox();

        final isSelected = _selectedDateMy != null &&
            _selectedDateMy!.year == month.year &&
            _selectedDateMy!.month == month.month &&
            _selectedDateMy!.day == day;
        
        final bookingsForDay = bookingsByDayMy[day];
        final isHoliday = bookingsForDay?.any((b) => b['status'] == 'HOLIDAY') ?? false;
        final isApproved = bookingsForDay?.any((b) => b['status'] == 'APPROVED') ?? false;
        final isPending = bookingsForDay?.any((b) => b['status'] == 'PENDING') ?? false;
        final isComplete = bookingsForDay?.any((b) => b['status'] == 'COMPLETE') ?? false;
        final isRejected = bookingsForDay?.any((b) => b['status'] == 'REJECTED') ?? false;

        Color borderColor = kBorder;
        if (isSelected) {
          borderColor = kPrimaryDark;
        } else if (isHoliday || isRejected) {
          borderColor = kWarning;
        } else if (isApproved || isPending || isComplete) {
          borderColor = isApproved ? kMyBookingApproved : isPending ? kPending : kComplete;
        }
        
        double borderWidth = (isSelected || isHoliday || isRejected || isApproved || isPending || isComplete) ? 2.0 : 1.25;

        return GestureDetector(
          onTap: () => _onDateTappedMy(month, day),
          child: Container(
            decoration: BoxDecoration(
              color: isSelected ? kPrimaryDark : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: borderColor, width: borderWidth),
            ),
            alignment: Alignment.center,
            child: Text('$day', style: TextStyle(color: isSelected ? Colors.white : const Color(0xFF2E3A59), fontWeight: FontWeight.w700)),
          ),
        );
      },
    );
  }

  Widget _buildMyCalendarDetails() {
    if (_selectedDateMy == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Column(
        children: [
          Text(
            '${_selectedDateMy?.day}/${_selectedDateMy?.month}/${_selectedDateMy?.year}',
            style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2E3A59), fontSize: 16),
          ),
          const SizedBox(height: 10),
          if (_bookingsForSelectedDateMy != null && _bookingsForSelectedDateMy!.isNotEmpty)
            ..._bookingsForSelectedDateMy!.map((b) => GestureDetector(
                  onTap: () => _navigateToBookingDetails(b),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: kBorder),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(b['plate'] ?? b['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              const SizedBox(height: 6),
                              Text(b['vehicle'] ?? '', style: const TextStyle(fontWeight: FontWeight.w600)),
                              const SizedBox(height: 6),
                              if((b['pickupDate'] as String?)?.isNotEmpty ?? false)
                                Text(
                                  '${_formatTime(b['pickupDate'])} - ${_formatTime(b['returnDate'])}',
                                  style: const TextStyle(color: Colors.black87),
                                ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: _statusColorMyCalendar(b['status'] ?? ''),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Text(b['status'] ?? '', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),
                ))
          else
            const Text('No bookings for this date', style: TextStyle(color: Colors.black54)),
        ],
      ),
    );
  }
}