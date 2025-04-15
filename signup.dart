import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:math';
import 'dart:convert';
import 'package:crypto/crypto.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> with SingleTickerProviderStateMixin {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference database = FirebaseDatabase.instance.ref();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );
    _animationController.forward();
  }

  Future<String> _getDeviceUUID() async {
    final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    String? deviceUUID;
    if (Theme.of(context).platform == TargetPlatform.android) {
      final androidInfo = await deviceInfo.androidInfo;
      deviceUUID = androidInfo.id;
    } else if (Theme.of(context).platform == TargetPlatform.iOS) {
      final iosInfo = await deviceInfo.iosInfo;
      deviceUUID = iosInfo.identifierForVendor;
    }
    return deviceUUID != null
        ? sha256.convert(utf8.encode(deviceUUID)).toString()
        : '';
  }

  List<int> _generateSeed() {
    final random = Random.secure();
    return List.generate(12, (_) => random.nextInt(900) + 100); // Generates a 3-digit number
  }

  Future<void> _signUpUser() async {
    if (passwordController.text.trim() != confirmPasswordController.text.trim()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match!')),
      );
      return;
    }

    if (phoneNumberController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Phone number is required!')),
      );
      return;
    }

    try {
      // ✅ Step 1: Create User with Email & Password
      final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      final User? user = userCredential.user;
      if (user == null) {
        throw Exception("User creation failed.");
      }

      final String deviceUUID = await _getDeviceUUID();
      final List<int> seed = _generateSeed();
      final String seedHash = sha256.convert(utf8.encode(seed.join(' '))).toString(); // Hash the seed

      // ✅ Step 2: Save User Data in Firebase Realtime Database
      await database.child('users/${user.uid}').set({
        'email': emailController.text.trim(),
        'phone_number': phoneNumberController.text.trim(),
        'device_uuid': deviceUUID,
        'seed': seedHash, // Save the hashed seed
        'created_at': DateTime.now().toIso8601String(),
      });

      // ✅ Step 3: Show New Seed Code
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Your Seed Code'),
          content: Text(
            'This is your recovery seed code. Please keep it safe and secret:\n\n${seed.join(' ')}',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pushNamed(context, '/login'),
              child: const Text('I Understand'),
            ),
          ],
        ),
      );
    } catch (e) {
      print("❌ Error during sign-up: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1A237E), Color(0xFF42A5F5)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              margin: const EdgeInsets.all(20),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Sign Up',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: emailController,
                      decoration: _customInputDecoration('Email'),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: _customInputDecoration('Password'),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: confirmPasswordController,
                      obscureText: true,
                      decoration: _customInputDecoration('Confirm Password'),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: phoneNumberController,
                      keyboardType: TextInputType.phone,
                      decoration: _customInputDecoration('Phone Number (e.g., +1234567890)'),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _signUpUser,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 40),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('Sign Up'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/login');
                      },
                      child: const Text('Already have an account? Login'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _customInputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      filled: true,
      fillColor: Colors.white,
    );
  }
}