import 'dart:math';

extension NumExtension on num {
  R square<R extends num>() {
    return this * this as R;
  }

  ///判断数字是否在范围内
  bool inRange(double left, double right) {
    final num = this.toDouble();
    final pre = min(left, right);
    final next = max(left, right);
    return num >= pre && num <= next;
  }
}
