// ignore_for_file: unnecessary_getters_setters

part of image_editor;

class ImageEditorProperty {
  ///底图数据(底图用于图片旋转后重新定位width,height)
  Size _baseMapSize = Size.zero;
  Size get baseMapSize {
    var size = _baseMapSize;
    //受绕x,y轴影响
    _addSizeByProportionWeight()?.go((it) {
      size = ui.Size(size.width + it.width, size.height + it.height);
    });
    //受90度旋转影响
    if ([90, -90].contains(fixedRotationAngle)) {
      size = ui.Size(size.height, size.width);
    }

    return size;
  }

  set baseMapSize(Size v) {
    _baseMapSize = v;
  }

  double baseMapRectLeftDiff = 0; //底图与目标编辑图的left 差异
  double baseMapRectTopDiff = 0; //底图与目标编辑图的top 差异

  ///目标图widget控件
  Image? targetImageWidget;

  ///目标图ui.image数据 _ 不受参数影响
  ui.Image? _targetUIImage;

  ///目标替身大小
  Size? _substituteSize;

  ///获取目标替身大小
  Size? get substituteSize {
    return _substituteSize;
  }

  ///获取目标替身大小(算上了scale, 受90度旋转 的影响)
  Size get substituteActualSize {
    var size = Size(_substituteSize?.width ?? 0, _substituteSize?.height ?? 0);
    //受绕x,y轴影响
    _addSizeByProportionWeight()?.go((it) {
      size = ui.Size(size.width + it.width, size.height + it.height);
    });
    //受缩放影响
    size = Size(size.width * scaleRatio, size.height * scaleRatio);
    //受90度旋转影响
    if ([90, -90].contains(fixedRotationAngle)) {
      size = ui.Size(size.height, size.width);
    }
    return size;
  }

  //--------------- 目标图旋转 -----

  //目标图旋转的角度
  final FNum<double> _rotateAngel =
      FNum<double>(0, min: 0, max: 360); //限制-45 ~ 45
  set rotateAngel(double v) {
    _rotateAngel.value = v;
  }

  double get rotateAngel {
    var ret = _rotateAngel.value;
    //受旋转90度影响
    // ret += fixedRotationAngle;

    //受左右翻转影响
    if (isTurnAround) {
      ret *= -1;
    }
    //受上下翻转影响
    if (isUpsideDown) {
      ret *= -1;
    }

    return ret;
  }

  //--------------- 目标图缩放 -----

  //目标图缩放的大小
  final FNum<double> _scaleRatio = FNum<double>(1, min: 1, max: 100); //限制1 ~ 5
  set scaleRatio(double v) {
    _scaleRatio.value = v;
  }

  double? scaleRatioCache;

  double get scaleRatio => _scaleRatio.value * (scaleRatioCache ?? 1);

  //--------------- 目标图上下翻转左右翻转 -----

  //目标图是否上下翻转
  bool _isUpsideDown = false;
  set isUpsideDown(bool v) {
    _isUpsideDown = v;
  }

  bool get isUpsideDown => _isUpsideDown;

  //目标图是否左右翻转
  bool _isTurnAround = false;
  set isTurnAround(bool v) {
    _isTurnAround = v;
  }

  bool get isTurnAround => _isTurnAround;

  //--------------- 外部旋转固定90角度 -----
  int _fixedRotationAngle = 0;
  int get fixedRotationAngle => _fixedRotationAngle;
  set fixedRotationAngle(int v) {
    //只支持 0，90，180， 270, 360
    const support = [-270, -180, -90, 0, 90, 180, 270];
    if (!support.contains(v)) {
      print('不在支持的角度数据当中');
      return;
    }
    var ret = v;
    if (v <= -270) {
      ret = 90;
    } else if (v >= 270) {
      ret = -90;
    }

    //实际最后结果只有 -180, -90, 0, 90, 180
    _fixedRotationAngle = ret;
  }

  //--------------- 绕x轴上下旋转，绕y轴左右旋转 -----
  //先根据xy正负值确定一下象限
  int _rotateX = 0;
  set rotateX(int v) {
    _rotateX = v;
  }

  int get rotateX {
    return _rotateX;
  }

  int _rotateY = 0;
  set rotateY(int v) {
    _rotateY = v;
  }

  int get rotateY {
    return _rotateY;
  }

  ///是否发生x,y旋转
  bool get hasXYRotate => _rotateX != 0 || _rotateY != 0;

  ///rotateX后最长边延伸落在哪个象限
  List<Direction>? longestStretchWithRotateX() {
    if (_rotateX < 0) {
      return [Direction.left_top, Direction.right_top];
    } else if (_rotateX > 0) {
      return [Direction.left_bottom, Direction.right_bottom];
    }
    return null;
  }

  ///rotateY后最长边延伸落在哪个象限
  List<Direction>? longestStretchWithRotateY() {
    if (_rotateY < 0) {
      return [Direction.right_top, Direction.right_bottom];
    } else if (_rotateY > 0) {
      return [Direction.left_top, Direction.left_bottom];
    }
    return null;
  }

  ///统计左上，右上，右下，左下 4个方向的权重占比
  Map<Direction, int> directionProportionWeight() {
    final list = <Direction, int>{};
    longestStretchWithRotateX()?.go(
      (it) {
        it.forEach((element) {
          list[element] ??= 0;
          list[element] = list[element]! + 1;
        });
      },
    );
    longestStretchWithRotateY()?.go((it) {
      it.forEach((element) {
        list[element] ??= 0;
        list[element] = list[element]! + 1;
      });
    });
    return list;
  }

  ///计算权重所需给底图和替身图额外增加的空间
  Size? _addSizeByProportionWeight() {
    Size? retSize;
    directionProportionWeight().go((it) {
      var maxV = 0;
      it.forEach((key, value) {
        maxV = math.max(value, maxV);
      });
      final ssSize = substituteSize ?? Size.zero;
      final xExtLen = (rotateX.abs() / 45) * ssSize.height;
      final yExtLen = (rotateY.abs() / 45) * ssSize.width;
      switch (maxV) {
        case 1:
          final n = math.max(xExtLen, yExtLen) * 1.0;
          retSize = Size(n, n);
          break;
        case 2:
          final n = xExtLen + yExtLen;
          retSize = Size(n, n);
          break;
        default:
      }
    });
    return retSize;
  }
}
