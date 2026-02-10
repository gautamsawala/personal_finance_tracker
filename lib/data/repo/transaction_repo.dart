import 'package:sqflite/sqflite.dart';
import '../db/transaction_db_init.dart';
import '../models/categories.dart';
import '../models/transaction_model.dart';

class TransactionRepo {
  /// Get all transactions from the database.
  Future<List<TransactionModel>> getAllTransactions() async {
    final db = await TransactionDatabaseInit.dbInstance.db;
    final List<Map<String, dynamic>> maps = await db.query('transactions', orderBy: 'transaction_date DESC');
    return maps.map(TransactionModel.fromMap).toList();
  }

  /// Insert a new transaction into the database.
  Future<TransactionModel> insertTransaction(TransactionModel transaction) async {
    final db = await TransactionDatabaseInit.dbInstance.db;
    final id = await db.insert(
      'transactions',
      transaction.toMap()..remove('id'),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return transaction.copyWith(id: id);
  }

  /// Update an existing transaction in the database.
  Future<void> updateTransaction(TransactionModel transaction) async {
    if (transaction.id == null) {
      throw ArgumentError('Transaction id cannot be null');
    }
    final db = await TransactionDatabaseInit.dbInstance.db;
    await db.update(
      'transactions',
      transaction.toMap(),
      where: 'id = ?',
      whereArgs: [transaction.id],
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Delete a transaction in the database
  Future<void> deleteTransactionById(int id) async {
    final db = await TransactionDatabaseInit.dbInstance.db;
    await db.delete('transactions', where: 'id = ?', whereArgs: [id]);
  }

  /// Fetch transactions by date range.
  Future<List<TransactionModel>> fetchTransactionsByDateRange(DateTime startDate, DateTime endDate) async {
    final db = await TransactionDatabaseInit.dbInstance.db;
    final List<Map<String, dynamic>> maps = await db.query(
      'transactions',
      where: 'transaction_date BETWEEN ? AND ?',
      whereArgs: [startDate.millisecondsSinceEpoch, endDate.millisecondsSinceEpoch],
    );
    return maps.map(TransactionModel.fromMap).toList();
  }

  /// Fetch transactions by category.
  Future<List<TransactionModel>> fetchTransactionsByCategory(TransactionCategory category) async {
    final db = await TransactionDatabaseInit.dbInstance.db;
    final List<Map<String, dynamic>> maps = await db.query(
      'transactions',
      where: 'category = ?',
      whereArgs: [category.toString()],
    );
    return maps.map(TransactionModel.fromMap).toList();
  }

  /// Fetch transactions by type.
  Future<List<TransactionModel>> fetchTransactionsByType(TransactionType type) async {
    final db = await TransactionDatabaseInit.dbInstance.db;
    final List<Map<String, dynamic>> maps = await db.query(
      'transactions',
      where: 'transaction_type = ?',
      whereArgs: [type.toString()],
    );
    return maps.map(TransactionModel.fromMap).toList();
  }
}
