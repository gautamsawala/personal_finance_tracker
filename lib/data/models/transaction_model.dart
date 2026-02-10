import 'package:equatable/equatable.dart';
import 'categories.dart';

enum TransactionType {income, expense, all}

class TransactionModel extends Equatable{
  final int? id;
  final int amountCents;
  final DateTime transactionDate;
  final TransactionCategory category;
  final String note;
  final TransactionType transactionType;

  const TransactionModel({
    this.id,
    required this.amountCents,
    required this.transactionDate,
    required this.category,
    required this.note,
    required this.transactionType,
  });

  TransactionModel copyWith({
    int? id,
    int? amountCents,
    DateTime? transactionDate,
    TransactionCategory? category,
    String? note,
    TransactionType? transactionType,
}){
    return TransactionModel(
      id: id ?? this.id,
      amountCents: amountCents ?? this.amountCents,
      transactionDate: transactionDate ?? this.transactionDate,
      category: category ?? this.category,
      note: note ?? this.note,
      transactionType: transactionType ?? this.transactionType,
    );
  }

  Map<String, Object?> toMap() => {
    'id': id,
    'amount_cents': amountCents,
    'transaction_date': transactionDate.millisecondsSinceEpoch,
    'category': category.toString(),
    'note': note,
    'transaction_type': transactionType.toString(),
  };

  factory TransactionModel.fromMap(Map<String, Object?> map) => TransactionModel(
    id: map['id'] as int?,
    amountCents: map['amount_cents'] as int,
    transactionDate: DateTime.fromMillisecondsSinceEpoch(map['transaction_date'] as int),
    category: TransactionCategory.values.firstWhere((element) => element.toString() == map['category']),
    note: map['note'] as String,
    transactionType: TransactionType.values.firstWhere((element) => element.toString() == map['transaction_type']),
  );

  @override
  List<Object?> get props => [id, amountCents, transactionDate, category, note, transactionType];
}
