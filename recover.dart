import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'dart:math';

class RecoverPage extends StatefulWidget {
  const RecoverPage({super.key});

  @override
  _RecoverPageState createState() => _RecoverPageState();
}

class _RecoverPageState extends State<RecoverPage> with SingleTickerProviderStateMixin {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final List<TextEditingController> seedControllers = List.generate(12, (_) => TextEditingController());
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

  List<int> _generateNewSeed() {
    final random = Random.secure();
    return List.generate(12, (_) => random.nextInt(900) + 100); // Generates a new 3-digit seed
  }

  void _recoverAccount() async {
    try {
      final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      final User? currentUser = userCredential.user;

      if (currentUser == null) {
        throw Exception('No authenticated user found.');
      }

      final DataSnapshot snapshot = await database.child('users/${currentUser.uid}/seed').get();

      if (snapshot.value == null) {
        throw Exception('No seed found for this account.');
      }

      final String storedSeedHash = snapshot.value as String; // Stored hashed seed
      final List<String> enteredSeed = seedControllers.map((controller) => controller.text.trim()).toList();
      final String normalizedEnteredSeed = enteredSeed.join(' ');

      // Hash the entered seed for comparison
      final String enteredSeedHash = sha256.convert(utf8.encode(normalizedEnteredSeed)).toString();

      if (enteredSeedHash != storedSeedHash) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Access Denied: Wrong seed.'),
          ),
        );
        return;
      }

      final String newDeviceUUID = await _getDeviceUUID();
      final List<int> newSeed = _generateNewSeed();
      final String newSeedHash = sha256.convert(utf8.encode(newSeed.join(' '))).toString(); // Hash the new seed

      // Update the database with the new UUID and new hashed seed
      await database.child('users/${currentUser.uid}').update({
        'device_uuid': newDeviceUUID,
        'seed': newSeedHash, // Save the new hashed seed
      });

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('New Seed Code'),
          content: Text(
            'Your recovery was successful! Here is your new recovery seed:\n\n${newSeed.join(' ')}',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pushNamed(context, '/home', arguments: newDeviceUUID),
              child: const Text('Proceed to Home'),
            ),
          ],
        ),
      );
    } catch (e) {
      print('Error during recovery: $e');
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
                      'Recover Account',
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
                    const SizedBox(height: 24),
                    const Text(
                      'Enter Your 12-Number Seed:',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),

                    // Grid layout for seed inputs
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: List.generate(12, (index) {
                        return SizedBox(
                          width: 70,
                          child: TextField(
                            controller: seedControllers[index],
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            maxLength: 3,
                            decoration: InputDecoration(
                              counterText: "",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              labelText: '${index + 1}',
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _recoverAccount,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 40),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('Recover Account'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/login');
                      },
                      child: const Text('Back to Login'),
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