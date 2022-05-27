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

  final Color bgColor;

  final EdgeInsets cropRectPadding;

  final double cornerLength;

  final double cornerWidth;

  final Color cornerColor;

  final Size cornerHitTestSize;

  final Color lineColor;

  final double lineWidth;

  final double lineHitTestWidth;

  final double dottedLength;

  final Color dottedColor;

  final EditorMaskColorHandler? editorMaskColorHandler;
}
