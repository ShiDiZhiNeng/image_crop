class DataSimpleCache<T> {
  DataSimpleCache({required this.value}) {
    _cacheValue = value;
  }

  late T _cacheValue;
  T get cacheValue => _cacheValue;

  T value;

  void restore() => value = _cacheValue;
  void coverCache() => _cacheValue = value;
}
