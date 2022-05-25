import 'package:extended_image/extended_image.dart';
import 'package:flutter/widgets.dart';
import 'package:new_image_crop/tools/phone_permission.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

class PhotoUtils {
  PhotoUtils._();

  static Future<List<String>> selectLocalPhotos(
      {required BuildContext context, int maxAssets = 1}) async {
    if (await PhonePermission.check() == false) {
      return [];
    }
    try {
      final entitys =
          await AssetPicker.pickAssets(context, maxAssets: maxAssets);
      if (entitys == null) {
        return [];
      }

      final chooseImagesPath = <String>[];
      //遍历
      for (final entity in entitys) {
        final imgFile = await entity.file;
        if (imgFile != null) chooseImagesPath.add(imgFile.path);
      }
      print('选择照片路径:$chooseImagesPath');

      return chooseImagesPath;
    } catch (e) {
      print('e:${e.toString()}');
    }
    return [];
  }

  static void getNetPhotos() {}
}
