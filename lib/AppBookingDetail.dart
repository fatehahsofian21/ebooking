// AppBookingDetail.dart

import 'package:flutter/material.dart';
import 'package:ibooking/AppHistory.dart';
import 'package:ibooking/approval.dart';

// --- Brand Guideline Colors ---
const Color kPrimaryColor = Color(0xFF007DC5);
const Color kBackgroundColor = Color(0xFFF5F5F5);
const Color kApproveColor = Color(0xFF28a745);
const Color kRejectColor = Color(0xFFdc3545);
const Color kPending = Color(0xFFF39F21);
const Color kWarning = Color(0xFFA82525);
const Color kPrimaryDarkColor = Color.fromARGB(255, 24, 42, 94);
const Color kBorder = Color(0xFFCFD6DE);
const Color kCompletedColor = Color(0xFF17a2b8);

// Helper function to determine the color of the status tag
Color _statusColor(String? status) {
  switch (status?.toUpperCase()) {
    case 'PENDING':
      return kPending;
    case 'APPROVED':
      return kPrimaryColor;
    case 'COMPLETED':
      return kCompletedColor;
    case 'REJECTED':
      return kRejectColor;
    case 'HOLIDAY':
      return kWarning;
    default:
      return Colors.grey;
  }
}

class AppBookingDetailPage extends StatefulWidget {
  final Map<String, dynamic> bookingDetails;
  final String? sourcePage;
  // This new property will determine the UI (e.g., 'approver' or 'driver')
  final String userRole;

  const AppBookingDetailPage({
    super.key,
    required this.bookingDetails,
    this.sourcePage,
    this.userRole = 'approver', // Default role is 'approver' if not specified
  });

  @override
  State<AppBookingDetailPage> createState() => _AppBookingDetailPageState();
}

class _AppBookingDetailPageState extends State<AppBookingDetailPage> {
  late final Map<String, dynamic> bookingData;

  @override
  void initState() {
    super.initState();
    // This logic to parse data from different sources remains the same
    bookingData = {
      'bookingId': widget.bookingDetails['bookingId'] ?? 'N/A',
      'requester': widget.bookingDetails['requester'] ?? widget.bookingDetails['subtitle2']?.split(':').last.trim() ?? 'N/A',
      'department': widget.bookingDetails['department'] ?? 'N/A',
      'model': widget.bookingDetails['model'] ?? widget.bookingDetails['title']?.split('(').first.trim() ?? 'N/A',
      'plate': widget.bookingDetails['plate'] ?? widget.bookingDetails['title']?.split('(').last.replaceAll(')', '').trim() ?? 'N/A',
      'pickupDate': widget.bookingDetails['pickupDate'] ?? widget.bookingDetails['subtitle1']?.split('•')[0].trim() ?? 'N/A',
      'returnDate': widget.bookingDetails['returnDate'] ?? widget.bookingDetails['subtitle1']?.split('•')[1].trim() ?? 'N/A',
      'destination': widget.bookingDetails['destination'] ?? 'N/A',
      'pickupLocation': widget.bookingDetails['pickupLocation'] ?? 'N/A',
      'returnLocation': widget.bookingDetails['returnLocation'] ?? 'N/A',
      'pax': widget.bookingDetails['pax'] ?? 0,
      'requireDriver': widget.bookingDetails['requireDriver'] ?? false,
      'purpose': widget.bookingDetails['purpose'] ?? 'N/A',
      'uploadedDocName': widget.bookingDetails['uploadedDocName'] ?? 'N/A',
      'status': widget.bookingDetails['status'] ?? 'PENDING',
      'driverName': widget.bookingDetails['driverName'],
      'rejectionReason': widget.bookingDetails['rejectionReason'],
    };
  }

  // --- All dialogs and helper functions for approvers remain unchanged ---
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
              maxLines: 3,
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

  Future<void> _showApproveDialog() async {
    final bool needsDriver = bookingData['requireDriver'] == true;

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
      _showConfirmationDialog(
        title: 'Booking Approved',
        content: 'The booking has been successfully approved.',
      );
    }
  }
  
  Future<void> _handleCompleteBooking() async {
    await _showConfirmationDialog(
      title: 'Booking Completed',
      content: 'The booking has now been marked as completed.',
    );
  }

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
                (route) => false,
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
    // This boolean will control which UI elements are shown
    final bool isDriver = widget.userRole == 'driver';

    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        backgroundColor: kPrimaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () {
            // This existing navigation logic is preserved
            if (widget.sourcePage == 'approval') {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const ApprovalPage()));
            } else if (widget.sourcePage == 'history') {
               Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const AppHistoryPage()));
            } else {
              Navigator.pop(context);
            }
          },
        ),
        title: const Text('Booking Details', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        // The calendar icon is now conditional: it only shows if it's NOT a driver
        actions: isDriver
            ? [] // No actions for driver
            : [
                IconButton(
                  icon: const Icon(Icons.calendar_month_outlined, color: Colors.white),
                  onPressed: () => showDialog(
                    context: context,
                    builder: (context) => const Dialog(
                      insetPadding: EdgeInsets.all(16),
                      child: SuperCalendarDialogWidget(),
                    ),
                  ),
                ),
              ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // This is the main conditional UI change for the header
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  // If it's a driver, show the new date header. Otherwise, show the old status tag.
                  child: isDriver
                      ? _buildDriverHeader(bookingData['pickupDate'])
                      : _buildStatusTag(bookingData['status']),
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
                    _buildInfoRow('Booking ID', bookingData['bookingId']),
                    _buildInfoRow('Requester', bookingData['requester']),
                    _buildInfoRow('Department', bookingData['department']),

                    // These rows are now conditional: only show if NOT a driver
                    if (!isDriver) ...[
                      _buildInfoRow('Vehicle Type', bookingData['model']),
                      _buildInfoRow('Plate Number', bookingData['plate']),
                    ],

                    _buildInfoRow('Pick-Up Date & Time', bookingData['pickupDate']),
                    _buildInfoRow('Return Date & Time', bookingData['returnDate']),
                    _buildInfoRow('Number of Pax', bookingData['pax'].toString()),

                    // This row is also conditional
                    if (!isDriver)
                      _buildInfoRow('Require Driver', (bookingData['requireDriver'] == true) ? 'Yes' : 'No'),
                    
                    _buildInfoRow('Destination', bookingData['destination']),
                    _buildInfoRow('Pick-Up Location', bookingData['pickupLocation']),
                    _buildInfoRow('Return Location', bookingData['returnLocation']),
                    _buildInfoRow('Purpose of Booking', bookingData['purpose']),
                    _buildInfoRow('Supported Document', bookingData['uploadedDocName']),
                    _buildInfoRow('Assigned Driver', bookingData['driverName']),
                    _buildHighlightedInfoRow('Reason for Rejection', bookingData['rejectionReason'], kRejectColor),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      // The bottom navigation bar now shows different buttons based on the role
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isDriver
            ? _buildDriverActionButtons()
            : _buildApproverActionButtons(),
      ),
    );
  }

  // --- NEW WIDGETS FOR DRIVER VIEW ---

  // New header widget for the driver's view
  Widget _buildDriverHeader(String? pickupDate) {
    final dateParts = (pickupDate ?? 'N/A • N/A').split('•');
    final date = dateParts[0].trim();
    final time = dateParts.length > 1 ? dateParts[1].trim() : '';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(date, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: kPrimaryColor)),
          const SizedBox(height: 4),
          Text(time, style: TextStyle(fontSize: 16, color: Colors.grey[700])),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.orange.shade100,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text('UPCOMING', style: TextStyle(color: Colors.orange, fontSize: 12, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
  
  // New action buttons for the driver's view
  Widget _buildDriverActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            icon: const Icon(Icons.cancel, size: 18),
            label: const Text('Reject'),
            onPressed: () {
              // Add logic for driver to reject the trip
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: kRejectColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton.icon(
            icon: const Icon(Icons.play_arrow_rounded, size: 18),
            label: const Text('Start Trip'),
            onPressed: () {
              // Add logic to start the trip
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: kPrimaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ),
      ],
    );
  }
  
  // --- EXISTING WIDGETS (REFACTORED AND UNCHANGED) ---

  // This widget now specifically builds the buttons for the approver
  Widget _buildApproverActionButtons() {
    final String currentStatus = (bookingData['status']?.toUpperCase() ?? 'PENDING');
    final bool showPendingActions = currentStatus == 'PENDING';
    final bool showApprovedActions = currentStatus == 'APPROVED';

    if (showPendingActions) {
      return Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              icon: const Icon(Icons.check_circle, size: 18),
              label: const Text('Approve'),
              onPressed: _showApproveDialog,
              style: ElevatedButton.styleFrom(
                backgroundColor: kApproveColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
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
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
        ],
      );
    }
    
    if (showApprovedActions) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          icon: const Icon(Icons.event_available, size: 18),
          label: const Text('Complete Booking'),
          onPressed: _handleCompleteBooking,
          style: ElevatedButton.styleFrom(
            backgroundColor: kCompletedColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
      );
    }
    // Return an empty box if no actions are available for the current status
    return const SizedBox.shrink();
  }

  // Helper Widgets (no changes needed for these)
  Widget _buildInfoRow(String title, String? value) {
    if (value == null || value == 'N/A' || value.trim().isEmpty) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF8B97A6))),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 16, color: Color(0xFF2E3A59))),
          const Divider(height: 16),
        ],
      ),
    );
  }
  
  Widget _buildHighlightedInfoRow(String title, String? value, Color textColor) {
    if (value == null || value.trim().isEmpty) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF8B97A6))),
          const SizedBox(height: 4),
          Text(value,
              style: TextStyle(
                  fontSize: 16, color: textColor, fontWeight: FontWeight.w500)),
          const Divider(height: 16),
        ],
      ),
    );
  }

  Widget _buildStatusTag(String? status) {
    final statusText = status ?? 'UNKNOWN';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(color: _statusColor(statusText), borderRadius: BorderRadius.circular(18)),
      child: Text(statusText.toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 0.8)),
    );
  }
}

// =========================================================================
// WIDGET: The Super Calendar functionality (No changes needed)
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
    5: [{'requester': 'Shera', 'department': 'Engineering', 'model': 'Toyota Vellfire', 'plate': 'WPC1234', 'time': '10:00 AM – 3:00 PM', 'status': 'APPROVED', 'purpose': 'Client meeting at KL Sentral', 'driver': 'Bala'}],
    21: [{'requester': 'Aiman', 'department': 'BST', 'model': 'Isuzu Bus', 'plate': 'BNM1234', 'time': '9:00 AM – 5:00 PM', 'status': 'APPROVED', 'purpose': 'Team building event at Port Dickson', 'driver': 'Ahmad'}],
    25: [{'name': 'PUBLIC HOLIDAY', 'status': 'HOLIDAY'}],
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
        IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: kPrimaryColor), onPressed: () => _pageController.previousPage(duration: const Duration(milliseconds: 200), curve: Curves.easeOut)),
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: kPrimaryDarkColor)),
        IconButton(icon: const Icon(Icons.arrow_forward_ios_rounded, size: 18, color: kPrimaryColor), onPressed: () => _pageController.nextPage(duration: const Duration(milliseconds: 200), curve: Curves.easeOut)),
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
        if (isHoliday) borderColor = kWarning;
        else if (isApproved) borderColor = kPrimaryColor;
        return GestureDetector(
          onTap: () => _onDateTappedSuper(month, day),
          child: Container(
            decoration: BoxDecoration(color: isSelected ? kPrimaryColor : Colors.transparent, borderRadius: BorderRadius.circular(8), border: Border.all(color: borderColor, width: isHoliday || isApproved ? 2.0 : 1.0)),
            alignment: Alignment.center,
            child: Text('$day', style: TextStyle(color: isSelected ? Colors.white : kPrimaryDarkColor, fontWeight: FontWeight.w700)),
          ),
        );
      },
    );
  }

  Widget _buildSuperCalendarDetails() {
    if (_selectedDateSuper == null) return const Padding(padding: EdgeInsets.all(16.0), child: Center(child: Text("Select a date to see details", style: TextStyle(color: Colors.grey))));
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Column(
        children: [
          Text('${_selectedDateSuper?.day}/${_selectedDateSuper?.month}/${_selectedDateSuper?.year}', style: const TextStyle(fontWeight: FontWeight.bold, color: kPrimaryDarkColor, fontSize: 16)),
          const SizedBox(height: 10),
          if (_bookingsForSelectedDateSuper != null) ..._bookingsForSelectedDateSuper!.map((b) => _buildBookingDetailCard(b))
          else const Text('No bookings for this date', style: TextStyle(color: Colors.black54)),
        ],
      ),
    );
  }

  Widget _buildBookingDetailCard(Map<String, dynamic> booking) {
    final status = booking['status'] as String?;
    if (status == 'HOLIDAY') return Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: kBorder)), child: Center(child: Text(booking['name'] as String? ?? 'Public Holiday', style: const TextStyle(color: kWarning, fontWeight: FontWeight.bold, fontSize: 16))));
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: kBorder)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(booking['model'] as String? ?? 'N/A', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: kPrimaryDarkColor)),
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
          if (booking['driver'] != null)
            _buildDetailRow(Icons.person_pin_circle_outlined, 'Driver:', '${booking['driver']}'),
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
                children: [TextSpan(text: value, style: const TextStyle(color: kPrimaryDarkColor, fontWeight: FontWeight.normal))],
              ),
            ),
          ),
        ],
      ),
    );
  }
}