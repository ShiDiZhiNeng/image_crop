import 'dart:ui' as ui;

import 'package:flutter/material.dart';

class ResultPaint extends CustomPainter {
  final ui.Image image;
  final Rect tailorRect;

  ResultPaint({required this.image, required this.tailorRect});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    canvas.drawImageRect(
        image,
        tailorRect,
        Rect.fromLTWH(0, 0, tailorRect.width, tailorRect.height),
        // Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
        // Rect.fromLTWH(0, 0, size.width, size.height),
        paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
