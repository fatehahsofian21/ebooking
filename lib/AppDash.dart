// AppDash.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ibooking/Vcalendar';
import 'package:ibooking/approval.dart'; // Import the new approval page
import 'package:ibooking/main.dart'; 

// --- Brand Guideline Colors (Consistent with dashboard.dart) ---
const Color kPrimaryColor = Color(0xFF007DC5);
const Color kBackgroundColor = Color(0xFFF5F5F5);

class AppDash extends StatelessWidget {
  const AppDash({super.key});

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
                      padding: const EdgeInsets.symmetric(horizontal: 36),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _DashboardButton(
                                iconData: Icons.meeting_room,
                                label: 'Meeting Room',
                                onTap: () {},
                              ),
                              _DashboardButton(
                                iconData: Icons.directions_car,
                                label: 'Vehicle',
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => const VCalendarPage()),
                                  );
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
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

                    // --- MODIFIED: "Upcoming Booking" Section (Matches dashboard.dart exactly) ---
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
            height: 85,
            width: 85,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))],
            ),
            child: Icon(iconData, size: 42, color: kPrimaryColor),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(color: Colors.black87, fontSize: 15, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}