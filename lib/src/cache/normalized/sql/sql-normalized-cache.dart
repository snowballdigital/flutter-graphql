import 'package:flutter_graphql/src/cache/cache.dart';
import 'package:flutter_graphql/src/cache/normalized/sql/sql_helper.dart';
import 'package:sqflite/sqflite.dart';

class SqlNormalizedCache implements Cache {

  static const String INSERT_STATEMENT = '''INSERT INTO ${SqlHelper.TABLE_RECORDS} (${SqlHelper.COLUMN_KEY},${SqlHelper.COLUMN_RECORD}) VALUES (?,?)''';
  static const String UPDATE_STATEMENT = '''UPDATE ${SqlHelper.TABLE_RECORDS} SET ${SqlHelper.COLUMN_KEY}=?, ${SqlHelper.COLUMN_RECORD}=? WHERE ${SqlHelper.COLUMN_KEY}=?''';

  static const String DELETE_STATEMENT = '''DELETE FROM ${SqlHelper.TABLE_RECORDS} WHERE ${SqlHelper.COLUMN_KEY}=?''';
  static const String DELETE_ALL_RECORD_STATEMENT = '''DELETE FROM ${SqlHelper.TABLE_RECORDS}''';

  Database database;
  final SqlHelper dbHelper;
  final allColumns = [
      SqlHelper.COLUMN_ID,
      SqlHelper.COLUMN_KEY,
      SqlHelper.COLUMN_RECORD];

  SqlNormalizedCache(this.dbHelper);
  
  /*
  private final SQLiteStatement insertStatement;
  private final SQLiteStatement updateStatement;
  private final SQLiteStatement deleteStatement;
  private final SQLiteStatement deleteAllRecordsStatement;
  private final RecordFieldJsonAdapter recordFieldAdapter;*/

  @override
  Object read(String key) {
    // TODO: implement read
    return null;
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
  void write(String key, value) {
    // TODO: implement write
  }

  @override
  Future<bool> remove(String key, bool cascade) {
    // TODO: implement remove
    return null;
  }
  
}