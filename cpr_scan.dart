import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class CPRScanPage extends StatelessWidget {
  const CPRScanPage({super.key});

  Future<void> _openCamera(BuildContext context) async {
    final picker = ImagePicker();
    await picker.pickImage(source: ImageSource.camera); // no need to use image
    Navigator.pushNamed(context, '/face_scan');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('CPR Scan')),
      body: Center(
        child: ElevatedButton(
          onPressed: () => _openCamera(context),
          child: const Text('Open Camera to Scan CPR'),
        ),
      ),
    );
  }
}
