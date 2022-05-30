class TimedTask {
  late final Function _backCall;
  final Duration duration;
  bool _isClose = false;

  TimedTask(this.duration, Function backCall) {
    _backCall = backCall;
  }

  /// 开始任务
  void start() {
    Future.delayed(this.duration, () {
      if (!_isClose) {
        _backCall.call();
      }
    });
  }

  /// 终止任务
  void close() => _isClose = true;
}
