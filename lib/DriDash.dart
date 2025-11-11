// DriDash.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ibooking/AppBookingDetail.dart'; // To navigate to details
import 'package:ibooking/main.dart'; // Needed for LoginPage navigation

// --- Brand Guideline Colors (Consistent with AppDash) ---
const Color kPrimaryColor = Color(0xFF007DC5);
const Color kBackgroundColor = Color(0xFFF5F5F5);

class DriDash extends StatefulWidget {
  const DriDash({super.key});

  @override
  State<DriDash> createState() => _DriDashState();
}

class _DriDashState extends State<DriDash> {
  // ======================= REFINED DUMMY DATA =======================
  // Each item is now a complete map, matching what AppBookingDetailPage expects.
  // This prevents the RangeError and ensures no "N/A" values on the detail screen.

  final List<Map<String, dynamic>> upcomingTrips = const [
    {
      'requester': 'Siti Aisyah', 'department': 'Human Resources',
      'model': 'Honda HRV', 'plate': 'HRV 2023',
      'pickupDate': '28 Oct 2025 (Tue) • 02:00 PM', 'returnDate': '28 Oct 2025 (Tue) • 04:00 PM',
      'destination': 'Putrajaya Convention Centre', 'purpose': 'Official Meeting',
      'pax': 2, 'requireDriver': true, 'status': 'APPROVED'
    },
    {
      'requester': 'Razak Bin Ali', 'department': 'Administration',
      'model': 'Scania Touring Bus', 'plate': 'BUS 1122',
      'pickupDate': '25 Oct 2025 (Sat) • 08:00 AM', 'returnDate': '25 Oct 2025 (Sat) • 06:00 PM',
      'destination': 'Melaka Heritage Trip', 'purpose': 'Company Outing',
      'pax': 40, 'requireDriver': true, 'status': 'APPROVED'
    },
    {
      'requester': 'Nor Fatehah Binti Sofian', 'department': 'ICT Department',
      'model': 'Toyota Vellfire', 'plate': 'WPC 1234',
      'pickupDate': '02 Nov 2025 (Sun) • 09:00 AM', 'returnDate': '02 Nov 2025 (Sun) • 11:00 AM',
      'destination': 'Menara TM, Kuala Lumpur', 'purpose': 'Technical Support',
      'pax': 3, 'requireDriver': true, 'status': 'APPROVED'
    },
  ];

  final List<Map<String, dynamic>> upcomingBookings = const [
    {
      'requester': 'David Lim', 'department': 'Marketing',
      'model': 'Proton X70', 'plate': 'VDE 1121',
      'pickupDate': '05 Nov 2025 (Wed) • 10:00 AM', 'returnDate': '05 Nov 2025 (Wed) • 12:00 PM',
      'destination': 'Client Office, Petaling Jaya', 'purpose': 'Sales Pitch',
      'pax': 2, 'requireDriver': true, 'status': 'PENDING',
      'icon': Icons.directions_car_rounded,
    },
    {
      'requester': 'Aisha Khan', 'department': 'Finance',
      'model': 'Honda City', 'plate': 'VFE 5543',
      'pickupDate': '06 Nov 2025 (Thu) • 03:00 PM', 'returnDate': '06 Nov 2025 (Thu) • 04:00 PM',
      'destination': 'Bank Negara Malaysia', 'purpose': 'Document Submission',
      'pax': 1, 'requireDriver': true, 'status': 'PENDING',
      'icon': Icons.directions_car_rounded,
    },
  ];
  // ====================================================================

  bool _isBookingStackExpanded = false;
  bool _isTripStackExpanded = false;

  Future<void> _confirmLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Logout'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Yes')),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await _logout(context);
    }
  }

  Future<void> _logout(BuildContext context) async {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 280.0,
            backgroundColor: kPrimaryColor,
            pinned: true,
            stretch: true,
            systemOverlayStyle: SystemUiOverlayStyle.light,
            actions: [
              IconButton(
                icon: const Icon(Icons.power_settings_new, color: Colors.white, size: 28),
                tooltip: 'Log out',
                onPressed: () => _confirmLogout(context),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const [StretchMode.zoomBackground, StretchMode.fadeTitle],
              background: Image.asset('assets/bangunan.jpg', fit: BoxFit.cover),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(60),
              child: Container(
                transform: Matrix4.translationValues(0.0, 30.0, 0.0),
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.white,
                  child: CircleAvatar(
                    radius: 46,
                    backgroundImage: const AssetImage('assets/profile.png'),
                  ),
                ),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              const SizedBox(height: 45),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Ismail Bin Sabri', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87)),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(8)),
                    child: Text('Driver', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey[700])),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text('Fleet Management Department', style: TextStyle(color: Colors.grey[700], fontSize: 14, fontWeight: FontWeight.w600), textAlign: TextAlign.center),
              const SizedBox(height: 30),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _DashboardButton(iconData: Icons.meeting_room, label: 'Meeting Room', onTap: () {}),
                    _DashboardButton(iconData: Icons.directions_car, label: 'Vehicle', onTap: () {}),
                    _DashboardButton(iconData: Icons.navigation_rounded, label: 'Trip', onTap: () {}),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              _CollapsibleCardStack(
                title: 'Upcoming Trip',
                items: upcomingTrips,
                isExpanded: _isTripStackExpanded,
                onToggle: () => setState(() => _isTripStackExpanded = !_isTripStackExpanded),
                cardBuilder: (item) => _TripInfoCard(item: item, onTap: () => _navigateToDetails(item)),
              ),
              const SizedBox(height: 24),
              _CollapsibleCardStack(
                title: 'Upcoming Booking',
                items: upcomingBookings,
                isExpanded: _isBookingStackExpanded,
                onToggle: () => setState(() => _isBookingStackExpanded = !_isBookingStackExpanded),
                cardBuilder: (item) => _BookingInfoCard(item: item, onTap: () => _navigateToDetails(item)),
              ),
              const SizedBox(height: 24),
            ]),
          ),
        ],
      ),
    );
  }

  void _navigateToDetails(Map<String, dynamic> item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AppBookingDetailPage(bookingDetails: item),
      ),
    );
  }
}

class _CollapsibleCardStack extends StatelessWidget {
  final String title;
  final List<Map<String, dynamic>> items;
  final bool isExpanded;
  final VoidCallback onToggle;
  final Widget Function(Map<String, dynamic> item) cardBuilder;

  const _CollapsibleCardStack({
    required this.title,
    required this.items,
    required this.isExpanded,
    required this.onToggle,
    required this.cardBuilder,
  });

  @override
  Widget build(BuildContext context) {
    // ======================= RENDERFLEX FIX =======================
    // Increased cardHeight to prevent overflow in the redesigned cards.
    const double cardHeight = 125.0; 
    // ===============================================================
    const double verticalSpacingExpanded = 12.0;
    const double verticalOffsetCollapsed = 18.0;

    final bool hasItems = items.isNotEmpty;
    final double stackedHeight = hasItems ? cardHeight + (items.length - 1) * verticalOffsetCollapsed : 88.0;
    final double expandedHeight = hasItems ? (cardHeight * items.length) + (verticalSpacingExpanded * (items.length - 1)) : 88.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: onToggle,
            child: Text(
              '$title (${items.length})',
              style: TextStyle(color: Colors.black.withOpacity(0.8), fontSize: 17, fontWeight: FontWeight.bold, letterSpacing: 0.5),
            ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: onToggle,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeOutCubic,
              height: isExpanded ? expandedHeight : stackedHeight,
              child: hasItems
                  ? Stack(
                      children: List.generate(items.length, (index) {
                        final item = items[index];
                        final topPosition = isExpanded
                            ? index * (cardHeight + verticalSpacingExpanded)
                            : index * verticalOffsetCollapsed;

                        return AnimatedPositioned(
                          duration: const Duration(milliseconds: 350),
                          curve: Curves.easeOutCubic,
                          top: topPosition,
                          left: 0,
                          right: 0,
                          child: AbsorbPointer(
                            absorbing: !isExpanded,
                            child: cardBuilder(item),
                          ),
                        );
                      }).reversed.toList(),
                    )
                  : Container(
                      height: 88,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.grey.shade300)),
                      child: const Text('No items to show.', style: TextStyle(color: Colors.grey)),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

// ======================= NEW TRIP CARD WIDGET (FIXED) =======================
class _TripInfoCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final VoidCallback onTap;

  const _TripInfoCard({required this.item, required this.onTap});
  
  @override
  Widget build(BuildContext context) {
    // Extracting date and time from the full pickupDate string for display
    final pickupDateParts = (item['pickupDate'] ?? 'N/A • N/A').split('•');
    final date = pickupDateParts[0].trim();
    final time = pickupDateParts.length > 1 ? pickupDateParts[1].trim() : 'N/A';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 125.0, // Increased height to fix overflow
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceAround, // Better spacing
          children: [
            Text(date, style: const TextStyle(color: kPrimaryColor, fontSize: 14, fontWeight: FontWeight.bold)),
            Text(time, style: TextStyle(color: Colors.grey[800], fontSize: 13, fontWeight: FontWeight.w500)),
            const Divider(),
            _InfoRow(icon: Icons.location_on_outlined, label: 'Destination:', value: item['destination'] ?? 'N/A'),
            _InfoRow(icon: Icons.wysiwyg, label: 'Plate:', value: item['plate'] ?? 'N/A'),
          ],
        ),
      ),
    );
  }
}
// Helper for Trip Card to ensure consistent layout
class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text(label, style: TextStyle(color: Colors.grey[700], fontSize: 13, fontWeight: FontWeight.bold)),
        const SizedBox(width: 4),
        Expanded(
          child: Text(value, style: TextStyle(color: Colors.grey[700], fontSize: 13), overflow: TextOverflow.ellipsis),
        ),
      ],
    );
  }
}

// ======================= BOOKING CARD WIDGET (dashboard.dart style) =======================
class _BookingInfoCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final VoidCallback onTap;

  const _BookingInfoCard({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 88.0, // Standard height for this card type
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(item['icon'] as IconData? ?? Icons.info, size: 32, color: kPrimaryColor),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('${item['model']} (${item['plate']})', style: const TextStyle(color: Colors.black87, fontSize: 15, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Text(item['pickupDate'] ?? 'N/A', style: TextStyle(color: Colors.grey[700], fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ======================= DASHBOARD BUTTON (Unchanged) =======================
class _DashboardButton extends StatelessWidget {
  final IconData iconData;
  final String label;
  final VoidCallback onTap;
  const _DashboardButton({required this.iconData, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            height: 75,
            width: 75,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))],
            ),
            child: Icon(iconData, size: 38, color: kPrimaryColor),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(color: Colors.black87, fontSize: 14, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}