import 'package:flutter/material.dart';
// Import the rating bar package
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:ibooking/Vcalendar';
import 'package:ibooking/dashboard.dart';
import 'package:ibooking/Vbooking.dart';

// --- Brand Guideline Colors (Refined) ---
const Color kPrimaryColor = Color(0xFF007DC5);       // PERKESO's primary blue
const Color kPrimaryDarkColor = Color.fromARGB(255, 24, 42, 94); // Dark blue for containers
const Color kBackgroundColor = Color(0xFFF5F5F5);   // Standard light gray background

// --- Status & Semantic Colors ---
const Color kApproved = Color(0xFF007DC5);     // Blue (matches primary)
const Color kPending = Color(0xFFF39F21);     // Mustard yellow
const Color kWarning = Color(0xFFA82525);     // Red (for rejected/canceled/errors)
const Color kComplete = Color(0xFF2ECC71);    // Green for complete status
const Color kBorder = Color(0xFFCFD6DE);

// Helper functions remain unchanged
String _formatDateTime(String? dt) {
  if (dt == null || dt.isEmpty) return 'N/A';
  try {
    final d = DateTime.parse(dt);
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year} ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  } catch (_) {
    return dt ?? 'N/A';
  }
}

String _formatTime(String? dt) {
  if (dt == null || dt.isEmpty) return '';
  try {
    final d = DateTime.parse(dt);
    return '${d.hour.toString().padLeft(2, "0")}:${d.minute.toString().padLeft(2, "0")}';
  } catch (_) {
    return dt ?? '';
  }
}

Color _statusColor(String status) {
  switch (status) {
    case 'PENDING':
      return kPending;
    case 'APPROVED':
      return kApproved;
    case 'HOLIDAY':
      return kWarning;
    case 'COMPLETE':
      return kComplete;
    case 'REJECTED':
      return kWarning;
    case 'CANCELED':
      return kWarning;
    default:
      return Colors.grey;
  }
}

// =========================================================================
// BOOKING DETAILS PAGE (REFINED WITH CONDITIONAL BOOKING ID)
// =========================================================================
class BookingDetailsPage extends StatelessWidget {
  final Map<String, dynamic> booking;
  const BookingDetailsPage({super.key, required this.booking});

  Widget _buildInfoRow(String title, String? value, {Color valueColor = const Color(0xFF2E3A59)}) {
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
            style: TextStyle(
              fontSize: 16,
              color: valueColor,
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
        color: _statusColor(status),
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
              style: TextButton.styleFrom(foregroundColor: kWarning),
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
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showFeedbackDialog(BuildContext context) async {
    double _rating = 3.0;
    final TextEditingController _feedbackController = TextEditingController();

    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Feedback'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('How was the driver?', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Center(
                      child: RatingBar.builder(
                        initialRating: _rating,
                        minRating: 1,
                        direction: Axis.horizontal,
                        itemCount: 5,
                        itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                        itemBuilder: (context, _) => const Icon(Icons.star, color: kPending),
                        onRatingUpdate: (rating) {
                          setState(() {
                            _rating = rating;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _feedbackController,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        hintText: 'Add your comments here...',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: kPrimaryColor),
              onPressed: () {
                final feedbackText = _feedbackController.text;
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Feedback submitted: $_rating stars. Comment: $feedbackText')),
                );
              },
              child: const Text('Submit', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showComplaintDialog(BuildContext context) async {
    String? _selectedCategory;
    double _severity = 1.0;
    final TextEditingController _complaintController = TextEditingController();
    final List<String> categories = ['Driver Behavior', 'Vehicle Condition', 'Punctuality', 'Other'];

    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('File a Complaint'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Complaint Category *', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8.0,
                      children: categories.map((category) {
                        return ChoiceChip(
                          label: Text(category),
                          selected: _selectedCategory == category,
                          onSelected: (selected) {
                            setState(() {
                              _selectedCategory = selected ? category : null;
                            });
                          },
                          selectedColor: kPrimaryColor,
                          labelStyle: TextStyle(
                            color: _selectedCategory == category ? Colors.white : Colors.black,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                    const Text('Severity Level', style: TextStyle(fontWeight: FontWeight.bold)),
                    Slider(
                      value: _severity,
                      min: 0,
                      max: 2,
                      divisions: 2,
                      label: _severity == 0 ? 'Minor' : (_severity == 1 ? 'Moderate' : 'Urgent'),
                      activeColor: _severity == 2 ? kWarning : (_severity == 1 ? kPending : kComplete),
                      onChanged: (value) {
                        setState(() {
                          _severity = value;
                        });
                      },
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _complaintController,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        hintText: 'Please describe the issue...',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: kWarning),
              onPressed: () {
                if (_selectedCategory == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please select a complaint category.')),
                  );
                  return;
                }
                final complaintText = _complaintController.text;
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Complaint filed for $_selectedCategory. Details: $complaintText')),
                );
              },
              child: const Text('Submit', style: TextStyle(color: Colors.white)),
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
    } else if (status == 'COMPLETE') {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => _showFeedbackDialog(context),
              style: OutlinedButton.styleFrom(
                foregroundColor: kComplete,
                side: BorderSide(color: kComplete),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Add Feedback'),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _showComplaintDialog(context),
              icon: const Icon(Icons.warning_amber_rounded, color: Colors.white),
              label: const Text('Complain', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: kWarning,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
        ],
      );
    }
    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    // MODIFIED: Store status in a variable for easy access
    final String status = booking['status'] ?? 'UNKNOWN';

    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        backgroundColor: kPrimaryColor,
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
                  child: _buildStatusTag(status),
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
                    const Text('Vehicle Booking Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: kPrimaryColor)),
                    const SizedBox(height: 16),
                    
                    // --- MODIFIED: Conditionally show Booking ID ---
                    if (status == 'APPROVED' || status == 'COMPLETE')
                      _buildInfoRow('Booking ID', booking['id'] ?? 'N/A'),
                      
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
                    if (status == 'REJECTED' && booking['rejectionReason'] != null)
                      _buildInfoRow('Rejection Reason', booking['rejectionReason'], valueColor: kWarning),
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
// MY BOOKING PAGE (REMAINS UNCHANGED)
// =========================================================================
class MyBookingPage extends StatefulWidget {
  const MyBookingPage({super.key});
  @override
  State<MyBookingPage> createState() => _MyBookingPageState();
}

class _MyBookingPageState extends State<MyBookingPage> {
  final PageController _pageController = PageController(initialPage: 120);
  DateTime _baseMonth = DateTime(DateTime.now().year, DateTime.now().month, 1);

  final List<Map<String, dynamic>> _bookings = [
    {'id': 'BK-001', 'vehicle': 'Car', 'plate': 'WPC1234', 'status': 'PENDING', 'pickupDate': '2025-10-05 10:00', 'returnDate': '2025-10-05 14:00', 'model': 'Toyota Vios', 'pax': 2, 'requireDriver': true, 'destination': 'Kuala Lumpur Convention Centre', 'pickupLocation': 'PERKESO JALAN AMPANG', 'returnLocation': 'PERKESO JALAN AMPANG', 'purpose': 'Official meeting with stakeholders.', 'uploadedDocName': 'meeting_req.pdf'},
    {'id': 'BK-002', 'vehicle': 'Van', 'plate': 'VAN9988', 'status': 'APPROVED', 'pickupDate': '2025-10-09 14:00', 'returnDate': '2025-10-09 17:00', 'model': 'Toyota Hiace', 'pax': 5, 'requireDriver': false, 'destination': 'Klang Valley Site A', 'pickupLocation': 'PERKESO JALAN AMPANG', 'returnLocation': 'Klang Valley Site A', 'purpose': 'Site inspection and survey.', 'uploadedDocName': null},
    {'id': 'BK-003', 'vehicle': 'Bus', 'plate': 'BUS1122', 'status': 'APPROVED', 'pickupDate': '2025-10-14 09:00', 'returnDate': '2025-10-14 13:00', 'model': 'Isuzu Bus', 'pax': 20, 'requireDriver': true, 'destination': 'Penang Bridge', 'pickupLocation': 'PERKESO JALAN AMPANG', 'returnLocation': 'PERKESO JALAN AMPANG', 'purpose': 'Outstation team building trip.', 'uploadedDocName': 'approval_letter.pdf'},
    {'id': 'BK-004', 'vehicle': 'Car', 'plate': 'CAR7788', 'status': 'PENDING', 'pickupDate': '2025-10-14 14:00', 'returnDate': '2025-10-14 16:00', 'model': 'Proton Persona', 'pax': 1, 'requireDriver': false, 'destination': 'Putrajaya Office', 'pickupLocation': 'Putrajaya Office', 'returnLocation': 'Putrajaya Office', 'purpose': 'Urgent document delivery.', 'uploadedDocName': null},
    {'id': 'BK-005', 'vehicle': '', 'plate': '', 'status': 'HOLIDAY', 'pickupDate': '2025-10-25 00:00', 'returnDate': '2025-10-25 00:00', 'name': 'PUBLIC HOLIDAY', 'model': null, 'pax': 0, 'requireDriver': false, 'destination': null, 'pickupLocation': null, 'returnLocation': null, 'purpose': null, 'uploadedDocName': null},
    {'id': 'BK-006', 'vehicle': 'Car', 'plate': 'CAR1234', 'status': 'COMPLETE', 'pickupDate': '2025-10-20 09:00', 'returnDate': '2025-10-20 12:00', 'model': 'Toyota Vios', 'pax': 3, 'requireDriver': false, 'destination': 'Bandar Sunway', 'pickupLocation': 'PERKESO JALAN AMPANG', 'returnLocation': 'PERKESO JALAN AMPANG', 'purpose': 'Client visit for project handover.', 'uploadedDocName': null},
    {'id': 'BK-007', 'vehicle': 'Car', 'plate': 'CAR6677', 'status': 'REJECTED', 'pickupDate': '2025-10-22 10:00', 'returnDate': '2025-10-22 14:00', 'model': 'Proton Persona', 'pax': 2, 'requireDriver': true, 'destination': 'Shah Alam Factory', 'pickupLocation': 'PERKESO JALAN AMPANG', 'returnLocation': 'PERKESO JALAN AMPANG', 'purpose': 'Machine inspection.', 'uploadedDocName': 'inspection_list.pdf', 'rejectionReason': 'Vehicle unavailable due to scheduled maintenance.'},
  ];

  final Map<int, List<Map<String, dynamic>>> bookingsByDay = {};
  DateTime _monthForPage(int page) {
    final offset = page - 120;
    return DateTime(_baseMonth.year, _baseMonth.month + offset, 1);
  }

  DateTime? _selectedDate;
  List<Map<String, dynamic>>? _bookingsForSelectedDate;

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
      } catch (_) {}
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

  void _navigateToBookingDetails(Map<String, dynamic> booking) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BookingDetailsPage(booking: booking),
      ),
    );
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
            onPressed: () => Navigator.pop(context)),
        title: const Text('My Booking', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        actions: [IconButton(icon: const Icon(Icons.home, color: Colors.white), onPressed: _navigateToDashboard)],
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
              if (_selectedDate != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Text(
                          '${_selectedDate?.day}/${_selectedDate?.month}/${_selectedDate?.year}',
                          style: const TextStyle(fontWeight: FontWeight.bold, color: kPrimaryDarkColor, fontSize: 16),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Builder(builder: (_) {
                        if (_bookingsForSelectedDate != null && _bookingsForSelectedDate!.isNotEmpty) {
                          return Column(
                            children: _bookingsForSelectedDate!.map((b) => Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: GestureDetector(
                                    onTap: () => _navigateToBookingDetails(b),
                                    child: Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(color: kBorder)),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                if ((b['plate'] ?? '').isNotEmpty)
                                                  Text(b['plate']!,
                                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                                const SizedBox(height: 6),
                                                Text(b['vehicle'] ?? b['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.w600)),
                                                const SizedBox(height: 6),
                                                if ((b['status'] ?? '') != 'HOLIDAY')
                                                  Text(
                                                      '${_formatTime(b['pickupDate'])} - ${_formatTime(b['returnDate'])}',
                                                      style: const TextStyle(color: Colors.black87)),
                                                if (b['status'] == 'REJECTED' && b['rejectionReason'] != null) ...[
                                                  const SizedBox(height: 6),
                                                  Text(
                                                    'Reason: ${b['rejectionReason']}',
                                                    style: const TextStyle(color: kWarning, fontSize: 12),
                                                  ),
                                                ],
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                            decoration: BoxDecoration(
                                                color: _statusColor(b['status'] ?? ''), borderRadius: BorderRadius.circular(14)),
                                            child: Text(b['status'] ?? '',
                                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                )).toList(),
                          );
                        }
                        return const Center(child: Text('No bookings for this date', style: TextStyle(color: Colors.black54)));
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
            Navigator.of(context).push(MaterialPageRoute(builder: (_) => const VCalendarPage()));
          } else if (i == 1) {
            Navigator.of(context).push(MaterialPageRoute(builder: (_) => const VBookingPage()));
          }
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: kPrimaryColor,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.grid_view_outlined), label: 'Summary'),
          BottomNavigationBarItem(icon: Icon(Icons.add), label: 'Book Vehicle'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today_outlined), label: 'My Bookings'),
        ],
      ),
    );
  }

  static const _monthNames = <String>[
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];

  Widget _monthHeader(DateTime month) {
    final title = '${_monthNames[month.month - 1]} ${month.year}';
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          color: kPrimaryColor,
          onPressed: () {
            if (_pageController.hasClients) {
              _pageController.previousPage(duration: const Duration(milliseconds: 200), curve: Curves.easeOut);
            }
          }),
      Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: kPrimaryDarkColor)),
      IconButton(
          icon: const Icon(Icons.arrow_forward_ios_rounded, size: 18),
          color: kPrimaryColor,
          onPressed: () {
            if (_pageController.hasClients) {
              _pageController.nextPage(duration: const Duration(milliseconds: 200), curve: Curves.easeOut);
            }
          }),
    ]);
  }

  Widget _weekHeader() {
    const days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: days
            .map((d) => Expanded(
                child: Center(
                    child: Text(d,
                        style: const TextStyle(
                            color: Color(0xFF8B97A6), fontWeight: FontWeight.bold, fontSize: 13)))))
            .toList());
  }

  Widget _monthGrid(DateTime month) {
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
          final isSelected =
              _selectedDate != null && _selectedDate!.year == month.year && _selectedDate!.month == month.month && _selectedDate!.day == day;
          final bookingsForDay = bookingsByDay[day];
          final isHoliday = bookingsForDay?.any((b) => (b['status'] ?? '') == 'HOLIDAY') ?? false;
          final isApproved = bookingsForDay?.any((b) => (b['status'] ?? '') == 'APPROVED') ?? false;
          final isPending = bookingsForDay?.any((b) => (b['status'] ?? '') == 'PENDING') ?? false;
          final isComplete = bookingsForDay?.any((b) => (b['status'] ?? '') == 'COMPLETE') ?? false;
          final isRejected = bookingsForDay?.any((b) => (b['status'] ?? '') == 'REJECTED') ?? false;
          Color backgroundColor = Colors.transparent;
          Color borderColor = kBorder;
          double borderWidth = 1.25;
          Color textColor = kPrimaryDarkColor;
          if (isSelected) {
            backgroundColor = kPrimaryColor;
            borderColor = kPrimaryColor;
            borderWidth = 1.25;
            textColor = Colors.white;
          } else if (isHoliday) {
            borderColor = kWarning;
            borderWidth = 2.6;
          } else if (isApproved || isPending || isComplete) {
            borderColor = isApproved ? kApproved : isPending ? kPending : kComplete;
            borderWidth = 2.6;
          } else if (isRejected) {
            borderColor = kWarning;
            borderWidth = 2.6;
          }
          return GestureDetector(
              onTap: () => _onDateTapped(month, day),
              child: Container(
                  decoration: BoxDecoration(
                      color: backgroundColor,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: borderColor, width: borderWidth)),
                  alignment: Alignment.center,
                  child: Text('$day', style: TextStyle(color: textColor, fontWeight: FontWeight.w700))));
        });
  }

  double _calendarHeightForPage(BuildContext context) {
    final month = _monthForPage(_pageController.hasClients ? _pageController.page?.round() ?? 120 : 120);
    final daysInMonth = DateUtils.getDaysInMonth(month.year, month.month);
    final firstWeekday = DateTime(month.year, month.month, 1).weekday % 7;
    final rows = ((firstWeekday + daysInMonth + 6) ~/ 7);
    final screenW = MediaQuery.of(context).size.width;
    final availableWidth = screenW - 48;
    final totalCrossSpacing = 8.0 * (7 - 1);
    final cellWidth = (availableWidth - totalCrossSpacing) / 7.0;
    final cellHeight = cellWidth * 0.95;
    final headerHeight = 44.0;
    final weekHeaderHeight = 28.0;
    final verticalGaps = 8.0 + 8.0;
    final gridSpacing = 8.0 * (rows > 0 ? (rows - 1) : 0);
    final containerVerticalPadding = 16.0 + 20.0;
    final totalHeight = headerHeight + weekHeaderHeight + verticalGaps + (rows * cellHeight) + gridSpacing + containerVerticalPadding + 8.0;
    return totalHeight;
  }
}