import 'dart:convert';
import 'dart:core';

class RecordFieldJsonAdapter {
  static RecordFieldJsonAdapter create() {
    return RecordFieldJsonAdapter();
  }

  dynamic toJson(Map<String, dynamic> fields) {
    return json.encode(fields);
  }

  Map<String, Object>? from(dynamic jsonObj) {
    assert(jsonObj != null);
    return json.decode(jsonObj);
  }

/*
  private Map<String, Object> fromBufferSource(BufferedSource bufferedFieldSource) throws IOException {
    final CacheJsonStreamReader cacheJsonStreamReader =
        cacheJsonStreamReader(bufferedSourceJsonReader(bufferedFieldSource));
    return cacheJsonStreamReader.toMap();
  }
*/
}
