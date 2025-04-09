import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'dart:io';
import 'package:camera/camera.dart';
import '../utils/animations.dart';
import '../components/camera_view.dart';
import 'order_form_screen.dart';

class HandprintScreen extends StatefulWidget {
  const HandprintScreen({super.key});

  @override
  State<HandprintScreen> createState() => _HandprintScreenState();
}

class _HandprintScreenState extends State<HandprintScreen> with SingleTickerProviderStateMixin {
  Uint8List? _handprintImage;
  String _statusMessage = "Press 'Capture Handprint' to start";
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
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // Function to show camera UI
  void _showCameraUI() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CameraView(
          title: 'Handprint Camera',
          guideText: 'Place hand here',
          overlayIcon: Icons.back_hand,
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
        _handprintImage = bytes;
        _isCapturing = false;
        _showImage = true;
        _statusMessage = "Handprint captured successfully!";
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
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Handprint Scanner'),
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
                            'Handprint Scan',
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
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
                            'Capture a clear image of your hand',
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 16,
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
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: _showImage
                                  ? Colors.green.withOpacity(0.1)
                                  : theme.colorScheme.secondary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _showImage
                                    ? Colors.green
                                    : theme.colorScheme.secondary,
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                if (_showImage)
                                  Icon(
                                    Icons.check_circle,
                                    color: Colors.green,
                                  ),
                                if (_isCapturing)
                                  SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: theme.colorScheme.secondary,
                                    ),
                                  ),
                                if (!_showImage && !_isCapturing)
                                  Icon(
                                    Icons.info_outline,
                                    color: theme.colorScheme.secondary,
                                  ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    _statusMessage,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      color: _showImage
                                          ? Colors.green[800]
                                          : theme.colorScheme.secondary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),

                      // Handprint image display
                      FadeTransition(
                        opacity: _animation,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0, 0.2),
                            end: Offset.zero,
                          ).animate(_animation),
                          child: Container(
                            height: 300,
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
                            child: _handprintImage != null
                                ? ClipRRect(
                              borderRadius: BorderRadius.circular(18),
                              child: Stack(
                                children: [
                                  // Handprint image
                                  Positioned.fill(
                                    child: Image.memory(
                                      _handprintImage!,
                                      fit: BoxFit.contain,
                                    ),
                                  ),

                                  // No screenshots watermark
                                  Center(
                                    child: Text(
                                      'PREVIEW ONLY - NO SAVING',
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.7),
                                        fontSize: 16,
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
                                      Icons.back_hand,
                                      size: 80,
                                      color: theme.colorScheme.secondary.withOpacity(0.5),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No handprint captured yet',
                                    style: TextStyle(
                                      color: Colors.grey[500],
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Use the camera to capture a handprint',
                                    style: TextStyle(
                                      color: Colors.grey[500],
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),

                      // Camera capture button
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
                              onPressed: _isCapturing ? null : _showCameraUI,
                              icon: Icon(Icons.camera_alt),
                              label: const Text('Camera Capture'),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                backgroundColor: theme.colorScheme.secondary,
                                foregroundColor: Colors.white,
                                disabledBackgroundColor: theme.colorScheme.secondary.withOpacity(0.6),
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
                          padding: const EdgeInsets.all(12),
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
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  "For security reasons, prints can only be viewed and cannot be saved or shared.",
                                  style: TextStyle(
                                    color: Colors.orange[800],
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
                                      builder: (context) => OrderFormScreen(
                                        scanImage: _handprintImage,
                                        scanType: 'Handprint',
                                      ),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
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
                  builder: (context) => OrderFormScreen(
                    scanImage: _handprintImage,
                    scanType: 'Handprint',
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('Proceed to Order'),
          ),
        ),
      ) : null,
    );
  }
}
