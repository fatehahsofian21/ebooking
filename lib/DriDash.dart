// DriDash.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ibooking/AppBookingDetail.dart'; // To navigate to details
import 'package:ibooking/dashboard2.dart'; // IMPORT THIS
import 'package:ibooking/main.dart'; // Needed for LoginPage navigation
import 'package:ibooking/DriBookingList.dart'; // <--- NEW IMPORT

// --- Brand Guideline Colors (Consistent with AppDash) ---
const Color kPrimaryColor = Color(0xFF007DC5);
const Color kBackgroundColor = Color(0xFFF5F5F5);

class DriDash extends StatefulWidget {
  const DriDash({super.key});

  @override
  State<DriDash> createState() => _DriDashState();
}

class _DriDashState extends State<DriDash> {
  // ======================= DUMMY DATA =======================
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
            automaticallyImplyLeading: false,
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
                  child: const CircleAvatar(
                    radius: 46,
                    backgroundImage: AssetImage('assets/ahmad.jpg'),
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
                    // ============== MODIFICATION: Vehicle Button Navigation ==============
                    _DashboardButton(
                      iconData: Icons.directions_car,
                      label: 'Vehicle',
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const Dashboard2Screen())),
                    ),
                    // ============== MODIFICATION: Trip Button Navigation to DriBookingListPage ==============
                    _DashboardButton(
                      iconData: Icons.navigation_rounded, 
                      label: 'Trip', 
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DriBookingListPage())), // <--- FIXED LINE
                    ),
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
                showPulsingDot: true,
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

  // ============== MODIFICATION: Pass userRole to Detail Page ==============
  void _navigateToDetails(Map<String, dynamic> item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AppBookingDetailPage(
          bookingDetails: item,
          userRole: 'driver', // Pass the role here
        ),
      ),
    );
  }
}

// --- All helper widgets below this line are unchanged ---

class _CollapsibleCardStack extends StatelessWidget {
  final String title;
  final List<Map<String, dynamic>> items;
  final bool isExpanded;
  final VoidCallback onToggle;
  final Widget Function(Map<String, dynamic> item) cardBuilder;
  final bool showPulsingDot;

  const _CollapsibleCardStack({
    required this.title,
    required this.items,
    required this.isExpanded,
    required this.onToggle,
    required this.cardBuilder,
    this.showPulsingDot = false,
  });

  @override
  Widget build(BuildContext context) {
    const double cardHeight = 125.0;
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
            behavior: HitTestBehavior.translucent,
            child: (showPulsingDot && hasItems)
                ? Row(
                    children: [
                      Text(
                        '$title (${items.length})',
                        style: TextStyle(color: Colors.black.withOpacity(0.8), fontSize: 17, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                      ),
                      const SizedBox(width: 8),
                      const _PulsingDot(),
                    ],
                  )
                : Text(
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

class _TripInfoCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final VoidCallback onTap;

  const _TripInfoCard({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final pickupDateParts = (item['pickupDate'] ?? 'N/A • N/A').split('•');
    final date = pickupDateParts[0].trim();
    final time = pickupDateParts.length > 1 ? pickupDateParts[1].trim() : 'N/A';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 125.0,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
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

class _BookingInfoCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final VoidCallback onTap;

  const _BookingInfoCard({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 88.0,
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

class _PulsingDot extends StatefulWidget {
  const _PulsingDot();
  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000))..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: Container(width: 10, height: 10, decoration: BoxDecoration(color: Colors.red.shade700, shape: BoxShape.circle)),
    );
  }
}