import 'package:personal_finance_tracker/data/models/transaction_model.dart';
import 'package:flutter/material.dart';

enum TransactionCategory { salary, dividend, investment, groceries, restaurant, travel, shopping, other }

extension TransactionCategoryX on TransactionCategory {
  bool get isIncome =>
      this == TransactionCategory.salary ||
      this == TransactionCategory.dividend ||
      this == TransactionCategory.investment;

  bool get isExpense => !isIncome;

  String get label {
    switch (this) {
      case TransactionCategory.salary:
        return 'Salary';
      case TransactionCategory.dividend:
        return 'Dividend';
      case TransactionCategory.investment:
        return 'Investment';
      case TransactionCategory.groceries:
        return 'Groceries';
      case TransactionCategory.restaurant:
        return 'Restaurant';
      case TransactionCategory.travel:
        return 'Travel';
      case TransactionCategory.shopping:
        return 'Shopping';
      case TransactionCategory.other:
        return 'Other';
    }
  }

  IconData get icon {
    switch (this) {
      case TransactionCategory.salary:
        return Icons.payments_outlined;
      case TransactionCategory.dividend:
        return Icons.trending_up;
      case TransactionCategory.investment:
        return Icons.show_chart;
      case TransactionCategory.groceries:
        return Icons.shopping_cart_outlined;
      case TransactionCategory.restaurant:
        return Icons.restaurant_outlined;
      case TransactionCategory.travel:
        return Icons.flight_takeoff;
      case TransactionCategory.shopping:
        return Icons.shopping_bag_outlined;
      case TransactionCategory.other:
        return Icons.more_horiz;
    }
  }
}

List<TransactionCategory> categoriesForType(TransactionType type) {
  return TransactionCategory.values.where((c) {
    return type == TransactionType.income ? c.isIncome : c.isExpense;
  }).toList();
}