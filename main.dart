import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// Pages
import 'pages/login.dart';
import 'pages/signup.dart';
import 'pages/home.dart';
import 'pages/recover.dart';
import 'pages/cpr_scan.dart';
import 'pages/face_scan.dart';
import 'pages/pattern_lock.dart';
import 'pages/pattern2.dart';
import 'pages/voice_recognition.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF1A237E),
        colorScheme: ColorScheme.fromSwatch().copyWith(
          secondary: const Color(0xFF42A5F5),
        ),
        scaffoldBackgroundColor: Colors.white,
        textTheme: const TextTheme(
          bodyLarge: TextStyle(fontSize: 18, color: Colors.black),
          bodyMedium: TextStyle(fontSize: 16, color: Colors.black54),
        ),
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginPage(),
        '/signup': (context) => const SignupPage(),
        '/home': (context) => const HomePage(),
        '/recover': (context) => const RecoverPage(),
        '/cpr_scan': (context) => const CPRScanPage(),
        '/face_scan': (context) => const FaceScanPage(),
        '/pattern_lock': (context) => const PatternLockPage(),
        '/pattern_lock2': (context) => const PatternLockPage2(),
        '/voice_recognition': (context) => const VoiceRecognitionPage(),
      },
    );
  }
}
