part of image_editor;

typedef FunTailorResult = void Function(
    ui.Image? img, ByteData bytedata, Size? size);

class ImageEditorController {
  final _stream = StreamController<Map>();

  void _dispose() {
    _stream.sink.close();
    _stream.close();
  }

  ///x轴旋转角度增加
  void addRotateXAngle() {
    _stream.sink.add({
      'FunName': 'rotateXAngle',
      'args': {
        'isAdd': true,
      },
    });
  }

  ///x轴旋转角度减少
  void reduceRotateXAngle() {
    _stream.sink.add({
      'FunName': 'rotateXAngle',
      'args': {
        'isAdd': false,
      },
    });
  }

  ///y轴旋转角度增加
  void addRotateYAngle() {
    _stream.sink.add({
      'FunName': 'rotateYAngle',
      'args': {
        'isAdd': true,
      },
    });
  }

  ///y轴旋转角度减少
  void reduceRotateYAngle() {
    _stream.sink.add({
      'FunName': 'rotateYAngle',
      'args': {
        'isAdd': false,
      },
    });
  }

  ///Z旋转角度增加
  void addRotateZAngle() {
    _stream.sink.add({
      'FunName': 'rotateAngle',
      'args': {
        'isAdd': true,
      },
    });
  }

  ///Z旋转角度减少
  void reduceRotateZAngle() {
    _stream.sink.add({
      'FunName': 'rotateAngle',
      'args': {
        'isAdd': false,
      },
    });
  }

  ///90度旋转角度增加
  void addRotateAngle90() {
    _stream.sink.add({
      'FunName': 'rotateAngle90',
      'args': {
        'isAdd': true,
      },
    });
  }

  ///90度旋转角度减少
  void reduceRotateAngle90() {
    _stream.sink.add({
      'FunName': 'rotateAngle90',
      'args': {
        'isAdd': false,
      },
    });
  }

  ///缩放比例增加
  void addScaleRatio() {
    _stream.sink.add({
      'FunName': 'scaleRatio',
      'args': {
        'isAdd': true,
      },
    });
  }

  ///缩放比例减少
  void reduceScaleRatio() {
    _stream.sink.add({
      'FunName': 'scaleRatio',
      'args': {
        'isAdd': false,
      },
    });
  }

  //上下翻转
  void upsideDown() {
    _stream.sink.add({
      'FunName': 'upsideDown',
      'args': null,
    });
  }

  //左右翻转
  void turnAround() {
    _stream.sink.add({
      'FunName': 'turnAround',
      'args': null,
    });
  }

  ///裁剪
  void tailor() {
    _stream.sink.add({
      'FunName': 'tailor',
      'args': null,
    });
  }

  ///还原
  void restore() {
    _stream.sink.add({
      'FunName': 'restore',
      'args': null,
    });
  }
}
