import 'package:flutter/material.dart';
import 'package:ibooking/dashboard.dart';
import 'package:ibooking/myBooking.dart'; // Import MyBookingPage

// Solid dark blue theme
const Color kPrimaryColor = Color.fromARGB(255, 24, 42, 94); // Dark Blue
const Color kAccentColor = Color(0xFF63B8FF);  // Light blue accent
const Color kWarningColor = Colors.red;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const IBookingApp());
}

class IBookingApp extends StatelessWidget {
  const IBookingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PERKESO iBooking',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        fontFamily: 'Roboto',  // Explicitly set Roboto as the default font.
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
          displayMedium: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
          displaySmall: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
          bodyLarge: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: Colors.black,
          ),
        ),
        primaryColor: kPrimaryColor,
        // Replacing accentColor with colorScheme
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
      },
    );
  }
}

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

  // Dummy credentials
  final String correctEmail = "fatehah.sofian@perkeso.gov.my";
  final String correctPassword = "fatehah2102_";

  void _handleLogin(BuildContext context) {
    final email = emailController.text.trim();
    final password = passwordController.text;

    if (email == correctEmail && password == correctPassword) {
      setState(() => errorMessage = null);
      if (!mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil('/dashboard', (route) => false);
    } else {
      setState(() {
        errorMessage = "Email or password entered is incorrect.";
      });
    }
  }

  InputDecoration _transparentFieldDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.white70),
      filled: false,
      fillColor: Colors.transparent,
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(color: Colors.white70.withOpacity(0.55), width: 1.2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: const BorderSide(color: Colors.white, width: 1.8),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: kPrimaryColor,
        child: Center(
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
                        Image.asset('assets/perkeso.png', height: 90, fit: BoxFit.contain),
                        const SizedBox(height: 8.0),
                        const Text(
                          'iBooking',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 36.0),
                  TextField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    style: const TextStyle(color: Colors.white),
                    cursorColor: Colors.white,
                    decoration: _transparentFieldDecoration('Email'),
                  ),
                  const SizedBox(height: 16.0),
                  TextField(
                    controller: passwordController,
                    obscureText: !_isPasswordVisible,
                    style: const TextStyle(color: Colors.white),
                    cursorColor: Colors.white,
                    decoration: _transparentFieldDecoration('Password').copyWith(
                      suffixIcon: IconButton(
                        icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off, color: Colors.white),
                        iconSize: 22,
                        padding: const EdgeInsets.all(8.0),
                        constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                        onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {},
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(1, 1),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text(
                        'Forgot password?',
                        style: TextStyle(
                          color: Colors.white,
                          decoration: TextDecoration.underline,
                          fontWeight: FontWeight.w600,
                          fontSize: 13.0,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  if (errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 6.0, bottom: 6.0),
                      child: Text(
                        errorMessage!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: kWarningColor, fontWeight: FontWeight.w600, fontSize: 13.0),
                      ),
                    ),
                  const SizedBox(height: 18.0),
                  GradientButton(
                    text: 'Login',
                    onPressed: () => _handleLogin(context),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF63B8FF), Color(0xFF1E88E5)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                  ),
                  const SizedBox(height: 22.0),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      '**Please login using your PERKESO email address and password.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white70, fontSize: 12.0, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
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
          BoxShadow(color: Colors.black.withOpacity(0.35), blurRadius: 12, offset: const Offset(0, 6)),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(10.0),
          child: const Center(
            child: Text('Login', style: TextStyle(color: Colors.white, fontSize: 18.0, fontWeight: FontWeight.bold)),
          ),
        ),
      ),
    );
  }
}
