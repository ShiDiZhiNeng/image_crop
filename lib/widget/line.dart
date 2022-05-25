import 'package:flutter/material.dart';

class Line extends StatelessWidget {
  final double width;
  final double height;
  EdgeInsets? padding;
  EdgeInsets? margin;
  Color? color;

  Line(
      {Key? key,
      required this.width,
      required this.height,
      this.padding,
      this.margin,
      this.color})
      : super(key: key) {
    this.color ??= Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: this.width,
      height: this.height,
      color: this.color,
      padding: this.padding,
      margin: this.margin,
    );
  }
}

///水平线
class HorizontalLine extends Line {
  HorizontalLine({
    Key? key,
    double? length,
    double? width,
    EdgeInsets? padding,
    EdgeInsets? margin,
    Color? color,
  }) : super(
            key: key,
            width: length ?? double.maxFinite,
            height: width ?? 1,
            padding: padding,
            margin: margin,
            color: color);
}

///垂直线
class VerticalLine extends Line {
  VerticalLine({
    Key? key,
    double? length,
    double? width,
    EdgeInsets? padding,
    EdgeInsets? margin,
    Color? color,
  }) : super(
            key: key,
            width: width ?? 1,
            height: length ?? double.maxFinite,
            padding: padding,
            margin: margin,
            color: color);
}
