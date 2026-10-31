import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/transaction_model.dart';

/// Quản lý cơ sở dữ liệu SQLite của ứng dụng (singleton).
class DatabaseHelper {
  DatabaseHelper._();
  static final DatabaseHelper instance = DatabaseHelper._();

  static const String _dbName = 'expense_manager.db';
  static const int _dbVersion = 1;
  static const String table = 'transactions';

  Future<Database>? _dbFuture;

  Future<Database> get database => _dbFuture ??= _open();

  Future<Database> _open() async {
    final path = join(await getDatabasesPath(), _dbName);
    return openDatabase(
      path,
      version: _dbVersion,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $table (
            id       INTEGER PRIMARY KEY AUTOINCREMENT,
            type     TEXT    NOT NULL CHECK (type IN ('expense', 'income')),
            category TEXT    NOT NULL,
            amount   INTEGER NOT NULL CHECK (amount > 0),
            date     TEXT    NOT NULL,
            note     TEXT    NOT NULL DEFAULT ''
          )
        ''');
        await db.execute('CREATE INDEX idx_${table}_date ON $table(date)');
      },
    );
  }

  /// Thêm giao dịch mới, trả về id vừa tạo.
  Future<int> insert(TransactionModel tx) async {
    final db = await database;
    final map = tx.toMap()..remove('id');
    return db.insert(table, map);
  }

  /// Cập nhật giao dịch theo id.
  Future<int> update(TransactionModel tx) async {
    final db = await database;
    return db.update(
      table,
      tx.toMap(),
      where: 'id = ?',
      whereArgs: [tx.id],
    );
  }

  /// Xóa giao dịch theo id.
  Future<int> delete(int id) async {
    final db = await database;
    return db.delete(table, where: 'id = ?', whereArgs: [id]);
  }

  /// Lấy giao dịch, mới nhất trước. Có thể giới hạn số lượng.
  Future<List<TransactionModel>> getTransactions({int? limit}) async {
    final db = await database;
    final rows = await db.query(
      table,
      orderBy: 'date DESC, id DESC',
      limit: limit,
    );
    return rows.map(TransactionModel.fromMap).toList();
  }
}
