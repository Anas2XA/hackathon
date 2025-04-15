import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class OTPPage extends StatefulWidget {
  final String phoneNumber;
  final String verificationId;
  final String deviceUUID;
  final String storedDeviceUUID;

  const OTPPage({
    super.key,
    required this.phoneNumber,
    required this.verificationId,
    required this.deviceUUID,
    required this.storedDeviceUUID,
  });

  @override
  _OTPPageState createState() => _OTPPageState();
}

class _OTPPageState extends State<OTPPage> with SingleTickerProviderStateMixin {
  final List<TextEditingController> controllers = List.generate(6, (_) => TextEditingController());
  final FirebaseAuth _auth = FirebaseAuth.instance;
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

  String _maskPhoneNumber(String phoneNumber) {
    if (phoneNumber.length > 5) {
      return phoneNumber.replaceRange(3, phoneNumber.length - 2, 'XXXXX');
    }
    return phoneNumber;
  }

  Future<void> _verifyOTP() async {
    final otp = controllers.map((controller) => controller.text.trim()).join();

    if (otp.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter all six digits.')),
      );
      return;
    }

    try {
      print("🔄 Attempting OTP Verification...");
      
      if (widget.verificationId.isEmpty) {
        print("❌ ERROR: Empty verificationId!");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error: Invalid OTP session. Please try logging in again.'),
          ),
        );
        return;
      }

      // Create credential using the OTP
      final PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: widget.verificationId,
        smsCode: otp,
      );

      // Sign in the user
      UserCredential userCredential = await _auth.signInWithCredential(credential);
      print("✅ OTP Verified Successfully! User: ${userCredential.user?.uid}");

      // Check UUID after successful authentication
      if (widget.deviceUUID != widget.storedDeviceUUID) {
        print("❌ Device UUID mismatch! Stored: ${widget.storedDeviceUUID}, Current: ${widget.deviceUUID}");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text( //Wrong device UUID
              'Access Denied❌: You are trying to log in from a different device Or Wrong OTP code',
            ),
          ),
        );
        return;
      }

      print("✅ Device UUID Matched! Redirecting to Home...");
      Navigator.pushNamed(context, '/home', arguments: widget.deviceUUID);
    } catch (e) {
      print("❌ Error during OTP verification: $e");
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text( //wrong OTP code
            'Access Denied❌: You are trying to log in from a different device Or Wrong OTP code',
          ),
        ),
      );
    }
  }

  Widget _buildOTPField(int index) {
    return Flexible(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: TextField(
          controller: controllers[index],
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          maxLength: 1,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          decoration: InputDecoration(
            counterText: '',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
          onChanged: (value) {
            if (value.isNotEmpty && index < 5) {
              FocusScope.of(context).nextFocus();
            } else if (value.isEmpty && index > 0) {
              FocusScope.of(context).previousFocus();
            }
          },
        ),
      ),
    );
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
                      'Verification',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Enter the verification code sent to ${_maskPhoneNumber(widget.phoneNumber)}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 24),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(6, (index) => _buildOTPField(index)),
                      ),
                    ),

                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _verifyOTP,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 40),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('Verify OTP'),
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
}