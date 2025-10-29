import 'package:flutter/material.dart';
import 'package:ibooking/Vcalendar';
import 'package:ibooking/dashboard.dart';
import 'package:ibooking/Vbooking.dart';

const Color kPrimaryDark = Color.fromARGB(255, 24, 42, 94); // dark blue
const Color kApproved = Color(0xFF007DC5); // blue (default)
const Color kPending = Color(0xFFF39F21); // mustard yellow
const Color kWarning = Color(0xFFA82525); // red (for rejected/canceled)
const Color kHoliday = Color(0xFFE74C3C); // red for holidays
const Color kComplete = Color(0xFF2ECC71); // green for complete status
const Color kBorder = Color(0xFFCFD6DE);
const Color kGreyBg = Color(0xFFF2F3F7);

class MyBookingPage extends StatefulWidget {
  const MyBookingPage({super.key});

  @override
  State<MyBookingPage> createState() => _MyBookingPageState();
}

class _MyBookingPageState extends State<MyBookingPage> {
  final PageController _pageController = PageController(initialPage: 120);
  DateTime _baseMonth = DateTime(DateTime.now().year, DateTime.now().month, 1);

  // Demo bookings with added "Complete" and "Canceled/Rejected" statuses
  final List<Map<String, String>> _bookings = [
    {'id': '1', 'vehicle': 'Car', 'plate': 'WPC1234', 'status': 'PENDING', 'pickupDate': '2025-10-05 10:00', 'returnDate': '2025-10-05 14:00'},
    {'id': '2', 'vehicle': 'Van', 'plate': 'VAN9988', 'status': 'APPROVED', 'pickupDate': '2025-10-09 14:00', 'returnDate': '2025-10-09 17:00'},
    {'id': '3', 'vehicle': 'Bus', 'plate': 'BUS1122', 'status': 'APPROVED', 'pickupDate': '2025-10-14 09:00', 'returnDate': '2025-10-14 13:00'},
    {'id': '4', 'vehicle': 'Car', 'plate': 'CAR7788', 'status': 'PENDING', 'pickupDate': '2025-10-14 14:00', 'returnDate': '2025-10-14 16:00'},
    {'id': '5', 'vehicle': '', 'plate': '', 'status': 'HOLIDAY', 'pickupDate': '2025-10-25 00:00', 'returnDate': '2025-10-25 00:00', 'name': 'PUBLIC HOLIDAY'},
    {'id': '6', 'vehicle': 'Car', 'plate': 'CAR1234', 'status': 'COMPLETE', 'pickupDate': '2025-10-20 09:00', 'returnDate': '2025-10-20 12:00'}, // Complete status
    {'id': '7', 'vehicle': 'Car', 'plate': 'CAR6677', 'status': 'REJECTED', 'pickupDate': '2025-10-22 10:00', 'returnDate': '2025-10-22 14:00'}, // Rejected status
  ];

  // Map day -> list of bookings for quick lookup (recomputed in init)
  final Map<int, List<Map<String, String>>> bookingsByDay = {};

  DateTime _monthForPage(int page) {
    final offset = page - 120;
    return DateTime(_baseMonth.year, _baseMonth.month + offset, 1);
  }

  DateTime? _selectedDate;
  List<Map<String, String>>? _bookingsForSelectedDate;

  @override
  void initState() {
    super.initState();
    _rebuildBookingsMap();
  }

  void _rebuildBookingsMap() {
    bookingsByDay.clear();
    for (final b in _bookings) {
      try {
        final pickup = DateTime.parse(b['pickupDate']!);
        final day = pickup.day;
        bookingsByDay.putIfAbsent(day, () => []).add(b);
      } catch (_) {
        // ignore parse errors for demo data
      }
    }
  }

  void _onDateTapped(DateTime month, int day) {
    final selectedDate = DateTime(month.year, month.month, day);
    setState(() {
      _selectedDate = selectedDate;
      _bookingsForSelectedDate = bookingsByDay[day];
    });
  }

  void _navigateToDashboard() {
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const DashboardScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kGreyBg,
      appBar: AppBar(
        backgroundColor: kPrimaryDark,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white), onPressed: () => Navigator.pop(context)),
        title: const Text('My Booking', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        actions: [IconButton(icon: const Icon(Icons.home, color: Colors.white), onPressed: _navigateToDashboard)],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Calendar card
              Container(
                margin: const EdgeInsets.all(12),
                padding: const EdgeInsets.fromLTRB(12, 16, 12, 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, 3))],
                ),
                child: SizedBox(
                  height: _calendarHeightForPage(context),
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (_) => setState(() {}),
                    itemBuilder: (context, page) {
                      final month = _monthForPage(page);
                      return Column(
                        children: [
                          _monthHeader(month),
                          const SizedBox(height: 8),
                          _weekHeader(),
                          const SizedBox(height: 8),
                          _monthGrid(month),
                        ],
                      );
                    },
                  ),
                ),
              ),

              // Location strip
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(color: const Color(0xFFE9EDF3), borderRadius: BorderRadius.circular(8)),
                alignment: Alignment.center,
                child: const Text('PERKESO JALAN AMPANG', style: TextStyle(color: Color(0xFF2E3A59), fontWeight: FontWeight.bold, letterSpacing: 0.7)),
              ),

              // Selected date area
              if (_selectedDate != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(child: Text('${_selectedDate?.day}/${_selectedDate?.month}/${_selectedDate?.year}', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2E3A59), fontSize: 16))),
                      const SizedBox(height: 6),
                      Builder(builder: (_) {
                        if (_bookingsForSelectedDate != null && _bookingsForSelectedDate!.isNotEmpty) {
                          return Column(
                            children: _bookingsForSelectedDate!.map((b) => Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: kBorder)),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          if ((b['plate'] ?? '').isNotEmpty) Text(b['plate']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                          const SizedBox(height: 6),
                                          Text(b['vehicle'] ?? '', style: const TextStyle(fontWeight: FontWeight.w600)),
                                          const SizedBox(height: 6),
                                          Text('${_formatTime(b['pickupDate'])} - ${_formatTime(b['returnDate'])}', style: const TextStyle(color: Colors.black87)),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                      decoration: BoxDecoration(color: _statusColor(b['status'] ?? ''), borderRadius: BorderRadius.circular(14)),
                                      child: Text(b['status'] ?? '', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                    ),
                                  ],
                                ),
                              ),
                            )).toList(),
                          );
                        }
                        return const Text('No bookings for this date', style: TextStyle(color: Colors.black54));
                      }),
                    ],
                  ),
                ),

              const SizedBox(height: 24),
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

  // ----- helpers (copied/adapted from Vcalendar) -----
  static const _monthNames = <String>['January','February','March','April','May','June','July','August','September','October','November','December'];

  Widget _monthHeader(DateTime month) {
    final title = '${_monthNames[month.month - 1]} ${month.year}';
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18), color: kPrimaryDark, onPressed: () { if (_pageController.hasClients) _pageController.previousPage(duration: const Duration(milliseconds: 200), curve: Curves.easeOut); else _pageController.jumpToPage((_pageController.initialPage) - 1); }),
      Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2E3A59))),
      IconButton(icon: const Icon(Icons.arrow_forward_ios_rounded, size: 18), color: kPrimaryDark, onPressed: () { if (_pageController.hasClients) _pageController.nextPage(duration: const Duration(milliseconds: 200), curve: Curves.easeOut); else _pageController.jumpToPage((_pageController.initialPage) + 1); }),
    ]);
  }

  Widget _weekHeader() { const days = ['Sun','Mon','Tue','Wed','Thu','Fri','Sat']; return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: days.map((d) => Expanded(child: Center(child: Text(d, style: const TextStyle(color: Color(0xFF8B97A6), fontWeight: FontWeight.bold, fontSize: 13))))).toList()); }

  Widget _monthGrid(DateTime month) {
    final daysInMonth = DateUtils.getDaysInMonth(month.year, month.month);
    final firstWeekday = DateTime(month.year, month.month, 1).weekday % 7; // Sun=0
    final totalCells = ((firstWeekday + daysInMonth + 6) ~/ 7) * 7;
    return GridView.builder(physics: const NeverScrollableScrollPhysics(), shrinkWrap: true, itemCount: totalCells, gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7, crossAxisSpacing: 8, mainAxisSpacing: 8), itemBuilder: (_, i) {
      final day = i - firstWeekday + 1;
      if (day < 1 || day > daysInMonth) return const SizedBox();
      final isSelected = _selectedDate != null && _selectedDate!.year == month.year && _selectedDate!.month == month.month && _selectedDate!.day == day;
      final bookingsForDay = bookingsByDay[day];
      final isHoliday = bookingsForDay != null && bookingsForDay.any((b) => (b['status'] ?? '') == 'HOLIDAY');
      final isApproved = bookingsForDay != null && bookingsForDay.any((b) => (b['status'] ?? '') == 'APPROVED');
      final isPending = bookingsForDay != null && bookingsForDay.any((b) => (b['status'] ?? '') == 'PENDING');
      final isComplete = bookingsForDay != null && bookingsForDay.any((b) => (b['status'] ?? '') == 'COMPLETE');
      final isRejected = bookingsForDay != null && bookingsForDay.any((b) => (b['status'] ?? '') == 'REJECTED');
      Color backgroundColor = Colors.transparent; Color borderColor = kBorder; double borderWidth = 1.25; Color textColor = const Color(0xFF2E3A59);
      if (isSelected) { backgroundColor = kPrimaryDark; borderColor = kPrimaryDark; borderWidth = 1.25; textColor = Colors.white; } else if (isHoliday) { borderColor = kWarning; borderWidth = 2.6; } else if (isApproved || isPending || isComplete) { borderColor = isApproved ? kApproved : isPending ? kPending : kComplete; borderWidth = 2.6; } else if (isRejected) { borderColor = kWarning; borderWidth = 2.6; }
      return GestureDetector(onTap: () => _onDateTapped(month, day), child: Container(decoration: BoxDecoration(color: backgroundColor, borderRadius: BorderRadius.circular(8), border: Border.all(color: borderColor, width: borderWidth)), alignment: Alignment.center, child: Text('$day', style: TextStyle(color: textColor, fontWeight: FontWeight.w700))));
    });
  }

  double _calendarHeightForPage(BuildContext context) {
    final month = _monthForPage(_pageController.hasClients ? _pageController.page?.round() ?? 120 : 120);
    final daysInMonth = DateUtils.getDaysInMonth(month.year, month.month);
    final firstWeekday = DateTime(month.year, month.month, 1).weekday % 7;
    final rows = ((firstWeekday + daysInMonth + 6) ~/ 7);
    final screenW = MediaQuery.of(context).size.width; final availableWidth = screenW - 48; final totalCrossSpacing = 8.0 * (7 - 1); final cellWidth = (availableWidth - totalCrossSpacing) / 7.0; final cellHeight = cellWidth * 0.95;
    final headerHeight = 44.0; final weekHeaderHeight = 28.0; final verticalGaps = 8.0 + 8.0; final gridSpacing = 8.0 * (rows > 0 ? (rows - 1) : 0); final containerVerticalPadding = 16.0 + 20.0; final totalHeight = headerHeight + weekHeaderHeight + verticalGaps + (rows * cellHeight) + gridSpacing + containerVerticalPadding + 8.0; return totalHeight;
  }

  static Color _statusColor(String status) { switch (status) { case 'PENDING': return kPending; case 'APPROVED': return kApproved; case 'HOLIDAY': return kWarning; case 'COMPLETE': return kComplete; case 'REJECTED': return kWarning; default: return Colors.grey; } }

  static String _formatTime(String? dt) { if (dt == null || dt.isEmpty) return ''; try { final d = DateTime.parse(dt); return '${d.hour.toString().padLeft(2, "0")}:${d.minute.toString().padLeft(2, "0")}'; } catch (_) { return dt ?? ''; } }
}
