import 'package:flutter/material.dart';
import 'package:pattern_lock/pattern_lock.dart';

class PatternLockPage2 extends StatelessWidget {
  const PatternLockPage2({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pattern Lock (Login)')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Draw any pattern to login'),
            const SizedBox(height: 20),
            SizedBox(
              height: 300,
              child: PatternLock(
                selectedColor: Colors.blue,
                pointRadius: 10,
                dimension: 3,
                onInputComplete: (_) {
                  Navigator.pushNamed(context, '/home');
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
