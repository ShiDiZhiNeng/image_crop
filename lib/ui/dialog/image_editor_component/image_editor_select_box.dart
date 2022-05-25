// ignore_for_file: non_constant_identifier_names

part of image_editor;

const _isTest = false;

enum _AngleType {
  top,
  right,
  bottom,
  left,
  topleft,
  topright,
  bottomright,
  bottomleft,
}

///图形编辑选择框
class _SelectBox extends StatefulWidget {
  ///外部旋转了多少度
  // final int fixedRotationAngle;

  final Size? winSize;

  ///初始化矩形数据
  final Rect? initRect;

  ///可移动的范围矩形数据
  final Rect? limitRect;

  ///图形编辑相关参数
  final DataEditorConfig editorConfig;

  ///返回选择框结果
  final Function(Rect resultRect) funResult;

  ///通知选择框正在操作中
  final Function(bool isOperation) funState;

  const _SelectBox(
      {Key? key,
      this.winSize,
      this.initRect,
      required this.funResult,
      this.limitRect,
      required this.funState,
      required this.editorConfig})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _SelectBoxState();
}

class _SelectBoxState extends State<_SelectBox> {
  final GlobalKey _globalKey = GlobalKey();

  final minRect = const Rect.fromLTWH(0, 0, 100, 100);

  ///图片编辑相关参数
  DataEditorConfig get editorConfig => widget.editorConfig;

  final Map<_AngleType, DataDragDetailsGroup> _dataDragDetailsGroup = {};
  final DataDragDetailsGroup _dataDragDetailsGroup_move =
      DataDragDetailsGroup();

  ///是否按下
  bool isPressDown = false;

  ///是否拖拽中
  bool isDraging = false;

  ///是否开启虚线框
  bool get isShowDottedLine => isPressDown == true;

  Rect? _srcRect;
  Rect get srcRect => _srcRect!;
  Rect? _curRect;
  Rect? get curRect {
    return _curRect ??= _srcRect;
  }

  set curRect(Rect? v) {
    v?.go((it) {
      _curRect = it;
      setState(() {});
    });
  }

  Color get _paddingColor => isPressDown
      ? Colors.black.withOpacity(0.3)
      : Colors.black.withOpacity(0.7);

  // MediaQueryData get _media => MediaQuery.of(context);

  Size? _winSize;
  Size? get winSize {
    return _winSize;
  }

  @override
  void initState() {
    super.initState();
    _AngleType.values.forEach((element) {
      _dataDragDetailsGroup[element] = DataDragDetailsGroup();
    });

    _srcRect = widget.initRect;

    if (widget.winSize != null) {
      _winSize = widget.winSize;
      _winSize?.go((it) {
        _srcRect ??= Rect.fromLTWH(0, 0, it.width, it.height);
      });
    } else {
      WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
        _winSize ??= _globalKey.currentContext?.size;
        _winSize?.go((it) {
          _srcRect ??= Rect.fromLTWH(0, 0, it.width, it.height);
          setState(() {});
        });
      });
    }
  }

  @override
  void didUpdateWidget(covariant _SelectBox oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initRect != oldWidget.initRect) {
      setState(() {
        _srcRect = widget.initRect;
      });
    }
  }

  ///第一行宽度和高度
  Size get line1_size {
    if (winSize == null) return const Size(0, 0);
    return Size(winSize!.width, curRect!.top);
  }

  ///第二行左边块宽度和高度
  Size get line2_left_size {
    return Size(curRect!.left, curRect!.height);
  }

  ///第二行中间块宽度和高度
  Size get line2_center_size {
    return Size(curRect!.width, curRect!.height);
  }

  ///第二行右边块宽度和高度
  Size get line2_right_size {
    if (winSize == null) return Size(0, curRect!.height);
    final width = winSize!.width - curRect!.left - curRect!.width;
    return Size(width, curRect!.height);
  }

  ///第三行宽度和高度
  Size get line3_size {
    if (winSize == null) return const Size(0, 0);
    return Size(
        winSize!.width, winSize!.height - curRect!.top - curRect!.height);
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: false,
      child: Container(
        key: _globalKey,
        color: Colors.transparent,
        child: Column(
          children: [
            _uiPart_1(),
            Row(
              children: [
                _uiPart_2_1(),
                _uiPart_2_2(),
                _uiPart_2_3(),
              ],
            ),
            _uiPart_3(),
          ],
        ),
      ),
    );
  }

  Widget _uiPart_1() {
    return Container(
      color: _paddingColor,
      width: line1_size.width,
      height: line1_size.height,
    ).gestureDetector(
      behavior: HitTestBehavior.translucent,
      onTapDown: (p0) {},
    );
  }

  Widget _uiPart_2_1() {
    // print('_line2_left_size:${_line2_left_size}');
    return Container(
      color: _paddingColor,
      width: line2_left_size.width.also((it) {
        if (it <= 0) return it.abs();
        return it;
      }),
      height: line2_left_size.height.also((it) {
        if (it <= 0) return it.abs();
        return it;
      }),
    );
  }

  ///中心块
  Widget _uiPart_2_2() {
    final width = line2_center_size.width.also((it) => it < 100 ? 100.0 : it);
    final height = line2_center_size.height.also((it) => it < 100 ? 100.0 : it);
    return Container(
        color: Colors.transparent,
        width: width,
        height: height,
        child: curRect == null
            ? const SizedBox()
            : Stack(
                alignment: AlignmentDirectional.center,
                children: [
                  //手势响应
                  //------------------ 4条贴边 ------------------
                  Positioned(
                      top: 0,
                      child: HorizontalLine(
                              length: width - 60,
                              width: editorConfig.lineHitTestWidth,
                              color:
                                  !_isTest ? Colors.transparent : Colors.yellow,
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 10))
                          .gestureVerticalWithData(
                              data: _dataDragDetailsGroup[_AngleType.top]!,
                              onVerticalDragDown: (p0, p1) {
                                _beginDownPress();
                              },
                              onVerticalDragUpdate: (p0, p1) {
                                // print(
                                //     'top line ${p0.localPosition.toString()}');
                                _updateRect(_AngleType.top, p1.diff());
                              },
                              onVerticalDragEnd: (p0, p1) {
                                _endChangeRect();
                              },
                              onVerticalDragCancel: (p1) {
                                _endChangeRect();
                              })),
                  Positioned(
                      right: 0,
                      child: VerticalLine(
                              length: height - 60,
                              width: editorConfig.lineHitTestWidth,
                              color:
                                  !_isTest ? Colors.transparent : Colors.yellow,
                              margin: const EdgeInsets.symmetric(vertical: 10))
                          .gestureHorizontalWithData(
                              data: _dataDragDetailsGroup[_AngleType.right]!,
                              onHorizontalDragDown: (p0, p1) {
                                _beginDownPress();
                              },
                              onHorizontalDragUpdate: (p0, p1) {
                                // print(
                                // 'right line ${p0.localPosition.toString()}');
                                _updateRect(_AngleType.right, p1.diff());
                              },
                              onHorizontalDragEnd: (p0, p1) {
                                _endChangeRect();
                              },
                              onHorizontalDragCancel: (p1) {
                                _endChangeRect();
                              })),
                  Positioned(
                      bottom: 0,
                      child: HorizontalLine(
                              length: width - 60,
                              width: editorConfig.lineHitTestWidth,
                              color:
                                  !_isTest ? Colors.transparent : Colors.yellow,
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 10))
                          .gestureVerticalWithData(
                              data: _dataDragDetailsGroup[_AngleType.bottom]!,
                              onVerticalDragDown: (p0, p1) {
                                _beginDownPress();
                              },
                              onVerticalDragUpdate: (p0, p1) {
                                // print(
                                // 'bottom line ${p0.localPosition.toString()}');
                                _updateRect(_AngleType.bottom, p1.diff());
                              },
                              onVerticalDragEnd: (p0, p1) {
                                _endChangeRect();
                              },
                              onVerticalDragCancel: (p1) {
                                _endChangeRect();
                              })),
                  Positioned(
                      left: 0,
                      child: VerticalLine(
                              length: height - 60,
                              width: editorConfig.lineHitTestWidth,
                              color:
                                  !_isTest ? Colors.transparent : Colors.yellow,
                              margin: const EdgeInsets.symmetric(vertical: 10))
                          .gestureHorizontalWithData(
                              data: _dataDragDetailsGroup[_AngleType.left]!,
                              onHorizontalDragDown: (p0, p1) {
                                _beginDownPress();
                              },
                              onHorizontalDragUpdate: (p0, p1) {
                                // print(
                                //     'left line ${p0.localPosition.toString()}');
                                _updateRect(_AngleType.left, p1.diff());
                              },
                              onHorizontalDragEnd: (p0, p1) {
                                _endChangeRect();
                              },
                              onHorizontalDragCancel: (p1) {
                                _endChangeRect();
                              })),
                  //------------------ 4个顶角 ------------------
                  Positioned(
                      top: 0,
                      left: 0,
                      child: Container(
                        width: editorConfig.cornerHitTestSize.width,
                        height: editorConfig.cornerHitTestSize.height,
                        color: !_isTest ? Colors.transparent : Colors.green,
                      ).gesturePanWithData(
                          data: _dataDragDetailsGroup[_AngleType.topleft]!,
                          onPanDown: (p0, p1) {
                            _beginDownPress();
                          },
                          onPanUpdate: (p0, p1) {
                            // print(
                            //     '左上 dragDownDetails:${p1.dragDownDetails!.globalPosition.toString()} dragUpdateDetails:${p1.dragUpdateDetails!.globalPosition.toString()} diff:${p1.diff().toString()}');
                            _updateRect(_AngleType.topleft, p1.diff());
                          },
                          onPanEnd: (p0, p1) {
                            _endChangeRect();
                          },
                          onPanCancel: (p1) {
                            _endChangeRect();
                          })),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      width: editorConfig.cornerHitTestSize.width,
                      height: editorConfig.cornerHitTestSize.height,
                      color: !_isTest ? Colors.transparent : Colors.green,
                    ).gesturePanWithData(
                        data: _dataDragDetailsGroup[_AngleType.topright]!,
                        onPanDown: (p0, p1) {
                          _beginDownPress();
                        },
                        onPanUpdate: (p0, p1) {
                          // print(
                          //     '右上 dragDownDetails:${p1.dragDownDetails!.globalPosition.toString()} dragUpdateDetails:${p1.dragUpdateDetails!.globalPosition.toString()} diff:${p1.diff().toString()}');
                          _updateRect(_AngleType.topright, p1.diff());
                        },
                        onPanEnd: (p0, p1) {
                          _endChangeRect();
                        },
                        onPanCancel: (p1) {
                          _endChangeRect();
                        }),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: editorConfig.cornerHitTestSize.width,
                      height: editorConfig.cornerHitTestSize.height,
                      color: !_isTest ? Colors.transparent : Colors.green,
                    ).gesturePanWithData(
                        data: _dataDragDetailsGroup[_AngleType.bottomright]!,
                        onPanDown: (p0, p1) {
                          _beginDownPress();
                        },
                        onPanUpdate: (p0, p1) {
                          // print('右下 line ${p0.localPosition.toString()}');
                          _updateRect(_AngleType.bottomright, p1.diff());
                        },
                        onPanEnd: (p0, p1) {
                          _endChangeRect();
                        },
                        onPanCancel: (p1) {
                          _endChangeRect();
                        }),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    child: Container(
                      width: editorConfig.cornerHitTestSize.width,
                      height: editorConfig.cornerHitTestSize.height,
                      color: !_isTest ? Colors.transparent : Colors.green,
                    ).gesturePanWithData(
                        data: _dataDragDetailsGroup[_AngleType.bottomleft]!,
                        onPanDown: (p0, p1) {
                          _beginDownPress();
                        },
                        onPanUpdate: (p0, p1) {
                          // print('左下 line ${p0.localPosition.toString()}');
                          _updateRect(_AngleType.bottomleft, p1.diff());
                        },
                        onPanEnd: (p0, p1) {
                          _endChangeRect();
                        },
                        onPanCancel: (p1) {
                          _endChangeRect();
                        }),
                  ),
                  //------------------ 中间透明矩形板 ------------------
                  //实际需求无需要，注释留着
                  // Positioned(
                  //   child: Container(
                  //     width: width - 40,
                  //     height: height - 40,
                  //     color: !_isTest ? Colors.transparent : Colors.green,
                  //   ).gesturePanWithData(
                  //       data: _dataDragDetailsGroup_move,
                  //       onPanUpdate: (p0, p1) {
                  //         _moveRect(p1.diff());
                  //       },
                  //       onPanEnd: (p0, p1) {
                  //         _endChangeRect();
                  //       },
                  //       onPanCancel: (p1) {
                  //         _endChangeRect();
                  //       }),
                  // ),

                  //------------------ 绘制取景框 ------------------
                  if (_isTest)
                    const SizedBox()
                  else
                    IgnorePointer(
                      ignoring: true,
                      child: CustomPaint(
                        size: Size(width, height),
                        painter: _SelectBoxPainter(
                            rect: curRect!,
                            isShowDottedLine: isShowDottedLine,
                            editorConfig: editorConfig),
                      ),
                    ),
                ],
              ));
  }

  Widget _uiPart_2_3() {
    return Container(
      color: _paddingColor,
      width: line2_right_size.width,
      height: line2_right_size.height,
    );
  }

  Widget _uiPart_3() {
    return Container(
      color: _paddingColor,
      width: line3_size.width,
      height: line3_size.height,
    );
  }

  ///按下
  void _beginDownPress() {
    setState(() {
      isPressDown = true;
    });
    widget.funState(true);
  }

  ///更新矩形
  void _updateRect(_AngleType type, Offset? diff) {
    if (diff == null) return;

    var dx = diff.dx;
    var dy = diff.dy;
    // MathUtils.coordinateSwitch(widget.fixedRotationAngle, dx, dy).go((it) {
    //   dx = it.dx;
    //   dy = it.dy;
    // });

    Rect? newRect;
    switch (type) {
      case _AngleType.top:
        newRect = Rect.fromLTRB(this.srcRect.left, this.srcRect.top + dy,
            this.srcRect.right, this.srcRect.bottom);
        this.curRect = _checlRectLegal(newRect, [type]);
        break;
      case _AngleType.right:
        newRect = Rect.fromLTRB(this.srcRect.left, this.srcRect.top,
            this.srcRect.right + dx, this.srcRect.bottom);
        this.curRect = _checlRectLegal(newRect, [type]);
        break;
      case _AngleType.bottom:
        newRect = Rect.fromLTRB(this.srcRect.left, this.srcRect.top,
            this.srcRect.right, this.srcRect.bottom + dy);
        this.curRect = _checlRectLegal(newRect, [type]);
        break;
      case _AngleType.left:
        newRect = Rect.fromLTRB(this.srcRect.left + dx, this.srcRect.top,
            this.srcRect.right, this.srcRect.bottom);
        this.curRect = _checlRectLegal(newRect, [type]);
        break;
      case _AngleType.topleft:
        newRect = Rect.fromLTRB(this.srcRect.left + dx, this.srcRect.top + dy,
            this.srcRect.right, this.srcRect.bottom);
        this.curRect =
            _checlRectLegal(newRect, [_AngleType.top, _AngleType.left]);
        break;
      case _AngleType.topright:
        newRect = Rect.fromLTRB(this.srcRect.left, this.srcRect.top + dy,
            this.srcRect.right + dx, this.srcRect.bottom);
        this.curRect =
            _checlRectLegal(newRect, [_AngleType.top, _AngleType.right]);
        break;
      case _AngleType.bottomright:
        newRect = Rect.fromLTRB(this.srcRect.left, this.srcRect.top,
            this.srcRect.right + dx, this.srcRect.bottom + dy);
        this.curRect =
            _checlRectLegal(newRect, [_AngleType.bottom, _AngleType.right]);
        break;
      case _AngleType.bottomleft:
        newRect = Rect.fromLTRB(this.srcRect.left + dx, this.srcRect.top,
            this.srcRect.right, this.srcRect.bottom + dy);
        this.curRect =
            _checlRectLegal(newRect, [_AngleType.bottom, _AngleType.left]);
        break;
    }
    //设置正在拖拽
    isDraging = true;

    // print('srcRect:${this.srcRect.toString()}  newRect:${newRect.toString()}');
  }

  ///移动矩形
  // ignore: unused_element
  void _moveRect(Offset? diff) {
    if (diff == null) return;
    final constraintSize = this.winSize!;
    this.curRect = Rect.fromLTWH(
        (this.srcRect.left + diff.dx).also((it) {
          if (it < 0) return 0;
          if (it > (constraintSize.width - this.srcRect.width)) {
            return constraintSize.width - this.srcRect.width;
          }
          return it;
        }),
        (this.srcRect.top + diff.dy).also((it) {
          if (it < 0) return 0;
          if (it > (constraintSize.height - this.srcRect.height)) {
            return constraintSize.height - this.srcRect.height;
          }
          return it;
        }),
        this.srcRect.width,
        this.srcRect.height);
  }

  ///判断新矩形数据是否合法
  Rect _checlRectLegal(Rect rect, List<_AngleType> typeList) {
    final constraintSize = this.winSize!;
    var retRect = Rect.fromLTRB(rect.left.also((it) {
      if (typeList.contains(_AngleType.left)) {
        if (it < 0) return 0;
        if (it > rect.right - 100) return rect.right - 100;
      }
      return it;
    }), rect.top.also((it) {
      if (typeList.contains(_AngleType.top)) {
        if (it < 0) return 0;
        if (it > rect.bottom - 100) return rect.bottom - 100;
      }
      return it;
    }), rect.right.also((it) {
      if (typeList.contains(_AngleType.right)) {
        if (it < rect.left + 100) return rect.left + 100;
        if (it > constraintSize.width) return constraintSize.width;
      }
      return it;
    }), rect.bottom.also((it) {
      if (typeList.contains(_AngleType.bottom)) {
        if (it < rect.top + 100) return rect.top + 100;
        if (it > constraintSize.height) return constraintSize.height;
      }
      return it;
    }));

    //限制取景框移动只能在指定范围内
    widget.limitRect?.go((limitRect) {
      var left = retRect.left;
      if (left < limitRect.left) {
        left = limitRect.left;
      }
      var top = retRect.top;
      if (top < limitRect.top) {
        top = limitRect.top;
      }
      var right = retRect.right;
      if (right > limitRect.right) {
        right = limitRect.right;
      }
      var bottom = retRect.bottom;
      if (bottom > limitRect.bottom) {
        bottom = limitRect.bottom;
      }
      retRect = Rect.fromLTRB(left, top, right, bottom);
    });
    return retRect;
  }

  ///手势结束或者取消
  void _endChangeRect() {
    setState(() {
      this._srcRect = this.curRect;

      ///设置不在拖拽中
      isDraging = false;
      isPressDown = false;
    });
    widget.funResult.call(this._srcRect!);
    widget.funState(false);
    // _createEndTask();
  }
}

class _SelectBoxPainter extends CustomPainter {
  _SelectBoxPainter({
    required this.rect,
    this.isShowDottedLine = false,
    required this.editorConfig,
  });

  ///图片编辑相关参数
  final DataEditorConfig editorConfig;
  final bool isShowDottedLine;
  final Rect rect;
  final double _dottedLen = 2;

  double get lineWidth => editorConfig.lineWidth;
  Color get lineColor => editorConfig.lineColor;
  double get cornerLength => editorConfig.cornerLength;
  double get cornerWidth => editorConfig.cornerWidth;
  Color get cornerColor => editorConfig.cornerColor;
  double get dottedLength => editorConfig.dottedLength;
  Color get dottedColor => editorConfig.dottedColor;

  @override
  void paint(Canvas canvas, Size size) {
    //修正值 lineWidth
    final fixLineWidth = lineWidth / 2;

    //修正值 CornerWidth
    final fixCornerWidth = cornerWidth / 2;

    //周长线
    canvas.drawPoints(
        ui.PointMode.lines,
        [
          //top
          Offset(0 + fixLineWidth, 0 + fixLineWidth),
          Offset(size.width + fixLineWidth, 0 + fixLineWidth),
          //right
          Offset(size.width - fixLineWidth, 0 + fixLineWidth),
          Offset(size.width - fixLineWidth, size.height - fixLineWidth),
          //bottom
          Offset(0 + fixLineWidth, size.height - fixLineWidth),
          Offset(size.width - fixLineWidth, size.height - fixLineWidth),
          //left
          Offset(0 + fixLineWidth, 0 + fixLineWidth),
          Offset(0 + fixLineWidth, size.height - fixLineWidth),
        ],
        Paint().let((paint) {
          paint
            ..strokeWidth = lineWidth
            ..color = lineColor
            ..strokeCap = StrokeCap.square;
        }));

    //四个直角框
    canvas.drawPoints(
        ui.PointMode.lines,
        [
          //左上角
          Offset(0 + fixCornerWidth, cornerLength),
          Offset(0 + fixCornerWidth, 0 + fixCornerWidth),
          Offset(0 + fixCornerWidth, 0 + fixCornerWidth),
          Offset(cornerLength + fixCornerWidth, 0 + fixCornerWidth),

          //右上角
          Offset(
              size.width - fixCornerWidth - cornerLength, 0 + fixCornerWidth),
          Offset(size.width - fixCornerWidth, 0 + fixCornerWidth),
          Offset(size.width - fixCornerWidth, 0 + fixCornerWidth),
          Offset(size.width - fixCornerWidth, cornerLength + fixCornerWidth),

          //右下角
          Offset(size.width - fixCornerWidth,
              size.height - cornerLength - fixCornerWidth),
          Offset(size.width - fixCornerWidth, size.height - fixCornerWidth),
          Offset(size.width - fixCornerWidth, size.height - fixCornerWidth),
          Offset(size.width - fixCornerWidth - cornerLength,
              size.height - fixCornerWidth),

          //左下角
          Offset(fixCornerWidth + cornerLength, size.height - fixCornerWidth),
          Offset(0 + fixCornerWidth, size.height - fixCornerWidth),
          Offset(0 + fixCornerWidth, size.height - fixCornerWidth),
          Offset(
              0 + fixCornerWidth, size.height - cornerLength - fixCornerWidth),
        ],
        Paint().let((paint) {
          paint
            ..strokeWidth = cornerWidth
            ..color = cornerColor
            ..strokeCap = StrokeCap.square;
        }));

    //辅助虚线九宫格
    final paint_DottedLine = Paint().let((paint) {
      paint
        ..strokeWidth = dottedLength
        ..color = dottedColor
        ..strokeCap = StrokeCap.round;
    });
    if (this.isShowDottedLine) {
      _drawHorizontalDottedLine(canvas, Offset(0, size.height / 3),
          Offset(size.width, size.height / 3), paint_DottedLine);
      _drawHorizontalDottedLine(canvas, Offset(0, size.height / 3 * 2),
          Offset(size.width, size.height / 3 * 2), paint_DottedLine);
      _drawVerticalDottedLine(canvas, Offset(size.width / 3, 0),
          Offset(size.width / 3, size.height), paint_DottedLine);
      _drawVerticalDottedLine(canvas, Offset(size.width / 3 * 2, 0),
          Offset(size.width / 3 * 2, size.height), paint_DottedLine);
    }
  }

  void _drawHorizontalDottedLine(
      Canvas canvas, Offset start, Offset end, Paint paint) {
    final List<Offset> points = [];
    final totalLen = end.dx - start.dx;
    final trunkLen = _dottedLen + 2;
    final num = totalLen ~/ trunkLen;
    for (var i = 0; i < num; i++) {
      points.add(Offset(trunkLen * i, start.dy));
      points.add(Offset(trunkLen * i + _dottedLen, start.dy));
    }
    canvas.drawPoints(ui.PointMode.lines, points, paint);
  }

  void _drawVerticalDottedLine(
      Canvas canvas, Offset start, Offset end, Paint paint) {
    final List<Offset> points = [];
    final totalLen = end.dy - start.dy;
    final trunkLen = _dottedLen + 2;
    final num = totalLen ~/ trunkLen;
    for (var i = 0; i < num; i++) {
      points.add(Offset(start.dx, trunkLen * i));
      points.add(Offset(start.dx, trunkLen * i + _dottedLen));
    }
    canvas.drawPoints(ui.PointMode.lines, points, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
