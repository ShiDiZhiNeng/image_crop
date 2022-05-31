class DataSimpleCache<T> {
  DataSimpleCache({required this.value}) {
    _cacheValue = value;
  }

  ///缓存值
  late T _cacheValue;
  T get cacheValue => _cacheValue;

  ///明面值
  T value;

  ///重置值
  void restore() => value = _cacheValue;

  ///更新缓存
  void coverCache() => _cacheValue = value;
}
