import 'package:flutter/material.dart';
import 'package:ibooking/dashboard.dart';
import 'package:ibooking/myBooking.dart';
// --- CHANGE: Added import for the new Approver Dashboard Screen ---
import 'package:ibooking/AppDash.dart';
// --- CHANGE: Added import for the new Driver Dashboard Screen ---
import 'package:ibooking/DriDash.dart'; // Make sure you have created this file

// --- Colors ---
const Color kPrimaryColor = Color(0xFF007DC5); // Primary Blue
const Color kAccentColor = Color(0xFF8DC63E); // Secondary Green
const Color kWarningColor = Colors.red;
const Color kBackgroundColor = Color(0xFFF5F5F5); // Background 800
const Color kLightBlueWave = Color(0xFFE0F7FA); // Light cyan for the waves

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const IBookingApp());
}

class IBookingApp extends StatelessWidget {
  const IBookingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PERKESO SmartBooking',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        fontFamily: 'Roboto',
        textTheme: const TextTheme(
          displayLarge: TextStyle(
              fontSize: 40, fontWeight: FontWeight.w700, color: Colors.white),
          displayMedium: TextStyle(
              fontSize: 28, fontWeight: FontWeight.w600, color: Colors.white),
          displaySmall: TextStyle(
              fontSize: 22, fontWeight: FontWeight.w500, color: Colors.white),
          bodyLarge: TextStyle(
              fontSize: 16, fontWeight: FontWeight.w400, color: Colors.black),
        ),
        primaryColor: kPrimaryColor,
        colorScheme: ColorScheme.light(
          primary: kPrimaryColor,
          secondary: kAccentColor,
        ),
      ),
      home: const LoginPage(),
      routes: {
        '/login': (context) => const LoginPage(),
        '/dashboard': (context) => const DashboardScreen(),
        '/myBookingPage': (context) => MyBookingPage(),
        // --- CHANGE: Added the route for the Approver Dashboard ---
        '/appdash': (context) => const AppDash(),
        // --- CHANGE: Added the route for the Driver Dashboard ---
        '/dridash': (context) => const DriDash(),
      },
    );
  }
}

// --- START: Wavy Background Clippers ---
// These classes create the custom wavy shapes.

class TopWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height * 0.8);
    var firstControlPoint = Offset(size.width / 4, size.height);
    var firstEndPoint = Offset(size.width / 2.25, size.height - 30.0);
    path.quadraticBezierTo(firstControlPoint.dx, firstControlPoint.dy,
        firstEndPoint.dx, firstEndPoint.dy);

    var secondControlPoint =
        Offset(size.width - (size.width / 3.25), size.height - 65);
    var secondEndPoint = Offset(size.width, size.height - 40);
    path.quadraticBezierTo(secondControlPoint.dx, secondControlPoint.dy,
        secondEndPoint.dx, secondEndPoint.dy);

    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class BottomWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.moveTo(0, size.height);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width, 20);
    var firstControlPoint = Offset(size.width * 0.75, 0);
    var firstEndPoint = Offset(size.width * 0.5, 30);
    path.quadraticBezierTo(firstControlPoint.dx, firstControlPoint.dy,
        firstEndPoint.dx, firstEndPoint.dy);

    var secondControlPoint = Offset(size.width * 0.25, 60);
    var secondEndPoint = Offset(0, 40);
    path.quadraticBezierTo(secondControlPoint.dx, secondControlPoint.dy,
        secondEndPoint.dx, secondEndPoint.dy);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

// --- END: Wavy Background Clippers ---

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  String? errorMessage;

  void _handleLogin(BuildContext context) {
    final email = emailController.text.trim();
    final password = passwordController.text;

    // --- CHANGE: Added Driver user credentials ---
    const String driverEmail = "driver@perkeso.gov.my";
    const String driverPassword = "1234";

    // Approver user credentials
    const String approverEmail = "approver@perkeso.gov.my";
    const String approverPassword = "1234";

    // Regular user credentials
    const String correctEmail = "user@perkeso.gov.my";
    const String correctPassword = "1234";

    // --- CHANGE: Updated logic to check for all user roles ---
    // Check for driver credentials
    if (email == driverEmail && password == driverPassword) {
      setState(() => errorMessage = null);
      if (!mounted) return;
      // Navigate to the Driver Dashboard
      Navigator.of(context)
          .pushNamedAndRemoveUntil('/dridash', (route) => false);
    }
    // Check for approver credentials
    else if (email == approverEmail && password == approverPassword) {
      setState(() => errorMessage = null);
      if (!mounted) return;
      // Navigate to the Approver Dashboard
      Navigator.of(context)
          .pushNamedAndRemoveUntil('/appdash', (route) => false);
    }
    // Check for regular user credentials
    else if (email == correctEmail && password == correctPassword) {
      setState(() => errorMessage = null);
      if (!mounted) return;
      // Navigate to the standard Dashboard
      Navigator.of(context)
          .pushNamedAndRemoveUntil('/dashboard', (route) => false);
    }
    // If no credentials match, show an error
    else {
      setState(() {
        errorMessage = "Email or password entered is incorrect.";
      });
    }
  }

  InputDecoration _fieldDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.grey),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(color: Colors.grey.shade400, width: 1.2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: const BorderSide(color: kPrimaryColor, width: 1.8),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: kBackgroundColor,
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: ClipPath(
              clipper: TopWaveClipper(),
              child: Container(
                height: screenHeight * 0.15,
                color: const Color.fromARGB(255, 182, 224, 230),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: ClipPath(
              clipper: BottomWaveClipper(),
              child: Container(
                height: screenHeight * 0.13,
                 color: const Color.fromARGB(255, 182, 224, 230),
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Center(
                      child: Column(
                        children: [
                          Image.asset('assets/perkeso.png',
                              height: 90, fit: BoxFit.contain),
                          const SizedBox(height: 8.0),
                          const Text(
                            'SmartBooking',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w700,
                                color: kPrimaryColor),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 36.0),
                    TextField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      style: const TextStyle(color: Colors.black),
                      cursorColor: kPrimaryColor,
                      decoration: _fieldDecoration('Email'),
                    ),
                    const SizedBox(height: 16.0),
                    TextField(
                      controller: passwordController,
                      obscureText: !_isPasswordVisible,
                      style: const TextStyle(color: Colors.black),
                      cursorColor: kPrimaryColor,
                      decoration: _fieldDecoration('Password').copyWith(
                        suffixIcon: IconButton(
                          icon: Icon(
                              _isPasswordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: Colors.grey),
                          onPressed: () =>
                              setState(() => _isPasswordVisible = !_isPasswordVisible),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {},
                        child: const Text(
                          'Forgot password?',
                          style: TextStyle(
                            color: kPrimaryColor,
                            decoration: TextDecoration.underline,
                            fontWeight: FontWeight.w600,
                            fontSize: 13.0,
                          ),
                        ),
                      ),
                    ),
                    if (errorMessage != null)
                      Padding(
                        padding:
                            const EdgeInsets.only(top: 6.0, bottom: 6.0),
                        child: Text(errorMessage!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                color: kWarningColor,
                                fontWeight: FontWeight.w600,
                                fontSize: 13.0)),
                      ),
                    const SizedBox(height: 18.0),
                    GradientButton(
                      text: 'Login',
                      onPressed: () => _handleLogin(context),
                      gradient: LinearGradient(
                        colors: [
                          kPrimaryColor,
                          Color.lerp(kPrimaryColor, Colors.blue, 0.4)!
                        ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                    ),
                    const SizedBox(height: 22.0),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        '**Please login using your PERKESO email address and password.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.grey.shade700,
                            fontSize: 12.0,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
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
              color: Colors.blue.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 6)),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(10.0),
          child: const Center(
            child: Text('Login',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold)),
          ),
        ),
      ),
    );
  }
}