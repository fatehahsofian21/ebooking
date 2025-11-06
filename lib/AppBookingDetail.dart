// AppBookingDetail.dart

import 'package:flutter/material.dart';
import 'package:ibooking/AppHistory.dart'; // Make sure this page exists

// --- Brand Guideline Colors ---
const Color kPrimaryColor = Color(0xFF007DC5);
const Color kBackgroundColor = Color(0xFFF5F5F5);
const Color kApproveColor = Color(0xFF28a745);
const Color kRejectColor = Color(0xFFdc3545);
const Color kPending = Color(0xFFF39F21);
const Color kWarning = Color(0xFFA82525);
const Color kPrimaryDarkColor = Color.fromARGB(255, 24, 42, 94);
const Color kBorder = Color(0xFFCFD6DE);

// --- Helper function to determine the color of the status tag ---
Color _statusColor(String status) {
  switch (status) {
    case 'PENDING':
      return kPending;
    case 'APPROVED':
      return kPrimaryColor;
    case 'HOLIDAY':
      return kWarning;
    default:
      return Colors.grey;
  }
}

class AppBookingDetailPage extends StatefulWidget {
  const AppBookingDetailPage({super.key});

  @override
  State<AppBookingDetailPage> createState() => _AppBookingDetailPageState();
}

class _AppBookingDetailPageState extends State<AppBookingDetailPage> {
  // --- Dummy data is now defined in the state for access across methods ---
  final Map<String, dynamic> dummyBooking = {
    'requester': 'Nor Fatehah Binti Sofian',
    'model': 'Toyota Vellfire',
    'plate': 'WPC1234',
    'pickupDate': '02 Nov 2025 09:00 AM',
    'returnDate': '02 Nov 2025 11:00 AM',
    'destination': 'Menara TM, Kuala Lumpur',
    'pickupLocation': 'PERKESO HQ, Jalan Ampang',
    'returnLocation': 'PERKESO HQ, Jalan Ampang',
    'pax': 3,
    // --- MODIFIED: Set to false to test the simple approve flow ---
    'requireDriver': true, 
    'purpose': 'Official meeting with Telekom Malaysia for project discussion.',
    'uploadedDocName': 'meeting_invitation.pdf',
  };

  // --- DIALOG: For Rejecting a Booking ---
  Future<void> _showRejectDialog() async {
    final TextEditingController reasonController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Reject Booking'),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: reasonController,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Reason for Rejection',
                hintText: 'e.g., Vehicle unavailable',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Reason cannot be empty.';
                }
                return null;
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: kRejectColor),
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  Navigator.pop(dialogContext);
                  _showConfirmationDialog(
                    title: 'Booking Rejected',
                    content: 'The booking has been successfully rejected.',
                  );
                }
              },
              child: const Text('Submit Rejection', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  // --- DIALOG: For Approving (with driver assignment) ---
  Future<void> _showApproveDialog() async {
    final bool needsDriver = dummyBooking['requireDriver'] == true;

    if (needsDriver) {
      final List<String> drivers = ['Ahmad', 'Bala', 'Chan'];
      String? selectedDriver;
      final formKey = GlobalKey<FormState>();

      await showDialog(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            title: const Text('Assign Driver'),
            content: Form(
              key: formKey,
              child: DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Select a Driver',
                  border: OutlineInputBorder(),
                ),
                items: drivers.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
                onChanged: (value) => selectedDriver = value,
                validator: (value) {
                  if (value == null) return 'Please select a driver.';
                  return null;
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: kApproveColor),
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    Navigator.pop(dialogContext);
                    _showConfirmationDialog(
                      title: 'Booking Approved',
                      content: 'The booking is approved and driver "$selectedDriver" has been assigned.',
                    );
                  }
                },
                child: const Text('Assign & Approve', style: TextStyle(color: Colors.white)),
              ),
            ],
          );
        },
      );
    } else {
      // --- This block will now be executed on "Approve" ---
      _showConfirmationDialog(
        title: 'Booking Approved',
        content: 'The booking has been successfully approved.',
      );
    }
  }

  // --- DIALOG: Final confirmation for both Approve/Reject ---
  Future<void> _showConfirmationDialog({required String title, required String content}) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const AppHistoryPage()),
                (Route<dynamic> route) => false,
              );
            },
            child: const Text('OK'),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const String status = 'PENDING';

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
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month_outlined, color: Colors.white),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => const Dialog(
                  insetPadding: EdgeInsets.all(16),
                  child: SuperCalendarDialogWidget(),
                ),
              );
            },
          ),
        ],
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
                    _buildInfoRow('Requester', dummyBooking['requester']),
                    _buildInfoRow('Vehicle Type', dummyBooking['model']),
                    _buildInfoRow('Plate Number', dummyBooking['plate']),
                    _buildInfoRow('Pick-Up Date & Time', dummyBooking['pickupDate']),
                    _buildInfoRow('Return Date & Time', dummyBooking['returnDate']),
                    _buildInfoRow('Number of Pax', dummyBooking['pax'].toString()),
                    _buildInfoRow('Require Driver', (dummyBooking['requireDriver'] == true) ? 'Yes' : 'No'),
                    _buildInfoRow('Destination', dummyBooking['destination']),
                    _buildInfoRow('Pick-Up Location', dummyBooking['pickupLocation']),
                    _buildInfoRow('Return Location', dummyBooking['returnLocation']),
                    _buildInfoRow('Purpose of Booking', dummyBooking['purpose']),
                    _buildInfoRow('Supported Document', dummyBooking['uploadedDocName']),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.check_circle, size: 18),
                      label: const Text('Approve'),
                      onPressed: _showApproveDialog,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kApproveColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.cancel, size: 18),
                      label: const Text('Reject'),
                      onPressed: _showRejectDialog,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kRejectColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String title, String? value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF8B97A6))),
          const SizedBox(height: 4),
          Text(value ?? 'N/A', style: const TextStyle(fontSize: 16, color: Color(0xFF2E3A59))),
          const Divider(height: 16),
        ],
      ),
    );
  }

  Widget _buildStatusTag(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(color: _statusColor(status), borderRadius: BorderRadius.circular(18)),
      child: Text(status, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 0.8)),
    );
  }
}

// =========================================================================
// WIDGET: The Super Calendar functionality, encapsulated for the dialog
// =========================================================================
class SuperCalendarDialogWidget extends StatefulWidget {
  const SuperCalendarDialogWidget({super.key});

  @override
  State<SuperCalendarDialogWidget> createState() => _SuperCalendarDialogWidgetState();
}

class _SuperCalendarDialogWidgetState extends State<SuperCalendarDialogWidget> {
  final PageController _pageController = PageController(initialPage: 120);
  final DateTime _baseMonth = DateTime(DateTime.now().year, DateTime.now().month, 1);
  static const _monthNames = <String>[
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];

  DateTime? _selectedDateSuper;
  List<Map<String, dynamic>>? _bookingsForSelectedDateSuper;
  
  final Map<int, List<Map<String, dynamic>>> bookingsByDaySuper = {
    5: [
      {
        'requester': 'Shera',
        'department': 'Engineering',
        'model': 'Toyota Vellfire',
        'plate': 'WPC1234',
        'time': '10:00 AM – 3:00 PM',
        'status': 'APPROVED',
        'purpose': 'Client meeting at KL Sentral'
      }
    ],
    21: [
      {
        'requester': 'Aiman',
        'department': 'BST',
        'model': 'Isuzu Bus',
        'plate': 'BNM1234',
        'time': '9:00 AM – 5:00 PM',
        'status': 'APPROVED',
        'purpose': 'Team building event at Port Dickson'
      }
    ],
    25: [
      {'name': 'PUBLIC HOLIDAY', 'status': 'HOLIDAY'}
    ],
  };

  DateTime _monthForPage(int page) => DateTime(_baseMonth.year, _baseMonth.month + (page - 120), 1);

  void _onDateTappedSuper(DateTime month, int day) {
    setState(() {
      _selectedDateSuper = DateTime(month.year, month.month, day);
      _bookingsForSelectedDateSuper = bookingsByDaySuper[day];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: kBackgroundColor,
        borderRadius: BorderRadius.circular(18),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 380,
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
                      Expanded(child: _monthGridSuper(month)),
                    ],
                  );
                },
              ),
            ),
            const Divider(),
            _buildSuperCalendarDetails(),
          ],
        ),
      ),
    );
  }

  Widget _monthHeader(DateTime month) {
    final title = '${_monthNames[month.month - 1]} ${month.year}';
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: kPrimaryColor),
          onPressed: () => _pageController.previousPage(duration: const Duration(milliseconds: 200), curve: Curves.easeOut),
        ),
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: kPrimaryDarkColor)),
        IconButton(
          icon: const Icon(Icons.arrow_forward_ios_rounded, size: 18, color: kPrimaryColor),
          onPressed: () => _pageController.nextPage(duration: const Duration(milliseconds: 200), curve: Curves.easeOut),
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

  Widget _monthGridSuper(DateTime month) {
    final daysInMonth = DateUtils.getDaysInMonth(month.year, month.month);
    final firstWeekday = DateTime(month.year, month.month, 1).weekday % 7;
    final totalCells = ((firstWeekday + daysInMonth + 6) ~/ 7) * 7;
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      itemCount: totalCells,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7, crossAxisSpacing: 8, mainAxisSpacing: 8),
      itemBuilder: (_, i) {
        final day = i - firstWeekday + 1;
        if (day < 1 || day > daysInMonth) return const SizedBox();

        final isSelected = _selectedDateSuper?.day == day && _selectedDateSuper?.month == month.month;
        final bookingsForDay = bookingsByDaySuper[day];
        final isHoliday = bookingsForDay?.any((b) => b['status'] == 'HOLIDAY') ?? false;
        final isApproved = bookingsForDay?.any((b) => b['status'] == 'APPROVED') ?? false;

        Color borderColor = kBorder;
        if (isHoliday) {
          borderColor = kWarning;
        } else if (isApproved) {
          borderColor = kPrimaryColor;
        }
        
        return GestureDetector(
          onTap: () => _onDateTappedSuper(month, day),
          child: Container(
            decoration: BoxDecoration(
              color: isSelected ? kPrimaryColor : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: borderColor, width: isHoliday || isApproved ? 2.0 : 1.0),
            ),
            alignment: Alignment.center,
            child: Text('$day', style: TextStyle(color: isSelected ? Colors.white : kPrimaryDarkColor, fontWeight: FontWeight.w700)),
          ),
        );
      },
    );
  }

  Widget _buildSuperCalendarDetails() {
    if (_selectedDateSuper == null) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(child: Text("Select a date to see details", style: TextStyle(color: Colors.grey))),
      );
    }
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Column(
        children: [
          Text(
            '${_selectedDateSuper?.day}/${_selectedDateSuper?.month}/${_selectedDateSuper?.year}',
            style: const TextStyle(fontWeight: FontWeight.bold, color: kPrimaryDarkColor, fontSize: 16),
          ),
          const SizedBox(height: 10),
          if (_bookingsForSelectedDateSuper != null)
            ..._bookingsForSelectedDateSuper!.map((b) => _buildBookingDetailCard(b))
          else
            const Text('No bookings for this date', style: TextStyle(color: Colors.black54)),
        ],
      ),
    );
  }

  Widget _buildBookingDetailCard(Map<String, dynamic> booking) {
    final status = booking['status'] as String?;

    if (status == 'HOLIDAY') {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: kBorder),
        ),
        child: Center(
          child: Text(
            booking['name'] as String? ?? 'Public Holiday',
            style: const TextStyle(color: kWarning, fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: kBorder)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                booking['model'] as String? ?? 'N/A',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: kPrimaryDarkColor),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: _statusColor(status ?? ''), borderRadius: BorderRadius.circular(12)),
                child: Text(status ?? '', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
              ),
            ],
          ),
          const Divider(height: 16),
          _buildDetailRow(Icons.person_outline, 'Requester:', '${booking['requester']} (${booking['department']})'),
          _buildDetailRow(Icons.directions_car_outlined, 'Vehicle:', '${booking['plate']}'),
          _buildDetailRow(Icons.access_time, 'Time:', '${booking['time']}'),
          _buildDetailRow(Icons.comment_outlined, 'Purpose:', '${booking['purpose']}'),
        ],
      ),
    );
  }
  
  Widget _buildDetailRow(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: Colors.grey[700]),
          const SizedBox(width: 8),
          Expanded(
            child: Text.rich(
              TextSpan(
                text: '$title ',
                style: TextStyle(color: Colors.grey[700], fontWeight: FontWeight.bold),
                children: [
                  TextSpan(
                    text: value,
                    style: const TextStyle(color: kPrimaryDarkColor, fontWeight: FontWeight.normal),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}