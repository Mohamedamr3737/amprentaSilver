import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'dart:async'; // ✅ Import Timer for auto-removal of focus indicator
import '../services/camera_service.dart';
import '../services/torch_service.dart';
import '../services/fingerprint_service.dart';
import '../widgets/fingerprint_overlay.dart';
import 'dart:io';
import 'dart:ui'; // ✅ Import for ImageFilter.blur

class FingerprintCameraScreen extends StatefulWidget {
  @override
  _FingerprintCameraScreenState createState() => _FingerprintCameraScreenState();
}

class _FingerprintCameraScreenState extends State<FingerprintCameraScreen> {
  late CameraService _cameraService;
  late FingerprintService _fingerprintService;
  bool isTorchOn = false;
  String? imagePath;
  bool fingerprintDetected = false;
  Offset? focusPoint;
  double focusOpacity = 0.0; // ✅ Controls visibility of the focus circle
  Timer? _focusTimer; // ✅ Timer for auto-removal of focus indicator

  @override
  void initState() {
    super.initState();
    _cameraService = CameraService();
    _fingerprintService = FingerprintService();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    await _cameraService.initializeCamera();
    if (mounted) setState(() {});
  }

  Future<void> _toggleTorch() async {
    if (_cameraService.controller != null) {
      isTorchOn = await TorchService.toggleTorch(_cameraService.controller!, isTorchOn);
      setState(() {});
    }
  }

  Future<void> _captureFingerprint() async {
    final XFile? file = await _cameraService.captureImage();
    if (file != null) {
      File imageFile = File(file.path);
      bool detected = await _fingerprintService.detectFingerprint(imageFile);

      setState(() {
        fingerprintDetected = detected;
        imagePath = file.path;
      });

      if (fingerprintDetected) {
        print("✅ Fingerprint detected!");
      } else {
        print("⚠ No fingerprint detected. Try again.");
      }
    }
  }

  /// Handles user tap on the screen to instantly show focus indicator
  void _onTapToFocus(TapUpDetails details) {
    if (_cameraService.controller == null || !_cameraService.controller!.value.isInitialized) {
      return;
    }

    final RenderBox box = context.findRenderObject() as RenderBox;
    final Offset localPosition = box.globalToLocal(details.globalPosition);

    // ✅ Show the focus circle immediately
    setState(() {
      focusPoint = localPosition;
      focusOpacity = 1.0; // Instantly make the focus circle visible
    });

    // ✅ Remove focus indicator after 1 second
    _focusTimer?.cancel();
    _focusTimer = Timer(Duration(seconds: 1), () {
      setState(() {
        focusOpacity = 0.0; // Start fade-out animation
      });
    });

    // ✅ Run camera focus asynchronously without blocking UI updates
    _focusCamera(details.globalPosition);
  }

  /// Runs the camera focus operation in the background
  Future<void> _focusCamera(Offset globalPosition) async {
    final screenSize = MediaQuery.of(context).size;

    // Convert screen tap position to camera focus point (0-1 scale)
    double x = globalPosition.dx / screenSize.width;
    double y = globalPosition.dy / screenSize.height;
    final cameraFocusPoint = Offset(x, y);

    try {
      await _cameraService.controller!.setFocusPoint(cameraFocusPoint);
      await _cameraService.controller!.setExposurePoint(cameraFocusPoint);
    } catch (e) {
      print("Focus error: $e");
    }
  }

  @override
  void dispose() {
    _focusTimer?.cancel(); // ✅ Prevent memory leaks
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTapUp: _onTapToFocus, // ✅ Listen for tap to focus instantly
        child: Stack(
          children: [
            if (_cameraService.controller != null && _cameraService.controller!.value.isInitialized)
              CameraPreview(_cameraService.controller!), // ✅ Camera preview

            // ✅ Overlay with blurred background but clear center
            Positioned.fill(
              child: CustomPaint(painter: FingerprintOverlayPainter()),
            ),

            // ✅ Instruction text
            Positioned(
              top: MediaQuery.of(context).size.height * 0.4,
              left: 0,
              right: 0,
              child: Center(
                child: Text(
                  "Place your finger inside the circle",
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            // ✅ Smooth and instant focus indicator at correct position
            if (focusPoint != null)
              Positioned(
                left: focusPoint!.dx - 20,
                top: focusPoint!.dy - 20,
                child: AnimatedOpacity(
                  opacity: focusOpacity,
                  duration: Duration(milliseconds: 50), // ✅ Fastest fade-in
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.green, width: 2),
                    ),
                  ),
                ),
              ),

            Align(
              alignment: Alignment.bottomCenter,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: _toggleTorch,
                    child: Text(isTorchOn ? "Turn Off Flash" : "Turn On Flash"),
                  ),
                  ElevatedButton(
                    onPressed: _captureFingerprint,
                    child: Text("Capture Fingerprint"),
                  ),
                  if (imagePath != null) ...[
                    Image.file(File(imagePath!)),
                    Text(
                      fingerprintDetected ? "✅ Fingerprint Detected" : "⚠ No Fingerprint Detected",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
