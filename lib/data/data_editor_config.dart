import 'package:flutter/material.dart';

typedef EditorMaskColorHandler = Color Function(
    BuildContext context, bool pointerDown);

///编辑可配置参数
class DataEditorConfig {
  DataEditorConfig({
    this.bgColor = Colors.black,
    this.cropRectPadding = const EdgeInsets.all(20.0),
    this.cornerLength = 30,
    this.cornerWidth = 4,
    this.cornerColor = Colors.blue,
    this.cornerHitTestSize = const Size(40, 40),
    this.lineColor = Colors.white,
    this.lineWidth = 2,
    this.lineHitTestWidth = 40,
    this.dottedLength = 2,
    this.dottedColor = Colors.white,
    this.editorMaskColorHandler,
  });

  /// 编辑区域背景颜色
  final Color bgColor;

  /// 编辑区域widght的padding
  final EdgeInsets cropRectPadding;

  /// 取景框边角长度
  final double cornerLength;

  /// 取景框边角宽度
  final double cornerWidth;

  /// 取景框边角颜色
  final Color cornerColor;

  /// 取景框边角响应范围
  final Size cornerHitTestSize;

  /// 取景框四条边颜色
  final Color lineColor;

  /// 取景框四条边边宽
  final double lineWidth;

  /// 取景框四条边响应面积宽度
  final double lineHitTestWidth;

  /// 取景框中九宫格虚线点单位长度
  final double dottedLength;

  /// 取景框中九宫格虚线颜色
  final Color dottedColor;

  /// 配置取景器外部部分的颜色
  final EditorMaskColorHandler? editorMaskColorHandler;
}
