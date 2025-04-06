import 'package:camera/camera.dart';

class CameraService {
  CameraController? controller;

  Future<void> initializeCamera() async {
    final cameras = await availableCameras();
    controller = CameraController(
      cameras.firstWhere((c) => c.lensDirection == CameraLensDirection.back),
      ResolutionPreset.high,
    );
    await controller!.initialize();
  }

  Future<XFile?> captureImage() async {
    if (controller != null && controller!.value.isInitialized) {
      return await controller!.takePicture();
    }
    return null;
  }

  void dispose() {
    controller?.dispose();
  }
}
