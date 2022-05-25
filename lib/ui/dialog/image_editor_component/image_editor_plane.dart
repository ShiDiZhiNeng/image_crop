// ignore_for_file: close_sinks, non_constant_identifier_names, unused_local_variable

///
///设计结构:
///底图(一个正方形图形,操作图刚好与其贴边，操作图发生状态改变时，只做坐标计算同步，本身不做状态改变)
///操作图(旋转，缩放，左右上下翻转)
///取景框(选择区域裁剪，操作图发生状态改变时，只做坐标计算同步，本身不做状态改变)
///

library image_editor;

import 'dart:async';
import 'dart:math' as math;
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

// import 'package:image/src/transform/copy_crop.dart' as crop;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:new_image_crop/constant/direction.dart';
import 'package:new_image_crop/data/data_coordinate_transformation_with_90_result.dart';
// import 'package:image/image.dart' as crop;
import 'package:new_image_crop/data/data_drag_details_group.dart';
import 'package:new_image_crop/data/data_editor_config.dart';
import 'package:new_image_crop/data/data_limit_result.dart';
import 'package:new_image_crop/data/data_scale_details_group.dart';
import 'package:new_image_crop/data/data_simple_cache.dart';
import 'package:new_image_crop/data/data_update_base_map_result.dart';
import 'package:new_image_crop/data/data_viewfinder_zoom_in_result.dart';
import 'package:new_image_crop/extensions/num_extension.dart';
import 'package:new_image_crop/extensions/rect_extension.dart';
import 'package:new_image_crop/extensions/template_extension.dart';
import 'package:new_image_crop/extensions/widget_extension.dart';
import 'package:new_image_crop/paint/result_paint.dart';
import 'package:new_image_crop/tools/fnum.dart';
import 'package:new_image_crop/tools/image_utils.dart';
import 'package:new_image_crop/tools/math_utils.dart';
import 'package:new_image_crop/tools/timed_task.dart';
import 'package:new_image_crop/widget/line.dart';

part './image_editor_select_box.dart';
part './image_editor_controller.dart';
part './image_editor_property.dart';
part './image_editor_calculate.dart';

/*
  旋转，缩放，剪裁
*/
class ImageEditorPlane extends StatefulWidget {
  const ImageEditorPlane({
    Key? key,
    required this.imageData,
    required this.editorConfig,
    required this.controller,
  }) : super(key: key);

  final DataEditorConfig editorConfig;
  final ByteData imageData;
  final ImageEditorController controller;

  @override
  State<StatefulWidget> createState() => _ImageEditorPlaneState();
}

class _ImageEditorPlaneState extends State<ImageEditorPlane>
    with TickerProviderStateMixin, ImageEditorCalculate {
  ///handlekey
  final GlobalKey<_ImageEditorPlaneState> _handleKey =
      GlobalKey<_ImageEditorPlaneState>();

  final _repaintBoundaryKey = GlobalKey();

  ///取景框key
  UniqueKey? _selectBoxKey;

  ///图片编辑操作管理
  late ImageEditorController _editorController;

  ///图片编辑相关参数
  DataEditorConfig get editorConfig => widget.editorConfig;

  //原始数据 _ 不受参数影响
  Size? _winSize;

  ///获取当前 win Size
  Size? get winSize {
    return _winSize;
  }

  ///获取可操作性空间 Rect
  Rect? get operationWinRect {
    return _winSize?.also((it) {
      return Rect.fromLTWH(10, 10, it.width - 20, it.height - 20);
    });
  }

  ///  '-((math.pi / 4) / 3) / 15)' = 1度 的意思
  final angel_1_degree = -((math.pi / 4) / 3) / 15;

  //可移动坐标(转底图,中心点使用， 位移，旋转，缩放，都以这个为中心点)
  ///用作位移中心点x
  final _moveX = DataSimpleCache<double>(value: 0);

  ///用作位移中心点y
  final _moveY = DataSimpleCache<double>(value: 0);

  ///获取中心点 _ 不受参数影响
  Offset get centrePoint {
    if (winSize != null) {
      return Offset(winSize!.width / 2, winSize!.height / 2);
    }
    return Offset.zero;
  }

  ///单指拖拽数据
  final dataDragDetailsGroup = DataDragDetailsGroup();

  ///多指缩放数据
  final dataScaleDetailsGroup = DataScaleDetailsGroup();

  ///编辑操作属性
  final prop = ImageEditorProperty();

  ///底图 rect
  Rect get baseMap_rect {
    return Rect.fromCenter(
        center: ui.Offset(_moveX.value, _moveY.value),
        width: prop.baseMapSize.width,
        height: prop.baseMapSize.height);
  }

  ///底图的坐标 left
  // double get posX_baseMap {
  // return _moveX.value - prop.baseMapSize.width / 2;
  // return rect_baseMap.left;
  // }

  ///底图的坐标 top
  // double get posY_baseMap {
  // return _moveY.value - prop.baseMapSize.height / 2;
  // return rect_baseMap.top;
  // }

  ///底图 中心坐标
  // Offset get centralPoint_baseMap {
  // return Offset(_moveX.value, _moveY.value);
  //   return rect_baseMap.center;
  // }

  ///底图替身的坐标 left
  double get posX_substitute {
    return _moveX.value - prop.substituteSize!.width / 2;
  }

  ///底图替身的坐标 top
  double get posY_substitute {
    return _moveY.value - prop.substituteSize!.height / 2;
  }

  ///底图替身 中心坐标
  Offset get centralPoint_substitute {
    return Offset(posX_substitute + prop.substituteSize!.width / 2,
        posY_substitute + prop.substituteSize!.height / 2);
  }

  ///是否拖拽替身图中
  bool _isDragingSubstitute = false;
  bool get isDragingSubstitute => _isDragingSubstitute;
  set isDragingSubstitute(bool v) {
    _isDragingSubstitute = v;
    if (v) {
      _animationController?.stop();
      _animationController_moveOffset?.stop();
      _animationController_propScale?.stop();
      _animationController_propRotate?.stop();
      _animationController_selectBox?.stop();
    }
  }

  ///取景器传入矩形值
  late Rect _initRect_selectBox;

  ///取景器可挪动变化的范围
  late Rect _limitRect_selectBox;

  ///取景器返回的矩形值
  late Rect _resultRect_selectBox;

  //定时任务
  TimedTask? _timedTask_Adaptive;

  ///------------ 动画相关 ------------
  AnimationController? _animationController;

  ///底图位移controller
  AnimationController? _animationController_moveOffset;

  ///底图位移间距
  Animation<Offset>? _animation_moveOffset;

  ///底图缩放controller
  AnimationController? _animationController_propScale;

  ///底图缩放间距
  Animation<double>? _animation_propScale;

  ///底图旋转controller
  AnimationController? _animationController_propRotate;

  ///底图旋转间距
  Animation<double>? _animation_propRotate;

  ///取景框controller
  AnimationController? _animationController_selectBox;

  ///取景框位移
  Animation<Offset>? _animation_selectBox_offset;

  ///取景框大小
  Animation<Size>? _animation_selectBox_size;

  @override
  void initState() {
    super.initState();

    //根据配置重置缩放值
    // prop._scaleRatio = prop._scaleRatio.clone(max: editorConfig.maxScale);

    _editorController = widget.controller;
    _editorController._stream.stream.listen((event) {
      if (event['FunName'] == 'rotateXAngle') {
        final isAdd = event['args']['isAdd'] as bool?;
        isAdd?.go((it) => it ? addRotateXAngle() : reduceRotateXAngle());
      } else if (event['FunName'] == 'rotateYAngle') {
        final isAdd = event['args']['isAdd'] as bool?;
        isAdd?.go((it) => it ? addRotateYAngle() : reduceRotateYAngle());
      } else if (event['FunName'] == 'rotateAngle') {
        final isAdd = event['args']['isAdd'] as bool?;
        isAdd?.go((it) => it ? addRotateAngle() : reduceRotateAngle());
      } else if (event['FunName'] == 'rotateAngle90') {
        final isAdd = event['args']['isAdd'] as bool?;
        isAdd?.go((it) => it ? addRotateAngle90() : reduceRotateAngle90());
      } else if (event['FunName'] == 'scaleRatio') {
        final isAdd = event['args']['isAdd'] as bool?;
        isAdd?.go((it) => it ? addScaleRatio() : reduceScaleRatio());
      } else if (event['FunName'] == 'upsideDown') {
        _upsideDown();
      } else if (event['FunName'] == 'turnAround') {
        _turnAround();
      } else if (event['FunName'] == 'tailor') {
        _tailor();
      } else if (event['FunName'] == 'restore') {
        _restore();
      }
    });

    ImageUtils.byte2UiImage(widget.imageData).then((value) {
      setState(() {
        prop._targetUIImage = value;
        _moveX.value = centrePoint.dx;
        _moveY.value = centrePoint.dy;

        _uiAdaptWinWithImage();
        _updateBaseMap();
        _uiAdaptWinWithSelectBox();
        _uiLimitImageMoveInScope();
      });
    });

    _updateSelectBox(const Rect.fromLTWH(0, 0, 100, 100));

    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      _winSize ??= _handleKey.currentContext?.size
          ?.also((it) => ui.Size(it.width, it.height));
    });
  }

  @override
  void dispose() {
    super.dispose();
    _animationController?.dispose();
    _animationController_moveOffset?.dispose();
    _animationController_propScale?.dispose();
    _animationController_propRotate?.dispose();
    _animationController_selectBox?.dispose();
    _editorController._dispose();
  }

  //================ 操作功能 begin ================

  //--------------- 目标图x,y轴旋转 -----
  void addRotateXAngle() {
    prop.rotateX += 2;
    if (prop.rotateX > 30) {
      prop.rotateX = 30;
    }
    _uiRecoverImageInScope();
    setState(() {
      print('prop.rotateX:${prop.rotateX}');
    });
  }

  void reduceRotateXAngle() {
    prop.rotateX -= 2;
    if (prop.rotateX < -30) {
      prop.rotateX = -30;
    }
    _uiRecoverImageInScope();
    setState(() {
      print('prop.rotateX:${prop.rotateX}');
    });
  }

  void addRotateYAngle() {
    prop.rotateY += 2;
    if (prop.rotateY > 30) {
      prop.rotateY = 30;
    }
    _uiRecoverImageInScope();
    setState(() {
      print('prop.rotateY:${prop.rotateY}');
    });
  }

  void reduceRotateYAngle() {
    prop.rotateY -= 2;
    if (prop.rotateY < -30) {
      prop.rotateY = -30;
    }
    _uiRecoverImageInScope();
    setState(() {
      print('prop.rotateY:${prop.rotateY}');
    });
  }

  //--------------- 目标图旋转 -----
  ///旋转后,得到限制区域的left边线
  double rotateLimitLeftLine = 0;

  ///旋转后，得到限制区域的top边线
  double rotateLimitTopLine = 0;

  ///旋转后，得到限制区域的right边线
  double rotateLimitRightLine = 0;

  ///旋转后，得到限制区域的bottom边线
  double rotateLimitBottomLine = 0;

  ///旋转角度增加
  void addRotateAngle() {
    prop.rotateAngel = prop._rotateAngel.value + 2.5;
    setState(_marginalDetection);
  }

  ///旋转角度减少
  void reduceRotateAngle() {
    prop.rotateAngel = prop._rotateAngel.value - 2.5;
    setState(_marginalDetection);
  }

  //--------------- 目标图缩放 -----

  ///缩放比例增加
  void addScaleRatio() {
    prop.scaleRatio += 0.1;
    setState(_marginalDetection);
  }

  ///缩放比例减少
  void reduceScaleRatio() {
    prop.scaleRatio -= 0.1;
    setState(_marginalDetection);
  }

  //--------------- 目标图上下翻转左右翻转 -----
  ///上下翻转
  void _upsideDown() {
    prop.isUpsideDown = !prop.isUpsideDown;
    setState(_marginalDetection);
  }

  //左右翻转
  void _turnAround() {
    prop.isTurnAround = !prop.isTurnAround;
    setState(_marginalDetection);
  }

  //--------------- 外部旋转固定90角度 -----

  ///旋转角度增加固定90度单位
  void addRotateAngle90() {
    _uiCoordinateTransformationWith90Degree(isLeftRotate: true);
    final beforeRotate = prop.fixedRotationAngle;
    prop.fixedRotationAngle += 90;
    final afterRotate = beforeRotate + 90;
    _uiRecoverImageInScope();
    setState(() {});
    // _uiPlayRotateAnimation(
    //     before: beforeRotate.toDouble(), after: afterRotate.toDouble());
  }

  ///旋转角度减少固定90度单位
  void reduceRotateAngle90() {
    _uiCoordinateTransformationWith90Degree(isLeftRotate: false);
    prop.fixedRotationAngle -= 90;
    _uiRecoverImageInScope();
    setState(() {});
  }

  ///边际检测
  void _marginalDetection() {
    //旋转后 更新底图
    _updateBaseMap();
    //检测是否超出取景有效范围
    _uiLimitImageMoveInScope();
    //如果图形发生旋转，则限制取景框在旋转的图形内
    final changeNum = _uiRealTimeLimitImageMoveInScope();
    //检测发生旋转时是否超出图片有效范围
    //大于1个以上的顶角需要挪动时，一般就是位置不够，需要改变scale
    if (changeNum > 1) {
      _uiLimitSelectBoxInSubstituteScopeWhenRotate();
    }

    _uiRecoverImageInScope();
  }

  ///裁剪
  void _tailor() {
    print('裁剪');
    _toShowScreenShotDialog(tailorRect: _resultRect_selectBox);
  }

  ///还原
  void _restore() {
    prop._scaleRatio.value = prop._scaleRatio.min;
    prop._rotateAngel.value = 0;
    prop._fixedRotationAngle = 0;
    prop._rotateX = 0;
    prop._rotateY = 0;

    prop.isTurnAround = false;
    prop.isUpsideDown = false;

    ImageUtils.byte2UiImage(widget.imageData).then((value) {
      setState(() {
        prop._targetUIImage = value;
        _moveX.value = centrePoint.dx;
        _moveY.value = centrePoint.dy;
        _uiAdaptWinWithImage();
        _updateBaseMap();
        _uiAdaptWinWithSelectBox();
        _uiLimitImageMoveInScope();
      });
    });

    _updateSelectBox(const Rect.fromLTWH(0, 0, 100, 100));
  }

  //================ 操作功能 end ================

  ///创建图片圈中图后自动适配屏幕放大对应的图片区域的定时任务
  void _createSamplingTask() {
    //取景框至少长或者宽其中一个贴边，否则触发采样放大任务
    _timedTask_Adaptive?.close();
    // ignore: unnecessary_lambdas
    _timedTask_Adaptive = TimedTask(const Duration(milliseconds: 1000), () {
      //检测限制
      _uiRecoverImageInScope();
      //如果超过max，就不做取景框变动了
      if (prop.scaleRatio >= prop._scaleRatio.max) return;
      _amplificationSampling(moveListener: (status) {
        if (status == AnimationStatus.completed) {
          if (prop.rotateAngel != 0) {
            _uiRecoverImageInScope(duration: const Duration(milliseconds: 200));
          }
        }
      });
    })
      ..start();
  }

  ///关闭任务
  void _closeSamplingTask() {
    _timedTask_Adaptive?.close();
  }

  ///获取当前取景框在底图上对应的位置rect(以底图为基准的坐标)
  Rect get clippingRegionRectInBaseMap {
    //获取当前底图rect
    final bm_rect = baseMap_rect;
    //获取当前取景框位置
    final box_rect = _resultRect_selectBox;
    final clippingRegion_rect = Rect.fromLTWH(box_rect.left - bm_rect.left,
        box_rect.top - bm_rect.top, box_rect.width, box_rect.height);
    return clippingRegion_rect;
  }

  ///取景框自动适配屏幕放大对应的图片区域
  void _amplificationSampling(
      {void Function(AnimationStatus)? selectBoxListener,
      void Function(AnimationStatus)? scaleListener,
      void Function(AnimationStatus)? moveListener}) {
    final result = _calculateAmplificationSampling(
      moveOffset: ui.Offset(_moveX.value, _moveY.value),
      prop: prop,
      bm_rect: baseMap_rect,
      box_rect: _resultRect_selectBox,
      centrePoint: centrePoint,
      operation_winSize: operationWinRect?.size ?? Size.zero,
      clippingRegionRectInBaseMap: clippingRegionRectInBaseMap,
    );

    const duration = Duration(milliseconds: 200);

    //刷新取景框
    result.boxNewRect?.go((rect) {
      // _updateSelectBox(rect);
      _uiPlaySelectBoxAnimation(
          duration: duration,
          offsetBefore: _resultRect_selectBox.topLeft,
          offsetAfter: rect.topLeft,
          sizeBefore: _resultRect_selectBox.size,
          sizeAfter: rect.size,
          listener: (status) {
            if (status == AnimationStatus.completed) {
              _updateSelectBox(rect);
            }
            selectBoxListener?.call(status);
          });
    });

    //更新prop scale
    result.newPropScaleRatio?.go((scale) {
      // prop._scaleRatio.value = scale;
      _uiPlayScaleAnimation(
          duration: duration,
          before: prop.scaleRatio,
          after: scale,
          listener: (status) {
            if (status == AnimationStatus.completed) {
              prop._scaleRatio.value = scale;
            }
            scaleListener?.call(status);
          });
    });

    //更新移动坐标
    result.needMoveOffset?.go((offset) {
      final after_moveX = _moveX.value + offset.dx;
      final after_moveY = _moveY.value + offset.dy;
      // _moveX.value += offset.dx;
      // _moveY.value += offset.dy;
      _uiPlayMoveAnimation(
          duration: duration,
          before: ui.Offset(_moveX.value, _moveY.value),
          after: ui.Offset(after_moveX, after_moveY),
          listener: (status) {
            if (status == AnimationStatus.completed) {
              _moveX.value = after_moveX;
              _moveY.value = after_moveY;
            }
            moveListener?.call(status);
          });
    });

    // print(
    //       '_initRect_selectBox:$_initRect_selectBox  _limitRect_selectBox:$_limitRect_selectBox  _resultRect_selectBox:$_resultRect_selectBox');

    // print(
    //     'posX_baseMap:${posX_baseMap.toString()}  posY_baseMap:${posY_baseMap.toString()}');
    // print(
    //     'posX_baseMap:${posX_baseMap.toString()}  posY_baseMap:${posY_baseMap.toString()}');

    // _updateBaseMap();
    // print(
    //     '判断刷新后的底图是否跟之前计算的一样  baseMapRect:${baseMapRect.toString()}  baseMap_new_rect:${baseMap_new_rect.toString()}');
    // setState(() {});
  }

  //更新取景框
  void _updateSelectBox(Rect rect) {
    _initRect_selectBox = rect.copy();
    _limitRect_selectBox = rect.copy();
    operationWinRect?.go((it) {
      _limitRect_selectBox = it;
    });
    _resultRect_selectBox = rect.copy();
    _selectBoxKey = UniqueKey();
  }

  //更新底图
  void _updateBaseMap() {
    final result = _calculateUpdateBaseMap(
        // substituteSize: prop.substituteSize,
        // scaleRatio: prop.scaleRatio,
        // rotateAngel: prop.rotateAngel,
        prop: prop);
    result.baseMapSize?.go((it) {
      prop.baseMapSize = it;
    });
    result.baseMapRectTopDiff?.go((it) {
      prop.baseMapRectTopDiff = it;
    });
    result.baseMapRectLeftDiff?.go((it) {
      prop.baseMapRectLeftDiff = it;
    });
  }

  ///刷新让图片适配屏幕
  void _uiAdaptWinWithImage() {
    prop._targetUIImage?.go((it) {
      if (it.height <= 0 || it.width <= 0 || operationWinRect == null) {
        return;
      }
      final scaleW = it.width / operationWinRect!.width;
      final scaleH = it.height / operationWinRect!.height;
      final resScale = math.max(scaleW, scaleH);

      prop._substituteSize =
          Size(it.width * (1 / resScale), it.height * (1 / resScale));
    });
  }

  ///刷新让取景框恢复贴边
  void _uiAdaptWinWithSelectBox() {
    if (operationWinRect != null) {
      final rect = Rect.fromLTWH(
          10,
          _moveY.value -
              prop.baseMapSize.height * prop._scaleRatio.min / 2 +
              10,
          operationWinRect!.width,
          prop.baseMapSize.height * prop._scaleRatio.min);
      _updateSelectBox(rect);
    }
  }

  ///图片发生90度旋转计算坐标轮换
  void _uiCoordinateTransformationWith90Degree({required bool isLeftRotate}) {
    final result = _calculateCoordinateTransformationWith90Degree(
        isLeftRotate: isLeftRotate,
        bm_rect: baseMap_rect,
        box_rect: _resultRect_selectBox,
        operationWinRect: operationWinRect,
        prop: prop);
    //更新取景框rect
    // ignore: unnecessary_lambdas
    result.selectBoxRect?.go((rect) {
      _updateSelectBox(rect);
      // _uiPlaySelectBoxAnimation(
      //     // duration: duration,
      //     offsetBefore: _resultRect_selectBox.topLeft,
      //     offsetAfter: rect.topLeft,
      //     sizeBefore: _resultRect_selectBox.size,
      //     sizeAfter: rect.size,
      //     listener: (status) {
      //       if (status == AnimationStatus.completed) {
      //         _updateSelectBox(rect);
      //       }
      //       // selectBoxListener?.call(status);
      //     });
    });
    //更新替身图，底图的scale
    result.minScaleSize?.go((minScale) {
      prop.scaleRatio *= minScale;
      _updateBaseMap();
    });

    //保存一下处理前的数据，留着以后做动画
    // final before_moveX = _moveX.value;
    // final before_moveY = _moveY.value;

    //更新moveX,moveY位置以备旋转后依然对齐取景框方向角度
    result.movePos?.go((it) {
      _moveX.value = it.dx;
      _moveY.value = it.dy;
    });

    //处理后的值
    // final after_moveX = _moveX.value;
    // final after_moveY = _moveY.value;

    // _uiPlayMoveAnimation(
    //     before: ui.Offset(before_moveX, before_moveY),
    //     after: ui.Offset(after_moveX, after_moveY),
    //     // duration: duration,
    //     listener: (status) {
    //       if (status == AnimationStatus.completed) {
    //         _moveX.value = after_moveX;
    //         _moveY.value = after_moveY;
    //       }
    //       // moveListener?.call(status);
    //     });
  }

  ///恢复图片包裹取景框
  void _uiRecoverImageInScope(
      {DataScaleDetailsGroup? dataGroup,
      Duration? duration = const Duration(milliseconds: 500),
      void Function(AnimationStatus)? moveListener}) {
    //保存一下处理前的数据，留着以后做动画
    final before_moveX = _moveX.value;
    final before_moveY = _moveY.value;

    //计算拖尾动画效果
    if (dataGroup?.scaleEndDetails != null) {
      dataGroup?.go((group) {
        if (group.scaleUpdateDetails != null) {
          final next_point = group.scaleUpdateDetails!.localFocalPoint;
          final pre_point = group.scaleUpdatePoint_last!;
          final moveLen = MathUtils.distanceTo(pre_point, next_point);
          print('moveLen:$moveLen');

          //计算方向
          int funDirectV(double pre, double next) {
            if (next > pre) {
              return 1;
            } else if (next < pre) {
              return -1;
            }
            return 0;
          }

          final symbol_x = funDirectV(pre_point.dx, next_point.dx);
          final symbol_y = funDirectV(pre_point.dy, next_point.dy);

          _moveX.value +=
              symbol_x * math.max((next_point.dx - pre_point.dx).abs(), 1);
          _moveY.value +=
              symbol_y * math.max((next_point.dy - pre_point.dy).abs(), 1);
        }
      });
    }

    final result = _calculateRecoverImageInScope(
        moveOffset: ui.Offset(_moveX.value, _moveY.value),
        bm_rect: baseMap_rect,
        box_rect: _resultRect_selectBox,
        prop: prop);

    result.scale?.go((scale) {
      prop.scaleRatio = scale;
      _updateBaseMap();
    });

    result.movePos?.go((it) {
      _moveX.value = it.dx.also((it) {
        if (it.isNaN) return centrePoint.dx;
        return it;
      });
      _moveY.value = it.dy.also((it) {
        if (it.isNaN) return centrePoint.dy;
        return it;
      });
    });

    //处理后的值
    final after_moveX = _moveX.value;
    final after_moveY = _moveY.value;

    _uiPlayMoveAnimation(
        before: ui.Offset(before_moveX, before_moveY),
        after: ui.Offset(after_moveX, after_moveY),
        duration: duration,
        listener: (status) {
          if (status == AnimationStatus.completed) {
            _moveX.value = after_moveX;
            _moveY.value = after_moveY;
          }
          moveListener?.call(status);
        });
  }

  ///限制图片移动超出取景框范围有效区域 检测
  void _uiLimitImageMoveInScope() {
    ///限制图片移动超出取景框范围有效区域

    //获取当前底图rect
    final bm_rect = baseMap_rect;

    if (prop.rotateAngel == 0) {
      //======== 考虑的是矩形情况 ==========
      //拿取景框判断，left, top , right, bottom
      _resultRect_selectBox.go((boxRect) {
        final bmWidth = prop.baseMapSize.width; //底图宽度
        final bmHeight = prop.baseMapSize.height; //底图高度

        //left
        if (bm_rect.left > boxRect.left) {
          _moveX.value = boxRect.left + bmWidth / 2;
        }
        //top
        if (bm_rect.top > boxRect.top) {
          _moveY.value = boxRect.top + bmHeight / 2;
        }
        //right
        final bmRight = bm_rect.left + bmWidth; //替身的右边坐标
        if (bmRight < boxRect.right) {
          _moveX.value = boxRect.right - bmWidth / 2;
        }
        //bottom
        final bmbBottom = bm_rect.top + bmHeight; //替身的底部坐标
        if (bmbBottom < boxRect.bottom) {
          _moveY.value = boxRect.bottom - bmHeight / 2;
        }
      });
    }
  }

  ///限制图片移动超出取景框范围有效区域 实时检测
  int _uiRealTimeLimitImageMoveInScope() {
    var changeNum = 0;

    final curRotateAngel = prop.rotateAngel.also((angel) {
      print(
          '左右切换:${prop.isTurnAround}  上下切换:${prop.isUpsideDown}  旋转:${prop.fixedRotationAngle}');
      var ret = prop.fixedRotationAngle.also((it) {
        if ([90, -90].contains(it)) {
          return it.abs();
        }
        return 0;
      });

      if (prop.isTurnAround) {
        //左右切换
        if (ret == 90) {
          ret -= 180;
        } else if (ret == -90) {
          ret += 180;
        }
      }
      if (prop.isUpsideDown) {
        //上下切换
        if (ret == 90) {
          ret -= 180;
        } else if (ret == -90) {
          ret += 180;
        }
      }
      return angel + ret;
    });

    //获取当前底图rect
    final bm_rect = baseMap_rect;

    if (curRotateAngel != 0) {
      //========== 考虑发生角度旋转后的情况 ===========
      /*
        主要看取景框四个点(左上，右上，右下，左下)都只能在目标图对应的四条边内
      */
      // print('curRotateAngel: $curRotateAngel 度 ');

      ///取景器当前框矩形值
      _resultRect_selectBox.go((boxRect) {
        // print(
        //     '画布中心点坐标:${centrePoint.toString()} 当前底图中心点坐标:${centralPoint_baseMap.toString()} ');
        final box_left_top = Offset(boxRect.left, boxRect.top);
        final box_right_top = Offset(boxRect.right, boxRect.top);
        final box_right_bottom = Offset(boxRect.right, boxRect.bottom);
        final box_left_bottom = Offset(boxRect.left, boxRect.bottom);
        // print(
        //     '取景器4个角坐标 左上:${box_left_top.toString()} 右上:${box_right_top.toString()} 右下:${box_right_bottom.toString()} 左下:${box_left_bottom.toString()}');
        // print('当前底图坐标:${Offset(posX_baseMap, posY_baseMap).toString()}');

        //求目标图四个顶点坐标
        //left, top 两个顶点间的线长(斜边长)，实际就是目标图width
        final hypotenuse = prop.substituteSize!.width * prop.scaleRatio; //受缩放影响
        //斜边和底图top边的夹角就是 curRotateAngel 旋转的角度
        //拿到旋转后做水平线的角度
        final angel = curRotateAngel.abs();
        //三角形模型中，计算另外top边和left边的长度
        //角度转弧度
        final radian = MathUtils.retrace(angel);
        //弧度拿到斜率
        final cosSlope = math.cos(radian);
        //底边比邻边得到斜率
        final topLength = cosSlope * hypotenuse;

        //拿到旋转后做水平线的对角角度
        // final remainAngel = 90 - curRotateAngel.abs();
        //三角形模型中，计算另外top边和left边的长度
        //角度转弧度
        // final remainRadian = MathUtils.retrace(remainAngel);
        //弧度拿到斜率
        final sinSlope = math.sin(radian);
        //底边比邻边得到斜率
        final leftLength = sinSlope * hypotenuse;

        // print('top边长度:$topLength  left边长度:$leftLength');

        // print(
        //     '目标图4个角坐标 左上:${sub_left_top.toString()} 右上:${sub_right_top.toString()} 右下:${sub_right_bottom.toString()} 左下:${sub_left_bottom.toString()}');

        //接下来判断取景器的顶点是否在目标图各自2个顶点间连线的边内
        if (curRotateAngel > 0) {
          //可以得到目标图的4个顶点坐标
          final sub_left_top = Offset(bm_rect.left, bm_rect.top + leftLength);
          final sub_right_top = Offset(bm_rect.left + topLength, bm_rect.top);
          final sub_right_bottom = Offset(bm_rect.left + prop.baseMapSize.width,
              bm_rect.top + (prop.baseMapSize.height - leftLength));
          final sub_left_bottom = Offset(
              bm_rect.left + (prop.baseMapSize.width - topLength),
              bm_rect.top + prop.baseMapSize.height);

          //curRotateAngel > 0 就是逆时针旋转，取景器topleft顶点对应目标图top边来做判断
          //判断左上角， 是否进入三角区范围才需要做判断
          if ((box_left_top.dx >= sub_left_top.dx &&
                  box_left_top.dx <= sub_right_top.dx) &&
              (box_left_top.dy >= sub_right_top.dy &&
                  box_left_top.dy <= sub_left_top.dy)) {
            final slope = MathUtils.calculateSlope(sub_left_top, sub_right_top);
            final slope2 =
                MathUtils.calculateSlope(box_left_top, sub_right_top);
            // print('斜率  长边:$slope 短边:$slope2 ');
            if (slope2 > slope) {
              // 这就超边了
              print('逆时针 斜率  长边:$slope 短边:$slope2  左上角超边了!');

              final standardSlope =
                  MathUtils.calculateSlopeNotAbs(sub_left_top, sub_right_top);
              final leftOffset = MathUtils.getReverseYBySlope(
                  standardSlope, sub_right_top, box_left_top.dx);
              final rightOffset = MathUtils.getReverseXBySlope(
                  standardSlope, sub_right_top, box_left_top.dy);
              print(
                  'leftOffset:${leftOffset.toString()}  rightOffset:${rightOffset.toString()}');

              //拿到左右2个相交点,然后可以计算以2个相交点和超框的取景器直角点为三角形的斜边为底的高
              //得到三角形斜边高
              final bevelledHigh = MathUtils.getTriangularHeight(
                  box_left_top, leftOffset, rightOffset);
              //然后计算得到需要移动的x，y距离
              final need_y =
                  MathUtils.angle2CosSlope(curRotateAngel) * bevelledHigh;
              final need_x =
                  MathUtils.angle2SinSlope(curRotateAngel) * bevelledHigh;
              print(
                  'bevelledHigh:${bevelledHigh.toString()} need_x:$need_x need_y:$need_y');
              _moveX.value -= need_x;
              _moveY.value -= need_y;
              changeNum++;
            }
          }

          //判断右上角， 是否进入三角区范围才需要做判断
          if ((box_right_top.dx >= sub_right_top.dx &&
                  box_right_top.dx <= sub_right_bottom.dx) &&
              (box_right_top.dy >= sub_right_top.dy &&
                  box_right_top.dy <= sub_right_bottom.dy)) {
            final slope =
                MathUtils.calculateSlope(sub_right_bottom, sub_right_top);
            final slope2 =
                MathUtils.calculateSlope(box_right_top, sub_right_top);
            // print('斜率  长边:$slope 短边:$slope2 ');
            if (slope2 > slope) {
              //这就超边了
              print('逆时针 斜率  长边:$slope 短边:$slope2  右上角超边了!');

              final standardSlope = MathUtils.calculateSlopeNotAbs(
                  sub_right_bottom, sub_right_top);
              final rightOffset = MathUtils.getReverseYBySlope(
                  standardSlope, sub_right_top, box_right_top.dx);
              final leftOffset = MathUtils.getReverseXBySlope(
                  standardSlope, sub_right_top, box_right_top.dy);
              print(
                  'leftOffset:${leftOffset.toString()}  rightOffset:${rightOffset.toString()}');

              //拿到左右2个相交点,然后可以计算以2个相交点和超框的取景器直角点为三角形的斜边为底的高
              //得到三角形斜边高
              final bevelledHigh = MathUtils.getTriangularHeight(
                  box_right_top, leftOffset, rightOffset);
              //然后计算得到需要移动的x，y距离
              final need_x =
                  MathUtils.angle2CosSlope(curRotateAngel) * bevelledHigh;
              final need_y =
                  MathUtils.angle2SinSlope(curRotateAngel) * bevelledHigh;
              print(
                  'bevelledHigh:${bevelledHigh.toString()} need_x:$need_x need_y:$need_y');
              _moveX.value += need_x;
              _moveY.value -= need_y;
              changeNum++;
            }
          }

          //判断右下角， 是否进入三角区范围才需要做判断
          if ((box_right_bottom.dx >= sub_left_bottom.dx &&
                  box_right_bottom.dx <= sub_right_bottom.dx) &&
              (box_right_bottom.dy >= sub_right_bottom.dy &&
                  box_right_bottom.dy <= sub_left_bottom.dy)) {
            final slope =
                MathUtils.calculateSlope(sub_right_bottom, sub_left_bottom);
            final slope2 =
                MathUtils.calculateSlope(box_right_bottom, sub_left_bottom);
            // print('斜率  长边:$slope 短边:$slope2 ');
            if (slope2 > slope) {
              //这就超边了
              print('逆时针 斜率  长边:$slope 短边:$slope2  右下角超边了!');

              final standardSlope = MathUtils.calculateSlopeNotAbs(
                  sub_right_bottom, sub_left_bottom);
              final rightOffset = MathUtils.getReverseYBySlope(
                  standardSlope, sub_left_bottom, box_right_bottom.dx);
              final leftOffset = MathUtils.getReverseXBySlope(
                  standardSlope, sub_left_bottom, box_right_bottom.dy);
              print(
                  'leftOffset:${leftOffset.toString()}  rightOffset:${rightOffset.toString()}');

              //拿到左右2个相交点,然后可以计算以2个相交点和超框的取景器直角点为三角形的斜边为底的高
              //得到三角形斜边高
              final bevelledHigh = MathUtils.getTriangularHeight(
                  box_right_bottom, leftOffset, rightOffset);
              //然后计算得到需要移动的x，y距离
              final need_y =
                  MathUtils.angle2CosSlope(curRotateAngel) * bevelledHigh;
              final need_x =
                  MathUtils.angle2SinSlope(curRotateAngel) * bevelledHigh;
              print(
                  'bevelledHigh:${bevelledHigh.toString()} need_x:$need_x need_y:$need_y');
              _moveX.value += need_x;
              _moveY.value += need_y;
              changeNum++;
            }
          }

          //判断左下角， 是否进入三角区范围才需要做判断
          if ((box_left_bottom.dx >= sub_left_top.dx &&
                  box_left_bottom.dx <= sub_left_bottom.dx) &&
              (box_left_bottom.dy >= sub_left_top.dy &&
                  box_left_bottom.dy <= sub_left_bottom.dy)) {
            final slope =
                MathUtils.calculateSlope(sub_left_top, sub_left_bottom);
            final slope2 =
                MathUtils.calculateSlope(box_left_bottom, sub_left_bottom);
            // print('斜率  长边:$slope 短边:$slope2 ');
            if (slope2 > slope) {
              //这就超边了
              print('逆时针 斜率  长边:$slope 短边:$slope2  左下角超边了!');

              final standardSlope =
                  MathUtils.calculateSlopeNotAbs(sub_left_top, sub_left_bottom);
              final leftOffset = MathUtils.getReverseYBySlope(
                  standardSlope, sub_left_bottom, box_left_bottom.dx);
              final rightOffset = MathUtils.getReverseXBySlope(
                  standardSlope, sub_left_bottom, box_left_bottom.dy);
              print(
                  'leftOffset:${leftOffset.toString()}  rightOffset:${rightOffset.toString()}');

              //拿到左右2个相交点,然后可以计算以2个相交点和超框的取景器直角点为三角形的斜边为底的高
              //得到三角形斜边高
              final bevelledHigh = MathUtils.getTriangularHeight(
                  box_left_bottom, leftOffset, rightOffset);
              //然后计算得到需要移动的x，y距离
              final need_x =
                  MathUtils.angle2CosSlope(curRotateAngel) * bevelledHigh;
              final need_y =
                  MathUtils.angle2SinSlope(curRotateAngel) * bevelledHigh;
              print(
                  'bevelledHigh:${bevelledHigh.toString()} need_x:$need_x need_y:$need_y');
              _moveX.value -= need_x;
              _moveY.value += need_y;
              changeNum++;
            }
          }
        } else if (curRotateAngel < 0) {
          //可以得到目标图的4个顶点坐标
          final topLength2 = prop.baseMapSize.width - topLength;
          final leftLength2 = leftLength;
          final sub_left_top = Offset(bm_rect.left + topLength2, bm_rect.top);
          final sub_right_top = Offset(
              bm_rect.left + prop.baseMapSize.width, bm_rect.top + leftLength2);
          final sub_right_bottom = Offset(
              bm_rect.left + (prop.baseMapSize.width - topLength2),
              bm_rect.top + prop.baseMapSize.height);
          final sub_left_bottom = Offset(bm_rect.left,
              bm_rect.top + (prop.baseMapSize.height - leftLength2));

          //curRotateAngel < 0 就是顺时针旋转，取景器topright顶点对应目标图top边来做判断
          //判断右上角， 是否进入三角区范围才需要做判断
          if ((box_right_top.dx >= sub_left_top.dx &&
                  box_right_top.dx <= sub_right_top.dx) &&
              (box_right_top.dy >= sub_left_top.dy &&
                  box_right_top.dy <= sub_right_top.dy)) {
            final slope = MathUtils.calculateSlope(sub_right_top, sub_left_top);
            final slope2 =
                MathUtils.calculateSlope(box_right_top, sub_left_top);
            // print('斜率  长边:$slope 短边:$slope2 ');
            if (slope2 > slope) {
              // 这就超边了
              print('顺时针 斜率  长边:$slope 短边:$slope2 右上角超边了!');

              final standardSlope =
                  MathUtils.calculateSlopeNotAbs(sub_right_top, sub_left_top);
              final rightOffset = MathUtils.getReverseYBySlope(
                  standardSlope, sub_left_top, box_right_top.dx);
              final leftOffset = MathUtils.getReverseXBySlope(
                  standardSlope, sub_left_top, box_right_top.dy);
              print(
                  'leftOffset:${leftOffset.toString()}  rightOffset:${rightOffset.toString()}');

              //拿到左右2个相交点,然后可以计算以2个相交点和超框的取景器直角点为三角形的斜边为底的高
              //得到三角形斜边高
              final bevelledHigh = MathUtils.getTriangularHeight(
                  box_right_top, leftOffset, rightOffset);
              //然后计算得到需要移动的x，y距离
              final need_y =
                  (MathUtils.angle2CosSlope(curRotateAngel) * bevelledHigh)
                      .abs();
              final need_x =
                  (MathUtils.angle2SinSlope(curRotateAngel) * bevelledHigh)
                      .abs();
              print(
                  'bevelledHigh:${bevelledHigh.toString()} need_x:$need_x need_y:$need_y');
              _moveX.value += need_x;
              _moveY.value -= need_y;
              changeNum++;
            }
          }

          //判断右下角， 是否进入三角区范围才需要做判断
          if ((box_right_bottom.dx >= sub_right_bottom.dx &&
                  box_right_bottom.dx <= sub_right_top.dx) &&
              (box_right_bottom.dy >= sub_right_top.dy &&
                  box_right_bottom.dy <= sub_right_bottom.dy)) {
            final slope =
                MathUtils.calculateSlope(sub_right_top, sub_right_bottom);
            final slope2 =
                MathUtils.calculateSlope(box_right_bottom, sub_right_bottom);
            // print('斜率  长边:$slope 短边:$slope2 ');
            if (slope2 > slope) {
              //这就超边了
              print('顺时针 斜率  长边:$slope 短边:$slope2  右下角超边了!');

              final standardSlope = MathUtils.calculateSlopeNotAbs(
                  sub_right_top, sub_right_bottom);
              final leftOffset = MathUtils.getReverseYBySlope(
                  standardSlope, sub_right_bottom, box_right_bottom.dx);
              final rightOffset = MathUtils.getReverseXBySlope(
                  standardSlope, sub_right_bottom, box_right_bottom.dy);
              print(
                  'leftOffset:${leftOffset.toString()}  rightOffset:${rightOffset.toString()}');

              //拿到左右2个相交点,然后可以计算以2个相交点和超框的取景器直角点为三角形的斜边为底的高
              //得到三角形斜边高
              final bevelledHigh = MathUtils.getTriangularHeight(
                  box_right_bottom, leftOffset, rightOffset);
              //然后计算得到需要移动的x，y距离
              final need_x =
                  (MathUtils.angle2CosSlope(curRotateAngel) * bevelledHigh)
                      .abs();
              final need_y =
                  (MathUtils.angle2SinSlope(curRotateAngel) * bevelledHigh)
                      .abs();
              print(
                  'bevelledHigh:${bevelledHigh.toString()} need_x:$need_x need_y:$need_y');
              _moveX.value += need_x;
              _moveY.value += need_y;
              changeNum++;
            }
          }

          //判断左下角， 是否进入三角区范围才需要做判断
          if ((box_left_bottom.dx >= sub_left_bottom.dx &&
                  box_left_bottom.dx <= sub_right_bottom.dx) &&
              (box_left_bottom.dy >= sub_left_bottom.dy &&
                  box_left_bottom.dy <= sub_right_bottom.dy)) {
            final slope =
                MathUtils.calculateSlope(sub_left_bottom, sub_right_bottom);
            final slope2 =
                MathUtils.calculateSlope(box_left_bottom, sub_right_bottom);
            // print('斜率  长边:$slope 短边:$slope2 ');
            if (slope2 > slope) {
              //这就超边了
              print('顺时针 斜率  长边:$slope 短边:$slope2  左下角超边了!');

              final standardSlope = MathUtils.calculateSlopeNotAbs(
                  sub_left_bottom, sub_right_bottom);
              final rightOffset = MathUtils.getReverseYBySlope(
                  standardSlope, sub_right_bottom, box_left_bottom.dx);
              final leftOffset = MathUtils.getReverseXBySlope(
                  standardSlope, sub_right_bottom, box_left_bottom.dy);
              print(
                  'leftOffset:${leftOffset.toString()}  rightOffset:${rightOffset.toString()}');

              //拿到左右2个相交点,然后可以计算以2个相交点和超框的取景器直角点为三角形的斜边为底的高
              //得到三角形斜边高
              final bevelledHigh = MathUtils.getTriangularHeight(
                  box_left_bottom, leftOffset, rightOffset);
              //然后计算得到需要移动的x，y距离
              final need_y =
                  (MathUtils.angle2CosSlope(curRotateAngel) * bevelledHigh)
                      .abs();
              final need_x =
                  (MathUtils.angle2SinSlope(curRotateAngel) * bevelledHigh)
                      .abs();
              print(
                  'bevelledHigh:${bevelledHigh.toString()} need_x:$need_x need_y:$need_y');
              _moveX.value -= need_x;
              _moveY.value += need_y;
              changeNum++;
            }
          }

          //判断左上角， 是否进入三角区范围才需要做判断
          if ((box_left_top.dx >= sub_left_bottom.dx &&
                  box_left_top.dx <= sub_left_top.dx) &&
              (box_left_top.dy >= sub_left_top.dy &&
                  box_left_top.dy <= sub_left_bottom.dy)) {
            final slope =
                MathUtils.calculateSlope(sub_left_bottom, sub_left_top);
            final slope2 = MathUtils.calculateSlope(box_left_top, sub_left_top);
            // print('斜率  长边:$slope 短边:$slope2 ');
            if (slope2 > slope) {
              //这就超边了
              print('顺时针 斜率  长边:$slope 短边:$slope2  左上角超边了!');

              final standardSlope =
                  MathUtils.calculateSlopeNotAbs(sub_left_bottom, sub_left_top);
              final leftOffset = MathUtils.getReverseYBySlope(
                  standardSlope, sub_left_top, box_left_top.dx);
              final rightOffset = MathUtils.getReverseXBySlope(
                  standardSlope, sub_left_top, box_left_top.dy);
              print(
                  'leftOffset:${leftOffset.toString()}  rightOffset:${rightOffset.toString()}');

              //拿到左右2个相交点,然后可以计算以2个相交点和超框的取景器直角点为三角形的斜边为底的高
              //得到三角形斜边高
              final bevelledHigh = MathUtils.getTriangularHeight(
                  box_left_top, leftOffset, rightOffset);
              //然后计算得到需要移动的x，y距离
              final need_x =
                  (MathUtils.angle2CosSlope(curRotateAngel) * bevelledHigh)
                      .abs();
              final need_y =
                  (MathUtils.angle2SinSlope(curRotateAngel) * bevelledHigh)
                      .abs();
              print(
                  'bevelledHigh:${bevelledHigh.toString()} need_x:$need_x need_y:$need_y');
              _moveX.value -= need_x;
              _moveY.value -= need_y;
              changeNum++;
            }
          }
        }
      });
    }
    return changeNum;
  }

  ///旋转图片时, 图片要进行scale去适配让取景框在图片内
  void _uiLimitSelectBoxInSubstituteScopeWhenRotate() {
    addScaleRatio();
  }

  ///移动图片时，限制取景框一直在底图内
  // void _uiLimitSelectBoxInBaseMapScope() {
  //   if (prop.rotateAngel != 0) {
  //     //限制一下moveX, moveY, 让底图一直包裹着取景框, (取景框是不动的，动得是底图)
  //     //top
  //     if (posY_baseMap >= _resultRect_selectBox.top) {
  //       _moveY.value = prop.baseMapSize.height / 2 +
  //           _resultRect_selectBox.top -
  //           0.1; //偏差一些，防止临界值干扰
  //     }
  //     //right
  //     if (posX_baseMap + prop.baseMapSize.width <=
  //         _resultRect_selectBox.right) {
  //       _moveX.value = _resultRect_selectBox.right -
  //           prop.baseMapSize.width / 2 +
  //           0.1; //偏差一些，防止临界值干扰
  //     }
  //     //bottom
  //     if (posY_baseMap + prop.baseMapSize.height <=
  //         _resultRect_selectBox.bottom) {
  //       _moveY.value = _resultRect_selectBox.bottom -
  //           prop.baseMapSize.height / 2 +
  //           0.1; //偏差一些，防止临界值干扰
  //     }
  //     //left
  //     if (posX_baseMap >= _resultRect_selectBox.left) {
  //       _moveX.value = prop.baseMapSize.width / 2 +
  //           _resultRect_selectBox.left -
  //           0.1; //偏差一些，防止临界值干扰
  //     }
  //   } else {
  //     //top
  //     if (posY_baseMap >= _resultRect_selectBox.top) {
  //       _moveY.value = prop.baseMapSize.height / 2 + _resultRect_selectBox.top;
  //     }
  //     //right
  //     if (posX_baseMap + prop.baseMapSize.width <=
  //         _resultRect_selectBox.right) {
  //       _moveX.value = _resultRect_selectBox.right - prop.baseMapSize.width / 2;
  //     }
  //     //bottom
  //     if (posY_baseMap + prop.baseMapSize.height <=
  //         _resultRect_selectBox.bottom) {
  //       _moveY.value =
  //           _resultRect_selectBox.bottom - prop.baseMapSize.height / 2;
  //     }
  //     //left
  //     if (posX_baseMap >= _resultRect_selectBox.left) {
  //       _moveX.value = prop.baseMapSize.width / 2 + _resultRect_selectBox.left;
  //     }
  //   }
  // }

  ///结束图片替身移动
  void _uiEndSubstituteMvoe({DataScaleDetailsGroup? dataGroup}) {
    isDragingSubstitute = false;

    // _uiLimitImageMoveInScope();

    prop.scaleRatio = prop._scaleRatio.value * (prop.scaleRatioCache ?? 1);
    prop.scaleRatioCache = null;

    _updateBaseMap(); //更新底图
    _uiRecoverImageInScope(dataGroup: dataGroup); //检测限制

    //完成移动覆盖缓存
    _moveX.coverCache();
    _moveY.coverCache();
    setState(() {});
  }

  //===============  动画 begin ==============

  ///播放位移动画
  void _uiPlayMoveAnimation(
      {required Offset before,
      required Offset after,
      AnimationController? controller,
      Duration? duration = const Duration(milliseconds: 500),
      void Function(AnimationStatus)? listener}) {
    _animationController_moveOffset?.stop();
    if (controller == null) {
      _animationController_moveOffset =
          AnimationController(vsync: this, duration: duration);
    }

    _animation_moveOffset = Tween<ui.Offset>(begin: before, end: after)
        .chain(CurveTween(curve: Curves.easeOut))
        .animate(controller ?? _animationController_moveOffset!);

    _animation_moveOffset!.addListener(() {
      setState(() {
        _moveX.value = _animation_moveOffset!.value.dx;
        _moveY.value = _animation_moveOffset!.value.dy;
      });
    });

    _animation_moveOffset!.addStatusListener((status) {
      // print('status:$status');
      listener?.call(status);
    });
    (controller ?? _animationController_moveOffset!).forward();
  }

  ///播放缩放动画
  void _uiPlayScaleAnimation(
      {required double before,
      required double after,
      AnimationController? controller,
      Duration duration = const Duration(milliseconds: 500),
      void Function(AnimationStatus)? listener}) {
    _animationController_propScale?.stop();
    if (controller == null) {
      _animationController_propScale =
          AnimationController(vsync: this, duration: duration);
    }

    _animation_propScale = Tween<double>(begin: before, end: after)
        .chain(CurveTween(curve: Curves.easeOut))
        .animate(controller ?? _animationController_propScale!);

    _animation_propScale!.addListener(() {
      setState(() {
        prop._scaleRatio.value = _animation_propScale!.value;
        _updateBaseMap();
      });
    });

    _animation_propScale!.addStatusListener((status) {
      // print('status:$status');
      listener?.call(status);
    });

    (controller ?? _animationController_propScale!).forward();
  }

  ///播放旋转动画
  void _uiPlayRotateAnimation(
      {required double before,
      required double after,
      AnimationController? controller,
      Duration duration = const Duration(milliseconds: 500),
      void Function(AnimationStatus)? listener}) {
    _animationController_propRotate?.stop();
    if (controller == null) {
      _animationController_propRotate =
          AnimationController(vsync: this, duration: duration);
    }

    _animation_propRotate = Tween<double>(begin: before, end: after)
        .chain(CurveTween(curve: Curves.easeOut))
        .animate(controller ?? _animationController_propRotate!);

    _animation_propRotate!.addListener(() {
      setState(() {});
    });

    _animation_propRotate!.addStatusListener((status) {
      // print('status:$status');
      listener?.call(status);
    });

    (controller ?? _animationController_propRotate!).forward();
  }

  ///播放取景框缩放移动动画
  void _uiPlaySelectBoxAnimation(
      {required Offset offsetBefore,
      required Offset offsetAfter,
      required Size sizeBefore,
      required Size sizeAfter,
      AnimationController? controller,
      Duration duration = const Duration(milliseconds: 500),
      void Function(AnimationStatus)? listener}) {
    _animationController_selectBox?.stop();
    if (controller == null) {
      _animationController_selectBox =
          AnimationController(vsync: this, duration: duration);
    }

    _animation_selectBox_offset =
        Tween<ui.Offset>(begin: offsetBefore, end: offsetAfter)
            .chain(CurveTween(curve: Curves.easeOut))
            .animate(controller ?? _animationController_selectBox!);

    _animation_selectBox_size =
        Tween<ui.Size>(begin: sizeBefore, end: sizeAfter)
            .chain(CurveTween(curve: Curves.easeOut))
            .animate(controller ?? _animationController_selectBox!);

    _animation_selectBox_size!.addListener(() {
      setState(() {
        final offset = _animation_selectBox_offset!.value;
        final size = _animation_selectBox_size!.value;
        final rect =
            Rect.fromLTWH(offset.dx, offset.dy, size.width, size.height);
        _updateSelectBox(rect);
      });
    });

    _animation_selectBox_size!.addStatusListener((status) {
      // print('status:$status');
      listener?.call(status);
    });

    (controller ?? _animationController_selectBox!).forward();
  }

  //===============  动画 end ==============

  @override
  Widget build(BuildContext context) {
    //获取当前底图rect
    final bm_rect = baseMap_rect;

    return Container(
      key: this._handleKey,
      width: double.maxFinite,
      height: double.maxFinite,
      color: Colors.grey.withOpacity(0.5),
      child: Container(
        color: Colors.transparent,
        width: double.maxFinite,
        height: double.maxFinite,
        child: RepaintBoundary(
          child: Stack(
            alignment: Alignment.center,
            children: [
              //
              //底图
              Transform.rotate(
                  angle: angel_1_degree * 0,
                  child: Container(
                    color: Colors.blue.withOpacity(0.0),
                    width: prop.baseMapSize.width, //控制宽度
                    height: prop.baseMapSize.height, //控制高度
                  )).positioned(
                left: bm_rect.left, // 控制left位置
                top: bm_rect.top, // 控制top位置
              ),

              //
              //目标图
              if (winSize != null && prop.substituteSize != null)
                // CustomPaint(painter: TestPatin(widget.image), size: winSize!)
                RepaintBoundary(
                  key: _repaintBoundaryKey,
                  child: Stack(alignment: Alignment.center, children: [
                    Container(
                        color: Colors
                            .transparent, // Colors.yellow.withOpacity(0.3),
                        child: Transform.rotate(
                          //控制90度旋转
                          angle: angel_1_degree *
                              prop.fixedRotationAngle.also((it) {
                                //这里特殊处理，如果存在动画，则取动画值
                                final isCompleted =
                                    _animationController_propRotate
                                            ?.isCompleted ??
                                        true;
                                final isDismissed =
                                    _animationController_propRotate
                                            ?.isDismissed ??
                                        true;
                                if (!isCompleted &&
                                    !isDismissed &&
                                    _animation_propRotate != null) {
                                  return _animation_propRotate!.value;
                                }
                                return it;
                              }),
                          child: Transform.rotate(
                              angle: angel_1_degree * prop.rotateAngel, //控制校正旋转
                              child: Transform.scale(
                                scaleX: prop.scaleRatio *
                                    (!prop.isTurnAround ? 1 : -1), //控制 X缩放+左右翻转
                                scaleY: prop.scaleRatio *
                                    (!prop.isUpsideDown ? 1 : -1), //控制 Y缩放+上下翻转
                                child: Transform.translate(
                                    offset: const ui.Offset(0, 0).also((it) {
                                      if (prop.hasXYRotate) {
                                        var ox = 0.0;
                                        var oy = 0.0;
                                        // rotate x --, y向下补充位移
                                        // rotate x ++, y向上补充位置
                                        // rotate y --, x向左补充位移
                                        // rotate y ++, x向右补充位移
                                        final rx = prop.rotateX.abs();
                                        final ry = prop.rotateY.abs();
                                        final ssSize =
                                            prop.substituteSize ?? Size.zero;
                                        prop.rotateX.go((it) {
                                          if (it > 0) {
                                            oy = rx /
                                                45 *
                                                ssSize.height /
                                                2 *
                                                -1;
                                          } else if (it < 0) {
                                            oy =
                                                rx / 45 * ssSize.height / 2 * 1;
                                          }
                                        });
                                        prop.rotateY.go((it) {
                                          if (it > 0) {
                                            ox = ry / 45 * ssSize.width / 2 * 1;
                                          } else if (it < 0) {
                                            ox =
                                                ry / 45 * ssSize.width / 2 * -1;
                                          }
                                        });
                                        return ui.Offset(ox, oy);
                                      }
                                      return it;
                                    }), //兼容xy轴旋转做位移补充
                                    // offset: const ui.Offset(0, 0),
                                    child: Transform(
                                      alignment: Alignment.center,
                                      transform: Matrix4.identity()
                                        ..setEntry(3, 2, 0.005)
                                        ..rotateX(angel_1_degree * prop.rotateX)
                                        ..rotateY(
                                            angel_1_degree * prop.rotateY),
                                      child: Container(
                                        color: Colors.pink.withOpacity(0.0),
                                        width:
                                            prop.substituteSize!.width, //控制宽度
                                        height:
                                            prop.substituteSize!.height, //控制高度
                                        child: _buildTargetImage(), //构图
                                      ),
                                    )),
                              )),
                        )).positioned(
                      left: posX_substitute, // 控制left位置
                      top: posY_substitute, // 控制top位置
                    )
                  ]),
                )
              else
                const SizedBox(),

              //
              //取景框
              _SelectBox(
                key: _selectBoxKey ?? ValueKey(_initRect_selectBox),
                // fixedRotationAngle: 0, //fixedRotationAngle,
                winSize: winSize,
                initRect: _initRect_selectBox,
                limitRect: _limitRect_selectBox,
                funResult: (resultRect) {
                  _resultRect_selectBox = resultRect;
                  print('返回${resultRect.toString()}');
                  _createSamplingTask(); //这行测试调用
                  // setState(() {
                  //   //暂时收到结果先还原默认框
                  //   _selectBoxKey = UniqueKey();
                  // });
                },
                funState: (isOperation) {
                  if (isOperation) {
                    _closeSamplingTask();
                  }
                },
                editorConfig: editorConfig,
              ),
            ],
          ),
        ),
      ),
    ).gestureScaleWithData(
        data: dataScaleDetailsGroup,
        onScaleStart: (p0, p1) {
          // print('start: ${p0.toString()}');
          _moveX.coverCache();
          _moveY.coverCache();
          prop.scaleRatioCache = 1;
        },
        onScaleUpdate: (p0, p1) {
          // print('update: ${p0.toString()}');
          isDragingSubstitute = true;

          setState(() {
            prop.scaleRatioCache = p0.scale;
            if (prop.scaleRatio < 0.8) {
              prop.scaleRatioCache = 0.8 / prop._scaleRatio.value;
            }

            p1.diff().go((it) {
              // print('移动 it?.dx:${it?.dx.toInt()} it?.dy:${it?.dy.toInt()}');
              var dx = it?.dx ?? 0;
              var dy = it?.dy ?? 0;
              //更新最新值
              _moveX.value = _moveX.cacheValue + dx;
              _moveY.value = _moveY.cacheValue + dy;

              //限制一下moveX, moveY, 让底图一直包裹着取景框, (取景框是不动的，动得是底图)
              // _uiLimitSelectBoxInBaseMapScope();

              //如果图形发生旋转，则限制取景框在旋转的图形内
              // _uiRealTimeLimitImageMoveInScope();
            });
          });
        },
        onScaleEnd: (p0, p1) {
          // print('end: ${p0.toString()}');
          _uiEndSubstituteMvoe(dataGroup: p1);
        });
  }

  ///目标图
  Image _buildTargetImage() {
    prop.targetImageWidget ??= Image.memory(
      widget.imageData.buffer.asUint8List(),
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        return Opacity(
          opacity: 1,
          child: child,
        );
      },
    );
    return prop.targetImageWidget!;
  }

  ///截图
  Future<Map?> _toScreenShot({required GlobalKey key}) async {
    final boundary =
        key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    if (boundary != null) {
      // final dpr = ui.window.devicePixelRatio; // 获取当前设备的像素比
      // final image = await boundary.toImage(pixelRatio: dpr);
      final image = await boundary.toImage();
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      return Future.value({'image': byteData, 'size': boundary.size});
    }

    return Future.value(null);
  }

  ///展示截图
  void _toShowScreenShotDialog({required Rect tailorRect}) {
    _toScreenShot(key: _repaintBoundaryKey).then((value) async {
      if (value != null) {
        final image = value['image'] as ByteData;
        final size = value['size'] as Size;

        final ui.Image img = await ImageUtils.byte2UiImage(image);
        final key = GlobalKey();
        showDialog(
            context: context,
            builder: (context) {
              return Stack(
                children: [
                  Container(
                    width: double.maxFinite,
                    height: double.maxFinite,
                    color: Colors.white,
                    alignment: Alignment.center,
                    child: RepaintBoundary(
                      key: key,
                      child: CustomPaint(
                          painter:
                              ResultPaint(image: img, tailorRect: tailorRect),
                          size: Size(tailorRect.width, tailorRect.height)),
                    ),
                  ).gestureDetector(
                    onTap: () async {
                      final map = await _toScreenShot(key: key);
                      Navigator.of(context).pop();
                    },
                  ),
                  Positioned(
                    bottom: 10,
                    child: Container(
                      width: winSize!.width,
                      alignment: Alignment.center,
                      child: Text(
                        '点击任意位置关闭',
                        style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey.withOpacity(0.8),
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                  )
                ],
              );
            });
      }
    });
  }

  //拿到截图数据切图
  // void _toCutTheFigure() {
  //   _toScreenShot(key: _repaintBoundaryKey).then((value) {
  //     if (value != null) {
  //       final image = value['image'] as ByteData;
  //       final size = value['size'] as Size;
  //       final srcImage = crop.Image.fromBytes(
  //           size.width.toInt(), size.height.toInt(), image.buffer.asInt8List());
  //       final retImage =
  //           crop.copyCrop(srcImage, 0, 100, size.width.toInt(), 200);
  //     }
  //   });
  // }
}
