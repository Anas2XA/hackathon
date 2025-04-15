import 'package:flutter/material.dart';
import 'package:pattern_lock/pattern_lock.dart';

class PatternLockPage extends StatelessWidget {
  const PatternLockPage({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map?;
    final isSignUpFlow = args?['isSignUpFlow'] ?? true;

    return Scaffold(
      appBar: AppBar(title: const Text('Pattern Lock (Sign Up)')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Draw your sign-up pattern'),
            const SizedBox(height: 20),
            SizedBox(
              height: 300,
              child: PatternLock(
                selectedColor: Colors.blue,
                pointRadius: 10,
                dimension: 3,
                onInputComplete: (_) {
                  if (isSignUpFlow) {
                    Navigator.pushNamed(context, '/voice_recognition');
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
