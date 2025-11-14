import 'package:flutter/material.dart';
import 'package:ibooking/DriHistory.dart'; // [NEW] For back navigation
import 'package:ibooking/DriTrip.dart'; 
import 'package:url_launcher/url_launcher.dart'; 

// --- Brand Guideline Colors (Copied from AppBookingDetail) ---
const Color kPrimaryColor = Color(0xFF007DC5);
const Color kBackgroundColor = Color(0xFFF5F5F5);
const Color kApproveColor = Color(0xFF28a745); // Used for ASSIGNED status tag
const Color kRejectColor = Color(0xFFdc3545);
const Color kPending = Color(0xFFF39F21);
const Color kWarning = Color(0xFFA82525);
const Color kPrimaryDarkColor = Color.fromARGB(255, 24, 42, 94);
const Color kBorder = Color(0xFFCFD6DE);
const Color kCompletedColor = Color(0xFF17a2b8); // Teal color

// DUMMY CONSTANTS for document download/view
const String kDownloadBaseUrl = 'https://docs.google.com/gview?url=';
const String kDummyPdfUrl = 'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf';

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
    case 'ASSIGNED':
      return kPrimaryColor; // Use primary blue for assigned
    case 'IN_PROGRESS':
      return kPending;
    default:
      return Colors.grey;
  }
}

// =========================================================
// CALL FUNCTIONALITY AND LOGIC
// =========================================================

// Enum to define the menu options
enum CallOption { requester, admin }

// Utility class for common driver actions
class DriverActions {
  static const String adminPhoneNumber = '0322221111';

  static Future<void> callNumber(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    
    if (await canLaunchUrl(launchUri)) { 
      await launchUrl(launchUri);
    } else {
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

// =========================================================
// Main Detail Page Widget (Driver Specific)
// =========================================================

class DriBookingDetailPage extends StatefulWidget {
  final Map<String, dynamic> bookingDetails;
  // Removed sourcePage and userRole as they are fixed here

  const DriBookingDetailPage({
    super.key,
    required this.bookingDetails,
  });

  @override
  State<DriBookingDetailPage> createState() => _DriBookingDetailPageState();
}

class _DriBookingDetailPageState extends State<DriBookingDetailPage> {
  late final Map<String, dynamic> bookingData;

  @override
  void initState() {
    super.initState();
    // Directly use the passed bookingDetails map, assuming it's clean data from DriHistory/DriBookingList
    bookingData = widget.bookingDetails; 
  }

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
  
  // Function to handle the document download/view
  Future<void> _launchDownloadUrl(String docName) async {
    final String encodedUrl = Uri.encodeComponent(kDummyPdfUrl);
    final Uri launchUri = Uri.parse('$kDownloadBaseUrl$encodedUrl');

    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri, mode: LaunchMode.externalApplication); 
    } else {
      // ignore: avoid_print
      print('Could not launch $launchUri');
    }
  }

  // Helper function to build the phone icon (Part of the DriverHeader)
  Widget _buildPhoneIconButton(String requesterPhone) {
    final String status = bookingData['status']?.toUpperCase() ?? 'N/A';
    // Driver can call requester only if status is ASSIGNED or IN_PROGRESS
    final bool canCallRequester = (status == 'ASSIGNED' || status == 'IN_PROGRESS') && requesterPhone != 'N/A';

    final Color iconColor = canCallRequester ? Colors.green.shade600 : Colors.grey.shade400;

    return PopupMenuButton<CallOption>(
      onSelected: (result) => _onCallOptionSelected(context, result, requesterPhone),
      itemBuilder: (BuildContext context) => <PopupMenuEntry<CallOption>>[
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
        PopupMenuItem<CallOption>(
          value: CallOption.admin,
          child: ListTile(
            leading: const Icon(Icons.support_agent, color: kRejectColor),
            title: const Text('Call Admin'),
            subtitle: const Text(DriverActions.adminPhoneNumber),
            contentPadding: EdgeInsets.zero,
            dense: true,
          ),
        ),
      ],
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Icon(
          Icons.phone_rounded,
          color: iconColor,
          size: 24,
        ),
      ),
      offset: const Offset(-20, 50), 
      color: Colors.white,
      elevation: 8,
    );
  }

  // Function to handle completion and navigation
  Future<void> _handleCompletion() async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Booking Completed'),
        content: const Text('The booking has now been marked as completed.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              // CRITICAL: Navigate back to DriHistoryPage after completion
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const DriHistoryPage()),
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
    final String currentStatus = (bookingData['status']?.toUpperCase() ?? 'N/A'); 
    final bool showCallButton = (currentStatus == 'ASSIGNED' || currentStatus == 'IN_PROGRESS'); 
    final bool showApprovalInfo = (currentStatus == 'COMPLETED' || currentStatus == 'ASSIGNED' || currentStatus == 'IN_PROGRESS') && bookingData['approvedBy'] != null;

    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        backgroundColor: kPrimaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () {
            // CRITICAL: Navigate back to the list page (DriHistory or DriBookingList's original path)
            // Since this page is called from either list, and both lists navigate away with pushReplacement, 
            // a simple pop should work if coming from DriHistory (which is not using pushReplacement to here)
            // or a manual pushReplacement to DriHistory is safe if we don't know the caller (as per the requirement for history).
            Navigator.pop(context); // Go back to the previous screen (either DriHistory or DriBookingList)
          },
        ),
        title: const Text('Trip Details', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
                  // Use the driver specific header
                  child: _buildDriverHeader(bookingData['pickupDate'], showCallButton),
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
                    if (showApprovalInfo) 
                      _buildApprovedByInfoRow(
                        bookingData['approvedBy'], 
                        bookingData['approvalDateTime'],
                      ),
                    
                    _buildInfoRow('Booking ID', bookingData['bookingId']),
                    _buildInfoRow('Requester', bookingData['requester']),
                    _buildInfoRow('Department', bookingData['department']),

                    _buildInfoRow('Vehicle Type', bookingData['model']),
                    _buildInfoRow('Plate Number', bookingData['plate']),
                    
                    _buildInfoRow('Pick-Up Date & Time', bookingData['pickupDate']),
                    _buildInfoRow('Return Date & Time', bookingData['returnDate']),
                    // Use null-aware operator for 'pax'
                    _buildInfoRow('Number of Pax', bookingData['pax']?.toString() ?? 'N/A'),
                    
                    _buildInfoRow('Destination', bookingData['destination']),
                    _buildInfoRow('Pick-Up Location', bookingData['pickupLocation']),
                    _buildInfoRow('Return Location', bookingData['returnLocation']),
                    _buildInfoRow('Purpose of Booking', bookingData['purpose']),
                    
                    _buildDownloadableInfoRow('Supported Document', bookingData['uploadedDocName']),
                    
                    _buildInfoRow('Assigned Driver', bookingData['driverName']),
                    _buildHighlightedInfoRow('Reason for Rejection', bookingData['rejectionReason'], kRejectColor),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _buildDriverActionButtons(),
      ),
    );
  }
  
  // Driver Header Widget
  Widget _buildDriverHeader(String? pickupDate, bool showCallIcon) {
    final dateParts = (pickupDate ?? 'N/A • N/A').split('•');
    final date = dateParts[0].trim();
    final time = dateParts.length > 1 ? dateParts[1].trim() : '';
    
    final String currentStatus = (bookingData['status']?.toUpperCase() ?? 'N/A');
    
    // Determine the tag for the header
    Widget statusTag = Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _statusColor(currentStatus).withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(currentStatus, style: TextStyle(color: _statusColor(currentStatus), fontSize: 12, fontWeight: FontWeight.bold)),
    );

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(date, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: kPrimaryColor)),
                    const SizedBox(height: 4),
                    Text(time, style: TextStyle(fontSize: 16, color: Colors.grey[700])),
                  ],
                ),
              ),
              
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  statusTag, // Use the determined status tag
                  
                  if (showCallIcon) ...[
                    const SizedBox(width: 8),
                    _buildPhoneIconButton(bookingData['requesterPhone']),
                  ],
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  // Action buttons for the driver's view
  Widget _buildDriverActionButtons() {
    final String currentStatus = (bookingData['status']?.toUpperCase() ?? 'N/A');
    
    // Only show action buttons for active/upcoming trips
    if (currentStatus == 'ASSIGNED') {
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
                // Navigate to DriTripPage and pass booking data
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DriTripPage(tripDetails: bookingData),
                  ),
                );
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
    
    // This is for a trip that is currently IN_PROGRESS 
    if (currentStatus == 'IN_PROGRESS') {
       return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          icon: const Icon(Icons.event_available, size: 18),
          label: const Text('Complete Trip'),
          onPressed: _handleCompletion,
          style: ElevatedButton.styleFrom(
            backgroundColor: kCompletedColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
      );
    }
    
    // For COMPLETED, REJECTED, or any other historical status, show nothing
    return const SizedBox.shrink();
  }
  
  // Info Row Helper
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
  
  // Info row for Downloadable Document
  Widget _buildDownloadableInfoRow(String title, String? docName) {
    if (docName == null || docName == 'N/A' || docName.trim().isEmpty) {
      return _buildInfoRow(title, 'No Document Uploaded');
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF8B97A6))),
          const SizedBox(height: 4),
          InkWell(
            onTap: () => _launchDownloadUrl(docName), 
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.picture_as_pdf, color: kRejectColor, size: 20),
                const SizedBox(width: 8),
                Text(
                  docName,
                  style: const TextStyle(
                    fontSize: 16, 
                    color: kPrimaryColor, 
                    decoration: TextDecoration.underline,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.download, color: kPrimaryColor, size: 18),
              ],
            ),
          ),
          const Divider(height: 16),
        ],
      ),
    );
  }
  
  // Info row for Approved By
  Widget _buildApprovedByInfoRow(String? approvedBy, String? approvalDateTime) {
    if (approvedBy == null || approvedBy.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    final String approvedText = 'Approved by: $approvedBy';
    final String dateTimeText = 'Date/Time: ${approvalDateTime ?? 'N/A'}';

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: kApproveColor.withOpacity(0.05),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: kApproveColor.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('APPROVAL DETAILS', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: kApproveColor)),
            const Divider(height: 12, color: Colors.transparent),
            Row(
              children: [
                const Icon(Icons.person_pin, size: 18, color: kApproveColor),
                const SizedBox(width: 8),
                Expanded(child: Text(approvedText, style: const TextStyle(fontSize: 15, color: kApproveColor, fontWeight: FontWeight.w500))),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.access_time_filled, size: 18, color: kApproveColor),
                const SizedBox(width: 8),
                Expanded(child: Text(dateTimeText, style: const TextStyle(fontSize: 15, color: kApproveColor, fontWeight: FontWeight.w500))),
              ],
            ),
          ],
        ),
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
}