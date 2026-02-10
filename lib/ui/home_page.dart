import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:personal_finance_tracker/bloc/transaction/transaction_cubit.dart';
import 'package:personal_finance_tracker/data/models/categories.dart';

import '../bloc/settings/settings_cubit.dart';
import '../data/models/transaction_model.dart';
import 'add_transaction_modal.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TransactionType _filterType = TransactionType.all;
  DateTime lastTransactionDate = DateTime.now();
  DateTime? firstTransactionDate;
  String _money(int cents) {
    final format = NumberFormat.currency(locale: 'de-DE', symbol: '€');
    return format.format(cents / 100.0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /*
      /// Disabled floating action button as it overlays on top of last transaction on the screen.
      /// Can be added back with the support to move the floating action button around of the screen.
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final transaction = await showModalBottomSheet<TransactionModel>(
            context: context,
            isScrollControlled: true,
            showDragHandle: true,
            builder: (_) => const AddTransactionModal(),
          );
          if (transaction != null && context.mounted) {
            context.read<TransactionCubit>().addTransaction(transaction);
          }
        },
        icon: const Icon(Icons.add),
        label: Text('Add Transaction', style: Theme.of(context).textTheme.labelLarge),
      ),
       */
      body: SafeArea(
        child: BlocBuilder<TransactionCubit, TransactionState>(
          builder: (context, state) {
            if (state is TransactionLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is TransactionError) {
              return Center(child: Text(state.errorMessage));
            }
            if (state is! TransactionLoaded) {
              return Center(child: Text('Something went wrong', style: Theme.of(context).textTheme.titleMedium));
            }
            final transactions = state.transactions;
            return RefreshIndicator(
              onRefresh: () async {
                context.read<TransactionCubit>().fetchAllTransactions();
                _filterType = TransactionType.all;
              },
              child: Column(
                      children: [
                        Container(
                          padding: EdgeInsets.all(20.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Balance', style: Theme.of(context).textTheme.displaySmall),
                                  Text(_money(state.balanceCents), style: Theme.of(context).textTheme.displayLarge),
                                  InkWell(
                                      child: Row(
                                        children: [
                                          Text(
                                            '${DateFormat(state.firstTransactionDate.year == lastTransactionDate.year ?
                                            'dd. MMM' : 'dd. MMM yyyy').format(firstTransactionDate ?? state.firstTransactionDate)} '
                                                '- ${DateFormat('dd. MMM yyyy').format(lastTransactionDate)}',
                                            style: Theme.of(context).textTheme.labelMedium,
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 10),
                                            child: Icon(Icons.calendar_today_outlined, size: 18),
                                          )
                                        ],
                                      ),
                                    onTap: () async{
                                      final filteredDateRange = await showDateRangePicker(
                                        context: context,
                                        firstDate: DateTime(2025, 1, 1),
                                        lastDate: DateTime.now(),
                                        initialDateRange: DateTimeRange(
                                          start: firstTransactionDate ?? state.firstTransactionDate,
                                          end: lastTransactionDate,
                                        ),
                                      );
                                      if (filteredDateRange != null) {
                                        lastTransactionDate = filteredDateRange.end;
                                        firstTransactionDate = filteredDateRange.start;
                                        _filterType = TransactionType.all;
                                        if(context.mounted){
                                          context.read<TransactionCubit>().fetchTransactionsByDateRange(filteredDateRange.start, filteredDateRange.end);
                                        }
                                      }
                                    }
                                  ),
                                ],
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Switch(
                                    thumbIcon: WidgetStateProperty.all(
                                      Icon(
                                        context.watch<SettingsCubit>().state.isDarkMode
                                            ? Icons.dark_mode
                                            : Icons.light_mode,
                                      ),
                                    ),
                                    value: context.watch<SettingsCubit>().state.isDarkMode,
                                    onChanged: (v) => context.read<SettingsCubit>().toggleDarkMode(v),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.add_circle_outline, size: 54),
                                    onPressed: () async{
                                      final transaction = await showModalBottomSheet<TransactionModel>(
                                        context: context,
                                        isScrollControlled: true,
                                        showDragHandle: true,
                                        builder: (_) => const AddTransactionModal(),
                                      );
                                      if (transaction != null && context.mounted) {
                                        context.read<TransactionCubit>().addTransaction(transaction);
                                      }
                                    },
                                  )
                                ],
                              ),
                            ],
                          ),
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                              height: 44,
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                separatorBuilder: (_, __) => const SizedBox(width: 8),
                                itemCount: 3,
                                itemBuilder: (context, index) {
                                  final String label;
                                  final TransactionType? type;
                                  if (index == 0) {
                                    label = 'All';
                                    type = TransactionType.all;
                                  } else if (index == 1) {
                                    label = 'Income';
                                    type = TransactionType.income;
                                  } else {
                                    label = 'Expense';
                                    type = TransactionType.expense;
                                  }
                                  final selected = _filterType == type;
                                  return ChoiceChip(
                                    onSelected: (_) => setState(() {
                                      _filterType = type!;
                                      if (_filterType == TransactionType.all) {
                                        context.read<TransactionCubit>().fetchAllTransactions();
                                      } else {
                                        context.read<TransactionCubit>().fetchTransactionByType(_filterType);
                                      }
                                    }),
                                    selected: selected,
                                    label: Text(label, style: Theme.of(context).textTheme.labelSmall),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                        Expanded(
                          child: transactions.isEmpty
                              ? ListView(
                            children: [
                              SizedBox(
                                height: 120,
                                child: Center(
                                  child: Text('No transactions yet', style: Theme.of(context).textTheme.titleMedium),
                                ),
                              ),
                            ],
                          )
                              : ListView.builder(
                            itemCount: transactions.length,
                            itemBuilder: (context, index) {
                              final transaction = transactions[index];
                              return transactionTile(transaction: transaction);
                            },
                          ),
                        ),
                      ],
                    ),
            );
          },
        ),
      ),
    );
  }

  Widget transactionTile({required TransactionModel transaction}) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: EdgeInsets.all(5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Theme.of(context).dividerColor, width: 1),
      ),
      child: Slidable(
        /// Swipe left to open the edit and delete actions.
        endActionPane: ActionPane(
          motion: const DrawerMotion(),
          children: [
            SlidableAction(
              onPressed: (_) async {
                Slidable.of(context)?.close();
                final updatedTransaction = await showModalBottomSheet<TransactionModel>(
                  context: context,
                  isScrollControlled: true,
                  showDragHandle: true,
                  builder: (_) => AddTransactionModal(initialTransaction: transaction),
                );
                if (updatedTransaction != null && context.mounted) {
                  context.read<TransactionCubit>().updateTransaction(updatedTransaction);
                }
              },
              icon: Icons.edit,
              label: 'Edit',
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            SlidableAction(
              onPressed: (_) async {
                Slidable.of(context)?.close();
                final bool? delete = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('Delete transaction?', style: Theme.of(context).textTheme.titleMedium),
                    content: Text('This action cannot be undone.', style: Theme.of(context).textTheme.labelLarge),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: Text('Cancel', style: Theme.of(context).textTheme.labelLarge),
                      ),
                      OutlinedButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: Text('Delete', style: Theme.of(context).textTheme.labelLarge),
                      ),
                    ],
                  ),
                );
                if (delete != null && delete) {
                  context.read<TransactionCubit>().removeTransaction(transaction.id!);
                }
              },
              icon: Icons.delete,
              label: 'Delete',
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
          ],
        ),
        child: ListTile(
          leading: Icon(transaction.category.icon, size: 32),
          title: Text(transaction.category.label, style: Theme.of(context).textTheme.titleMedium),
          subtitle: Text(transaction.note, style: Theme.of(context).textTheme.labelMedium),
          trailing: Column(
            children: [
              Text(
                _money(transaction.amountCents),
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: transaction.transactionType == TransactionType.income ? Colors.green : Colors.red,
                ),
              ),
              Text(
                DateFormat('dd. MMM yyyy').format(transaction.transactionDate),
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
