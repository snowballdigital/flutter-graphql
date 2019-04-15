abstract class Cache {
  Future<bool> remove(String key, bool cascade) async {}

  dynamic read(String key) {}

  void write(
    String key,
    dynamic value,
  ) {}

  void save() {}

  void restore() {}

  void reset() {}

}
