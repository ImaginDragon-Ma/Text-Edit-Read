/// SQLite 数据库配置（预留）
///
/// 用 sqflite 包，当前为预留接口，后续用于存储：
/// - 文件历史记录
/// - 搜索历史
/// - 书签等结构化数据

// import 'package:sqflite/sqflite.dart';
// import 'package:path/path.dart' as p;

class Database {
  // static Database? _instance;
  // static const String _dbName = 'text_edit_read.db';
  // static const int _version = 1;

  // /// 获取数据库单例
  // static Future<Database> getInstance() async {
  //   if (_instance != null) return _instance!;
  //
  //   final dbPath = await getDatabasesPath();
  //   final path = p.join(dbPath, _dbName);
  //
  //   _instance = await openDatabase(
  //     path,
  //     version: _version,
  //     onCreate: _onCreate,
  //   );
  //   return _instance!;
  // }

  // static Future<void> _onCreate(Database db, int version) async {
  //   await db.execute('''
  //     CREATE TABLE IF NOT EXISTS file_history (
  //       id INTEGER PRIMARY KEY AUTOINCREMENT,
  //       file_path TEXT NOT NULL,
  //       file_name TEXT NOT NULL,
  //       encoding TEXT DEFAULT 'utf-8',
  //       last_opened_at INTEGER NOT NULL,
  //       cursor_position INTEGER DEFAULT 0
  //     );
  //   ''');
  //
  //   await db.execute('''
  //     CREATE TABLE IF NOT EXISTS search_history (
  //       id INTEGER PRIMARY KEY AUTOINCREMENT,
  //       term TEXT NOT NULL,
  //       searched_at INTEGER NOT NULL
  //     );
  //   ''');
  //
  //   await db.execute('''
  //     CREATE TABLE IF NOT EXISTS bookmarks (
  //       id INTEGER PRIMARY KEY AUTOINCREMENT,
  //       file_path TEXT NOT NULL,
  //       chapter_title TEXT,
  //       cursor_position INTEGER NOT NULL,
  //       created_at INTEGER NOT NULL
  //     );
  //   ''');
  // }

  /// 预留：关闭数据库
  // static Future<void> close() async {
  //   if (_instance != null) {
  //     await _instance!.close();
  //     _instance = null;
  //   }
  // }
}
