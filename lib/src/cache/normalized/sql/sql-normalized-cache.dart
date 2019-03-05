import 'dart:collection';

import 'package:flutter_graphql/src/cache/normalized/record_field_json_adapter.dart';
import 'package:flutter_graphql/src/cache/normalized/sql/sql_helper.dart';
import 'package:sqflite/sqflite.dart';

import '../../cache.dart';

class SqlNormalizedCache implements Cache {

  SqlNormalizedCache(this.dbHelper, this.recordFieldAdapter) {
    dbHelper.open();
    database = dbHelper.db;
  }
  
  static const String UPDATE_STATEMENT = '''UPDATE ${SqlHelper.TABLE_RECORDS} SET ${SqlHelper.COLUMN_KEY}=?, ${SqlHelper.COLUMN_RECORD}=? WHERE ${SqlHelper.COLUMN_KEY}=?''';
  static const String DELETE_STATEMENT = '''DELETE FROM ${SqlHelper.TABLE_RECORDS} WHERE ${SqlHelper.COLUMN_KEY}=?''';
  static const String DELETE_ALL_RECORD_STATEMENT = '''DELETE FROM ${SqlHelper.TABLE_RECORDS}''';

  Database database;
  final SqlHelper dbHelper;
  final allColumns = [
      SqlHelper.COLUMN_ID,
      SqlHelper.COLUMN_KEY,
      SqlHelper.COLUMN_RECORD];
  final RecordFieldJsonAdapter recordFieldAdapter;
  HashMap<String, dynamic> _inMemoryCache = HashMap<String, dynamic>();

  @override
  Object read(String key) {
    // TODO: implement read
    return null;
  }

  Future<List<HashMap<String, dynamic>>> _readFromStorage() async {
    List<HashMap<String, dynamic>> records = await database.query(SqlHelper.TABLE_RECORDS);
    return records;
  }

  @override
  void reset() {
    // TODO: implement reset
  }

  @override
  void restore() {
    // TODO: implement restore
  }

  @override
  void save() {
    // TODO: implement save
  }

  @override
  void write(String key, dynamic values) {
    database.insert(SqlHelper.TABLE_RECORDS, values);
  }

  @override
  Future<bool> remove(String key, bool cascade) async {
    assert(key != null);
    final deletedObj = await database.delete(SqlHelper.TABLE_RECORDS, where: '${SqlHelper.COLUMN_KEY}=?', whereArgs: [key].toList());
    return true;
  }
  
}