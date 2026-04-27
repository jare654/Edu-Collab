class LocalCache<T> {
  final Map<String, T> _store = {};

  T? get(String key) => _store[key];
  void set(String key, T value) => _store[key] = value;
  bool contains(String key) => _store.containsKey(key);
}
