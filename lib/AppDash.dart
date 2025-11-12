import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ibooking/AppBookingDetail.dart';
import 'package:ibooking/approval.dart';
import 'package:ibooking/dashboard2.dart';
import 'package:ibooking/main.dart';

// --- Brand Guideline Colors ---
const Color kPrimaryColor = Color(0xFF007DC5);
const Color kBackgroundColor = Color(0xFFF5F5F5);

class AppDash extends StatefulWidget {
  const AppDash({super.key});

  @override
  State<AppDash> createState() => _AppDashState();
}

class _AppDashState extends State<AppDash> with SingleTickerProviderStateMixin {
  // ======================= REFINED DUMMY DATA =======================
  // Added 'uploadedDocName' to ensure the detail page has complete information.
  final List<Map<String, dynamic>> pendingApprovals = const [
    {
      'icon': Icons.directions_car,
      'title': 'Toyota Vellfire (VBB 1234)',
      'subtitle1': '31 Oct 2025 (Fri) • 9:00 AM - 11:00 AM',
      'subtitle2': 'Requested by: Siti Aisyah',
      // --- Full Details ---
      'requester': 'Siti Aisyah',
      'department': 'Human Resources',
      'model': 'Toyota Vellfire',
      'plate': 'VBB 1234',
      'pickupDate': '31 Oct 2025 • 9:00 AM',
      'returnDate': '31 Oct 2025 • 11:00 AM',
      'destination': 'KL Sentral',
      'purpose': 'Meeting with external client',
      'pax': 4,
      'requireDriver': true,
      'status': 'PENDING',
      'uploadedDocName': 'Client_Meeting_Agenda.pdf', // ADDED THIS FIELD
    },
    {
      'icon': Icons.directions_bus,
      'title': 'Scania Touring (BUS 8899)',
      'subtitle1': '03 Nov 2025 (Mon) • 2:00 PM - 5:00 PM',
      'subtitle2': 'Requested by: Razak Bin Ali',
      // --- Full Details ---
      'requester': 'Razak Bin Ali',
      'department': 'Administration',
      'model': 'Scania Touring',
      'plate': 'BUS 8899',
      'pickupDate': '03 Nov 2025 • 2:00 PM',
      'returnDate': '03 Nov 2025 • 5:00 PM',
      'destination': 'Putrajaya',
      'purpose': 'Official Government Business',
      'pax': 25,
      'requireDriver': true,
      'status': 'PENDING',
      'uploadedDocName': null, // Example with no document
    },
    {
      'icon': Icons.local_taxi,
      'title': 'Proton X50 (VCD 5678)',
      'subtitle1': '04 Nov 2025 (Tue) • 1:00 PM - 3:00 PM',
      'subtitle2': 'Requested by: Michael Chen',
      // --- Full Details ---
      'requester': 'Michael Chen',
      'department': 'Sales & Marketing',
      'model': 'Proton X50',
      'plate': 'VCD 5678',
      'pickupDate': '04 Nov 2025 • 1:00 PM',
      'returnDate': '04 Nov 2025 • 3:00 PM',
      'destination': 'Cyberjaya',
      'purpose': 'Product Demonstration',
      'pax': 2,
      'requireDriver': false,
      'status': 'PENDING',
      'uploadedDocName': 'Product_Demo_Slides.pdf', // ADDED THIS FIELD
    },
  ];
  // ====================================================================

  bool _isStackExpanded = false;

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
    const double cardHeight = 88.0;
    const double verticalSpacingExpanded = 12.0;
    const double verticalOffsetCollapsed = 18.0;

    final double stackedHeight = cardHeight + (pendingApprovals.length - 1) * verticalOffsetCollapsed;
    final double expandedHeight = (cardHeight * pendingApprovals.length) + (verticalSpacingExpanded * (pendingApprovals.length - 1));

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
            // ============== MODIFICATION START ==============
            // This line removes the back arrow that Flutter automatically adds.
            automaticallyImplyLeading: false,
            // ============== MODIFICATION END ==============
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
                    backgroundImage: const AssetImage('assets/ahmad.jpg'),
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
                  const Text('Ahmad Bin Hassan', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87)),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(8)),
                    child: Text('Approver', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey[700])),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text('Bahagian Strategi dan Transformasi & ICT', style: TextStyle(color: Colors.grey[700], fontSize: 14, fontWeight: FontWeight.w600), textAlign: TextAlign.center),
              const SizedBox(height: 30),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _DashboardButton(iconData: Icons.meeting_room, label: 'Meeting Room', onTap: () {}),
                    _DashboardButton(iconData: Icons.directions_car, label: 'Vehicle', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const Dashboard2Screen()))),
                    _DashboardButton(iconData: Icons.playlist_add_check_rounded, label: 'Approval', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ApprovalPage()))),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: GestureDetector(
                  onTap: () => setState(() => _isStackExpanded = !_isStackExpanded),
                  behavior: HitTestBehavior.translucent,
                  child: Row(
                    children: [
                      Text(
                        'Pending Approval (${pendingApprovals.length})',
                        style: TextStyle(color: Colors.black.withOpacity(0.8), fontSize: 17, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                      ),
                      const SizedBox(width: 8),
                      if (pendingApprovals.isNotEmpty) const _PulsingDot(),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              if (pendingApprovals.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: GestureDetector(
                    onTap: () => setState(() => _isStackExpanded = !_isStackExpanded),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 350),
                      curve: Curves.easeOutCubic,
                      height: _isStackExpanded ? expandedHeight : stackedHeight,
                      child: Stack(
                        children: List.generate(pendingApprovals.length, (index) {
                          final item = pendingApprovals[index];
                          final topPosition = _isStackExpanded ? index * (cardHeight + verticalSpacingExpanded) : index * verticalOffsetCollapsed;
                          return AnimatedPositioned(
                            duration: const Duration(milliseconds: 350),
                            curve: Curves.easeOutCubic,
                            top: topPosition,
                            left: 0,
                            right: 0,
                            child: AbsorbPointer(
                              absorbing: !_isStackExpanded,
                              child: _buildApprovalCard(
                                icon: item['icon'],
                                title: item['title'],
                                subtitle1: item['subtitle1'],
                                subtitle2: item['subtitle2'],
                                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AppBookingDetailPage(bookingDetails: item))),
                              ),
                            ),
                          );
                        }).reversed.toList(),
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Text('Upcoming Booking', style: TextStyle(color: Colors.black.withOpacity(0.8), fontSize: 17, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))]),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Row(
                    children: [
                      const Icon(Icons.directions_car, size: 32, color: kPrimaryColor),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Toyota Vellfire', style: TextStyle(color: Colors.black87, fontSize: 15, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 2),
                            Text('30 Oct 2025 (Thu) • 10:00 AM – 3:00 PM', style: TextStyle(color: Colors.grey[700], fontSize: 13)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _buildApprovalCard({required IconData icon, required String title, required String subtitle1, required String subtitle2, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 88.0,
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 10, offset: const Offset(0, 4))]),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(icon, size: 32, color: kPrimaryColor),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(title, style: const TextStyle(color: Colors.black87, fontSize: 15, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Text(subtitle1, style: TextStyle(color: Colors.grey[700], fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Text(subtitle2, style: TextStyle(color: Colors.grey[700], fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- Helper Widgets ---
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
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))]),
            child: Icon(iconData, size: 38, color: kPrimaryColor),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(color: Colors.black87, fontSize: 14, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}