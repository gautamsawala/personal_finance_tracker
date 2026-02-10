part of 'transaction_cubit.dart';

sealed class TransactionState extends Equatable {
  const TransactionState();
  @override
  List<Object?> get props => [];
}

class TransactionLoading extends TransactionState {
  const TransactionLoading();
}

class TransactionLoaded extends TransactionState {
  final List<TransactionModel> transactions;
  const TransactionLoaded(this.transactions);

  int get incomeCents => transactions
      .where((transaction) => transaction.transactionType == TransactionType.income)
      .fold(0, (sum, transaction) => sum + transaction.amountCents);

  int get expenseCents => transactions
      .where((transaction) => transaction.transactionType == TransactionType.expense)
      .fold(0, (sum, transaction) => sum + transaction.amountCents);

  int get balanceCents => incomeCents - expenseCents;

  DateTime get firstTransactionDate => DateTime.fromMillisecondsSinceEpoch(transactions.isEmpty ? 0 : transactions.last.transactionDate.millisecondsSinceEpoch);

  @override
  List<Object?> get props => [transactions];
}

class TransactionError extends TransactionState {
  final String errorMessage;
  const TransactionError(this.errorMessage);

  @override
  List<Object?> get props => [errorMessage];
}
