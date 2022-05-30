import 'package:flutter/material.dart';

///操作限制返回结果
class DataLimitResult {
  ///返回需变更 移动坐标
  Offset? movePos;

  ///返回需变更 缩放大小
  double? scale;

  DataLimitResult();
}
