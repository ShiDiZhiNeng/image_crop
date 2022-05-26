import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:new_image_crop/data/data_editor_config.dart';
import 'package:new_image_crop/extensions/widget_extension.dart';
import 'package:new_image_crop/ui/dialog/image_editor_component/image_editor_plane.dart';

class ExampleDemo {
  static void show({
    required BuildContext context,
    required ByteData imageData,
  }) {
    final controller = ImageEditorController();
    final editorConfig = DataEditorConfig(
        // Configure the padding of the editing area
        cropRectPadding: const EdgeInsets.all(20.0),
        // Configure the length of the four corners of the viewfinder
        cornerLength: 30,
        // Configure the width of the four corners of the viewfinder
        cornerWidth: 4,
        // Configure the color of the four corners of the viewfinder
        cornerColor: Colors.blue,
        // Configure the click response area of the four corners of the viewfinder
        cornerHitTestSize: const Size(40, 40),
        // Configure the color of the four sides of the viewfinder
        lineColor: Colors.white,
        // Configure the color of the four sides of the viewfinder
        lineWidth: 2,
        // Configure the width of the four sides of the viewfinder frame
        lineHitTestWidth: 40,
        // Configure the length of each unit of the nine-square dotted line in the viewfinder
        dottedLength: 2,
        // Configure the color of the dotted line of the nine-square grid in the viewfinder
        dottedColor: Colors.white,
        // Configure the color of the outer portion of the viewfinder
        editorMaskColorHandler: (context, isTouching) {
          return Colors.black;
        });

    showGeneralDialog(
        context: context,
        pageBuilder: (context, animation, secondaryAnimation) {
          final media = MediaQuery.of(context);
          return Material(
            child: Center(
              child: Container(
                width: media.size.width,
                height: media.size.height,
                color: Colors.black,
                child: Column(
                  children: [
                    SizedBox(
                      width: double.maxFinite,
                      height: media.padding.top,
                    ),
                    Expanded(
                      child: ImageEditorPlane(
                          imageData: imageData,
                          controller: controller,
                          editorConfig: editorConfig),
                    ),
                    Container(
                      width: double.maxFinite,
                      height: 1,
                      color: Colors.white,
                    ),
                    Container(
                      color: Colors.grey.withOpacity(0.5),
                      height: 50,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          //------------ 旋转
                          Container(
                              color: Colors.transparent,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 10),
                              child: const Text(
                                'x轴 --',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 12),
                              )).gestureDetector(
                            onTap: () {
                              print('x轴 --');
                              controller.reduceRotateXAngle();
                            },
                          ),
                          Container(
                              color: Colors.transparent,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 10),
                              child: const Text(
                                'x轴 ++',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 12),
                              )).gestureDetector(
                            onTap: () {
                              print('x轴 ++');
                              controller.addRotateXAngle();
                            },
                          ),
                          //------------ y轴旋转
                          Container(
                              color: Colors.transparent,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 10),
                              child: const Text(
                                'y轴 --',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 12),
                              )).gestureDetector(
                            onTap: () {
                              print('y轴 --');
                              controller.reduceRotateYAngle();
                            },
                          ),
                          Container(
                              color: Colors.transparent,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 10),
                              child: const Text(
                                'y轴 ++',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 12),
                              )).gestureDetector(
                            onTap: () {
                              print('y轴 ++');
                              controller.addRotateYAngle();
                            },
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: double.maxFinite,
                      height: 1,
                      color: Colors.white,
                    ),
                    Container(
                      color: Colors.grey.withOpacity(0.5),
                      height: 50,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          //------------ 旋转
                          Container(
                              color: Colors.transparent,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 10),
                              child: const Text(
                                '<<旋转',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 12),
                              )).gestureDetector(
                            onTap: () {
                              print('+ <<');
                              controller.addRotateAngle();
                            },
                          ),
                          Container(
                              color: Colors.transparent,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 10),
                              child: const Text(
                                '旋转>>',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 12),
                              )).gestureDetector(
                            onTap: () {
                              print('>> -');
                              controller.reduceRotateAngle();
                            },
                          ),
                          //------------ 旋转 90
                          Container(
                              color: Colors.transparent,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 10),
                              child: const Text(
                                '旋转左90',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 12),
                              )).gestureDetector(
                            onTap: () {
                              print('+ <<');
                              controller.addRotateAngle90();
                            },
                          ),
                          // Container(
                          //     color: Colors.transparent,
                          //     padding: const EdgeInsets.symmetric(
                          //         horizontal: 10, vertical: 10),
                          //     child: const Text(
                          //       '旋转右90',
                          //       style: TextStyle(
                          //           color: Colors.white, fontSize: 12),
                          //     )).gestureDetector(
                          //   onTap: () {
                          //     print('>> -');
                          //     controller.reduceRotateAngle90();
                          //   },
                          // ),
                          //------------ 缩放
                          Container(
                              color: Colors.transparent,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 10),
                              child: const Text(
                                '缩放 --',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 12),
                              )).gestureDetector(
                            onTap: () {
                              print('缩放 --');
                              controller.reduceScaleRatio();
                            },
                          ),
                          Container(
                              color: Colors.transparent,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 10),
                              child: const Text(
                                '缩放 ++',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 12),
                              )).gestureDetector(
                            onTap: () {
                              print('缩放 ++');
                              controller.addScaleRatio();
                            },
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: double.maxFinite,
                      height: 1,
                      color: Colors.white,
                    ),
                    Container(
                      color: Colors.grey.withOpacity(0.5),
                      height: 50,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          //------------ 上下翻转
                          Container(
                              color: Colors.transparent,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 10),
                              child: const Text(
                                '上下翻转',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 12),
                              )).gestureDetector(
                            onTap: controller.upsideDown,
                          ),
                          //------------ 左右翻转
                          Container(
                              color: Colors.transparent,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 10),
                              child: const Text(
                                '左右翻转',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 12),
                              )).gestureDetector(
                            onTap: controller.turnAround,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: double.maxFinite,
                      height: 1,
                      color: Colors.white,
                    ),
                    Container(
                      color: Colors.grey.withOpacity(0.5),
                      height: 50,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Container(
                              color: Colors.transparent,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 10),
                              child: const Text(
                                '取消',
                                style: TextStyle(color: Colors.white),
                              )).gestureDetector(
                            onTap: () {
                              print('取消');
                              Navigator.pop(context);
                            },
                          ),
                          Container(
                              color: Colors.transparent,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 10),
                              child: const Text(
                                '裁剪',
                                style: TextStyle(color: Colors.white),
                              )).gestureDetector(
                            onTap: () {
                              print('裁剪');
                              controller.tailor();
                            },
                          ),
                          Container(
                              color: Colors.transparent,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 10),
                              child: const Text(
                                '还原',
                                style: TextStyle(color: Colors.white),
                              )).gestureDetector(
                            onTap: () {
                              print('还原');
                              controller.restore();
                            },
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: double.maxFinite,
                      height: 1,
                      color: Colors.white,
                      margin: EdgeInsets.only(bottom: media.padding.bottom),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }
}
