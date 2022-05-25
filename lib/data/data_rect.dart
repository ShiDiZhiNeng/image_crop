class DataRect {
  late double left;
  late double top;
  late double right;
  late double bottom;

  double get width => right - left;
  set width(double v) {
    right = left + v;
  }

  double get height => bottom - top;
  set height(double v) {
    bottom = top + v;
  }

  DataRect.fromLTRB(
    this.left,
    this.top,
    this.right,
    this.bottom,
  );

  DataRect.fromLTWH(
    double left,
    double top,
    double width,
    double height,
  ) : this.fromLTRB(left, top, left + width, top + height);
}
