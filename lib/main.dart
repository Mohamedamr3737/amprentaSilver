import 'package:flutter/material.dart';
import 'package:biopassid_fingerprint_sdk/biopassid_fingerprint_sdk.dart';
import 'dart:typed_data';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fingerprint Scanner',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const FingerprintScreen(),
    );
  }
}

class FingerprintScreen extends StatefulWidget {
  const FingerprintScreen({super.key});

  @override
  State<FingerprintScreen> createState() => _FingerprintScreenState();
}

class _FingerprintScreenState extends State<FingerprintScreen> {
  late FingerprintController controller;
  Uint8List? _fingerprintImage; // Stores the fingerprint image
  String _statusMessage = "Press 'Capture Fingerprint' to start"; // Stores status messages

  @override
  void initState() {
    super.initState();

    // Initialize the fingerprint scanner with your license key
    final config = FingerprintConfig(licenseKey: 'EGUM-V26N-8FR3-WHFI');

    controller = FingerprintController(
      config: config,
      onFingerCapture: (images, error) {
        if (error != null) {
          setState(() {
            _statusMessage = "Error capturing fingerprint: $error";
          });
          print('Error capturing fingerprint: $error');
          return;
        }

        if (images.isNotEmpty) {
          Uint8List fingerprintData = images[1]; // Extract the first fingerprint image

          setState(() {
            _fingerprintImage = fingerprintData;
            _statusMessage = "Fingerprint captured successfully!";
          });

          print('Fingerprint captured successfully!');
        } else {
          setState(() {
            _statusMessage = "No fingerprint detected.";
          });
          print('No fingerprint images found.');
        }
      },
      onStatusChanged: (FingerprintCaptureState state) {
        setState(() {
          _statusMessage = "Status: $state";
        });
        print('onStatusChanged: $state');
      },
      onFingerDetected: (List<Rect> fingerRects) {
        print('onFingerDetected: $fingerRects');
      },
    );
  }

  // Function to start fingerprint capture
  void takeFingerprint() async {
    setState(() {
      _statusMessage = "Capturing fingerprint...";
    });
    await controller.takeFingerprint();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fingerprint Scanner'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: ElevatedButton(
              onPressed: takeFingerprint,
              child: const Text('Capture Fingerprint'),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            _statusMessage,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          // Display the fingerprint image if available
          if (_fingerprintImage != null)
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black, width: 2),
              ),
              child: Image.memory(
                _fingerprintImage!,
                fit: BoxFit.contain,
              ),
            )
          else
            const Text('No fingerprint captured yet'),
        ],
      ),
    );
  }
}
