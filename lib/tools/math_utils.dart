import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:new_image_crop/extensions/num_extension.dart';

class MathUtils {
  MathUtils._();

  ///输入弧度值，return 角度值
  static double trace(num x) {
    //弧度 = 角度 * Math.PI / 180
    return 180 * x / math.pi;
  }

  ///输入角度值，return 弧度值
  static double retrace(num x) {
    //弧度 = 角度 * Math.PI / 180
    return x * math.pi / 180;
  }

  ///输入角度值，return cos斜率
  static double angle2CosSlope(double angle) {
    final radian = MathUtils.retrace(angle);
    //弧度拿到斜率
    final cosSlope = math.cos(radian);
    return cosSlope;
  }

  ///输入cos斜率, return 角度值
  static double cosSlope2Angle(double cosSlope) {
    final radian = math.acos(cosSlope);
    //弧度拿到角度
    final angle = MathUtils.trace(radian);
    return angle;
  }

  ///输入角度值，return sin斜率
  static double angle2SinSlope(double angle) {
    final radian = MathUtils.retrace(angle);
    //弧度拿到斜率
    final sinSlope = math.sin(radian);
    return sinSlope;
  }

  ///输入sin斜率, return 角度值
  static double sinSlope2Angle(double sinSlope) {
    final radian = math.asin(sinSlope);
    //弧度拿到角度
    final angle = MathUtils.trace(radian);
    return angle;
  }

  ///计算两个坐标的斜率值
  static double calculateSlope(Offset pre, Offset next) {
    final diffWidth = next.dx - pre.dx;
    final diffHeight = next.dy - pre.dy;
    return diffWidth.abs() / diffHeight.abs();
  }

  ///计算两个坐标的斜率值
  static double calculateSlopeNotAbs(Offset pre, Offset next) {
    final diffWidth = next.dx - pre.dx;
    final diffHeight = next.dy - pre.dy;
    return diffWidth / diffHeight;
  }

  ///判断某个点是在在两个点连线的里边还是外边
  static int insideOrOutsideOfLine(Offset pre, Offset center, Offset next) {
    final slope1 = calculateSlope(pre, next);
    final slope2 = calculateSlope(center, next);
    if (slope1 > slope2) {
      return 1; //里边
    } else if (slope1 < slope2) {
      return -1;
    } //外边
    return 0; //相等
  }

  ///判断某个点是在在两个点连线的里边还是外边2
  static int insideOrOutsideOfLine2(Offset left, Offset right, Offset point,
      {required bool inRight}) {
    if (inRight && left.dx < right.dx && left.dy > right.dy) {
      //判断左上角
      if (point.dx.inRange(left.dx, right.dx) &&
          point.dy.inRange(left.dy, right.dy)) {
        final slope1 = calculateSlope(left, right);
        final slope2 = calculateSlope(left, point);
        if (slope2 > slope1) {
          return 1; //里边
        } else if (slope2 < slope1) {
          return -1; //外边
        }
      }
    } else if (!inRight && left.dx < right.dx && left.dy < right.dy) {
      //判断右上角
      if (point.dx.inRange(left.dx, right.dx) &&
          point.dy.inRange(left.dy, right.dy)) {
        final slope1 = calculateSlope(left, right);
        final slope2 = calculateSlope(point, right);
        if (slope2 > slope1) {
          return 1; //里边
        } else if (slope2 < slope1) {
          return -1; //外边
        }
      }
    } else if (!inRight && left.dx < right.dx && left.dy > right.dy) {
      //判断右下角
      if (point.dx.inRange(left.dx, right.dx) &&
          point.dy.inRange(left.dy, right.dy)) {
        final slope1 = calculateSlope(left, right);
        final slope2 = calculateSlope(left, point);
        if (slope2 > slope1) {
          return -1; //外边
        } else if (slope2 < slope1) {
          return 1; //里边
        }
      }
    } else if (inRight && left.dx < right.dx && left.dy < right.dy) {
      //判断左下角
      if (point.dx.inRange(left.dx, right.dx) &&
          point.dy.inRange(left.dy, right.dy)) {
        final slope1 = calculateSlope(left, right);
        final slope2 = calculateSlope(point, right);
        if (slope2 > slope1) {
          return -1; //外边
        } else if (slope2 < slope1) {
          return 1; //里边
        }
      }
    }
    return 0; //相等
  }

  ///斜率 = (bx - ax) / (by - ay)
  ///逆推得到ax
  static Offset getReverseXBySlope(
      double slope, Offset bOffset /*bx, by*/, double ay) {
    final ax = bOffset.dx - slope * (bOffset.dy - ay);
    return Offset(ax, ay);
  }

  ///斜率 = (bx - ax) / (by - ay)
  ///逆推得到ay
  static Offset getReverseYBySlope(
      double slope, Offset bOffset /*bx, by*/, double ax) {
    final ret = (bOffset.dx - ax) / slope;
    final ay = bOffset.dy - ret;
    return Offset(ax, ay);
  }

  ///计算两点距离
  static double distanceTo(Offset pre, Offset next) {
    final length =
        math.Point(pre.dx, pre.dy).distanceTo(math.Point(next.dx, next.dy));
    return length;
  }

  ///传入直角三角形3个顶点，然后计算斜边为底的高度h
  static double getTriangularHeight(
      Offset rightAnglePoint, Offset other, Offset other2) {
    //先计算3边长度
    //斜边
    final hypotenuse = distanceTo(other, other2);
    //另外两条边
    final section = distanceTo(other, rightAnglePoint);
    final section2 = distanceTo(other2, rightAnglePoint);
    final h = section * section2 / hypotenuse;
    return h;
  }

  ///传入直角三角形斜边和其中一个夹角，然后计算斜边为底的高度h
  static double getTriangularHeight2(double hypotenuse, double angle) {
    //另外两条边
    final section = angle2SinSlope(angle) * hypotenuse;
    final section2 = angle2CosSlope(angle) * hypotenuse;
    final h = section * section2 / hypotenuse;
    return h;
  }

  ///传入直角三角形三个顶点坐标和三角形内任意一个坐标点，然后计算得到该坐标点到斜边上的高
  ///通过求大三角形的面积，减去坐标点(x, y)垂直于三角形另外两条边形成的2个三角形面积，再除以斜边得到斜边上的高
  // static double getHeightFromHypotenuseAndArbitraryPoint(
  //     Offset rectangularCoordinates/**直角坐标 */,
  //     Offset acuteAngleCoordinate/**锐角坐标 */,
  //     Offset acuteAngleCoordinate2/**锐角坐标 */,
  //     Offset arbitraryPoint/** 任意点 */) {
  //   final hypotenuseLen = distanceTo(acuteAngleCoordinate, acuteAngleCoordinate2);
  //   final rightSide = distanceTo(acuteAngleCoordinate, rectangularCoordinates);
  //   final rightSide2 = distanceTo(acuteAngleCoordinate2, rectangularCoordinates);

  //   return 0;
  // }

  ///坐标系转换(支持 90, 180, -180, -90)
  static Offset coordinateSwitch(int fixedRotationAngle, double dx, double dy) {
    switch (fixedRotationAngle) {
      case 90:
        return Offset(-dy, dx);
      case 180:
      case -180:
        return Offset(-dx, -dy);
      case -90:
        return Offset(dy, -dx);
      default:
        return Offset(dx, dy);
    }
  }
}
