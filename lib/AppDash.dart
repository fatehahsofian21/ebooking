// AppDash.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ibooking/approval.dart'; // Import the new approval page
import 'package:ibooking/main.dart';

// --- Brand Guideline Colors (Consistent with dashboard.dart) ---
const Color kPrimaryColor = Color(0xFF007DC5);
const Color kBackgroundColor = Color(0xFFF5F5F5);

class AppDash extends StatelessWidget {
  const AppDash({super.key});

  // --- Dummy Data for Pending Approvals ---
  final List<Map<String, dynamic>> pendingApprovals = const [
    {
      'icon': Icons.directions_car,
      'title': 'Toyota Vellfire (VBB 1234)',
      'subtitle1': '31 Oct 2025 (Fri) • 9:00 AM - 11:00 AM',
      'subtitle2': 'Requested by: Siti Aisyah',
    },
    {
      'icon': Icons.directions_bus,
      'title': 'Scania Touring (BUS 8899)',
      'subtitle1': '03 Nov 2025 (Mon) • 2:00 PM - 5:00 PM',
      'subtitle2': 'Requested by: Razak Bin Ali',
    },
    // You can add more items here, but only the top 3 will be visually stacked.
  ];


  // --- Logout Logic ---
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
    // Determine how many cards to show in the visual stack (max 3)
    final stackedCardCount = pendingApprovals.length > 3 ? 3 : pendingApprovals.length;

    return Scaffold(
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark.copyWith(
          statusBarColor: Colors.transparent,
        ),
        child: Container(
          width: double.infinity,
          height: double.infinity,
          color: kBackgroundColor,
          child: Stack(
            children: [
              // Layer 1: Header Image
              SizedBox(
                width: double.infinity,
                height: 260,
                child: ClipPath(
                  clipper: _StraightHeaderClipper(),
                  child: Image.asset('assets/bangunan.jpg', fit: BoxFit.cover, alignment: Alignment.topCenter),
                ),
              ),
              
              // Layer 2: Profile Picture
              Positioned(
                top: 220,
                left: 0,
                right: 0,
                child: Center(
                  child: CircleAvatar(
                    radius: 48,
                    backgroundColor: Colors.white,
                    backgroundImage: const AssetImage('assets/profile.png'),
                  ),
                ),
              ),

              // Layer 3: Scrollable Content
              SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    const SizedBox(height: 330),
                    // Approver's Name and Role
                    const Text('Ahmad Bin Hassan', style: TextStyle(color: Colors.black87, fontSize: 20, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                    const SizedBox(height: 4),
                    Text('Bahagian Strategi dan Transformasi & ICT', style: TextStyle(color: Colors.grey[700], fontSize: 14, fontWeight: FontWeight.w600), textAlign: TextAlign.center),
                    const SizedBox(height: 30),

                    // --- Button Layout ---
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _DashboardButton(
                            iconData: Icons.meeting_room,
                            label: 'Meeting Room',
                            onTap: () {},
                          ),
                          _DashboardButton(
                            iconData: Icons.directions_car,
                            label: 'Vehicle',
                            onTap: () {},
                          ),
                          _DashboardButton(
                            iconData: Icons.playlist_add_check_rounded,
                            label: 'Approval',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const ApprovalPage()),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 45),

                    // --- "Work Basket" Section ---
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 36.0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // --- Pending Approval Sub-section ---
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 36.0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Pending Approval (${pendingApprovals.length})', 
                          style: TextStyle(color: Colors.red.shade700, fontSize: 17, fontWeight: FontWeight.bold, letterSpacing: 0.5)
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // --- MODIFIED: Stacking card layout ---
                    if (pendingApprovals.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 36.0),
                        child: SizedBox(
                          // Calculate height needed for the stack to not overflow
                          height: 95 + (stackedCardCount - 1) * 12.0,
                          child: Stack(
                            children: List.generate(stackedCardCount, (index) {
                              final item = pendingApprovals[index];
                              // Calculate offsets for the stacking effect
                              final topOffset = index * 12.0;
                              final horizontalPadding = index * 8.0;

                              // The .reversed.toList() is crucial: it makes sure the first item
                              // in the list is drawn last, so it appears on top.
                              return Positioned(
                                top: topOffset,
                                left: horizontalPadding,
                                right: horizontalPadding,
                                child: _buildApprovalCard(
                                  icon: item['icon'],
                                  title: item['title'],
                                  subtitle1: item['subtitle1'],
                                  subtitle2: item['subtitle2'],
                                ),
                              );
                            }).reversed.toList(),
                          ),
                        ),
                      ),
                    const SizedBox(height: 24),

                    // --- Upcoming Booking Sub-section ---
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 36.0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text('Upcoming Booking', style: TextStyle(color: Colors.black.withOpacity(0.8), fontSize: 17, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 36.0),
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))],
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
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
                    const SizedBox(height: 24), // Bottom padding
                  ],
                ),
              ),

              // Layer 4: Logout Button
              Positioned(
                top: 40,
                right: 16,
                child: IconButton(
                  icon: const Icon(Icons.power_settings_new, color: Colors.white, size: 28),
                  tooltip: 'Log out',
                  onPressed: () => _confirmLogout(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Reusable widget for approval cards ---
  Widget _buildApprovalCard({
    required IconData icon,
    required String title,
    required String subtitle1,
    required String subtitle2,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 32, color: kPrimaryColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.black87, fontSize: 15, fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Text(subtitle1, style: TextStyle(color: Colors.grey[700], fontSize: 13)),
                const SizedBox(height: 2),
                Text(subtitle2, style: TextStyle(color: Colors.grey[700], fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// --- WIDGET: Header Clipper ---
class _StraightHeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path()..lineTo(0, size.height)..lineTo(size.width, size.height)..lineTo(size.width, 0)..close();
    return path;
  }
  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

// --- WIDGET: Dashboard Button ---
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