class TimedTask {
  late final Function _backCall;
  final Duration duration;
  bool _isClose = false;

  TimedTask(this.duration, Function backCall) {
    _backCall = backCall;
  }

  void start() {
    Future.delayed(this.duration, () {
      if (!_isClose) {
        _backCall.call();
      }
    });
  }

  void close() => _isClose = true;
}
