import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class SqlHelper {

  static const String TABLE_RECORDS = 'records';
  static const String COLUMN_ID = '_id';
  static const String COLUMN_RECORD = 'record';
  static const String COLUMN_KEY = 'key';

  static const String DATABASE_NAME = 'graphql-flutter.db';
  static const int DATABASE_VERSION = 1;

  static const String DATABASE_CREATE = '''CREATE TABLE $TABLE_RECORDS ($COLUMN_ID INTEGER PRIMARY KEY AUTOINCREMENT, $COLUMN_KEY TEXT NOT NULL, $COLUMN_RECORD TEXT NOT NULL''';
  static const String IDX_RECORDS_KEY = 'idx_records_key';
  static const String CREATE_KEY_INDEX = '''CREATE INDEX $IDX_RECORDS_KEY ON $TABLE_RECORDS ($COLUMN_KEY)''';

  Database db;

  Future open() async {
    final databasesPath = await getDatabasesPath();
    String path = join(databasesPath, DATABASE_NAME);
    db = await openDatabase(path, version: DATABASE_VERSION, onCreate: (Database db, int version) async {
      await db.execute(DATABASE_CREATE);
      await db.execute(CREATE_KEY_INDEX);
    });
  }

  Future close() async {
    await db.close();
  }
  
}