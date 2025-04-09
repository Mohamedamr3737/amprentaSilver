import 'package:flutter/material.dart';
import 'package:biopassid_fingerprint_sdk/biopassid_fingerprint_sdk.dart';
import 'dart:typed_data';
import '../utils/animations.dart';
import 'order_form_screen.dart';
import 'dart:io';
import 'package:camera/camera.dart';
import '../components/camera_view.dart';

class FingerprintScreen extends StatefulWidget {
  const FingerprintScreen({super.key});

  @override
  State<FingerprintScreen> createState() => _FingerprintScreenState();
}

class _FingerprintScreenState extends State<FingerprintScreen> with SingleTickerProviderStateMixin {
  late FingerprintController controller;
  Uint8List? _fingerprintImage;
  String _statusMessage = "Press 'Capture Fingerprint' to start";
  bool _isCapturing = false;
  bool _showImage = false;

  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    // Animation setup
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();

    // Initialize the fingerprint scanner with your license key
    final config = FingerprintConfig(licenseKey: 'EGUM-V26N-8FR3-WHFI');

    controller = FingerprintController(
      config: config,
      onFingerCapture: (images, error) {
        if (error != null) {
          setState(() {
            _statusMessage = "Error capturing fingerprint: $error";
            _isCapturing = false;
            _showImage = false;
          });
          print('Error capturing fingerprint: $error');
          return;
        }

        if (images.isNotEmpty) {
          Uint8List fingerprintData = images[1]; // Extract the first fingerprint image

          setState(() {
            _fingerprintImage = fingerprintData;
            _isCapturing = false;
            _showImage = true;
            _statusMessage = "Fingerprint captured successfully!";
          });

          print('Fingerprint captured successfully!');
        } else {
          setState(() {
            _statusMessage = "No fingerprint detected.";
            _isCapturing = false;
            _showImage = false;
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

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // Function to start fingerprint capture
  void takeFingerprint() async {
    setState(() {
      _statusMessage = "Capturing fingerprint...";
      _isCapturing = true;
      _showImage = false;
    });
    await controller.takeFingerprint();
  }

  // Function to show camera UI
  void _showCameraUI() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            CameraView(
              title: 'Fingerprint Camera',
              guideText: 'Place finger here',
              overlayIcon: Icons.fingerprint,
              onImageCaptured: _handleCapturedImage,
            ),
      ),
    );
  }

  // Handle the captured image
  void _handleCapturedImage(XFile image) {
    setState(() {
      _isCapturing = true;
      _statusMessage = "Processing image...";
    });

    // Read the image file
    File(image.path).readAsBytes().then((bytes) {
      setState(() {
        _fingerprintImage = bytes;
        _isCapturing = false;
        _showImage = true;
        _statusMessage = "Fingerprint captured successfully!";
      });
    }).catchError((error) {
      setState(() {
        _isCapturing = false;
        _statusMessage = "Error processing image: $error";
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomPadding = MediaQuery
        .of(context)
        .padding
        .bottom;
    final screenSize = MediaQuery
        .of(context)
        .size;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Fingerprint Scanner'),
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      FadeTransition(
                        opacity: _animation,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0, -0.2),
                            end: Offset.zero,
                          ).animate(_animation),
                          child: Text(
                            'Fingerprint Scan',
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: screenSize.width < 360 ? 20 : null,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      FadeTransition(
                        opacity: _animation,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0, -0.2),
                            end: Offset.zero,
                          ).animate(_animation),
                          child: Text(
                            'Capture a high-quality fingerprint image',
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: screenSize.width < 360 ? 14 : 16,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Status message
                      FadeTransition(
                        opacity: _animation,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0, 0),
                            end: Offset.zero,
                          ).animate(_animation),
                          child: Container(
                            padding: EdgeInsets.all(
                                screenSize.width < 360 ? 12 : 16),
                            decoration: BoxDecoration(
                              color: _showImage
                                  ? Colors.green.withOpacity(0.1)
                                  : theme.colorScheme.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _showImage
                                    ? Colors.green
                                    : theme.colorScheme.primary,
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                if (_showImage)
                                  Icon(
                                    Icons.check_circle,
                                    color: Colors.green,
                                    size: screenSize.width < 360 ? 20 : 24,
                                  ),
                                if (_isCapturing)
                                  SizedBox(
                                    width: screenSize.width < 360 ? 20 : 24,
                                    height: screenSize.width < 360 ? 20 : 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: theme.colorScheme.primary,
                                    ),
                                  ),
                                if (!_showImage && !_isCapturing)
                                  Icon(
                                    Icons.info_outline,
                                    color: theme.colorScheme.primary,
                                    size: screenSize.width < 360 ? 20 : 24,
                                  ),
                                SizedBox(
                                    width: screenSize.width < 360 ? 8 : 12),
                                Expanded(
                                  child: Text(
                                    _statusMessage,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      color: _showImage
                                          ? Colors.green[800]
                                          : theme.colorScheme.primary,
                                      fontSize: screenSize.width < 360
                                          ? 13
                                          : 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),

                      // Fingerprint image display
                      FadeTransition(
                        opacity: _animation,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0, 0.2),
                            end: Offset.zero,
                          ).animate(_animation),
                          child: Container(
                            height: screenSize.height * 0.3,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: theme.cardTheme.color,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 10,
                                  spreadRadius: 0,
                                ),
                              ],
                              border: _showImage
                                  ? Border.all(
                                color: Colors.green,
                                width: 2,
                              )
                                  : null,
                            ),
                            child: _fingerprintImage != null
                                ? ClipRRect(
                              borderRadius: BorderRadius.circular(18),
                              child: Stack(
                                children: [
                                  // Fingerprint image
                                  Positioned.fill(
                                    child: Image.memory(
                                      _fingerprintImage!,
                                      fit: BoxFit.contain,
                                    ),
                                  ),

                                  // No screenshots watermark
                                  Center(
                                    child: Text(
                                      'PREVIEW ONLY - NO SAVING',
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.7),
                                        fontSize: screenSize.width < 360
                                            ? 14
                                            : 16,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                                : Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  PulseAnimationWidget(
                                    child: Icon(
                                      Icons.fingerprint,
                                      size: screenSize.width < 360 ? 60 : 80,
                                      color: theme.colorScheme.primary
                                          .withOpacity(0.5),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No fingerprint captured yet',
                                    style: TextStyle(
                                      color: Colors.grey[500],
                                      fontSize: screenSize.width < 360
                                          ? 14
                                          : 16,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Use the SDK capture below',
                                    style: TextStyle(
                                      color: Colors.grey[500],
                                      fontSize: screenSize.width < 360
                                          ? 12
                                          : 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),

                      // SDK capture button
                      FadeTransition(
                        opacity: _animation,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0, 0.4),
                            end: Offset.zero,
                          ).animate(_animation),
                          child: SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _isCapturing ? null : takeFingerprint,
                              icon: Icon(Icons.fingerprint),
                              label: Text(_isCapturing
                                  ? 'Capturing...'
                                  : 'Capture Fingerprint'),
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.symmetric(
                                    vertical: screenSize.width < 360 ? 12 : 16
                                ),
                                backgroundColor: theme.colorScheme.primary,
                                foregroundColor: Colors.white,
                                disabledBackgroundColor: theme.colorScheme
                                    .primary.withOpacity(0.6),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Note about saving
                      FadeTransition(
                        opacity: _animation,
                        child: Container(
                          padding: EdgeInsets.all(screenSize.width < 360
                              ? 10
                              : 12),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.orange,
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: Colors.orange,
                                size: screenSize.width < 360 ? 20 : 24,
                              ),
                              SizedBox(width: screenSize.width < 360 ? 8 : 12),
                              Expanded(
                                child: Text(
                                  "For security reasons, prints can only be viewed and cannot be saved or shared.",
                                  style: TextStyle(
                                    color: Colors.orange[800],
                                    fontSize: screenSize.width < 360 ? 12 : 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Show the proceed button in the content when image is captured
                      if (_showImage)
                        Padding(
                          padding: const EdgeInsets.only(top: 24),
                          child: FadeTransition(
                            opacity: _animation,
                            child: SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          OrderFormScreen(
                                            scanImage: _fingerprintImage,
                                            scanType: 'Fingerprint',
                                          ),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(
                                      vertical: screenSize.width < 360 ? 12 : 16
                                  ),
                                ),
                                child: const Text('Proceed to Order'),
                              ),
                            ),
                          ),
                        ),

                      // Extra padding to ensure scrollability and avoid navigation bar
                      SizedBox(height: bottomPadding + 20),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      // Persistent bottom button that stays above the navigation bar
      bottomNavigationBar: _showImage ? SafeArea(
        child: Container(
          padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 8,
              bottom: 8 + bottomPadding
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      OrderFormScreen(
                        scanImage: _fingerprintImage,
                        scanType: 'Fingerprint',
                      ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(
                  vertical: screenSize.width < 360 ? 12 : 16
              ),
            ),
            child: const Text('Proceed to Order'),
          ),
        ),
      ) : null,
    );
  }
}
