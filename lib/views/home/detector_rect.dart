import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:khmer_fingerspelling_flutter/core/constants/config_constant.dart';
import 'package:khmer_fingerspelling_flutter/tflite/predicted_position.dart';
import 'package:khmer_fingerspelling_flutter/widgets/kf_fade_in.dart';
import 'package:khmer_fingerspelling_flutter/widgets/kf_scale_in.dart';

class DetectorRect extends StatefulWidget {
  const DetectorRect({
    Key? key,
    required this.position,
    required this.relativeImageSize,
    required this.onLongPress,
    required this.onTap,
    required this.onPositionUpdate,
  }) : super(key: key);

  final PredictedPosition position;
  final Size relativeImageSize;

  final void Function() onLongPress;
  final void Function(PredictedPosition position) onTap;
  final void Function(PredictedPosition position) onPositionUpdate;

  @override
  State<DetectorRect> createState() => _DetectorRectState();
}

enum _Conrner {
  topLeft,
  topRight,
  bottomLeft,
  bottomRight,
}

class _DetectorRectState extends State<DetectorRect> {
  late double top;
  late double bottom;
  late double left;
  late double right;

  late final double initialTop;
  late final double initialBottom;
  late final double initialLeft;
  late final double initialRight;
  late final Size initialSize;

  _Conrner? selectingCorner;

  @override
  void initState() {
    top = widget.position.y * widget.relativeImageSize.height;
    bottom = widget.relativeImageSize.height - (top + widget.position.h * widget.relativeImageSize.height);

    left = widget.position.x * widget.relativeImageSize.width;
    right = widget.relativeImageSize.width - (left + widget.position.w * widget.relativeImageSize.width);

    initialTop = top;
    initialBottom = bottom;
    initialLeft = left;
    initialRight = right;

    initialSize = Size(
      widget.relativeImageSize.width - (initialLeft + initialRight),
      widget.relativeImageSize.height - (initialTop + initialBottom),
    );

    double add = 12;
    if (add > 0) {
      top = top - add;
      bottom = bottom - add;

      left = left - add;
      right = right - add;
    }

    widget.onPositionUpdate(getCurrentPosition());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
        top: max(0, top),
        left: max(0, left),
        right: max(0, right),
        bottom: max(0, bottom),
      ),
      child: KfFadeIn(
        child: KfScaleIn(
          transformAlignment: Alignment.center,
          duration: ConfigConstant.duration,
          curve: Curves.ease,
          child: GestureDetector(
            onTap: () => onTap(),
            onPanEnd: (_) => selectingCorner = null,
            onLongPress: () => widget.onLongPress(),
            onPanDown: (details) => loadSettlingCorner(details),
            onPanUpdate: (details) => onPanUpdate(details),
            child: CustomPaint(
              foregroundPainter: _BorderPainter(),
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

  void onTap() {
    PredictedPosition position = getCurrentPosition();
    widget.onTap(position);
  }

  PredictedPosition getCurrentPosition() {
    double x = left;
    double y = top;
    double w = widget.relativeImageSize.width - (left + right);
    double h = widget.relativeImageSize.height - (top + bottom);

    x = x / widget.relativeImageSize.width;
    y = y / widget.relativeImageSize.height;
    w = w / widget.relativeImageSize.width;
    h = h / widget.relativeImageSize.height;

    final position = PredictedPosition(x, y, w, h);
    return position;
  }

  void loadSettlingCorner(DragDownDetails details) {
    // topLeft     : Offset(7.5, 6.8)
    // topRight    : Offset(62.0, 9.3)
    // bottomRight : Offset(61.0, 87.8)
    // bottomLeft  : Offset(9.0, 88.3)

    bool t1 = details.localPosition.dx < initialSize.width / 2;
    bool t2 = details.localPosition.dy < initialSize.height / 2;
    bool t3 = details.localPosition.dx > initialSize.width / 2;
    bool t4 = details.localPosition.dy > initialSize.height / 2;

    bool topLeft = t1 && t2;
    bool topRight = t3 && t2;
    bool bottomLeft = t1 && t4;
    bool bottomRight = t3 && t4;

    if (topLeft) selectingCorner = _Conrner.topLeft;
    if (topRight) selectingCorner = _Conrner.topRight;
    if (bottomLeft) selectingCorner = _Conrner.bottomLeft;
    if (bottomRight) selectingCorner = _Conrner.bottomRight;

    if (kDebugMode) {
      print("topLeft: $topLeft, topRight: $topRight, bottomRight: $bottomRight, bottomLeft: $bottomLeft");
    }
  }

  void onPanUpdate(DragUpdateDetails details) {
    switch (selectingCorner) {
      case _Conrner.topLeft:
        left = left + details.delta.dx;
        top = top + details.delta.dy;

        bool excedeWidth = initialSize.width + left > widget.relativeImageSize.width - right;
        if (excedeWidth) selectingCorner = _Conrner.topRight;

        bool excedeHeight = initialSize.height + top > widget.relativeImageSize.height - bottom;
        if (excedeHeight) selectingCorner = _Conrner.bottomLeft;

        reloadState();
        break;
      case _Conrner.topRight:
        right = right - details.delta.dx;
        top = top + details.delta.dy;

        bool excedeWidth = initialSize.width + right > widget.relativeImageSize.width - left;
        if (excedeWidth) selectingCorner = _Conrner.topLeft;

        bool excedeHeight = initialSize.height + top > widget.relativeImageSize.height - bottom;
        if (excedeHeight) selectingCorner = _Conrner.bottomRight;

        reloadState();
        break;
      case _Conrner.bottomLeft:
        left = left + details.delta.dx;
        bottom = bottom - details.delta.dy;

        bool excedeWidth = initialSize.width + left > widget.relativeImageSize.width - right;
        if (excedeWidth) selectingCorner = _Conrner.bottomRight;

        bool excedeHeight = initialSize.height + bottom > widget.relativeImageSize.height - top;
        if (excedeHeight) selectingCorner = _Conrner.topLeft;

        reloadState();
        break;
      case _Conrner.bottomRight:
        right = right - details.delta.dx;
        bottom = bottom - details.delta.dy;

        bool excedeWidth = initialSize.width + right > widget.relativeImageSize.width - left;
        if (excedeWidth) selectingCorner = _Conrner.bottomLeft;

        bool excedeHeight = initialSize.height + bottom > widget.relativeImageSize.height - top;
        if (excedeHeight) selectingCorner = _Conrner.topRight;

        reloadState();
        break;
      default:
        break;
    }

    widget.onPositionUpdate(getCurrentPosition());
  }

  void reloadState() {
    setState(() {
      top = max(0, top);
      left = max(0, left);
      bottom = max(0, bottom);
      right = max(0, right);
    });
  }
}

class _BorderPainter extends CustomPainter {
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
  bool shouldRepaint(_BorderPainter oldDelegate) => false;

  @override
  bool shouldRebuildSemantics(_BorderPainter oldDelegate) => false;
}
