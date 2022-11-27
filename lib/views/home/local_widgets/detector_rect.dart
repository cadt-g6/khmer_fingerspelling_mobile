import 'dart:math';
import 'package:flutter/material.dart';
import 'package:khmer_fingerspelling_flutter/core/constants/config_constant.dart';
import 'package:khmer_fingerspelling_flutter/tflite/predicted_position.dart';
import 'package:khmer_fingerspelling_flutter/widgets/kf_fade_in.dart';
import 'package:khmer_fingerspelling_flutter/widgets/kf_scale_in.dart';

class DetectorRect extends StatelessWidget {
  const DetectorRect({
    Key? key,
    required this.rectPosition,
    required this.parentSize,
    required this.parentImageAspectRatio,
    required this.predictionIndexNotifier,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  final PredictedPosition rectPosition;
  final Size parentImageAspectRatio;
  final Size parentSize;
  final ValueNotifier<int?> predictionIndexNotifier;
  final bool Function() isSelected;
  final void Function(bool selected) onTap;

  @override
  Widget build(BuildContext context) {
    double imageSize = max(parentSize.width, parentSize.height);

    double x = rectPosition.x;
    double y = rectPosition.y;
    double w = rectPosition.w;
    double h = rectPosition.h;

    x = x * imageSize / parentImageAspectRatio.height;
    w = w * imageSize / parentImageAspectRatio.height;

    y = y * imageSize / parentImageAspectRatio.width;
    h = h * imageSize / parentImageAspectRatio.width;

    double add = 12;
    if (add > 0) {
      x = x - add / 2;
      y = y - add / 2;
      w = w + add;
      h = h + add;
    }

    double xw = x + w;
    double yh = y + h;

    return Positioned.fromRect(
      rect: Rect.fromPoints(
        Offset(x, yh),
        Offset(xw, y),
      ),
      child: Material(
        color: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
        clipBehavior: Clip.hardEdge,
        child: ValueListenableBuilder<int?>(
          valueListenable: predictionIndexNotifier,
          builder: (context, selectedIndex, child) {
            if (isSelected()) {
              return _DetectorRectSelected(
                onTap: () => onTap(isSelected()),
              );
            } else {
              return _DetectorRectDot(
                w: w,
                h: h,
                onTap: () => onTap(isSelected()),
              );
            }
          },
        ),
      ),
    );
  }
}

class _DetectorRectSelected extends StatelessWidget {
  const _DetectorRectSelected({
    Key? key,
    required this.onTap,
  }) : super(key: key);

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return KfFadeIn(
      child: KfScaleIn(
        transformAlignment: Alignment.center,
        duration: ConfigConstant.duration,
        curve: Curves.ease,
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: InkWell(
            borderRadius: BorderRadius.circular(8.0),
            onTap: onTap,
            child: CustomPaint(
              foregroundPainter: BorderPainter(),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.0),
                  color: Colors.white.withOpacity(0.35),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DetectorRectDot extends StatelessWidget {
  const _DetectorRectDot({
    Key? key,
    required this.w,
    required this.h,
    required this.onTap,
  }) : super(key: key);

  final double w;
  final double h;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      highlightColor: Colors.transparent,
      borderRadius: BorderRadius.circular(8.0),
      onTap: onTap,
      child: KfFadeIn(
        child: Container(
          alignment: Alignment.center,
          width: w,
          height: h,
          child: Container(
            width: 12.0,
            height: 12.0,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.25),
                  blurRadius: 1,
                ),
                const BoxShadow(
                  color: Colors.white,
                  blurRadius: 24,
                  spreadRadius: 4,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class BorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    double height = size.height;
    double width = size.width;
    double cornerSide = 10.0;

    Paint paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    Path path = Path()
      ..moveTo(cornerSide, 0)
      ..quadraticBezierTo(0, 0, 0, cornerSide)
      ..moveTo(0, height - cornerSide)
      ..quadraticBezierTo(0, height, cornerSide, height)
      ..moveTo(width - cornerSide, height)
      ..quadraticBezierTo(width, height, width, height - cornerSide)
      ..moveTo(width, cornerSide)
      ..quadraticBezierTo(width, 0, width - cornerSide, 0);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(BorderPainter oldDelegate) => false;

  @override
  bool shouldRebuildSemantics(BorderPainter oldDelegate) => false;
}
