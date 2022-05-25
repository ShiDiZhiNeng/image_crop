// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:new_image_crop/data/data_drag_details_group.dart';
import 'package:new_image_crop/data/data_scale_details_group.dart';
import 'package:new_image_crop/extensions/template_extension.dart';

export 'package:new_image_crop/extensions/widget_extension.dart';

extension WidgetExtension on Widget {
  Expanded expanded({
    Key? key,
    int flex = 1,
  }) {
    return Expanded(key: key, child: this);
  }

  Positioned positioned({
    Key? key,
    double? left,
    double? top,
    double? right,
    double? bottom,
    double? width,
    double? height,
  }) {
    return Positioned(
      left: left,
      top: top,
      right: right,
      bottom: bottom,
      width: width,
      height: height,
      child: this,
    );
  }

  GestureDetector gestureDetector({
    Key? key,
    HitTestBehavior? behavior,
    void Function()? onTap,
    void Function(TapDownDetails)? onTapDown,
    void Function()? onTapCancel,
    //垂直
    void Function(DragDownDetails)? onVerticalDragDown,
    void Function(DragStartDetails)? onVerticalDragStart,
    void Function(DragUpdateDetails)? onVerticalDragUpdate,
    void Function(DragEndDetails)? onVerticalDragEnd,
    void Function()? onVerticalDragCancel,
    //水平
    void Function(DragDownDetails)? onHorizontalDragDown,
    void Function(DragStartDetails)? onHorizontalDragStart,
    void Function(DragUpdateDetails)? onHorizontalDragUpdate,
    void Function(DragEndDetails)? onHorizontalDragEnd,
    void Function()? onHorizontalDragCancel,
    //垂直_水平
    void Function(DragDownDetails)? onPanDown,
    void Function(DragStartDetails)? onPanStart,
    void Function(DragUpdateDetails)? onPanUpdate,
    void Function(DragEndDetails)? onPanEnd,
    void Function()? onPanCancel,
  }) {
    return GestureDetector(
      key: key,
      behavior: behavior,
      onTap: onTap,
      onTapDown: onTapDown,
      onTapCancel: onTapCancel,
      onVerticalDragDown: onVerticalDragDown,
      onVerticalDragStart: onVerticalDragStart,
      onVerticalDragUpdate: onVerticalDragUpdate,
      onVerticalDragEnd: onVerticalDragEnd,
      onVerticalDragCancel: onVerticalDragCancel,
      onHorizontalDragDown: onHorizontalDragDown,
      onHorizontalDragStart: onHorizontalDragStart,
      onHorizontalDragUpdate: onHorizontalDragUpdate,
      onHorizontalDragEnd: onHorizontalDragEnd,
      onHorizontalDragCancel: onHorizontalDragCancel,
      onPanDown: onPanDown,
      onPanStart: onPanStart,
      onPanUpdate: onPanUpdate,
      onPanEnd: onPanEnd,
      onPanCancel: onPanCancel,
      child: this,
    );
  }

  GestureDetector gestureVerticalWithData({
    Key? key,
    required DataDragDetailsGroup data,
    //垂直
    FunDragDown? onVerticalDragDown,
    FunDragStart? onVerticalDragStart,
    FunDragUpdate? onVerticalDragUpdate,
    FunDragEnd? onVerticalDragEnd,
    FunDragCancel? onVerticalDragCancel,
  }) {
    return GestureDetector(
      key: key,
      //垂直
      onVerticalDragDown: (p0) {
        data.reset();
        data.dragDownDetails = p0;
        onVerticalDragDown?.call(p0, data);
      },
      onVerticalDragStart: (p0) {
        data.dragStartDetails = p0;
        onVerticalDragStart?.call(p0, data);
      },
      onVerticalDragUpdate: (p0) {
        data.dragUpdateDetails = p0;
        onVerticalDragUpdate?.call(p0, data);
      },
      onVerticalDragEnd: (p0) {
        data.dragEndDetails = p0;
        onVerticalDragEnd?.call(p0, data);
        data.reset();
      },
      onVerticalDragCancel: () {
        onVerticalDragCancel?.call(data);
        data.reset();
      },
      child: this,
    );
  }

  GestureDetector gestureHorizontalWithData({
    Key? key,
    required DataDragDetailsGroup data,
    //水平
    FunDragDown? onHorizontalDragDown,
    FunDragStart? onHorizontalDragStart,
    FunDragUpdate? onHorizontalDragUpdate,
    FunDragEnd? onHorizontalDragEnd,
    FunDragCancel? onHorizontalDragCancel,
  }) {
    return GestureDetector(
      key: key,
      //水平
      onHorizontalDragDown: (p0) {
        data.reset();
        data.dragDownDetails = p0;
        onHorizontalDragDown?.call(p0, data);
      },
      onHorizontalDragStart: (p0) {
        data.dragStartDetails = p0;
        onHorizontalDragStart?.call(p0, data);
      },
      onHorizontalDragUpdate: (p0) {
        data.dragUpdateDetails = p0;
        onHorizontalDragUpdate?.call(p0, data);
      },
      onHorizontalDragEnd: (p0) {
        data.dragEndDetails = p0;
        onHorizontalDragEnd?.call(p0, data);
        data.reset();
      },
      onHorizontalDragCancel: () {
        onHorizontalDragCancel?.call(data);
        data.reset();
      },
      child: this,
    );
  }

  GestureDetector gesturePanWithData(
      {Key? key,
      required DataDragDetailsGroup data,
      //垂直_水平
      FunDragDown? onPanDown,
      FunDragStart? onPanStart,
      FunDragUpdate? onPanUpdate,
      FunDragEnd? onPanEnd,
      FunDragCancel? onPanCancel,
      void Function()? onTap,
      void Function()? onDoubleTap}) {
    return GestureDetector(
        key: key,
        //垂直_水平
        onPanDown: (p0) {
          data.reset();
          data.dragDownDetails = p0;
          onPanDown?.call(p0, data);
        },
        onPanStart: (p0) {
          data.dragStartDetails = p0;
          onPanStart?.call(p0, data);
        },
        onPanUpdate: (p0) {
          data.dragUpdateDetails = p0;
          onPanUpdate?.call(p0, data);
        },
        onPanEnd: (p0) {
          data.dragEndDetails = p0;
          onPanEnd?.call(p0, data);
          data.reset();
        },
        onPanCancel: () {
          onPanCancel?.call(data);
          data.reset();
        },
        //增加一个普通的点击
        onTap: onTap,
        onDoubleTap: onDoubleTap,
        child: this);
  }

  GestureDetector gestureScaleWithData({
    Key? key,
    required DataScaleDetailsGroup data,
    FunScaleStart? onScaleStart,
    FunScaleUpdate? onScaleUpdate,
    FunScaleEnd? onScaleEnd,
  }) {
    return GestureDetector(
      key: key,
      child: this,
      onScaleStart: (p0) {
        data.reset();
        data.scaleStartDetails = p0;
        onScaleStart?.call(p0, data);
      },
      onScaleUpdate: (p0) {
        data.scaleUpdateDetails = p0;
        onScaleUpdate?.call(p0, data);
      },
      onScaleEnd: (p0) {
        data.scaleEndDetails = p0;
        onScaleEnd?.call(p0, data);
        data.reset();
      },
    );
  }
}
