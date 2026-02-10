import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:personal_finance_tracker/data/repo/transaction_repo.dart';

import '../../data/models/categories.dart';
import '../../data/models/transaction_model.dart';
import '../../data/repo/settings_repo.dart';

part 'transaction_state.dart';

class TransactionCubit extends Cubit<TransactionState> {
  final TransactionRepo transactionRepo;

  TransactionCubit({required this.transactionRepo}) : super(const TransactionLoading());

  Future<void> fetchAllTransactions() async {
    emit(const TransactionLoading());
    try {
      final transactions = await transactionRepo.getAllTransactions();
      emit(TransactionLoaded(transactions));
    } catch (error) {
      emit(TransactionError('Failed to load: ${error.toString()}'));
    }
  }

  Future<void> addTransaction(TransactionModel transaction) async {
    final previousState = state;
    try {
      await transactionRepo.insertTransaction(transaction);
      final transactions = await transactionRepo.getAllTransactions();
      emit(TransactionLoaded(transactions));
    } catch (error) {
      emit(TransactionError('Failed to add: ${error.toString()}'));
      if (previousState is TransactionLoaded) emit(previousState);
    }
  }

  Future<void> updateTransaction(TransactionModel transaction) async {
    final previousState = state;
    try {
      await transactionRepo.updateTransaction(transaction);
      final transactions = await transactionRepo.getAllTransactions();
      emit(TransactionLoaded(transactions));
    } catch (error) {
      emit(TransactionError('Failed to add: ${error.toString()}'));
      if (previousState is TransactionLoaded) emit(previousState);
    }
  }

  Future<void> removeTransaction(int id) async {
    final previousState = state;
    try {
      await transactionRepo.deleteTransactionById(id);
      final transactions = await transactionRepo.getAllTransactions();
      emit(TransactionLoaded(transactions));
    } catch (error) {
      emit(TransactionError('Failed to add: ${error.toString()}'));
      if (previousState is TransactionLoaded) emit(previousState);
    }
  }

  Future<void> fetchTransactionsByDateRange(DateTime startDate, DateTime endDate) async {
    final previousState = state;
    emit(const TransactionLoading());
    try {
      final transactions = await transactionRepo.fetchTransactionsByDateRange(startDate, endDate);
      emit(TransactionLoaded(transactions));
    } catch (error) {
      emit(TransactionError('Failed to load: ${error.toString()}'));
      if (previousState is TransactionLoaded) emit(previousState);
    }
  }

  Future<void> fetchTransactionsByCategory(TransactionCategory category) async {
    final previousState = state;
    emit(const TransactionLoading());
    try {
      final transactions = await transactionRepo.fetchTransactionsByCategory(category);
      emit(TransactionLoaded(transactions));
      } catch (error) {
      emit(TransactionError('Failed to load: ${error.toString()}'));
      if (previousState is TransactionLoaded) emit(previousState);
    }
  }

  Future<void> fetchTransactionByType(TransactionType type) async {
    final previousState = state;
    emit(const TransactionLoading());
    try {
      final transactions = await transactionRepo.fetchTransactionsByType(type);
      emit(TransactionLoaded(transactions));
    } catch (error) {
      emit(TransactionError('Failed to load: ${error.toString()}'));
      if (previousState is TransactionLoaded) emit(previousState);
    }
  }
}
