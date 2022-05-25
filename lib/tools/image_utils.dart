import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:image/image.dart' as image_lib;

class ImageUtils {
  ImageUtils._();

  /// ByteData 转 ui.image图片
  static Future<ui.Image> byte2UiImage(ByteData imageByteData) async {
    final u8 = imageByteData.buffer.asUint8List();
    final ui.Codec codec = await ui.instantiateImageCodec(u8);
    final ui.FrameInfo fi = await codec.getNextFrame();
    return fi.image;
  }

  ///图片旋转操作
  static Uint8List rotate(Uint8List srcU8, num angle) {
    final sImage = image_lib.decodeImage(srcU8);
    final rotateImage = image_lib.copyRotate(sImage!, angle);
    final newU8 = image_lib.writePng(rotateImage) as Uint8List;
    return newU8;
  }
}
