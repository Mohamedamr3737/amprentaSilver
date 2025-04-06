import 'package:camera/camera.dart';

class TorchService {
  static Future<bool> toggleTorch(CameraController controller, bool currentState) async {
    try {
      if (controller.value.isInitialized) {
        await controller.setFlashMode(currentState ? FlashMode.off : FlashMode.torch);
        return !currentState;
      }
    } catch (e) {
      print("Torch Error: $e");
    }
    return currentState;
  }
}
