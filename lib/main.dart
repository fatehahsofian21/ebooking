import 'package:flutter/material.dart';

// Define custom colors based on the design
// You can adjust these hex codes to perfectly match your brand colors.
const Color kPrimaryColorStart = Color(0xFF63B8FF); // Light Blue
const Color kPrimaryColorEnd = Color(0xFF1E88E5);   // Slightly darker Blue
const Color kWarningColor = Colors.red;
const Color kBackgroundColor = Color(0xFFF7F9FC);

void main() {
  runApp(const PerkesoApp());
}

class PerkesoApp extends StatelessWidget {
  const PerkesoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PERKESO eBooking System',
      theme: ThemeData(
        // Set a light theme for the entire app
        brightness: Brightness.light,
        scaffoldBackgroundColor: kBackgroundColor,
        // Define a text theme, especially for the large title
        textTheme: const TextTheme(
          displaySmall: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: Color(0xFF333333), // Dark text color
          ),
        ),
        // Style for input fields
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          hintStyle: TextStyle(color: Colors.grey[600]),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 18.0, horizontal: 20.0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: const BorderSide(color: Colors.grey, width: 1.0),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: const BorderSide(color: Color(0xFFDDDDDD), width: 1.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide:
                const BorderSide(color: kPrimaryColorEnd, width: 2.0),
          ),
        ),
      ),
      home: const LoginPage(),
    );
  }
}

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  // Dummy function for button press handlers
  void _handlePress(String action) {
    debugPrint('$action pressed');
    // In a real app, you would implement navigation or API calls here.
  }

  @override
  Widget build(BuildContext context) {
    // Determine screen size for responsive layout adjustments
    final Size screenSize = MediaQuery.of(context).size;

    return Scaffold(
      // Use Stack to layer the custom background and the content
      body: Stack(
        children: <Widget>[
          // 1. Custom Wave Background
          CustomBackground(screenSize: screenSize),

          // 2. Main Content (Scrollable)
          // Use SingleChildScrollView to prevent overflow on smaller screens
          SingleChildScrollView(
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    // Spacer to position content correctly under the wave
                    SizedBox(height: screenSize.height * 0.20),

                    // --- Logo and Title Section ---
                    Center(
                      child: Column(
                        children: [
                          // *** FIX APPLIED HERE ***
                          Image.asset(
                            'assets/perkeso.png',
                            height: 100,
                            fit: BoxFit.contain,
                          ),
                          const SizedBox(height: 8.0),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32.0),

                    Text(
                      'eBooking System',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.displaySmall,
                    ),

                    const SizedBox(height: 48.0),

                    // --- Form Fields ---
                    const TextField(
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        hintText: 'Email',
                      ),
                    ),
                    const SizedBox(height: 20.0),
                    const TextField(
                      obscureText: true,
                      decoration: InputDecoration(
                        hintText: 'Password',
                      ),
                    ),
                    const SizedBox(height: 30.0),

                    // --- Login Button ---
                    GradientButton(
                      text: 'Login',
                      onPressed: () => _handlePress('Login'),
                      gradient: const LinearGradient(
                        colors: [kPrimaryColorStart, kPrimaryColorEnd],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                    ),
                    const SizedBox(height: 20.0),

                    // --- Warning Text ---
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        '**Please login to your account using PERKESO\'s E-mail Address and Password.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: kWarningColor,
                          fontSize: 12.0,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    // --- Bottom Links ---
                    const SizedBox(height: 50.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        BottomLink(
                            text: 'Forgot password?',
                            onPressed: () => _handlePress('Forgot password')),
                        BottomLink(
                            text: 'PDP Notice',
                            onPressed: () => _handlePress('PDP Notice')),
                      ],
                    ),
                    const SizedBox(height: 15.0),
                    Center(
                      child: BottomLink(
                          text: 'Booking Conditions',
                          onPressed: () => _handlePress('Booking Conditions')),
                    ),
                    const SizedBox(height: 40.0),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Custom widget for the gradient Login button
class GradientButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Gradient gradient;

  const GradientButton({
    super.key,
    required this.text,
    required this.onPressed,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50.0,
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: [
          BoxShadow(
            color: kPrimaryColorEnd.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(10.0),
          child: Center(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Custom widget for the hyperlinked text at the bottom
class BottomLink extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const BottomLink({
    super.key,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        padding: EdgeInsets.zero,
        minimumSize: const Size(1, 1),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: kPrimaryColorEnd,
          decoration: TextDecoration.underline,
          fontWeight: FontWeight.w600,
          fontSize: 13.0,
        ),
      ),
    );
  }
}

// CustomPainter to draw the wave-like background shape
class CustomBackground extends StatelessWidget {
  final Size screenSize;

  const CustomBackground({super.key, required this.screenSize});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(screenSize.width, screenSize.height * 0.4),
      painter: WavePainter(),
    );
  }
}

class WavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Create a linear gradient for the background
    final gradient = LinearGradient(
      colors: [kPrimaryColorStart.withOpacity(0.9), kPrimaryColorEnd.withOpacity(0.8)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final Paint paint = Paint()..shader = gradient;

    final path = Path();

    // Start from the top left
    path.lineTo(0, size.height * 0.4);

    // Wave 1: Curve 1
    path.cubicTo(
      size.width * 0.1,      // Control point x1
      size.height * 0.25,     // Control point y1
      size.width * 0.35,      // Control point x2
      size.height * 0.6,      // Control point y2
      size.width * 0.6,       // End point x
      size.height * 0.4,      // End point y
    );

    // Wave 2: Curve 2
    path.cubicTo(
      size.width * 0.8,       // Control point x1
      size.height * 0.2,      // Control point y1
      size.width * 0.9,       // Control point x2
      size.height * 0.5,      // Control point y2
      size.width,             // End point x
      size.height * 0.35,     // End point y
    );

    // Close the path to fill the area
    path.lineTo(size.width, 0);
    path.close();

    canvas.drawPath(path, paint);
    
    // Add a secondary, slightly transparent wave layer for depth
    final secondaryPaint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    final secondaryPath = Path();
    secondaryPath.lineTo(0, size.height * 0.3);
    
    // Secondary Wave Curve
    secondaryPath.cubicTo(
      size.width * 0.25,      // Control point x1
      size.height * 0.45,     // Control point y1
      size.width * 0.65,      // Control point x2
      size.height * 0.1,      // Control point y2
      size.width,             // End point x
      size.height * 0.2,      // End point y
    );

    secondaryPath.lineTo(size.width, 0);
    secondaryPath.close();

    canvas.drawPath(secondaryPath, secondaryPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
