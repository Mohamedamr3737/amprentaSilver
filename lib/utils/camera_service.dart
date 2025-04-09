import 'dart:io';
import 'dart:ui' as ui;
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:permission_handler/permission_handler.dart';
import 'package:image/image.dart' as img;

class CameraService {
  static CameraService? _instance;
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _isInitialized = false;
  bool _isPermissionGranted = false;

  // Singleton pattern
  factory CameraService() {
    _instance ??= CameraService._internal();
    return _instance!;
  }

  CameraService._internal();

  bool get isInitialized => _isInitialized;
  bool get isPermissionGranted => _isPermissionGranted;
  CameraController? get controller => _controller;

  Future<void> requestCameraPermission() async {
    final status = await Permission.camera.request();
    _isPermissionGranted = status == PermissionStatus.granted;
  }

  Future<void> initialize() async {
    if (_isInitialized) return;

    await requestCameraPermission();
    if (!_isPermissionGranted) {
      throw Exception('Camera permission not granted');
    }

    _cameras = await availableCameras();
    if (_cameras == null || _cameras!.isEmpty) {
      throw Exception('No cameras available');
    }

    // Use the first camera (usually the back camera)
    await initializeCamera(0);
    _isInitialized = true;
  }

  Future<void> initializeCamera(int cameraIndex) async {
    if (_cameras == null || _cameras!.isEmpty) {
      throw Exception('No cameras available');
    }

    if (_controller != null) {
      await _controller!.dispose();
    }

    _controller = CameraController(
      _cameras![cameraIndex],
      ResolutionPreset.high,
      enableAudio: false,
    );

    try {
      await _controller!.initialize();
    } catch (e) {
      throw Exception('Failed to initialize camera: $e');
    }
  }

  Future<XFile?> takePicture() async {
    if (_controller == null || !_controller!.value.isInitialized) {
      throw Exception('Camera not initialized');
    }

    try {
      final XFile file = await _controller!.takePicture();
      return file;
    } catch (e) {
      print('Error taking picture: $e');
      return null;
    }
  }

  Future<void> toggleFlash() async {
    if (_controller == null || !_controller!.value.isInitialized) {
      return;
    }

    try {
      if (_controller!.value.flashMode == FlashMode.off) {
        await _controller!.setFlashMode(FlashMode.torch);
      } else {
        await _controller!.setFlashMode(FlashMode.off);
      }
    } catch (e) {
      print('Error toggling flash: $e');
    }
  }

  Future<void> dispose() async {
    if (_controller != null) {
      await _controller!.dispose();
      _controller = null;
    }
    _isInitialized = false;
  }

  Future<String> saveImage(XFile image, String prefix) async {
    final directory = await getTemporaryDirectory();
    final fileName = '${prefix}_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final filePath = path.join(directory.path, fileName);

    // Copy the image to the new path
    await File(image.path).copy(filePath);

    return filePath;
  }

  Future<XFile> cropToSquare(XFile originalImage, Rect cropRect, Size originalSize) async {
    // Read the image file
    final bytes = await File(originalImage.path).readAsBytes();
    final image = img.decodeImage(bytes);

    if (image == null) {
      throw Exception('Failed to decode image');
    }

    // Calculate the scaling factor between the image and the screen
    final double scaleX = image.width / originalSize.width;
    final double scaleY = image.height / originalSize.height;

    // Calculate the crop rectangle in the image coordinates
    final int cropX = (cropRect.left * scaleX).round();
    final int cropY = (cropRect.top * scaleY).round();
    final int cropWidth = (cropRect.width * scaleX).round();
    final int cropHeight = (cropRect.height * scaleY).round();

    // Crop the image
    final croppedImage = img.copyCrop(
      image,
      x: cropX,
      y: cropY,
      width: cropWidth,
      height: cropHeight,
    );

    // Save the cropped image to a temporary file
    final directory = await getTemporaryDirectory();
    final fileName = 'cropped_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final filePath = path.join(directory.path, fileName);

    final file = File(filePath);
    await file.writeAsBytes(img.encodeJpg(croppedImage));

    return XFile(filePath);
  }
}
