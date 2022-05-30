import 'dart:ui';

extension RectExtension on Rect {
  ///Rect copy
  Rect copy({double? left, double? top, double? width, double? height}) {
    return Rect.fromLTWH(left ?? this.left, top ?? this.top,
        width ?? this.width, height ?? this.height);
  }
}
