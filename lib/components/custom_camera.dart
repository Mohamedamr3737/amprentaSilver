import 'package:flutter/material.dart';
import 'dart:typed_data';

// This is a mock camera component since we can't implement actual camera functionality
// In a real app, you would use camera plugin
class CustomCamera extends StatefulWidget {
  final String title;
  final Function(Uint8List) onImageCaptured;

  const CustomCamera({
    super.key,
    required this.title,
    required this.onImageCaptured,
  });

  @override
  State<CustomCamera> createState() => _CustomCameraState();
}

class _CustomCameraState extends State<CustomCamera> {
  bool _torchOn = false;
  bool _isCameraReady = false;

  @override
  void initState() {
    super.initState();
    // Simulate camera initialization
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _isCameraReady = true;
      });
    });
  }

  void _toggleTorch() {
    setState(() {
      _torchOn = !_torchOn;
    });
    // In a real app, you would toggle the camera torch here
  }

  void _captureImage() {
    // Simulate image capture
    setState(() {
      _isCameraReady = false;
    });

    // Simulate processing delay
    Future.delayed(const Duration(seconds: 2), () {
      // In a real app, this would be the actual image data from the camera
      // For now, we're just creating a dummy Uint8List
      final dummyImageData = Uint8List(100);

      widget.onImageCaptured(dummyImageData);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          widget.title,
          style: const TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(
                  color: theme.colorScheme.secondary,
                  width: 2,
                ),
              ),
              child: Stack(
                children: [
                  // Camera preview (mock)
                  Container(
                    color: Colors.grey[900],
                    child: Center(
                      child: _isCameraReady
                          ? Icon(
                        Icons.camera,
                        size: 100,
                        color: Colors.grey[700],
                      )
                          : const CircularProgressIndicator(
                        color: Colors.white,
                      ),
                    ),
                  ),

                  // Camera overlay
                  if (_isCameraReady)
                    Center(
                      child: Container(
                        width: 250,
                        height: 250,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: theme.colorScheme.secondary,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),

                  // Torch indicator
                  if (_torchOn)
                    Positioned(
                      top: 16,
                      right: 16,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.flash_on,
                              color: Colors.amber,
                              size: 16,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'TORCH ON',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Camera controls
          Container(
            color: Colors.black,
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Torch toggle
                IconButton(
                  onPressed: _toggleTorch,
                  icon: Icon(
                    _torchOn ? Icons.flash_on : Icons.flash_off,
                    color: _torchOn ? Colors.amber : Colors.white,
                    size: 32,
                  ),
                ),

                // Capture button
                GestureDetector(
                  onTap: _isCameraReady ? _captureImage : null,
                  child: Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: 3,
                      ),
                    ),
                    child: Center(
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _isCameraReady
                              ? theme.colorScheme.secondary
                              : Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ),

                // Settings (placeholder)
                IconButton(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.settings,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

