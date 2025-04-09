import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'dart:io';
import '../utils/camera_service.dart';

class CameraView extends StatefulWidget {
  final String title;
  final String guideText;
  final Function(XFile) onImageCaptured;
  final IconData overlayIcon;

  const CameraView({
    super.key,
    required this.title,
    required this.guideText,
    required this.onImageCaptured,
    required this.overlayIcon,
  });

  @override
  State<CameraView> createState() => _CameraViewState();
}

class _CameraViewState extends State<CameraView> with WidgetsBindingObserver {
  final CameraService _cameraService = CameraService();
  bool _isInitializing = true;
  bool _isCapturing = false;
  bool _isTorchOn = false;
  String _errorMessage = '';

  // Overlay guide dimensions and position
  final double _overlayWidth = 250;
  final double _overlayHeight = 250; // Making it square
  GlobalKey _previewContainerKey = GlobalKey();
  Size _previewSize = Size.zero;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();

    // Get the preview size after the layout is complete
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updatePreviewSize();
    });
  }

  void _updatePreviewSize() {
    final RenderBox? renderBox = _previewContainerKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      setState(() {
        _previewSize = renderBox.size;
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cameraService.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Handle app lifecycle changes to properly manage camera resources
    if (_cameraService.controller == null) return;

    if (state == AppLifecycleState.inactive) {
      _cameraService.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera();
    }
  }

  Future<void> _initializeCamera() async {
    setState(() {
      _isInitializing = true;
      _errorMessage = '';
    });

    try {
      await _cameraService.initialize();
      setState(() {
        _isInitializing = false;
      });
    } catch (e) {
      setState(() {
        _isInitializing = false;
        _errorMessage = 'Failed to initialize camera: $e';
      });
    }
  }

  Future<void> _toggleTorch() async {
    await _cameraService.toggleFlash();
    setState(() {
      _isTorchOn = _cameraService.controller?.value.flashMode == FlashMode.torch;
    });
  }

  Future<void> _takePicture() async {
    if (_isCapturing) return;

    setState(() {
      _isCapturing = true;
    });

    try {
      final XFile? image = await _cameraService.takePicture();

      if (image != null) {
        // Calculate the crop rectangle
        final double centerX = _previewSize.width / 2;
        final double centerY = _previewSize.height / 2;
        final Rect cropRect = Rect.fromCenter(
          center: Offset(centerX, centerY),
          width: _overlayWidth,
          height: _overlayHeight,
        );

        // Crop the image
        final XFile croppedImage = await _cameraService.cropToSquare(
            image,
            cropRect,
            _previewSize
        );

        // Close the camera screen and return the cropped image
        Navigator.pop(context);
        widget.onImageCaptured(croppedImage);
      } else {
        setState(() {
          _isCapturing = false;
          _errorMessage = 'Failed to capture image';
        });
      }
    } catch (e) {
      setState(() {
        _isCapturing = false;
        _errorMessage = 'Failed to take picture: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Camera header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
            ),

            // Camera preview
            Expanded(
              child: Container(
                key: _previewContainerKey,
                margin: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.primary,
                    width: 2,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Stack(
                    children: [
                      if (_errorMessage.isNotEmpty)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Text(
                              _errorMessage,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        )
                      else if (_isInitializing)
                        const Center(
                          child: CircularProgressIndicator(
                            color: Colors.white,
                          ),
                        )
                      else if (_cameraService.controller != null)
                          Positioned.fill(
                            child: CameraPreview(_cameraService.controller!),
                          ),

                      // Overlay guide - now square
                      Center(
                        child: Container(
                          width: _overlayWidth,
                          height: _overlayHeight,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.white,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  widget.overlayIcon,
                                  color: Colors.white.withOpacity(0.5),
                                  size: 50,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  widget.guideText,
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.7),
                                    fontSize: 14,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Camera instructions
                      Positioned(
                        bottom: 20,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.7),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'Ensure good lighting for best results',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Torch indicator
                      if (_isTorchOn)
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
            ),

            // Camera controls
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Torch toggle
                  IconButton(
                    onPressed: _cameraService.isInitialized ? _toggleTorch : null,
                    icon: Icon(
                      _isTorchOn ? Icons.flash_on : Icons.flash_off,
                      color: _isTorchOn ? Colors.amber : Colors.white,
                      size: 32,
                    ),
                  ),

                  // Capture button
                  GestureDetector(
                    onTap: _cameraService.isInitialized && !_isCapturing ? _takePicture : null,
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
                            color: _cameraService.isInitialized && !_isCapturing
                                ? Colors.white
                                : Colors.grey,
                          ),
                          child: _isCapturing
                              ? const CircularProgressIndicator(
                            color: Colors.black,
                            strokeWidth: 2,
                          )
                              : null,
                        ),
                      ),
                    ),
                  ),

                  // Empty space to maintain layout balance
                  const SizedBox(width: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
