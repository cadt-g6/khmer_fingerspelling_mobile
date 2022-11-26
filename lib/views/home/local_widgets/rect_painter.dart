import 'package:flutter/material.dart';
import 'package:khmer_fingerspelling_flutter/tflite/predicted_position.dart';

@Deprecated("Draw with Stack / Container instead for clickable")
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
    double imageSize = constraints.maxWidth;

    double x = position.x;
    double y = position.y;
    double w = position.w;
    double h = position.h;

    x = x * imageSize / imageAspectRatio.height;
    w = w * imageSize / imageAspectRatio.height;

    y = y * imageSize / imageAspectRatio.width;
    h = h * imageSize / imageAspectRatio.width;

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
