import 'dart:convert';

class RecordFieldJsonAdapter {

  static RecordFieldJsonAdapter create() {
    return new RecordFieldJsonAdapter();
  }

  RecordFieldJsonAdapter() {
  }

  dynamic toJson(Map<String, dynamic> fields) {
    assert(fields != null);
    return json.encode(fields);
  }

  Map<String, Object> from(dynamic jsonObj) {
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