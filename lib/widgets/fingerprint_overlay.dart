import 'package:flutter/material.dart';
import 'dart:ui'; // Required for ImageFilter.blur

class FingerprintOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double holeWidth = size.width * 0.4;  // Adjust oval width
    final double holeHeight = size.height * 0.15; // Adjust oval height
    final Offset holeCenter = Offset(size.width / 2, size.height / 2);

    // Create a blurred background
    canvas.saveLayer(Rect.fromLTWH(0, 0, size.width, size.height), Paint());

    final backgroundPaint = Paint()
      ..color = Colors.black.withOpacity(0.4)
      ..imageFilter = ImageFilter.blur(sigmaX: 10, sigmaY: 10); // Blur effect

    // Draw the blurred overlay covering the entire screen
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), backgroundPaint);

    // Create a clear transparent oval cutout in the middle
    final cutoutPath = Path()
      ..addOval(Rect.fromCenter(center: holeCenter, width: holeWidth, height: holeHeight))
      ..close();

    canvas.drawPath(cutoutPath, Paint()..blendMode = BlendMode.clear);

    // Draw a white oval border to indicate the fingerprint placement
    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0;

    canvas.drawOval(
      Rect.fromCenter(center: holeCenter, width: holeWidth, height: holeHeight),
      borderPaint,
    );

    canvas.restore(); // Restore the canvas to prevent unintended effects
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
