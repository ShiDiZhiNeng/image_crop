import 'dart:ui' as ui;

import 'package:flutter/services.dart';
import 'package:new_image_crop/tools/image_utils.dart';

class AssertUtils {
  AssertUtils._();

  static Future<ui.Image> readImage(String fileName) async {
    final ByteData data = await rootBundle.load(fileName);
    final u8List = data.buffer.asUint8List();
    final u8 = ImageUtils.rotate(u8List, -0);
    final ui.Codec codec = await ui.instantiateImageCodec(u8);
    final ui.FrameInfo fi = await codec.getNextFrame();
    return fi.image;
  }

  static Future<ByteData> readImageByByteData(String fileName) async {
    final ByteData data = await rootBundle.load(fileName);
    return data;
  }
}
