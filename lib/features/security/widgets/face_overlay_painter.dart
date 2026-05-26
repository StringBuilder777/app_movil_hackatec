import 'dart:math';
import 'package:flutter/material.dart';

class FaceOverlayPainter extends CustomPainter {
  final Rect? detectedFaceRect;
  final bool isQualityOk;
  final Size imageSize;
  final bool isFrontCamera;

  FaceOverlayPainter({
    this.detectedFaceRect,
    this.isQualityOk = false,
    required this.imageSize,
    this.isFrontCamera = true,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Dim overlay outside the oval guide
    final ovalRect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height * 0.40),
      width: size.width * 0.65,
      height: size.width * 0.85,
    );

    final bgPaint = Paint()..color = Colors.black.withOpacity(0.5);
    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addOval(ovalRect)
      ..fillType = PathFillType.evenOdd;
    canvas.drawPath(path, bgPaint);

    // Oval guide border
    final ovalPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..color = detectedFaceRect != null
          ? (isQualityOk ? Colors.green : Colors.orange)
          : Colors.white.withOpacity(0.7);
    canvas.drawOval(ovalRect, ovalPaint);

    // Draw detected face bounding box
    if (detectedFaceRect != null && imageSize.width > 0 && imageSize.height > 0) {
      final scaleX = size.width / imageSize.width;
      final scaleY = size.height / imageSize.height;

      double left = detectedFaceRect!.left * scaleX;
      double top = detectedFaceRect!.top * scaleY;
      double right = detectedFaceRect!.right * scaleX;
      double bottom = detectedFaceRect!.bottom * scaleY;

      if (isFrontCamera) {
        final tmpLeft = size.width - right;
        right = size.width - left;
        left = tmpLeft;
      }

      final facePaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0
        ..color = isQualityOk ? Colors.green.withOpacity(0.8) : Colors.orange.withOpacity(0.8);

      final cornerLength = min(20.0, (right - left) * 0.2);
      final faceRect = Rect.fromLTRB(left, top, right, bottom);

      // Draw corner brackets
      _drawCorner(canvas, facePaint, faceRect.topLeft, cornerLength, 1, 1);
      _drawCorner(canvas, facePaint, faceRect.topRight, cornerLength, -1, 1);
      _drawCorner(canvas, facePaint, faceRect.bottomLeft, cornerLength, 1, -1);
      _drawCorner(canvas, facePaint, faceRect.bottomRight, cornerLength, -1, -1);
    }
  }

  void _drawCorner(Canvas canvas, Paint paint, Offset corner, double length, int dx, int dy) {
    canvas.drawLine(corner, Offset(corner.dx + length * dx, corner.dy), paint);
    canvas.drawLine(corner, Offset(corner.dx, corner.dy + length * dy), paint);
  }

  @override
  bool shouldRepaint(FaceOverlayPainter oldDelegate) {
    return detectedFaceRect != oldDelegate.detectedFaceRect ||
        isQualityOk != oldDelegate.isQualityOk;
  }
}
