import 'package:flutter/material.dart';

typedef EditorMaskColorHandler = Color Function(
    BuildContext context, bool pointerDown);

///编辑可配置参数
class DataEditorConfig {
  DataEditorConfig({
    // this.maxScale = 5.0,
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

  // double maxScale;

  EdgeInsets cropRectPadding;

  double cornerLength;

  double cornerWidth;

  Color cornerColor;

  Size cornerHitTestSize;

  Color lineColor;

  double lineWidth;

  double lineHitTestWidth;

  double dottedLength;

  Color dottedColor;

  EditorMaskColorHandler? editorMaskColorHandler;
}
