import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ibooking/Vcalendar';
// import 'package:shared_preferences/shared_preferences.dart'; // REMOVED
import 'package:ibooking/main.dart'; 

const Color kPrimaryColor = Color.fromARGB(255, 24, 42, 94);
const Color kAccentColor = Color(0xFF63B8FF);

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  // Logout function: Only navigates to LoginPage and clears the stack
  Future<void> _logout(BuildContext context) async {
    // REMOVED SharedPreferences logic (no more saving/clearing login state)
    
    // ✅ FIX: Use MaterialPageRoute to directly navigate to LoginPage 
    // and remove all previous screens.
    if (context.mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginPage()), // Direct navigation
        (route) => false,
      );
    }
  }

  // Confirm dialog before logout
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
      await _logout(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
        child: Container(
          width: double.infinity,
          height: double.infinity,
          color: kPrimaryColor,
          child: Stack(
            children: [
              // ===== Straight header image =====
              SizedBox(
                width: double.infinity,
                height: 280,
                child: ClipPath(
                  clipper: _StraightHeaderClipper(),
                  child: Image.asset(
                    'assets/bangunan.jpg',
                    fit: BoxFit.cover,
                    alignment: Alignment.topCenter,
                  ),
                ),
              ),

              // ===== Logout button (Re-added) =====
              Positioned(
                top: 25,
                right: 16,
                child: IconButton(
                  icon: const Icon(Icons.power_settings_new, color: Colors.white, size: 28),
                  tooltip: 'Log out',
                  onPressed: () => _confirmLogout(context), // Re-added call
                  style: IconButton.styleFrom(
                    shadowColor: Colors.white.withOpacity(0.4),
                    elevation: 10,
                    backgroundColor: Colors.transparent,
                  ),
                ),
              ),

              // ===== Profile picture overlapping header line =====
              Positioned(
                top: 240,
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

              // ===== Scrollable Content Below =====
              SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 340),
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
                    const Text(
                      'Bahagian Strategi dan Transformasi & ICT',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 45),

                    // ===== Buttons =====
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

                    // ===== Upcoming Booking =====
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 36.0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Upcoming Booking',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 36.0),
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.07),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.15),
                            width: 0.7,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: const [
                            Icon(Icons.directions_car, size: 32, color: Colors.white),
                            SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Toyota Vellfire',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    '30 Oct 2025 (Thu) • 10:00 AM – 3:00 PM',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 13,
                                    ),
                                  ),
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
            ],
          ),
        ),
      ),
    );
  }
}

// Straight header clipper
class _StraightHeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path()
      ..lineTo(0, size.height)
      ..lineTo(size.width, size.height)
      ..lineTo(size.width, 0)
      ..close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

// Dashboard button widget (updated to use images)
class _DashboardButton extends StatelessWidget {
  final String? imagePath;
  final IconData? iconData;
  final String label;
  final VoidCallback onTap;

  const _DashboardButton({
    this.imagePath,
    this.iconData,
    required this.label,
    required this.onTap,
  }) : assert(imagePath != null || iconData != null, 'Either imagePath or iconData must be provided');

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
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.25), width: 0.8),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.10), blurRadius: 8, offset: const Offset(0, 4)),
              ],
            ),
            child: (iconData != null)
                ? Icon(iconData, size: 42, color: Colors.white)
                : Image.asset(imagePath!, fit: BoxFit.cover),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}