// dashboard.dart (CORRECTED COLORS FOR LIGHT BACKGROUND)

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ibooking/Vcalendar';
import 'package:ibooking/main.dart';

// --- Brand Guideline Colors ---
const Color kPrimaryColor = Color(0xFF007DC5);
const Color kBackgroundColor = Color(0xFFF5F5F5); // The standard light gray background

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  // --- Logout Logic (Remains the same) ---
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

    if (confirmed == true) {
      // ignore: use_build_context_synchronously
      await _logout(context);
    }
  }

  Future<void> _logout(BuildContext context) async {
    if (context.mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginPage()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        // CHANGED: Status bar icons are now dark to be visible on the light background
        value: SystemUiOverlayStyle.dark.copyWith(
          statusBarColor: Colors.transparent,
        ),
        child: Container(
          width: double.infinity,
          height: double.infinity,
          // The background is the standard light gray
          color: kBackgroundColor,
          child: Stack(
            children: [
              // Layer 1: Header Image (Unchanged)
              SizedBox(
                width: double.infinity,
                height: 260,
                child: ClipPath(
                  clipper: _StraightHeaderClipper(),
                  child: Image.asset('assets/bangunan.jpg', fit: BoxFit.cover, alignment: Alignment.topCenter),
                ),
              ),
              
              // Layer 2: Profile Picture (Unchanged)
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
                child: Column(
                  children: [
                    const SizedBox(height: 330),
                    // CHANGED: Text color is now dark for readability
                    const Text('Nor Fatehah Binti Sofian', style: TextStyle(color: Colors.black87, fontSize: 20, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                    const SizedBox(height: 4),
                    // CHANGED: Text color is now gray for readability
                    Text('Bahagian Strategi dan Transformasi & ICT', style: TextStyle(color: Colors.grey[700], fontSize: 14, fontWeight: FontWeight.w600), textAlign: TextAlign.center),
                    const SizedBox(height: 45),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 36),
                      child: Row(
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
                    ),
                    const SizedBox(height: 85),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 36.0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        // CHANGED: Text color is now dark for readability
                        child: Text('Upcoming Booking', style: TextStyle(color: Colors.black.withOpacity(0.8), fontSize: 17, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 36.0),
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          // CHANGED: Card background is now solid white
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          // Optional: A more subtle shadow for a light background
                          boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))],
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // CHANGED: Icon now uses the primary brand color
                            const Icon(Icons.directions_car, size: 32, color: kPrimaryColor),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // CHANGED: Text color is now dark for readability
                                  const Text('Toyota Vellfire', style: TextStyle(color: Colors.black87, fontSize: 15, fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 2),
                                  // CHANGED: Text color is now gray for readability
                                  Text('30 Oct 2025 (Thu) • 10:00 AM – 3:00 PM', style: TextStyle(color: Colors.grey[700], fontSize: 13)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),

              // Layer 4: Logout Button (Unchanged, as it's on the dark image)
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

// --- Helper Widgets (With Color Adjustments) ---
class _StraightHeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path()..lineTo(0, size.height)..lineTo(size.width, size.height)..lineTo(size.width, 0)..close();
    return path;
  }
  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class _DashboardButton extends StatelessWidget {
  final IconData? iconData;
  final String label;
  final VoidCallback onTap;
  const _DashboardButton({this.iconData, required this.label, required this.onTap});

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
              // CHANGED: Button background is now solid white
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              // Optional: A more subtle shadow for a light background
              boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))],
            ),
            // CHANGED: Icon now uses the primary brand color
            child: Icon(iconData, size: 42, color: kPrimaryColor),
          ),
          const SizedBox(height: 8),
          // CHANGED: Text color is now dark for readability
          Text(label, style: const TextStyle(color: Colors.black87, fontSize: 15, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}