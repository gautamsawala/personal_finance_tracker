import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../data/models/categories.dart';
import '../data/models/transaction_model.dart';

class AddTransactionModal extends StatefulWidget {
  final TransactionModel? initialTransaction;
  const AddTransactionModal({super.key, this.initialTransaction});

  @override
  State<AddTransactionModal> createState() => _AddTransactionModalState();
}

class _AddTransactionModalState extends State<AddTransactionModal> {
  final _amountController = TextEditingController();
  int? _transactionId;
  DateTime _transactionDate = DateTime.now();
  late TransactionCategory _category;
  final _noteController = TextEditingController();
  TransactionType _transactionType = TransactionType.expense;

  late List<TransactionCategory> _categoryOptions;

  final DateFormat _dateFormat = DateFormat('dd. MMM yyyy');

  @override
  void initState() {
    super.initState();

    /// Initialize the values with the transaction passed for editing.
    if (widget.initialTransaction != null) {
      _transactionId = widget.initialTransaction!.id;
      _amountController.text = (widget.initialTransaction!.amountCents / 100).toString();
      _transactionType = widget.initialTransaction!.transactionType;
      _transactionDate = widget.initialTransaction!.transactionDate;
      _noteController.text = widget.initialTransaction!.note;
    }
    _categoryOptions = categoriesForType(_transactionType);
    _category = widget.initialTransaction?.category ?? _categoryOptions.first;
  }

  void _setType(TransactionType transactionType) {
    setState(() {
      _transactionType = transactionType;
      _categoryOptions = categoriesForType(_transactionType);
      _category = _categoryOptions.first;
    });
  }

  int? _parseAmountToCents(String amount) {
    /// Provides support for both . and , as decimal separator
    final normalize = amount.trim().replaceAll(',', '.');
    final normalizedAmount = double.tryParse(normalize);
    if (normalizedAmount == null) return null;
    return (normalizedAmount * 100).round();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final initial = _transactionDate;

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000, 1, 1),
      lastDate: DateTime(now.year + 5, 12, 31),
    );
    if (picked == null) return;
    final normalized = DateTime(picked.year, picked.month, picked.day, 12);
    setState(() => _transactionDate = normalized);
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, top: 0, left: 20, right: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Add Transaction', style: Theme.of(context).textTheme.titleMedium),
              IconButton(onPressed: () => Navigator.of(context).pop(), icon: const Icon(Icons.close)),
            ],
          ),
          SegmentedButton<TransactionType>(
            segments: [
              ButtonSegment(
                value: TransactionType.income,
                label: Text('Income', style: Theme.of(context).textTheme.labelMedium),
              ),
              ButtonSegment(
                value: TransactionType.expense,
                label: Text('Expense', style: Theme.of(context).textTheme.labelMedium),
              ),
            ],
            selected: {_transactionType},
            onSelectionChanged: (transactionType) => _setType(transactionType.first),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IntrinsicWidth(
                  child: TextField(
                    controller: _amountController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 72),
                    decoration: InputDecoration(
                      hint: Text('0.00', style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 72)),
                      border: InputBorder.none,
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Text('€', style: TextStyle(fontSize: 48)),
              ],
            ),
          ),
          Container(
            height: 44,
            margin: const EdgeInsets.symmetric(vertical: 10),
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemCount: _categoryOptions.length,
              itemBuilder: (context, index) {
                final category = _categoryOptions[index];
                final selectedCategory = category == _category;
                return ChoiceChip(
                  selected: selectedCategory,
                  onSelected: (_) => setState(() => _category = category),
                  label: Text(category.label, style: Theme.of(context).textTheme.labelSmall),
                );
              },
            ),
          ),
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: _pickDate, // tap anywhere to edit
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(_dateFormat.format(_transactionDate), style: Theme.of(context).textTheme.titleMedium),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Icon(Icons.calendar_today_outlined, size: 18),
                  ),
                ],
              ),
            ),
          ),
          TextField(
            controller: _noteController,
            textAlign: TextAlign.center,
            decoration: const InputDecoration(hintText: '+ Add Note', border: InputBorder.none, isDense: true),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: OutlinedButton(
              onPressed:
                  _parseAmountToCents(_amountController.text) == null ||
                      _parseAmountToCents(_amountController.text) == 0
                  ? null
                  : () {
                      final amountCents = _parseAmountToCents(_amountController.text);
                      final transaction = TransactionModel(
                        id: _transactionId,
                        amountCents: amountCents!,
                        transactionDate: _transactionDate,
                        category: _category,
                        note: _noteController.text.trim(),
                        transactionType: _transactionType,
                      );
                      Navigator.of(context).pop(transaction);
                    },
              child: Text(
                'Add Transaction',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color:
                      _parseAmountToCents(_amountController.text) == null ||
                          _parseAmountToCents(_amountController.text) == 0
                      ? Colors.grey
                      : null,
                ),
              ),
            ),
          ),
          SizedBox(height: 50),
        ],
      ),
    );
  }
}
