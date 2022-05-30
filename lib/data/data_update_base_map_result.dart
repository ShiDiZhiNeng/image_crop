import 'dart:ui';

///返回更新底图数据
class DataUpdateBaseMapResult {
  ///返回需变更 底图size
  Size? baseMapSize;

  ///返回需变更 底图与替身的差异top
  double? baseMapRectTopDiff;

  ///返回需变更 底图与替身的差异left
  double? baseMapRectLeftDiff;
}
