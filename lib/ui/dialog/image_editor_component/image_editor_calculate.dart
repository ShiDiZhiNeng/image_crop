// ignore_for_file: non_constant_identifier_names, use_late_for_private_fields_and_variables

part of image_editor;

//计算部分
mixin ImageEditorCalculate {
  /// 计算 取景框自动适配屏幕放大对应的图片区域
  DataViewfinderZoomInResult _calculateAmplificationSampling({
    required Offset moveOffset,
    required Size operation_winSize,
    required Rect bm_rect,
    required Rect box_rect,
    required Offset centrePoint,
    required Rect clippingRegionRectInBaseMap,
    required ImageEditorProperty prop,
  }) {
    final result = DataViewfinderZoomInResult();
    //可操作winsize
    // final operation_winSize = operationWinRect?.size ?? Size.zero;

    //获取当前底图rect
    // final bm_rect = baseMap_rect;

    //获取当前取景框rect
    // final box_rect = _resultRect_selectBox;

    //获取当前图片位置
    // final substitute_rect = Rect.fromLTWH(posX_substitute, posY_substitute,
    //     substituteSize!.width, substituteSize!.height);

    //放大后取景框的新Rect计算(要一定间隙，方便用户触摸)
    final box_new_width_scale = operation_winSize.width / box_rect.width;
    final box_new_height_scale = operation_winSize.height / box_rect.height;
    //取最小能完成贴边的scale
    final box_new_size_scale =
        math.min(box_new_width_scale, box_new_height_scale);
    final box_new_width = box_new_size_scale * box_rect.width;
    final box_new_height = box_new_size_scale * box_rect.height;
    //取景器新rect
    final box_new_rect = Rect.fromLTWH(centrePoint.dx - box_new_width / 2,
        centrePoint.dy - box_new_height / 2, box_new_width, box_new_height);

    print(
        '取景器当前rect:${box_rect.toString()}  取景器新的rect:${box_new_rect.toString()}');
    //计算取景框圈中的图片跟随取景框适配屏幕后的moveX, moveY
    //计算裁剪图rect的offset在底图中的比例，先记录，在底图放大后，就可以反推回去具体位置
    var relative_position_ratioX =
        clippingRegionRectInBaseMap.left / bm_rect.width;
    var relative_position_ratioY =
        clippingRegionRectInBaseMap.top / bm_rect.height;

    relative_position_ratioX = (box_rect.left - bm_rect.left) / bm_rect.width;
    relative_position_ratioY = (box_rect.top - bm_rect.top) / bm_rect.height;
    //首先整个底图也要跟随取景框缩放
    final baseMap_new_width = bm_rect.width * box_new_size_scale;
    final baseMap_new_height = bm_rect.height * box_new_size_scale;
    final baseMap_new_rect = Rect.fromLTWH(
        moveOffset.dx - baseMap_new_width / 2, //posX_baseMap,
        moveOffset.dy - baseMap_new_height / 2, //posY_baseMap,
        baseMap_new_width,
        baseMap_new_height);
    //新底图下的新裁剪图rect
    final clippingRegion_new_rect = Rect.fromLTWH(
        baseMap_new_rect.left +
            baseMap_new_rect.width * relative_position_ratioX,
        baseMap_new_rect.top +
            baseMap_new_rect.height * relative_position_ratioY,
        clippingRegionRectInBaseMap.width * box_new_size_scale,
        clippingRegionRectInBaseMap.height * box_new_size_scale);
    //然后将新裁剪图移动贴合新取景框,实际就是计算需要挪动的x,y, 基准就是新剪裁的图的中心要对准取景框中心
    print('裁剪图新的rect:${clippingRegion_new_rect.toString()} ');
    //计算差值，用于挪动moveX, moveY, 中心点挪去中心点，终点减去始点
    final needMoveWidth = box_new_rect.left - clippingRegion_new_rect.left;
    final needMoveHeight = box_new_rect.top - clippingRegion_new_rect.top;
    print(
        '需要挪动的距离  needMoveWidth:$needMoveWidth  needMoveHeight:$needMoveHeight');
    //数据拿齐了，可以开始干活

    result.boxNewRect = box_new_rect;
    result.newPropScaleRatio = prop.scaleRatio * box_new_size_scale;
    result.needMoveOffset = Offset(needMoveWidth, needMoveHeight);

    return result;
  }

  ///图片发生90度旋转计算坐标轮换
  DataCoordinateTransformationWith90Result
      _calculateCoordinateTransformationWith90Degree({
    required bool isLeftRotate,
    required Rect bm_rect,
    required Rect box_rect,
    required Rect? operationWinRect,
    required ImageEditorProperty prop,
  }) {
    final result = DataCoordinateTransformationWith90Result();
    //获取当前底图rect
    // final bm_rect = baseMap_rect;

    box_rect.go((box) {
      final half_width = box.width / 2; //宽的一半
      final half_height = box.height / 2; //高的一半
      final center = box.center;
      final new_left = center.dx - half_height;
      final new_top = center.dy - half_width;
      var new_rect =
          Rect.fromLTWH(new_left, new_top, half_height * 2, half_width * 2);

      //保持长宽比旋转后，再计算取景框贴屏幕边计算
      operationWinRect?.go((it) {
        final scale_width = it.width / new_rect.width;
        final scale_height = it.height / new_rect.height;
        final min_scale_size = math.min(scale_width, scale_height);
        final new_center = new_rect.center;
        final new_width = new_rect.width * min_scale_size;
        final new_height = new_rect.height * min_scale_size;
        new_rect = Rect.fromLTWH(new_center.dx - new_width / 2,
            new_center.dy - new_height / 2, new_width, new_height);

        result.minScaleSize = min_scale_size;

        if (isLeftRotate) {
          //向左旋转
          //计算旋转前取景框中心点到底图right,和到底图top的距离
          final old_top_len = center.dy - bm_rect.top;
          final old_right_len =
              bm_rect.left + prop.baseMapSize.width - center.dx;
          //top 变 left
          final new_left_len = old_top_len * min_scale_size;
          //right 变 top
          final new_top_len = old_right_len * min_scale_size;
          //反推底图旋转后对应两条边的位置
          final new_baseMap_height = prop.baseMapSize.height * min_scale_size;
          final new_baseMap_width = prop.baseMapSize.width * min_scale_size;
          final new_posX_baseMap = new_center.dx - new_left_len;
          final new_posY_baseMap = new_center.dy - new_top_len;
          final new_moveX = new_posX_baseMap + new_baseMap_height / 2;
          final new_moveY = new_posY_baseMap + new_baseMap_width / 2;
          result.movePos = ui.Offset(new_moveX, new_moveY);
        } else {
          //向右旋转
          //计算旋转前取景框中心点到底图bottom,和到底图left的距离
          final old_bottom_len =
              bm_rect.top + prop.baseMapSize.height - center.dy;
          final old_left_len = center.dx - bm_rect.left;
          //bottom 变 left
          final new_left_len = old_bottom_len * min_scale_size;
          //left 变 top
          final new_top_len = old_left_len * min_scale_size;
          //反推底图旋转后对应两条边的位置
          final new_baseMap_height = prop.baseMapSize.height * min_scale_size;
          final new_baseMap_width = prop.baseMapSize.width * min_scale_size;
          final new_posX_baseMap = new_center.dx - new_left_len;
          final new_posY_baseMap = new_center.dy - new_top_len;
          final new_moveX = new_posX_baseMap + new_baseMap_height / 2;
          final new_moveY = new_posY_baseMap + new_baseMap_width / 2;
          result.movePos = ui.Offset(new_moveX, new_moveY);
        }

        //处理moveX,moveY,保持旋转后也要按照之前的比例对齐
        // final ratio_y = center.dx / _moveX.value;
        // final ratio_x = center.dy / _moveY.value;

        //拿到新的取景框x,y再换算回去
        // final new_center2 = new_rect.center;
        // final new_move_x = ratio_x * new_center2.dx + new_center2.dx;
        // final new_move_y = ratio_y * new_center2.dy + new_center2.dy;

        //处理moveX,moveY,保持旋转后也要按照之前的比例对齐, 拿任意一个角做参考标准
        // final box_left_top = box.topLeft; //旧的selectBox左上角坐标
        // final baseMap_left_top = ui.Size(posX_baseMap, posY_baseMap); //旧的底图左上角坐标

        // result.movePos = ui.Offset(new_move_x, new_move_y);
      });

      result.selectBoxRect = new_rect;
    });

    return result;
  }

//计算更新底图
  DataUpdateBaseMapResult _calculateUpdateBaseMap({
    Size? substituteSize,
    double? scaleRatio,
    double? rotateAngel,
    required ImageEditorProperty prop,
  }) {
    substituteSize ??= prop.substituteSize;
    scaleRatio ??= prop.scaleRatio;
    rotateAngel ??= prop.rotateAngel;

    final result = DataUpdateBaseMapResult();
    //拿到目标编辑状态图的size后可以设置其对应的底图
    substituteSize?.go((it) {
      //先计算比例
      it = Size(it.width * scaleRatio!, it.height * scaleRatio);

      final height2 = it.height / 2;
      final width2 = it.width / 2;

      if (height2 <= 0 || width2 <= 0) return;

      //计算斜边长
      final double hypotenuse = math.sqrt(height2.square() + width2.square());
      //传入对边比底边，通过atan2拿到弧度
      final radian = math.atan2(height2, width2); //拿到弧度
      //弧度再转角度
      final angle = MathUtils.trace(radian);
      //拿到旋转后做水平线的合角度
      final totalAngle = angle + rotateAngel!.abs();
      //合角度转合弧度
      final totalRadian = MathUtils.retrace(totalAngle);
      //合弧度拿到斜率
      final slope = math.sin(totalRadian);
      //对边比邻边等到斜率
      final vLines = slope * hypotenuse;

      //计算另一个角的溢出长度
      //传入对边比底边，通过atan2拿到弧度
      final radian2 = math.atan2(width2, height2); //拿到弧度
      //弧度再转角度
      final angle2 = MathUtils.trace(radian2);
      //拿到旋转后做水平线的剩余角度
      final remainAngle = 90 - (180 - angle2 - rotateAngel.abs());
      //剩余角度转剩余弧度
      final remainRadian = MathUtils.retrace(remainAngle);
      //剩余弧度拿到斜率
      final slope2 = math.cos(remainRadian);
      //邻边比斜边等到斜率
      final vLines2 = slope2 * hypotenuse;

      // print(
      //     'hypotenuse:${hypotenuse}  radian:${radian}  angle:${angle}  vLines:${vLines}  vLines2:${vLines2}');

      final newBaseMapHeight = vLines * 2;
      final newBaseMapWidth = vLines2 * 2;

      result.baseMapSize = Size(newBaseMapWidth, newBaseMapHeight);
      result.baseMapRectTopDiff = vLines - height2;
      result.baseMapRectLeftDiff = vLines2 - width2;
    });
    return result;
  }

  ///用户操作结束，计算让图片归位到包裹取景框的最近坐标
  DataLimitResult _calculateRecoverImageInScope({
    required Offset moveOffset,
    required Rect bm_rect,
    required Rect box_rect,
    required ImageEditorProperty prop,
  }) {
    final result = DataLimitResult();

    ///限制图片移动超出取景框范围有效区域
    var ssWidth = prop.substituteActualSize.width; //替身宽度
    var ssHeight = prop.substituteActualSize.height; //替身高度

    // var ssWidth = prop.substituteSize!.width; //替身宽度
    // var ssHeight = prop.substituteSize!.height; //替身高度

    //获取当前底图rect
    // final bm_rect = baseMap_rect;

    var bmWidth = bm_rect.width; //底图宽度
    var bmHeight = bm_rect.height; //底图高度

    if (prop.rotateAngel == 0 || prop.hasXYRotate) {
      //======== 考虑偏移角度为0的情况 ==========
      //拿取景框判断，left, top , right, bottom
      box_rect.go((boxRect) {
        // final bmWidth = prop.baseMapSize.width; //底图宽度
        // final bmHeight = prop.baseMapSize.height; //底图高度
        var new_move_x = moveOffset.dx;
        var new_move_y = moveOffset.dy;

        //------------------------------------
        //检测一下缩放会不会过度导致无法容纳取景框，需要满足最低放入取景框条件
        //替身图至少要大于，取景框的长或者宽
        var new_ssWidth_scale = 1.0;
        var new_ssHeight_scale = 1.0;
        if (bmWidth < boxRect.width) {
          new_ssWidth_scale = boxRect.width / bmWidth;
        }
        if (bmHeight < boxRect.height) {
          new_ssHeight_scale = boxRect.height / bmHeight;
        }

        var new_posX_baseMap = bm_rect.left;
        var new_posY_baseMap = bm_rect.top;

        if (new_ssWidth_scale > 1 || new_ssHeight_scale > 1) {
          final new_scale = max(new_ssWidth_scale, new_ssHeight_scale);
          result.scale = prop.scaleRatio * new_scale;
          //scale变动，需要更新
          bmWidth = prop.baseMapSize.width * new_scale;
          bmHeight = prop.baseMapSize.height * new_scale;
          // ssWidth = prop.substituteSize!.width * new_scale;
          // ssHeight = prop.substituteSize!.height * new_scale;

          new_posX_baseMap = moveOffset.dx - bmWidth / 2;
          new_posY_baseMap = moveOffset.dy - bmHeight / 2;
        }

        //left
        if (new_posX_baseMap > boxRect.left) {
          new_move_x = boxRect.left + bmWidth / 2;
        }
        //top
        if (new_posY_baseMap > boxRect.top) {
          new_move_y = boxRect.top + bmHeight / 2;
        }
        //right
        final bmRight = new_posX_baseMap + bmWidth; //替身的右边坐标
        if (bmRight < boxRect.right) {
          new_move_x = boxRect.right - bmWidth / 2;
        }
        //bottom
        final bmbBottom = new_posY_baseMap + bmHeight; //替身的底部坐标
        if (bmbBottom < boxRect.bottom) {
          new_move_y = boxRect.bottom - bmHeight / 2;
        }

        result.movePos = ui.Offset(new_move_x, new_move_y);
      });
    } else {
      //======== 考虑偏移角度不为0的情况 ==========
      box_rect.go((boxRect) {
        var fix_diff_left = 0.0;
        var fix_diff_top = 0.0;
        var fix_diff_right = 0.0;
        var fix_diff_bottom = 0.0;

        //计算替身4个角所对应的内斜边上的高
        if (prop.rotateAngel < 0) {
          //向右旋转

        } else if (prop.rotateAngel > 0) {
          //向左旋转

        }
        fix_diff_top = MathUtils.getTriangularHeight2(
            boxRect.width, prop.rotateAngel.abs());
        fix_diff_bottom = fix_diff_top;

        fix_diff_left = MathUtils.getTriangularHeight2(
            boxRect.height, prop.rotateAngel.abs());
        fix_diff_right = fix_diff_left;
        //取景框每边到底图对应边的距离至少都要大于上面计算的高度
        var diff_left = boxRect.left - bm_rect.left;
        var diff_top = boxRect.top - bm_rect.top;
        var diff_right = bm_rect.left + bmWidth - boxRect.right;
        var diff_bottom = bm_rect.top + bmHeight - boxRect.bottom;

        //------------------------------------
        //检测一下缩放会不会过度导致无法容纳取景框，需要满足最低放入取景框条件
        //替身图至少要大于，取景框的斜边根据旋转角度的补角用cosSlope值得到的另一条边长
        var new_ssWidth_scale = 1.0;
        var new_ssHeight_scale = 1.0;

        //计算取景器斜边长
        final boxRect_diagonalLine_len =
            math.sqrt(boxRect.width.square() + boxRect.height.square());
        //计算斜边与height的角度
        final angle_from_height =
            MathUtils.cosSlope2Angle(boxRect.height / boxRect_diagonalLine_len);
        //计算斜边与width的角度
        final angle_from_width =
            MathUtils.cosSlope2Angle(boxRect.width / boxRect_diagonalLine_len);

        //计算得到最小需要的替身图高度
        final min_ssHeight = boxRect_diagonalLine_len *
            MathUtils.angle2CosSlope(
                angle_from_height - prop.rotateAngel.abs());
        //计算得到最小需要的替身图宽度
        final min_ssWidth = boxRect_diagonalLine_len *
            MathUtils.angle2CosSlope(angle_from_width - prop.rotateAngel.abs());

        if (ssHeight < min_ssHeight) {
          new_ssHeight_scale = min_ssHeight / ssHeight;
        }
        if (ssWidth < min_ssWidth) {
          new_ssWidth_scale = min_ssWidth / ssWidth;
        }

        if (new_ssWidth_scale > 1 || new_ssHeight_scale > 1) {
          final new_scale = max(new_ssWidth_scale, new_ssHeight_scale);
          result.scale = prop.scaleRatio * new_scale;
          //scale变动，需要更新
          ssWidth = prop.substituteSize!.width * new_scale;
          ssHeight = prop.substituteSize!.height * new_scale;
          final bmCalculateResult = _calculateUpdateBaseMap(
              // substituteSize: Size(ssWidth, ssHeight),
              scaleRatio: result.scale,
              prop: prop);
          bmCalculateResult.baseMapSize?.go((it) {
            bmWidth = it.width;
            bmHeight = it.height;
          });
          // bmWidth = prop.baseMapSize.width * new_scale;
          // bmHeight = prop.baseMapSize.height * new_scale;
          final bmWidth222 = prop.baseMapSize.width * new_scale;
          final bmHeight222 = prop.baseMapSize.height * new_scale;

          diff_left = boxRect.left - (moveOffset.dx - bmWidth / 2);
          diff_top = boxRect.top - (moveOffset.dy - bmHeight / 2);
          diff_right = (moveOffset.dx - bmWidth / 2) + bmWidth - boxRect.right;
          diff_bottom =
              (moveOffset.dy - bmHeight / 2) + bmHeight - boxRect.bottom;
        }
        //------------------------------------

        var need_move_left = 0.0;
        var need_move_top = 0.0;
        if (diff_left < fix_diff_left) {
          need_move_left += fix_diff_left - diff_left;
        }
        if (diff_top < fix_diff_top) {
          need_move_top += fix_diff_top - diff_top;
        }
        if (diff_right < fix_diff_right) {
          need_move_left -= fix_diff_right - diff_right;
        }
        if (diff_bottom < fix_diff_bottom) {
          need_move_top -= fix_diff_bottom - diff_bottom;
        }

        //处理的是图片中心坐标，所以带负数(反向位移)
        var new_move_x = moveOffset.dx + (-need_move_left);
        var new_move_y = moveOffset.dy + (-need_move_top);

        //接下来处理取景框4个顶点超框问题
        var ssOffset_left = ui.Offset.zero;
        var ssOffset_top = ui.Offset.zero;
        var ssOffset_right = ui.Offset.zero;
        var ssOffset_bottom = ui.Offset.zero;

        final temp_baseMap_x = new_move_x - bmWidth / 2;
        final temp_baseMap_y = new_move_y - bmHeight / 2;

        final temp_sinSlope = MathUtils.angle2SinSlope(prop.rotateAngel.abs());
        final temp_cosSlope = MathUtils.angle2CosSlope(prop.rotateAngel.abs());

        if (prop.rotateAngel < 0) {
          //向右转情况
          ssOffset_left = ui.Offset(
              temp_baseMap_x, temp_baseMap_y + temp_cosSlope * ssHeight);

          ssOffset_top = ui.Offset(
              temp_baseMap_x + temp_sinSlope * ssHeight, temp_baseMap_y);

          ssOffset_right = ui.Offset(temp_baseMap_x + bmWidth,
              temp_baseMap_y + temp_sinSlope * ssWidth);

          ssOffset_bottom = ui.Offset(temp_baseMap_x + temp_cosSlope * ssWidth,
              temp_baseMap_y + bmHeight);
        } else if (prop.rotateAngel > 0) {
          //向左转情况
          ssOffset_left = ui.Offset(
              temp_baseMap_x, temp_baseMap_y + temp_sinSlope * ssWidth);

          ssOffset_top = ui.Offset(
              temp_baseMap_x + temp_cosSlope * ssWidth, temp_baseMap_y);

          ssOffset_right = ui.Offset(temp_baseMap_x + bmWidth,
              temp_baseMap_y + temp_cosSlope * ssHeight);

          ssOffset_bottom = ui.Offset(temp_baseMap_x + temp_sinSlope * ssHeight,
              temp_baseMap_y + bmHeight);
        }

        //根据任意点+2个顶点，计算出任意点垂直于2个顶点连线的最短距离
        double calculatedHeight(Offset pre, Offset next, Offset point) {
          //拿到2个顶点斜率
          final slope = MathUtils.calculateSlopeNotAbs(pre, next);
          //用斜率加固定的x或者y倒退x对应的y, y对应的x
          final crossingA =
              MathUtils.getReverseXBySlope(slope, next, point.dy); //相交点a
          final crossingB =
              MathUtils.getReverseYBySlope(slope, next, point.dx); //相交点b
          //然后根据直角三角形面积计算公式得到斜边上的高
          final height = MathUtils.distanceTo(crossingA, point) *
              MathUtils.distanceTo(crossingB, point) /
              MathUtils.distanceTo(crossingA, crossingB);
          return height;
        }

        if (MathUtils.insideOrOutsideOfLine2(
                ssOffset_left, ssOffset_top, boxRect.topLeft,
                inRight: true) ==
            -1) {
          //选择框左上角超了
          final height =
              calculatedHeight(ssOffset_left, ssOffset_top, boxRect.topLeft);
          print('选择框左上角超了:$height');
          //拿到高然后计算需要偏移的x,y
          final move_x_len =
              (prop.rotateAngel > 0 ? temp_sinSlope : temp_cosSlope) * height;
          final move_y_len =
              (prop.rotateAngel > 0 ? temp_cosSlope : temp_sinSlope) * height;
          new_move_x += -move_x_len;
          new_move_y += -move_y_len;
        } else if (MathUtils.insideOrOutsideOfLine2(
                ssOffset_top, ssOffset_right, boxRect.topRight,
                inRight: false) ==
            -1) {
          //选择框右上角超了
          final height =
              calculatedHeight(ssOffset_top, ssOffset_right, boxRect.topRight);
          print('选择框右上角超了:$height');
          //拿到高然后计算需要偏移的x,y
          final move_x_len =
              (prop.rotateAngel > 0 ? temp_cosSlope : temp_sinSlope) * height;
          final move_y_len =
              (prop.rotateAngel > 0 ? temp_sinSlope : temp_cosSlope) * height;
          new_move_x += move_x_len;
          new_move_y += -move_y_len;
        } else if (MathUtils.insideOrOutsideOfLine2(
                ssOffset_bottom, ssOffset_right, boxRect.bottomRight,
                inRight: false) ==
            -1) {
          //选择框右下角超了
          final height = calculatedHeight(
              ssOffset_right, ssOffset_bottom, boxRect.bottomRight);
          print('选择框右下角超了:$height');
          //拿到高然后计算需要偏移的x,y
          final move_x_len =
              (prop.rotateAngel > 0 ? temp_sinSlope : temp_cosSlope) * height;
          final move_y_len =
              (prop.rotateAngel > 0 ? temp_cosSlope : temp_sinSlope) * height;
          new_move_x += move_x_len;
          new_move_y += move_y_len;
        } else if (MathUtils.insideOrOutsideOfLine2(
                ssOffset_left, ssOffset_bottom, boxRect.bottomLeft,
                inRight: true) ==
            -1) {
          //选择框左下角超了
          final height = calculatedHeight(
              ssOffset_bottom, ssOffset_left, boxRect.bottomLeft);
          print('选择框左下角超了:$height');
          //拿到高然后计算需要偏移的x,y
          final move_x_len =
              (prop.rotateAngel > 0 ? temp_cosSlope : temp_sinSlope) * height;
          final move_y_len =
              (prop.rotateAngel > 0 ? temp_sinSlope : temp_cosSlope) * height;
          new_move_x += -move_x_len;
          new_move_y += move_y_len;
        }

        result.movePos = ui.Offset(new_move_x, new_move_y);
      });
    }
    return result;
  }
}











//================== 备份 ===================

/// 计算 取景框自动适配屏幕放大对应的图片区域
  // DataViewfinderZoomInResult _calculateAmplificationSampling() {
  //   final result = DataViewfinderZoomInResult();
  //   //可操作winsize
  //   final operation_winSize = operationWinRect?.size ?? Size.zero;

  //   //获取当前底图rect
  //   final bm_rect = baseMap_rect;

  //   //获取当前取景框位置
  //   final box_rect = _resultRect_selectBox;

  //   //获取当前图片位置
  //   // final substitute_rect = Rect.fromLTWH(posX_substitute, posY_substitute,
  //   //     substituteSize!.width, substituteSize!.height);

  //   //放大后取景框的新Rect计算(要一定间隙，方便用户触摸)
  //   final box_new_width_scale = operation_winSize.width / box_rect.width;
  //   final box_new_height_scale = operation_winSize.height / box_rect.height;
  //   //取最小能完成贴边的scale
  //   final box_new_size_scale =
  //       math.min(box_new_width_scale, box_new_height_scale);
  //   final box_new_width = box_new_size_scale * box_rect.width;
  //   final box_new_height = box_new_size_scale * box_rect.height;
  //   //取景器新rect
  //   final box_new_rect = Rect.fromLTWH(centrePoint.dx - box_new_width / 2,
  //       centrePoint.dy - box_new_height / 2, box_new_width, box_new_height);

  //   print(
  //       '取景器当前rect:${box_rect.toString()}  取景器新的rect:${box_new_rect.toString()}');
  //   //计算取景框圈中的图片跟随取景框适配屏幕后的moveX, moveY
  //   //计算裁剪图rect的offset在底图中的比例，先记录，在底图放大后，就可以反推回去具体位置
  //   var relative_position_ratioX =
  //       clippingRegionRectInBaseMap.left / bm_rect.width;
  //   var relative_position_ratioY =
  //       clippingRegionRectInBaseMap.top / bm_rect.height;

  //   relative_position_ratioX = (box_rect.left - bm_rect.left) / bm_rect.width;
  //   relative_position_ratioY = (box_rect.top - bm_rect.top) / bm_rect.height;
  //   //首先整个底图也要跟随取景框缩放
  //   final baseMap_new_width = bm_rect.width * box_new_size_scale;
  //   final baseMap_new_height = bm_rect.height * box_new_size_scale;
  //   final baseMap_new_rect = Rect.fromLTWH(
  //       _moveX.value - baseMap_new_width / 2, //posX_baseMap,
  //       _moveY.value - baseMap_new_height / 2, //posY_baseMap,
  //       baseMap_new_width,
  //       baseMap_new_height);
  //   //新底图下的新裁剪图rect
  //   final clippingRegion_new_rect = Rect.fromLTWH(
  //       baseMap_new_rect.left +
  //           baseMap_new_rect.width * relative_position_ratioX,
  //       baseMap_new_rect.top +
  //           baseMap_new_rect.height * relative_position_ratioY,
  //       clippingRegionRectInBaseMap.width * box_new_size_scale,
  //       clippingRegionRectInBaseMap.height * box_new_size_scale);
  //   //然后将新裁剪图移动贴合新取景框,实际就是计算需要挪动的x,y, 基准就是新剪裁的图的中心要对准取景框中心
  //   print('裁剪图新的rect:${clippingRegion_new_rect.toString()} ');
  //   //计算差值，用于挪动moveX, moveY, 中心点挪去中心点，终点减去始点
  //   final needMoveWidth = box_new_rect.left - clippingRegion_new_rect.left;
  //   final needMoveHeight = box_new_rect.top - clippingRegion_new_rect.top;
  //   print(
  //       '需要挪动的距离  needMoveWidth:$needMoveWidth  needMoveHeight:$needMoveHeight');
  //   //数据拿齐了，可以开始干活

  //   result.boxNewRect = box_new_rect;
  //   result.newPropScaleRatio = prop.scaleRatio * box_new_size_scale;
  //   result.needMoveOffset = Offset(needMoveWidth, needMoveHeight);

  //   return result;
  // }


  ///图片发生90度旋转计算坐标轮换
  // DataCoordinateTransformationWith90Result
  //     _calculateCoordinateTransformationWith90Degree(
  //         {required bool isLeftRotate}) {
  //   final result = DataCoordinateTransformationWith90Result();
  //   //获取当前底图rect
  //   final bm_rect = baseMap_rect;

  //   _resultRect_selectBox.go((box) {
  //     final half_width = box.width / 2; //宽的一半
  //     final half_height = box.height / 2; //高的一半
  //     final center = box.center;
  //     final new_left = center.dx - half_height;
  //     final new_top = center.dy - half_width;
  //     var new_rect =
  //         Rect.fromLTWH(new_left, new_top, half_height * 2, half_width * 2);

  //     //保持长宽比旋转后，再计算取景框贴屏幕边计算
  //     operationWinRect?.go((it) {
  //       final scale_width = it.width / new_rect.width;
  //       final scale_height = it.height / new_rect.height;
  //       final min_scale_size = math.min(scale_width, scale_height);
  //       final new_center = new_rect.center;
  //       final new_width = new_rect.width * min_scale_size;
  //       final new_height = new_rect.height * min_scale_size;
  //       new_rect = Rect.fromLTWH(new_center.dx - new_width / 2,
  //           new_center.dy - new_height / 2, new_width, new_height);

  //       result.minScaleSize = min_scale_size;

  //       if (isLeftRotate) {
  //         //向左旋转
  //         //计算旋转前取景框中心点到底图right,和到底图top的距离
  //         final old_top_len = center.dy - bm_rect.top;
  //         final old_right_len =
  //             bm_rect.left + prop.baseMapSize.width - center.dx;
  //         //top 变 left
  //         final new_left_len = old_top_len * min_scale_size;
  //         //right 变 top
  //         final new_top_len = old_right_len * min_scale_size;
  //         //反推底图旋转后对应两条边的位置
  //         final new_baseMap_height = prop.baseMapSize.height * min_scale_size;
  //         final new_baseMap_width = prop.baseMapSize.width * min_scale_size;
  //         final new_posX_baseMap = new_center.dx - new_left_len;
  //         final new_posY_baseMap = new_center.dy - new_top_len;
  //         final new_moveX = new_posX_baseMap + new_baseMap_height / 2;
  //         final new_moveY = new_posY_baseMap + new_baseMap_width / 2;
  //         result.movePos = ui.Offset(new_moveX, new_moveY);
  //       } else {
  //         //向右旋转
  //         //计算旋转前取景框中心点到底图bottom,和到底图left的距离
  //         final old_bottom_len =
  //             bm_rect.top + prop.baseMapSize.height - center.dy;
  //         final old_left_len = center.dx - bm_rect.left;
  //         //bottom 变 left
  //         final new_left_len = old_bottom_len * min_scale_size;
  //         //left 变 top
  //         final new_top_len = old_left_len * min_scale_size;
  //         //反推底图旋转后对应两条边的位置
  //         final new_baseMap_height = prop.baseMapSize.height * min_scale_size;
  //         final new_baseMap_width = prop.baseMapSize.width * min_scale_size;
  //         final new_posX_baseMap = new_center.dx - new_left_len;
  //         final new_posY_baseMap = new_center.dy - new_top_len;
  //         final new_moveX = new_posX_baseMap + new_baseMap_height / 2;
  //         final new_moveY = new_posY_baseMap + new_baseMap_width / 2;
  //         result.movePos = ui.Offset(new_moveX, new_moveY);
  //       }

  //       //处理moveX,moveY,保持旋转后也要按照之前的比例对齐
  //       // final ratio_y = center.dx / _moveX.value;
  //       // final ratio_x = center.dy / _moveY.value;

  //       //拿到新的取景框x,y再换算回去
  //       // final new_center2 = new_rect.center;
  //       // final new_move_x = ratio_x * new_center2.dx + new_center2.dx;
  //       // final new_move_y = ratio_y * new_center2.dy + new_center2.dy;

  //       //处理moveX,moveY,保持旋转后也要按照之前的比例对齐, 拿任意一个角做参考标准
  //       // final box_left_top = box.topLeft; //旧的selectBox左上角坐标
  //       // final baseMap_left_top = ui.Size(posX_baseMap, posY_baseMap); //旧的底图左上角坐标

  //       // result.movePos = ui.Offset(new_move_x, new_move_y);
  //     });

  //     result.selectBoxRect = new_rect;
  //   });

  //   return result;
  // }


  //计算更新底图
  // DataUpdateBaseMapResult _calculateUpdateBaseMap({
  //   Size? substituteSize,
  //   double? scaleRatio,
  //   double? rotateAngel,
  // }) {
  //   substituteSize ??= prop.substituteSize;
  //   scaleRatio ??= prop.scaleRatio;
  //   rotateAngel ??= prop.rotateAngel;

  //   final result = DataUpdateBaseMapResult();
  //   //拿到目标编辑状态图的size后可以设置其对应的底图
  //   substituteSize?.go((it) {
  //     //先计算比例
  //     it = Size(it.width * scaleRatio!, it.height * scaleRatio);

  //     final height2 = it.height / 2;
  //     final width2 = it.width / 2;

  //     if (height2 <= 0 || width2 <= 0) return;

  //     //计算斜边长
  //     final double hypotenuse = math.sqrt(height2.square() + width2.square());
  //     //传入对边比底边，通过atan2拿到弧度
  //     final radian = math.atan2(height2, width2); //拿到弧度
  //     //弧度再转角度
  //     final angle = MathUtils.trace(radian);
  //     //拿到旋转后做水平线的合角度
  //     final totalAngle = angle + rotateAngel!.abs();
  //     //合角度转合弧度
  //     final totalRadian = MathUtils.retrace(totalAngle);
  //     //合弧度拿到斜率
  //     final slope = math.sin(totalRadian);
  //     //对边比邻边等到斜率
  //     final vLines = slope * hypotenuse;

  //     //计算另一个角的溢出长度
  //     //传入对边比底边，通过atan2拿到弧度
  //     final radian2 = math.atan2(width2, height2); //拿到弧度
  //     //弧度再转角度
  //     final angle2 = MathUtils.trace(radian2);
  //     //拿到旋转后做水平线的剩余角度
  //     final remainAngle = 90 - (180 - angle2 - rotateAngel.abs());
  //     //剩余角度转剩余弧度
  //     final remainRadian = MathUtils.retrace(remainAngle);
  //     //剩余弧度拿到斜率
  //     final slope2 = math.cos(remainRadian);
  //     //邻边比斜边等到斜率
  //     final vLines2 = slope2 * hypotenuse;

  //     // print(
  //     //     'hypotenuse:${hypotenuse}  radian:${radian}  angle:${angle}  vLines:${vLines}  vLines2:${vLines2}');

  //     final newBaseMapHeight = vLines * 2;
  //     final newBaseMapWidth = vLines2 * 2;

  //     result.baseMapSize = Size(newBaseMapWidth, newBaseMapHeight);
  //     result.baseMapRectTopDiff = vLines - height2;
  //     result.baseMapRectLeftDiff = vLines2 - width2;
  //   });
  //   return result;
  // }

  ///用户操作结束，计算让图片归位到包裹取景框的最近坐标
  // DataLimitResult _calculateRecoverImageInScope() {
  //   final result = DataLimitResult();

  //   ///限制图片移动超出取景框范围有效区域
  //   var ssWidth = prop.substituteActualSize.width; //替身宽度
  //   var ssHeight = prop.substituteActualSize.height; //替身高度

  //   // var ssWidth = prop.substituteSize!.width; //替身宽度
  //   // var ssHeight = prop.substituteSize!.height; //替身高度

  //   //获取当前底图rect
  //   final bm_rect = baseMap_rect;

  //   var bmWidth = bm_rect.width; //底图宽度
  //   var bmHeight = bm_rect.height; //底图高度

  //   if (prop.rotateAngel == 0 || prop.hasXYRotate) {
  //     //======== 考虑偏移角度为0的情况 ==========
  //     //拿取景框判断，left, top , right, bottom
  //     _resultRect_selectBox.go((boxRect) {
  //       // final bmWidth = prop.baseMapSize.width; //底图宽度
  //       // final bmHeight = prop.baseMapSize.height; //底图高度
  //       var new_move_x = _moveX.value;
  //       var new_move_y = _moveY.value;

  //       //------------------------------------
  //       //检测一下缩放会不会过度导致无法容纳取景框，需要满足最低放入取景框条件
  //       //替身图至少要大于，取景框的长或者宽
  //       var new_ssWidth_scale = 1.0;
  //       var new_ssHeight_scale = 1.0;
  //       if (bmWidth < boxRect.width) {
  //         new_ssWidth_scale = boxRect.width / bmWidth;
  //       }
  //       if (bmHeight < boxRect.height) {
  //         new_ssHeight_scale = boxRect.height / bmHeight;
  //       }

  //       var new_posX_baseMap = bm_rect.left;
  //       var new_posY_baseMap = bm_rect.top;

  //       if (new_ssWidth_scale > 1 || new_ssHeight_scale > 1) {
  //         final new_scale = max(new_ssWidth_scale, new_ssHeight_scale);
  //         result.scale = prop.scaleRatio * new_scale;
  //         //scale变动，需要更新
  //         bmWidth = prop.baseMapSize.width * new_scale;
  //         bmHeight = prop.baseMapSize.height * new_scale;
  //         // ssWidth = prop.substituteSize!.width * new_scale;
  //         // ssHeight = prop.substituteSize!.height * new_scale;

  //         new_posX_baseMap = _moveX.value - bmWidth / 2;
  //         new_posY_baseMap = _moveY.value - bmHeight / 2;
  //       }

  //       //left
  //       if (new_posX_baseMap > boxRect.left) {
  //         new_move_x = boxRect.left + bmWidth / 2;
  //       }
  //       //top
  //       if (new_posY_baseMap > boxRect.top) {
  //         new_move_y = boxRect.top + bmHeight / 2;
  //       }
  //       //right
  //       final bmRight = new_posX_baseMap + bmWidth; //替身的右边坐标
  //       if (bmRight < boxRect.right) {
  //         new_move_x = boxRect.right - bmWidth / 2;
  //       }
  //       //bottom
  //       final bmbBottom = new_posY_baseMap + bmHeight; //替身的底部坐标
  //       if (bmbBottom < boxRect.bottom) {
  //         new_move_y = boxRect.bottom - bmHeight / 2;
  //       }

  //       result.movePos = ui.Offset(new_move_x, new_move_y);
  //     });
  //   } else {
  //     //======== 考虑偏移角度不为0的情况 ==========
  //     _resultRect_selectBox.go((boxRect) {
  //       var fix_diff_left = 0.0;
  //       var fix_diff_top = 0.0;
  //       var fix_diff_right = 0.0;
  //       var fix_diff_bottom = 0.0;

  //       //计算替身4个角所对应的内斜边上的高
  //       if (prop.rotateAngel < 0) {
  //         //向右旋转

  //       } else if (prop.rotateAngel > 0) {
  //         //向左旋转

  //       }
  //       fix_diff_top = MathUtils.getTriangularHeight2(
  //           boxRect.width, prop.rotateAngel.abs());
  //       fix_diff_bottom = fix_diff_top;

  //       fix_diff_left = MathUtils.getTriangularHeight2(
  //           boxRect.height, prop.rotateAngel.abs());
  //       fix_diff_right = fix_diff_left;
  //       //取景框每边到底图对应边的距离至少都要大于上面计算的高度
  //       var diff_left = boxRect.left - bm_rect.left;
  //       var diff_top = boxRect.top - bm_rect.top;
  //       var diff_right = bm_rect.left + bmWidth - boxRect.right;
  //       var diff_bottom = bm_rect.top + bmHeight - boxRect.bottom;

  //       //------------------------------------
  //       //检测一下缩放会不会过度导致无法容纳取景框，需要满足最低放入取景框条件
  //       //替身图至少要大于，取景框的斜边根据旋转角度的补角用cosSlope值得到的另一条边长
  //       var new_ssWidth_scale = 1.0;
  //       var new_ssHeight_scale = 1.0;

  //       //计算取景器斜边长
  //       final boxRect_diagonalLine_len =
  //           math.sqrt(boxRect.width.square() + boxRect.height.square());
  //       //计算斜边与height的角度
  //       final angle_from_height =
  //           MathUtils.cosSlope2Angle(boxRect.height / boxRect_diagonalLine_len);
  //       //计算斜边与width的角度
  //       final angle_from_width =
  //           MathUtils.cosSlope2Angle(boxRect.width / boxRect_diagonalLine_len);

  //       //计算得到最小需要的替身图高度
  //       final min_ssHeight = boxRect_diagonalLine_len *
  //           MathUtils.angle2CosSlope(
  //               angle_from_height - prop.rotateAngel.abs());
  //       //计算得到最小需要的替身图宽度
  //       final min_ssWidth = boxRect_diagonalLine_len *
  //           MathUtils.angle2CosSlope(angle_from_width - prop.rotateAngel.abs());

  //       if (ssHeight < min_ssHeight) {
  //         new_ssHeight_scale = min_ssHeight / ssHeight;
  //       }
  //       if (ssWidth < min_ssWidth) {
  //         new_ssWidth_scale = min_ssWidth / ssWidth;
  //       }

  //       if (new_ssWidth_scale > 1 || new_ssHeight_scale > 1) {
  //         final new_scale = max(new_ssWidth_scale, new_ssHeight_scale);
  //         result.scale = prop.scaleRatio * new_scale;
  //         //scale变动，需要更新
  //         ssWidth = prop.substituteSize!.width * new_scale;
  //         ssHeight = prop.substituteSize!.height * new_scale;
  //         final bmCalculateResult = _calculateUpdateBaseMap(
  //             // substituteSize: Size(ssWidth, ssHeight),
  //             scaleRatio: result.scale,
  //             prop: prop);
  //         bmCalculateResult.baseMapSize?.go((it) {
  //           bmWidth = it.width;
  //           bmHeight = it.height;
  //         });
  //         // bmWidth = prop.baseMapSize.width * new_scale;
  //         // bmHeight = prop.baseMapSize.height * new_scale;
  //         final bmWidth222 = prop.baseMapSize.width * new_scale;
  //         final bmHeight222 = prop.baseMapSize.height * new_scale;

  //         diff_left = boxRect.left - (_moveX.value - bmWidth / 2);
  //         diff_top = boxRect.top - (_moveY.value - bmHeight / 2);
  //         diff_right = (_moveX.value - bmWidth / 2) + bmWidth - boxRect.right;
  //         diff_bottom =
  //             (_moveY.value - bmHeight / 2) + bmHeight - boxRect.bottom;
  //       }
  //       //------------------------------------

  //       var need_move_left = 0.0;
  //       var need_move_top = 0.0;
  //       if (diff_left < fix_diff_left) {
  //         need_move_left += fix_diff_left - diff_left;
  //       }
  //       if (diff_top < fix_diff_top) {
  //         need_move_top += fix_diff_top - diff_top;
  //       }
  //       if (diff_right < fix_diff_right) {
  //         need_move_left -= fix_diff_right - diff_right;
  //       }
  //       if (diff_bottom < fix_diff_bottom) {
  //         need_move_top -= fix_diff_bottom - diff_bottom;
  //       }

  //       //处理的是图片中心坐标，所以带负数(反向位移)
  //       var new_move_x = _moveX.value + (-need_move_left);
  //       var new_move_y = _moveY.value + (-need_move_top);

  //       //接下来处理取景框4个顶点超框问题
  //       var ssOffset_left = ui.Offset.zero;
  //       var ssOffset_top = ui.Offset.zero;
  //       var ssOffset_right = ui.Offset.zero;
  //       var ssOffset_bottom = ui.Offset.zero;

  //       final temp_baseMap_x = new_move_x - bmWidth / 2;
  //       final temp_baseMap_y = new_move_y - bmHeight / 2;

  //       final temp_sinSlope = MathUtils.angle2SinSlope(prop.rotateAngel.abs());
  //       final temp_cosSlope = MathUtils.angle2CosSlope(prop.rotateAngel.abs());

  //       if (prop.rotateAngel < 0) {
  //         //向右转情况
  //         ssOffset_left = ui.Offset(
  //             temp_baseMap_x, temp_baseMap_y + temp_cosSlope * ssHeight);

  //         ssOffset_top = ui.Offset(
  //             temp_baseMap_x + temp_sinSlope * ssHeight, temp_baseMap_y);

  //         ssOffset_right = ui.Offset(temp_baseMap_x + bmWidth,
  //             temp_baseMap_y + temp_sinSlope * ssWidth);

  //         ssOffset_bottom = ui.Offset(temp_baseMap_x + temp_cosSlope * ssWidth,
  //             temp_baseMap_y + bmHeight);
  //       } else if (prop.rotateAngel > 0) {
  //         //向左转情况
  //         ssOffset_left = ui.Offset(
  //             temp_baseMap_x, temp_baseMap_y + temp_sinSlope * ssWidth);

  //         ssOffset_top = ui.Offset(
  //             temp_baseMap_x + temp_cosSlope * ssWidth, temp_baseMap_y);

  //         ssOffset_right = ui.Offset(temp_baseMap_x + bmWidth,
  //             temp_baseMap_y + temp_cosSlope * ssHeight);

  //         ssOffset_bottom = ui.Offset(temp_baseMap_x + temp_sinSlope * ssHeight,
  //             temp_baseMap_y + bmHeight);
  //       }

  //       //根据任意点+2个顶点，计算出任意点垂直于2个顶点连线的最短距离
  //       double calculatedHeight(Offset pre, Offset next, Offset point) {
  //         //拿到2个顶点斜率
  //         final slope = MathUtils.calculateSlopeNotAbs(pre, next);
  //         //用斜率加固定的x或者y倒退x对应的y, y对应的x
  //         final crossingA =
  //             MathUtils.getReverseXBySlope(slope, next, point.dy); //相交点a
  //         final crossingB =
  //             MathUtils.getReverseYBySlope(slope, next, point.dx); //相交点b
  //         //然后根据直角三角形面积计算公式得到斜边上的高
  //         final height = MathUtils.distanceTo(crossingA, point) *
  //             MathUtils.distanceTo(crossingB, point) /
  //             MathUtils.distanceTo(crossingA, crossingB);
  //         return height;
  //       }

  //       if (MathUtils.insideOrOutsideOfLine2(
  //               ssOffset_left, ssOffset_top, boxRect.topLeft,
  //               inRight: true) ==
  //           -1) {
  //         //选择框左上角超了
  //         final height =
  //             calculatedHeight(ssOffset_left, ssOffset_top, boxRect.topLeft);
  //         print('选择框左上角超了:$height');
  //         //拿到高然后计算需要偏移的x,y
  //         final move_x_len =
  //             (prop.rotateAngel > 0 ? temp_sinSlope : temp_cosSlope) * height;
  //         final move_y_len =
  //             (prop.rotateAngel > 0 ? temp_cosSlope : temp_sinSlope) * height;
  //         new_move_x += -move_x_len;
  //         new_move_y += -move_y_len;
  //       } else if (MathUtils.insideOrOutsideOfLine2(
  //               ssOffset_top, ssOffset_right, boxRect.topRight,
  //               inRight: false) ==
  //           -1) {
  //         //选择框右上角超了
  //         final height =
  //             calculatedHeight(ssOffset_top, ssOffset_right, boxRect.topRight);
  //         print('选择框右上角超了:$height');
  //         //拿到高然后计算需要偏移的x,y
  //         final move_x_len =
  //             (prop.rotateAngel > 0 ? temp_cosSlope : temp_sinSlope) * height;
  //         final move_y_len =
  //             (prop.rotateAngel > 0 ? temp_sinSlope : temp_cosSlope) * height;
  //         new_move_x += move_x_len;
  //         new_move_y += -move_y_len;
  //       } else if (MathUtils.insideOrOutsideOfLine2(
  //               ssOffset_bottom, ssOffset_right, boxRect.bottomRight,
  //               inRight: false) ==
  //           -1) {
  //         //选择框右下角超了
  //         final height = calculatedHeight(
  //             ssOffset_right, ssOffset_bottom, boxRect.bottomRight);
  //         print('选择框右下角超了:$height');
  //         //拿到高然后计算需要偏移的x,y
  //         final move_x_len =
  //             (prop.rotateAngel > 0 ? temp_sinSlope : temp_cosSlope) * height;
  //         final move_y_len =
  //             (prop.rotateAngel > 0 ? temp_cosSlope : temp_sinSlope) * height;
  //         new_move_x += move_x_len;
  //         new_move_y += move_y_len;
  //       } else if (MathUtils.insideOrOutsideOfLine2(
  //               ssOffset_left, ssOffset_bottom, boxRect.bottomLeft,
  //               inRight: true) ==
  //           -1) {
  //         //选择框左下角超了
  //         final height = calculatedHeight(
  //             ssOffset_bottom, ssOffset_left, boxRect.bottomLeft);
  //         print('选择框左下角超了:$height');
  //         //拿到高然后计算需要偏移的x,y
  //         final move_x_len =
  //             (prop.rotateAngel > 0 ? temp_cosSlope : temp_sinSlope) * height;
  //         final move_y_len =
  //             (prop.rotateAngel > 0 ? temp_sinSlope : temp_cosSlope) * height;
  //         new_move_x += -move_x_len;
  //         new_move_y += move_y_len;
  //       }

  //       result.movePos = ui.Offset(new_move_x, new_move_y);
  //     });
  //   }
  //   return result;
  // }