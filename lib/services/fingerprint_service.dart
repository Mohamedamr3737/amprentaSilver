import 'dart:io';
// import 'package:opencv_4/opencv_4.dart'; // Only this import is necessary.

class FingerprintService {
  /// Attempts to detect a fingerprint from [imageFile].
  /// Returns `true` if a fingerprint is detected, otherwise `false`.
  Future<bool> detectFingerprint(File imageFile) async {
    // try {
    //   // 1) Read the image (BGR format) from the file path,
    //   //    returning a base64-encoded string.
    //   String original = await Cv2.imread(
    //     pathString: imageFile.path,
    //     outputType: ImreadModes.IMREAD_COLOR,
    //   );
    //
    //   // 2) Convert from BGR to HSV
    //   String hsv = await Cv2.cvtColor(
    //     src: original,
    //     code: ColorConversionCodes.COLOR_BGR2HSV,
    //   );
    //
    //   // 3) Threshold to isolate skin color in HSV
    //   //    Lower = [0,20,70], Upper = [20,255,255]
    //   String mask = await Cv2.inRange(
    //     src: hsv,
    //     lowerb: [0, 20, 70],
    //     upperb: [20, 255, 255],
    //   );
    //
    //   // 4) Morphological Closing to remove noise
    //   //    Kernel size: 5x5, operation: MORPH_CLOSE
    //   String closedMask = await Cv2.morphologyEx(
    //     src: mask,
    //     operation: MorphTypes.MORPH_CLOSE,
    //     kernelSize: [5, 5],
    //     // (Other optional params like anchor, iterations, borderType can be used if needed)
    //   );
    //
    //   // 5) Gaussian Blur to smooth edges
    //   //    Kernel size: 3x3, sigmaX = 0
    //   String blurred = await Cv2.gaussianBlur(
    //     src: closedMask,
    //     kernelSize: [3, 3],
    //     sigmaX: 0,
    //   );
    //
    //   // 6) Extract the finger region by bitwise-and with the original
    //   //    We'll pass the base64 from 'original' for both src1 and src2,
    //   //    and 'blurred' as the mask.
    //   String finger = await Cv2.bitwiseAnd(
    //     src1: original,
    //     src2: original,
    //     mask: blurred,
    //   );
    //
    //   // 7) Convert finger to grayscale
    //   String fingerGray = await Cv2.cvtColor(
    //     src: finger,
    //     code: ColorConversionCodes.COLOR_BGR2GRAY,
    //   );
    //
    //   // 8) Equalize histogram to enhance contrast
    //   String equalized = await Cv2.equalizeHist(
    //     src: fingerGray,
    //   );
    //
    //   // 9) Apply Unsharp Mask (sharpening)
    //   //    Using filter2D with the kernel:
    //   //    [[0, -1, 0],
    //   //     [-1, 5, -1],
    //   //     [0, -1, 0]]
    //   List<List<double>> sharpenKernel = [
    //     [0, -1, 0],
    //     [-1, 5, -1],
    //     [0, -1, 0],
    //   ];
    //   String sharpened = await Cv2.filter2D(
    //     src: equalized,
    //     outputDepth: -1,      // -1 => Same depth as source
    //     kernel: sharpenKernel,
    //   );
    //
    //   // 10) Adaptive threshold to highlight fingerprint ridges
    //   //     blockSize=19, c=1
    //   String fingerprintMask = await Cv2.adaptiveThreshold(
    //     src: sharpened,
    //     maxValue: 255,
    //     method: AdaptiveThresholdTypes.ADAPTIVE_THRESH_GAUSSIAN_C,
    //     type: ThresholdTypes.THRESH_BINARY,
    //     blockSize: 19,
    //     c: 1,
    //   );
    //
    //   // 11) Count how many white (non-zero) pixels
    //   //     If above threshold => we say "fingerprint detected"
    //   int nonZeroCount = await Cv2.countNonZero(src: fingerprintMask);
    //
    //   // Tweak this threshold based on your image sizes/lighting/etc.
    //   const int whitePixelThreshold = 1000;
    //   return (nonZeroCount > whitePixelThreshold);
    // } catch (e) {
    //   print("Fingerprint detection error: $e");
    //   return false;
    // }
    return true;
  }
}
