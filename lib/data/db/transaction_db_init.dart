import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class TransactionDatabaseInit{
  static final TransactionDatabaseInit dbInstance = TransactionDatabaseInit._();
  TransactionDatabaseInit._();

  static const _dbName = 'transactions.db';
  static const _dbVersion = 1;

  Database? _db;

  Future<Database> get db async {
    if (_db != null) {
      return _db!;
    }
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);
    return await openDatabase(path, version: _dbVersion, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    /// 'type' refers to the transaction type, either 'income' or 'expense'.
    await db.execute('''
      CREATE TABLE transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        transaction_date int NOT NULL,
        category TEXT NOT NULL,
        note TEXT NOT NULL,
        amount_cents INTEGER NOT NULL,
        transaction_type TEXT NOT NULL
      )
    ''');

    /// Create an index on the transaction_date column for faster queries, while filtering transactions with date range.
    await db.execute('''
    CREATE INDEX idx_transactions_transaction_date ON transactions (transaction_date)
    ''');
  }
}