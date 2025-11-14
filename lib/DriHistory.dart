import 'package:flutter/material.dart';
import 'package:ibooking/DriBookingDetail.dart'; // [NEW] Import the driver-specific detail page
import 'package:ibooking/DriDash.dart'; 
import 'package:ibooking/DriBookingList.dart'; // Import to navigate back and reuse constants

// --- Brand Guideline Colors (from DriBookingList.dart / reference) ---
const Color kPrimaryColor = Color(0xFF007DC5);       // PERKESO's primary blue
const Color kPrimaryDarkColor = Color.fromARGB(255, 24, 42, 94); // Dark blue for text/headers
const Color kBackgroundColor = Color(0xFFF5F5F5);   // Standard light gray background
const Color kAssignedColor = Color(0xFF007DC5);     // Blue (matches primary, for Assigned)
const Color kCompletedColor = Color(0xFF28a745);    // Green (for Complete)
const Color kBorder = Color(0xFFCFD6DE);
const Color kHoliday = Color(0xFFE74C3C);           // Red for holidays (if needed, though not used in coloring)

// Centralized helper function to determine status color
Color _statusColor(String status) {
  switch (status) {
    case 'Assigned':
      return kAssignedColor;
    case 'Completed':
      return kCompletedColor;
    case 'HOLIDAY':
      return kHoliday; 
    default:
      return Colors.grey;
  }
}

// Function to parse the simple date string "28 Oct 2025 (Tue) • 02:00 PM" into a DateTime
DateTime? _parseDriverTripDate(String? dtString) {
  if (dtString == null || dtString.isEmpty) return null;
  
  try {
    final parts = dtString.split('•');
    if (parts.length != 2) return null;

    final datePart = parts[0].trim().split(' (')[0]; 
    final timePart = parts[1].trim(); 
    
    final timeParts = timePart.split(' ');
    if (timeParts.length != 2) return null;
    
    final timeStr = timeParts[0]; 
    final ampm = timeParts[1]; 
    final hourMinute = timeStr.split(':');
    if (hourMinute.length != 2) return null;

    int hour = int.parse(hourMinute[0]);
    int minute = int.parse(hourMinute[1]);

    if (ampm.toUpperCase() == 'PM' && hour < 12) {
      hour += 12;
    } else if (ampm.toUpperCase() == 'AM' && hour == 12) {
      hour = 0; 
    }
    
    final dateComponents = datePart.split(' '); 
    final day = int.parse(dateComponents[0]);
    final year = int.parse(dateComponents[2]);
    final monthMap = {
      'Jan': 1, 'Feb': 2, 'Mar': 3, 'Apr': 4, 'May': 5, 'Jun': 6,
      'Jul': 7, 'Aug': 8, 'Sep': 9, 'Oct': 10, 'Nov': 11, 'Dec': 12
    };
    final month = monthMap[dateComponents[1]] ?? 1;

    return DateTime(year, month, day, hour, minute);

  } catch (_) {
    return null; 
  }
}

// Simple time formatter for the list
String _formatTime(DateTime? dt) {
  if (dt == null) return '';
  // Use 12-hour format with AM/PM
  final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
  final minute = dt.minute.toString().padLeft(2, "0");
  final ampm = dt.hour >= 12 ? 'PM' : 'AM';
  return '$hour:$minute $ampm';
}


// The main page for Driver's History
class DriHistoryPage extends StatefulWidget {
  const DriHistoryPage({super.key}); 

  @override
  State<DriHistoryPage> createState() => _DriHistoryPageState();
}

class _DriHistoryPageState extends State<DriHistoryPage> {
  
  // ADDED: More dummy data for the driver's trips for better history demonstration
  final List<Map<String, dynamic>> _localDriverTrips = [
    {
      'id': 1, 'bookingId': 'T1001', 'requester': 'Siti Aisyah', 'department': 'Human Resources', 
      'model': 'Honda HRV', 'plate': 'HRV 2023', 'pickupDate': '28 Oct 2025 (Tue) • 02:00 PM', 
      'returnDate': '28 Oct 2025 (Tue) • 04:00 PM', 'destination': 'Putrajaya Convention Centre', 
      'pickupLocation': 'PERKESO HQ, Jalan Ampang', 'returnLocation': 'PERKESO HQ, Jalan Ampang',
      'requesterPhone': '0123456789', 
      'purpose': 'Official Meeting', 'status': 'Assigned', // Upcoming Trip
      'approvedBy': 'Encik Amir', 'approvalDateTime': '25 Oct 2025 10:30 AM', 'driverName': 'Bala'
    },
    {
      'id': 2, 'bookingId': 'T1002', 'requester': 'Tan Chee Keong', 'department': 'Finance', 
      'model': 'Toyota Vellfire', 'plate': 'WPC 1234', 'pickupDate': '01 Nov 2025 (Sat) • 10:00 AM', 
      'returnDate': '01 Nov 2025 (Sat) • 05:00 PM', 'destination': 'Klang Branch Office', 
      'pickupLocation': 'PERKESO HQ, Jalan Ampang', 'returnLocation': 'PERKESO HQ, Jalan Ampang',
      'requesterPhone': '0198765432', 
      'purpose': 'Document Delivery', 'status': 'Assigned', // Upcoming Trip
      'approvedBy': 'Encik Amir', 'approvalDateTime': '30 Oct 2025 09:00 AM', 'driverName': 'Bala'
    },
    {
      'id': 3, 'bookingId': 'T1003', 'requester': 'Lina Teoh', 'department': 'Marketing', 
      'model': 'Proton X70', 'plate': 'X70 8899', 'pickupDate': '29 Oct 2025 (Wed) • 09:00 AM', 
      'returnDate': '29 Oct 2025 (Wed) • 01:00 PM', 'destination': 'Petaling Jaya Client Office', 
      'pickupLocation': 'PERKESO HQ, Jalan Ampang', 'returnLocation': 'PERKESO HQ, Jalan Ampang',
      'requesterPhone': '01155554444', 
      'purpose': 'Client Visit', 'status': 'Completed', // Past Trip
      'approvedBy': 'Encik Razak', 'approvalDateTime': '27 Oct 2025 09:00 AM', 'driverName': 'Bala'
    },
    {
      'id': 4, 'bookingId': 'T0901', 'requester': 'Dr. Chong', 'department': 'R&D', 
      'model': 'Toyota Camry', 'plate': 'CAM 7777', 'pickupDate': '15 Oct 2025 (Wed) • 08:30 AM', 
      'returnDate': '15 Oct 2025 (Wed) • 12:30 PM', 'destination': 'University Lab', 
      'pickupLocation': 'PERKESO HQ, Jalan Ampang', 'returnLocation': 'PERKESO HQ, Jalan Ampang',
      'requesterPhone': '0101112222', 
      'purpose': 'Research Collaboration', 'status': 'Completed', // Past Trip
      'approvedBy': 'Encik Razak', 'approvalDateTime': '10 Oct 2025 04:00 PM', 'driverName': 'Bala'
    },
    {
      'id': 5, 'bookingId': 'T1110', 'requester': 'Zainal Abidin', 'department': 'Maintenance', 
      'model': 'Isuzu D-Max', 'plate': 'DMZ 3333', 'pickupDate': '14 Nov 2025 (Fri) • 10:00 AM', 
      'returnDate': '14 Nov 2025 (Fri) • 01:00 PM', 'destination': 'Subang Depot', 
      'pickupLocation': 'PERKESO HQ, Jalan Ampang', 'returnLocation': 'PERKESO HQ, Jalan Ampang',
      'requesterPhone': '0171234567', 
      'purpose': 'Vehicle Service', 'status': 'Completed', // Current Day Trip (for testing)
      'approvedBy': 'Encik Amir', 'approvalDateTime': '13 Nov 2025 11:00 AM', 'driverName': 'Bala'
    },
  ];
  
  final PageController _pageController = PageController(initialPage: 120);
  final DateTime _baseMonth = DateTime(DateTime.now().year, DateTime.now().month, 1);
  static const _monthNames = <String>[
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];

  DateTime? _selectedDate;
  List<Map<String, dynamic>>? _bookingsForSelectedDate;
  final Map<int, List<Map<String, dynamic>>> bookingsByDay = {};

  @override
  void initState() {
    super.initState();
    _rebuildCalendarBookingsMap();
  }
  
  // Maps all driver trips (Assigned and Completed) to their pickup day for the calendar dots
  void _rebuildCalendarBookingsMap() {
    bookingsByDay.clear();
    for (final b in _localDriverTrips) {
      try {
        final pickup = _parseDriverTripDate(b['pickupDate'] as String?);
        if (pickup != null) {
          final day = pickup.day;
          bookingsByDay.putIfAbsent(day, () => []).add(b);
        }
      } catch (_) {}
    }
    // Force initial selection if today has a booking
    final today = DateTime.now();
    _onDateTapped(today, today.day);
  }

  DateTime _monthForPage(int page) => DateTime(_baseMonth.year, _baseMonth.month + (page - 120), 1);

  void _onDateTapped(DateTime month, int day) {
    setState(() {
      _selectedDate = DateTime(month.year, month.month, day);
      
      final currentMonthTrips = _localDriverTrips.where((trip) {
        final date = _parseDriverTripDate(trip['pickupDate'] as String?);
        return date != null && date.year == month.year && date.month == month.month;
      }).toList();

      _bookingsForSelectedDate = currentMonthTrips.where((trip) {
        final date = _parseDriverTripDate(trip['pickupDate'] as String?);
        return date != null && date.day == day;
      }).toList();
      
    });
  }

  void _navigateToBookingDetails(Map<String, dynamic> booking) {
    // CRITICAL FIX: Navigate to the new DriBookingDetailPage
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DriBookingDetailPage(
          bookingDetails: booking, 
        ),
      ),
    );
  }

  // Navigation logic for the Bottom Nav Bar
  void _onTabTapped(int index) {
    if (index == 2) return; // Already on History page
    
    if (index == 0) { // Assigned Trip
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const DriBookingListPage()));
    } else if (index == 1) { // Home
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const DriDash()));
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        backgroundColor: kPrimaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('My Trip History', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
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
                  height: _calendarHeightForPage(context),
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (pageIndex) {
                      final month = _monthForPage(pageIndex);
                      setState(() {
                         // Set selected date to the 1st of the month when changing page
                         _selectedDate = DateTime(month.year, month.month, 1); 
                         _onDateTapped(month, 1); 
                      });
                    },
                    itemBuilder: (context, page) {
                      final month = _monthForPage(page);
                      return Column(
                        children: [
                          _monthHeader(month),
                          const SizedBox(height: 8),
                          _weekHeader(),
                          const SizedBox(height: 8),
                          Expanded(
                            child: _monthGrid(month),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
              // PERKESO JALAN AMPANG header
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(color: const Color(0xFFE9EDF3), borderRadius: BorderRadius.circular(8)),
                alignment: Alignment.center,
                child: const Text('PERKESO JALAN AMPANG', style: TextStyle(color: kPrimaryDarkColor, fontWeight: FontWeight.bold, letterSpacing: 0.7)),
              ),
              _buildCalendarDetails(), 
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2, 
        onTap: _onTabTapped,
        type: BottomNavigationBarType.fixed,
        backgroundColor: kPrimaryColor,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.navigation_rounded),
            label: 'Assigned Trip',
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

  Widget _monthHeader(DateTime month) {
    final title = '${_monthNames[month.month - 1]} ${month.year}';
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          color: kPrimaryColor,
          onPressed: () {
            if (_pageController.hasClients) {
              _pageController.previousPage(duration: const Duration(milliseconds: 200), curve: Curves.easeOut);
            }
          },
        ),
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: kPrimaryDarkColor)),
        IconButton(
          icon: const Icon(Icons.arrow_forward_ios_rounded, size: 18),
          color: kPrimaryColor,
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
  
  Widget _monthGrid(DateTime month) {
    final daysInMonth = DateUtils.getDaysInMonth(month.year, month.month);
    final firstWeekday = DateTime(month.year, month.month, 1).weekday % 7;
    final totalCells = ((firstWeekday + daysInMonth + 6) ~/ 7) * 7;
    
    // Filter bookings for the current month/year
    final Map<int, List<Map<String, dynamic>>> currentMonthBookings = {};
    for (final trip in _localDriverTrips) {
        final date = _parseDriverTripDate(trip['pickupDate'] as String?);
        if (date != null && date.year == month.year && date.month == month.month) {
            currentMonthBookings.putIfAbsent(date.day, () => []).add(trip);
        }
    }
    
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: totalCells,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7, crossAxisSpacing: 8, mainAxisSpacing: 8),
      itemBuilder: (_, i) {
        final day = i - firstWeekday + 1;
        if (day < 1 || day > daysInMonth) return const SizedBox();

        final isSelected = _selectedDate != null &&
            _selectedDate!.year == month.year &&
            _selectedDate!.month == month.month &&
            _selectedDate!.day == day;
        
        final bookingsForDay = currentMonthBookings[day];
        
        // Check for Completed first, then Assigned
        final isCompleted = bookingsForDay?.any((b) => b['status'] == 'Completed') ?? false;
        final isAssigned = bookingsForDay?.any((b) => b['status'] == 'Assigned') ?? false;

        Color backgroundColor = Colors.transparent;
        Color borderColor = kBorder;
        double borderWidth = 1.25;
        Color textColor = kPrimaryDarkColor;

        // Calendar border logic for status
        if (isSelected) {
          backgroundColor = kPrimaryColor;
          borderColor = kPrimaryColor;
          textColor = Colors.white;
        } else if (isCompleted) {
          // Green border for Completed
          borderColor = kCompletedColor;
          borderWidth = 2.6;
        } else if (isAssigned) {
          // Blue border for Assigned
          borderColor = kAssignedColor;
          borderWidth = 2.6;
        }

        return GestureDetector(
          onTap: () => _onDateTapped(month, day),
          child: Container(
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: borderColor, width: borderWidth),
            ),
            alignment: Alignment.center,
            child: Text('$day', style: TextStyle(color: textColor, fontWeight: FontWeight.w700)),
          ),
        );
      },
    );
  }
  
  Widget _buildCalendarDetails() {
    if (_selectedDate == null) return const SizedBox.shrink();
    
    final selectedDateStr = '${_selectedDate!.day.toString().padLeft(2, '0')}/${_selectedDate!.month.toString().padLeft(2, '0')}/${_selectedDate!.year}';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // MODIFICATION: Centered the date text
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                selectedDateStr,
                style: const TextStyle(fontWeight: FontWeight.bold, color: kPrimaryDarkColor, fontSize: 16),
              ),
            ),
          ),
          const SizedBox(height: 10),
          if (_bookingsForSelectedDate != null && _bookingsForSelectedDate!.isNotEmpty)
            ..._bookingsForSelectedDate!.map((b) {
                final pickupDate = _parseDriverTripDate(b['pickupDate'] as String?);
                final returnDate = _parseDriverTripDate(b['returnDate'] as String?);
                final timeRange = pickupDate != null && returnDate != null
                  ? '${_formatTime(pickupDate)} - ${_formatTime(returnDate)}'
                  : 'N/A';
                  
                final status = b['status'] ?? '';
                final model = b['model'] ?? 'N/A';
                final plate = b['plate'] ?? 'N/A';
                final destination = b['destination'] ?? 'N/A';
                
                return GestureDetector(
                  onTap: () => _navigateToBookingDetails(b),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      // The list item border also uses the status color
                      border: Border.all(color: _statusColor(status).withOpacity(0.5), width: 1.5), 
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('$model ($plate)', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: kPrimaryColor)),
                              const SizedBox(height: 6),
                              Text(destination, style: const TextStyle(fontWeight: FontWeight.w500)),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  const Icon(Icons.access_time_filled, size: 14, color: Colors.black54),
                                  const SizedBox(width: 4),
                                  Text(timeRange, style: const TextStyle(color: Colors.black87)),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: _statusColor(status),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Text(status.toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                        ),
                      ],
                    ),
                  ),
                );
            }).toList()
          else
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('No trips found for this date.', style: TextStyle(color: Colors.black54)),
            ),
        ],
      ),
    );
  }
  
  // Reusing the calculation from the reference to ensure proper calendar sizing
  double _calendarHeightForPage(BuildContext context) {
    // This calculation is an approximation for proper sizing
    final month = _monthForPage(_pageController.hasClients ? _pageController.page?.round() ?? 120 : 120);
    final daysInMonth = DateUtils.getDaysInMonth(month.year, month.month);
    final firstWeekday = DateTime(month.year, month.month, 1).weekday % 7;
    final rows = ((firstWeekday + daysInMonth + 6) ~/ 7);
    final screenW = MediaQuery.of(context).size.width;
    final availableWidth = screenW - 48; // 12*2 margin + 12*2 padding
    final totalCrossSpacing = 8.0 * (7 - 1);
    final cellWidth = (availableWidth - totalCrossSpacing) / 7.0;
    final cellHeight = cellWidth * 0.95;
    const headerHeight = 44.0;
    const weekHeaderHeight = 28.0;
    const verticalGaps = 8.0 + 8.0;
    final gridSpacing = 8.0 * (rows > 0 ? (rows - 1) : 0);
    
    final totalHeight = headerHeight + weekHeaderHeight + verticalGaps + (rows * cellHeight) + gridSpacing;

    return totalHeight;
  }
