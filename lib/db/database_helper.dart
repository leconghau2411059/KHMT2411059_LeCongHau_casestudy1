import 'package:flutter/foundation.dart';
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

  /// Tăng giá trị mỗi khi dữ liệu thay đổi để các màn hình tự tải lại.
  final ValueNotifier<int> changes = ValueNotifier<int>(0);

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
    final id = await db.insert(table, map);
    changes.value++;
    return id;
  }

  /// Cập nhật giao dịch theo id.
  Future<int> update(TransactionModel tx) async {
    final db = await database;
    final count = await db.update(
      table,
      tx.toMap(),
      where: 'id = ?',
      whereArgs: [tx.id],
    );
    changes.value++;
    return count;
  }

  /// Xóa giao dịch theo id.
  Future<int> delete(int id) async {
    final db = await database;
    final count = await db.delete(table, where: 'id = ?', whereArgs: [id]);
    changes.value++;
    return count;
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

  /// Tổng thu nhập và tổng chi tiêu, tính trực tiếp bằng SQL.
  Future<({int income, int expense})> getTotals() async {
    final db = await database;
    final rows = await db.rawQuery(
      'SELECT type, SUM(amount) AS total FROM $table GROUP BY type',
    );
    var income = 0;
    var expense = 0;
    for (final row in rows) {
      final total = (row['total'] as int?) ?? 0;
      if (row['type'] == 'income') {
        income = total;
      } else {
        expense = total;
      }
    }
    return (income: income, expense: expense);
  }

  /// Tổng chi tiêu theo từng danh mục, nhiều nhất trước.
  Future<List<({String category, int total})>> getExpenseByCategory() async {
    final db = await database;
    final rows = await db.rawQuery(
      'SELECT category, SUM(amount) AS total FROM $table '
      "WHERE type = 'expense' GROUP BY category ORDER BY total DESC",
    );
    return rows
        .map((r) => (
              category: r['category'] as String,
              total: (r['total'] as int?) ?? 0,
            ))
        .toList();
  }
}
