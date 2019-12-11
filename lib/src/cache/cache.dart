abstract class Cache {
  Future<bool> remove(String key, bool cascade);

  dynamic read(String key) {}

  void write(
    String key,
    dynamic value,
  ) {}

  void save() {}

  void restore() {}

  void reset() {}
}
