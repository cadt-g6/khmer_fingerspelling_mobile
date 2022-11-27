import 'package:flutter/material.dart';
import 'package:khmer_fingerspelling_flutter/core/constants/config_constant.dart';
import 'package:khmer_fingerspelling_flutter/tflite/predicted_position.dart';
import 'package:khmer_fingerspelling_flutter/views/home/home_view_model.dart';
import 'package:khmer_fingerspelling_flutter/widgets/kf_fade_in.dart';
import 'package:khmer_fingerspelling_flutter/widgets/kf_scale_in.dart';

class DetectorRect extends StatelessWidget {
  const DetectorRect({
    Key? key,
    required this.viewModel,
    required this.context,
    required this.index,
    required this.position,
    required this.constraints,
  }) : super(key: key);

  final HomeViewModel viewModel;
  final BuildContext context;
  final int index;
  final PredictedPosition position;
  final BoxConstraints constraints;

  @override
  Widget build(BuildContext context) {
    double imageSize = constraints.maxWidth;

    double x = position.x;
    double y = position.y;
    double w = position.w;
    double h = position.h;

    x = x * imageSize / viewModel.currentImageAspectRatio!.height;
    w = w * imageSize / viewModel.currentImageAspectRatio!.height;

    y = y * imageSize / viewModel.currentImageAspectRatio!.width;
    h = h * imageSize / viewModel.currentImageAspectRatio!.width;

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
          valueListenable: viewModel.selectedPredictionIndexNotifier,
          builder: (context, selectedIndex, child) {
            if (index == selectedIndex) {
              return _DetectorRectSelected(
                onTap: () => viewModel.selectedPredictionIndexNotifier.value = null,
              );
            } else {
              return _DetectorRectDot(
                w: w,
                h: h,
                onTap: () => viewModel.selectedPredictionIndexNotifier.value = index,
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
            onTap: () => onTap,
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
