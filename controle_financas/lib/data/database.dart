import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/transaction.dart';

class AppDatabase {
  AppDatabase._();
  static final AppDatabase instance = AppDatabase._();

  Future<Database>? _opening;

  
  Future<Database> get _database => _opening ??= _openOrReset();

  Future<Database> _openOrReset() async {
    try {
      return await _open();
    } catch (_) {
      _opening = null;
      rethrow;
    }
  }

  Future<Database> _open() async {
    final path = join(await getDatabasesPath(), 'financas.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE transactions (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            description TEXT NOT NULL,
            amount_cents INTEGER NOT NULL,
            date INTEGER NOT NULL,
            type TEXT NOT NULL,
            category TEXT NOT NULL
          )
        ''');
      },
    );
  }

  Future<int> insert(FinanceTransaction t) async {
    final db = await _database;
    return db.insert('transactions', t.toMap());
  }

  Future<void> update(FinanceTransaction t) async {
    final db = await _database;
    await db.update('transactions', t.toMap(), where: 'id = ?', whereArgs: [t.id]);
  }

  Future<void> delete(int id) async {
    final db = await _database;
    await db.delete('transactions', where: 'id = ?', whereArgs: [id]);
  }


  Future<List<FinanceTransaction>> byRange(DateTime start, DateTime end) async {
    final db = await _database;
    final rows = await db.query(
      'transactions',
      where: 'date >= ? AND date < ?',
      whereArgs: [start.millisecondsSinceEpoch, end.millisecondsSinceEpoch],
      orderBy: 'date DESC, id DESC',
    );
    return rows.map(FinanceTransaction.fromMap).toList();
  }
}
