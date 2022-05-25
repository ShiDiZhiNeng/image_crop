import 'package:flutter/gestures.dart';

class DataDragDetailsGroup {
  ///按下
  DragDownDetails? dragDownDetails;

  ///开始
  DragStartDetails? dragStartDetails;

  ///刷新
  DragUpdateDetails? dragUpdateDetails;

  ///结束
  DragEndDetails? dragEndDetails;

  ///重置
  void reset() {
    dragDownDetails = null;
    dragStartDetails = null;
    dragUpdateDetails = null;
    dragEndDetails = null;
  }

  Offset? diff() {
    if (dragUpdateDetails != null && dragDownDetails != null) {
      final dx = dragUpdateDetails!.globalPosition.dx -
          dragDownDetails!.globalPosition.dx;
      final dy = dragUpdateDetails!.globalPosition.dy -
          dragDownDetails!.globalPosition.dy;
      return Offset(dx, dy);
    }
    return null;
  }
}

//水平
typedef FunDragDown = void Function(DragDownDetails, DataDragDetailsGroup);
typedef FunDragStart = void Function(DragStartDetails, DataDragDetailsGroup);
typedef FunDragUpdate = void Function(DragUpdateDetails, DataDragDetailsGroup);
typedef FunDragEnd = void Function(DragEndDetails, DataDragDetailsGroup);
typedef FunDragCancel = void Function(DataDragDetailsGroup);

//垂直
// typedef FunOnHorizontalDragDown = void Function(
//     DragDownDetails, DataDragDetailsGroup?);
// typedef FunOnHorizontalDragStart = void Function(
//     DragStartDetails, DataDragDetailsGroup?);
// typedef FunOnHorizontalDragUpdate = void Function(
//     DragUpdateDetails, DataDragDetailsGroup?);
// typedef FunOnHorizontalDragEnd = void Function(
//     DragEndDetails, DataDragDetailsGroup?);
// typedef FunOnHorizontalDragCancel = void Function(DataDragDetailsGroup?);

//垂直_水平
// typedef FunOnPanDown = void Function(DragDownDetails, DataDragDetailsGroup?);
// typedef FunOnPanStart = void Function(DragStartDetails, DataDragDetailsGroup?);
// typedef FunOnPanUpdate = void Function(
//     DragUpdateDetails, DataDragDetailsGroup?);
// typedef FunOnPanEnd = void Function(DragEndDetails, DataDragDetailsGroup?);
// typedef FunOnPanCancel = void Function(DataDragDetailsGroup?);
