class PredictedPosition {
  final double x;
  final double y;
  final double w;
  final double h;

  PredictedPosition(this.x, this.y, this.w, this.h);
  factory PredictedPosition.withParams({
    required double x,
    required double y,
    required double w,
    required double h,
  }) {
    return PredictedPosition(x, y, w, h);
  }

  @override
  String toString() {
    return "x: $x, y: $y, w: $w, h: $h";
  }
}
