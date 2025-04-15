import 'package:flutter/material.dart';

class VoiceRecognitionPage extends StatelessWidget {
  const VoiceRecognitionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Voice Recognition')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.mic, size: 80),
            const SizedBox(height: 20),
            const Text('Just pretend to speak something cool 😄'),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/home');
              },
              child: const Text('Simulate Voice Success'),
            ),
          ],
        ),
      ),
    );
  }
}
