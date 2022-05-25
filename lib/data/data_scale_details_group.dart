// ignore_for_file: non_constant_identifier_names

import 'package:flutter/gestures.dart';

class DataScaleDetailsGroup {
  ///开始
  DateTime? _dateTime_scaleStartDetails;
  DateTime? get dateTime_scaleStartDetails => _dateTime_scaleStartDetails;
  ScaleStartDetails? _scaleStartDetails;
  ScaleStartDetails? get scaleStartDetails => _scaleStartDetails;
  set scaleStartDetails(ScaleStartDetails? v) {
    _scaleStartDetails = v;
    _dateTime_scaleStartDetails = v != null ? DateTime.now() : null;
  }

  ///上一次刷新
  DateTime? _dateTime_scaleUpdateDetails_last;
  DateTime? get dateTime_scaleUpdateDetails_last =>
      _dateTime_scaleUpdateDetails_last ?? dateTime_scaleStartDetails;
  Offset? _scaleUpdatePoint_last;
  Offset? get scaleUpdatePoint_last =>
      _scaleUpdatePoint_last ?? scaleStartDetails?.localFocalPoint;

  ///刷新
  DateTime? _dateTime_scaleUpdateDetails;
  DateTime? get dateTime_scaleUpdateDetails => _dateTime_scaleUpdateDetails;
  ScaleUpdateDetails? _scaleUpdateDetails;
  ScaleUpdateDetails? get scaleUpdateDetails => _scaleUpdateDetails;
  set scaleUpdateDetails(ScaleUpdateDetails? v) {
    //原值保存为上一次
    _scaleUpdatePoint_last = _scaleUpdateDetails?.localFocalPoint;
    _dateTime_scaleUpdateDetails_last = _dateTime_scaleUpdateDetails;
    //赋值新值
    _scaleUpdateDetails = v;
    _dateTime_scaleUpdateDetails = v != null ? DateTime.now() : null;
  }

  ///结束
  DateTime? _dateTime_scaleEndDetails;
  DateTime? get dateTime_scaleEndDetails => _dateTime_scaleEndDetails;
  ScaleEndDetails? _scaleEndDetails;
  ScaleEndDetails? get scaleEndDetails => _scaleEndDetails;
  set scaleEndDetails(ScaleEndDetails? v) {
    _scaleEndDetails = v;
    _dateTime_scaleEndDetails = v != null ? DateTime.now() : null;
  }

  ///重置
  void reset() {
    scaleStartDetails = null;
    scaleUpdateDetails = null;
    scaleEndDetails = null;
  }

  Offset? diff() {
    if (scaleUpdateDetails != null && scaleStartDetails != null) {
      final dx = scaleUpdateDetails!.localFocalPoint.dx -
          scaleStartDetails!.localFocalPoint.dx;
      final dy = scaleUpdateDetails!.localFocalPoint.dy -
          scaleStartDetails!.localFocalPoint.dy;
      return Offset(dx, dy);
    }
    return null;
  }
}

typedef FunScaleStart = void Function(ScaleStartDetails, DataScaleDetailsGroup);
typedef FunScaleUpdate = void Function(
    ScaleUpdateDetails, DataScaleDetailsGroup);
typedef FunScaleEnd = void Function(ScaleEndDetails, DataScaleDetailsGroup);
