import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class FaceScanPage extends StatelessWidget {
  const FaceScanPage({super.key});

  Future<void> _scanFace(BuildContext context) async {
    final picker = ImagePicker();
    await picker.pickImage(source: ImageSource.camera); // simulate face scan
    Navigator.pushNamed(context, '/pattern_lock');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Face Scan')),
      body: Center(
        child: ElevatedButton(
          onPressed: () => _scanFace(context),
          child: const Text('Scan Face'),
        ),
      ),
    );
  }
}
