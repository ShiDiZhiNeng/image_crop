class FNum<T extends num> {
  FNum(this.initValue, {required T min, required T max}) {
    if (min > max) {
      min = max;
    }
    this._min = min;
    this._max = max;
    value = initValue;
  }

  ///限制区间
  late T _min;
  T get min => _min;

  late T _max;
  T get max => _max;

  final T initValue;

  late T _value;
  set value(T v) {
    if (v < _min) {
      _value = _min;
    } else if (v > _max) {
      _value = _max;
    } else {
      _value = v;
    }
  }

  T get value => _value;

  FNum<T> clone({T? initValue, T? min, T? max}) {
    return FNum(initValue ?? this.initValue,
        min: min ?? this.min, max: max ?? this.max);
  }
}
