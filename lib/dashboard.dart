import 'package:flutter/material.dart';
import 'main.dart';     // for logout navigation
import 'booking.dart';  // for booking page navigation
import 'package:flutter/services.dart';


// Updated gradient colors (light blue + grey)
const Color kPrimaryColorStart = Color(0xFFAED7FF); // soft light blue
const Color kPrimaryColorEnd   = Color(0xFFD6D6D6); // light grey

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Logout'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const IBookingApp()),
                (route) => false,
              );
            },
            child: const Text('Yes'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        // Makes status bar transparent & hides system inset
        value: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [kPrimaryColorStart, Color.fromARGB(255, 123, 166, 184)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Stack(
            children: [
              // ===== Full header image with caret shape (^)
              SizedBox(
                width: double.infinity,
                height: 350,
                child: ClipPath(
                  clipper: _CaretHeaderClipper(
                    leftDrop: 0.72,
                    rightDrop: 0.70,
                    peak: 0.50, // slightly lower and soft
                  ),
                  child: Image.asset(
                    'assets/bangunan.jpg',
                    fit: BoxFit.cover,
                    alignment: Alignment.topCenter,
                  ),
                ),
              ),

              // Logout icon (no background, just pop-out shadow)
              Positioned(
                top: 25, // still visible after status bar removed
                right: 16,
                child: Container(
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.power_settings_new,
                      color: Colors.white,
                      size: 28,
                    ),
                    tooltip: 'Log out',
                    onPressed: () => _confirmLogout(context),
                    style: IconButton.styleFrom(
                      shadowColor: Colors.black.withOpacity(0.5),
                      elevation: 12,
                      backgroundColor: Colors.transparent,
                    ),
                  ),
                ),
              ),

              // ===== Main content =====
              Align(
                alignment: Alignment.topCenter,
                child: Column(
                  children: [
                    const SizedBox(height: 140),

                    // Profile avatar
                    const CircleAvatar(
                      radius: 45,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.person, size: 70, color: Color(0xFF1E88E5)),
                    ),
                    const SizedBox(height: 10),

                    // Name
                    const Text(
                      'Nor Fatehah Binti Sofian',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),

                    // Department
                    const Text(
                      'Bahagian Strategi dan Transformasi & ICT',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 56),

                    // Two main buttons
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 36),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _DashboardButton(
                            icon: Icons.meeting_room,
                            label: 'Meeting Room',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const BookingPage()),
                              );
                            },
                          ),
                          _DashboardButton(
                            icon: Icons.directions_car_filled,
                            label: 'Vehicle',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const BookingPage()),
                              );
                            },
                          ),
                        ],
                      ),
                    ),

                    const Expanded(child: SizedBox()),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Caret (^) header clipper with gentle, soft center
class _CaretHeaderClipper extends CustomClipper<Path> {
  final double leftDrop;
  final double rightDrop;
  final double peak;

  _CaretHeaderClipper({
    this.leftDrop = 0.72,
    this.rightDrop = 0.70,
    this.peak = 0.50,
  });

  @override
  Path getClip(Size size) {
    final w = size.width;
    final h = size.height;

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(0, h * leftDrop)
      ..quadraticBezierTo(w * 0.25, h * (leftDrop + peak) / 2, w * 0.5, h * peak)
      ..quadraticBezierTo(w * 0.75, h * (rightDrop + peak) / 2, w, h * rightDrop)
      ..lineTo(w, 0)
      ..close();

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

/// Button style (Meeting Room / Vehicle)
class _DashboardButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _DashboardButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            height: 90,
            width: 90,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 10,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Icon(icon, size: 42, color: Colors.white),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
