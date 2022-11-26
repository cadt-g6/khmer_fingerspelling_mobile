import 'package:flutter/material.dart';
import 'package:khmer_fingerspelling_flutter/tflite/predicted_position.dart';

class RectPainter extends CustomPainter {
  final PredictedPosition position;
  final BoxConstraints constraints;
  final Size imageAspectRatio;
  final Color? color;

  RectPainter(
    this.position,
    this.imageAspectRatio,
    this.constraints,
    this.color,
  );

  @override
  void paint(Canvas canvas, Size size) {
    double imageWidth = constraints.maxWidth;
    double imageHeight = constraints.maxWidth;

    double x = position.x;
    double y = position.y;
    double w = position.w;
    double h = position.h;

    x = x * imageWidth / imageAspectRatio.height;
    w = w * imageWidth / imageAspectRatio.height;

    y = y * imageHeight / imageAspectRatio.width;
    h = h * imageHeight / imageAspectRatio.width;

    double xw = x + w;
    double yh = y + h;

    Paint paint = Paint()
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..color = color ?? Colors.red
      ..style = PaintingStyle.stroke;

    canvas.drawRect(
      Rect.fromPoints(
        Offset(x, yh),
        Offset(xw, y),
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
