import 'dart:ui' as ui;

import 'package:flutter/services.dart';
import 'package:new_image_crop/tools/image_utils.dart';

class AssertUtils {
  AssertUtils._();

  /// 读取assert里的文件， 返回图片类型数据
  static Future<ui.Image> readImage(String fileName) async {
    final ByteData data = await rootBundle.load(fileName);
    final u8List = data.buffer.asUint8List();
    final u8 = ImageUtils.rotate(u8List, -0);
    final ui.Codec codec = await ui.instantiateImageCodec(u8);
    final ui.FrameInfo fi = await codec.getNextFrame();
    return fi.image;
  }

  /// 读取assert里的文件， 返回ByteData类型数据
  static Future<ByteData> readImageByByteData(String fileName) async {
    final ByteData data = await rootBundle.load(fileName);
    return data;
  }
}
