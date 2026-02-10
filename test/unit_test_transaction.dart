import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:personal_finance_tracker/bloc/transaction/transaction_cubit.dart';
import 'package:personal_finance_tracker/data/models/categories.dart';
import 'package:personal_finance_tracker/data/models/transaction_model.dart';
import 'package:personal_finance_tracker/data/repo/transaction_repo.dart';
import 'package:test/test.dart';

class MockTransactionRepo extends Mock implements TransactionRepo {}

void main() {
  late TransactionRepo repo;

  // A real TransactionModel instances for fallback + helpers
  final fallbackTransactionIncome = TransactionModel(
    id: 1,
    amountCents: 1000,
    transactionDate: DateTime(2026, 1, 1),
    category: categoriesForType(TransactionType.income).first,
    note: 'fallback',
    transactionType: TransactionType.income,
  );

  final fallbackTransactionExpense = TransactionModel(
    id: 1,
    amountCents: 1000,
    transactionDate: DateTime(2026, 1, 1),
    category: categoriesForType(TransactionType.expense).first,
    note: 'fallback',
    transactionType: TransactionType.expense,
  );

  setUpAll(() {
    registerFallbackValue(fallbackTransactionIncome);
    registerFallbackValue(fallbackTransactionExpense);
  });

  setUp(() {
    repo = MockTransactionRepo();
  });

  TransactionModel transaction({
    int? id,
    required int amountCents,
    required DateTime date,
    required TransactionType type,
    TransactionCategory? category,
    String note = '',
  }) {
    return TransactionModel(
      id: id,
      amountCents: amountCents,
      transactionDate: date,
      category: category ?? categoriesForType(type).first,
      note: note,
      transactionType: type,
    );
  }

  group('TransactionCubit', () {
    test('Initial state is TransactionLoading?', () {
      final cubit = TransactionCubit(transactionRepo: repo);
      expect(cubit.state, const TransactionLoading());
      cubit.close();
    });

    blocTest<TransactionCubit, TransactionState>(
      'fetchAllTransactions emits [Loading, Loaded] on success?',
      build: () {
        when(() => repo.getAllTransactions()).thenAnswer((_) async => <TransactionModel>[]);
        return TransactionCubit(transactionRepo: repo);
      },
      act: (cubit) => cubit.fetchAllTransactions(),
      expect: () => const <TransactionState>[TransactionLoading(), TransactionLoaded(<TransactionModel>[])],
      verify: (_) => verify(() => repo.getAllTransactions()).called(1),
    );

    blocTest<TransactionCubit, TransactionState>(
      'fetchAllTransactions emits [Loading, Error] on failure?',
      build: () {
        when(() => repo.getAllTransactions()).thenThrow(Exception('failed'));
        return TransactionCubit(transactionRepo: repo);
      },
      act: (cubit) => cubit.fetchAllTransactions(),
      expect: () => [
        const TransactionLoading(),
        isA<TransactionError>().having((e) => e.errorMessage, 'errorMessage', contains('Failed to load:')),
      ],
    );

    blocTest<TransactionCubit, TransactionState>(
      'addTransaction emits Loaded with refreshed list on success?',
      build: () {
        when(
          () => repo.insertTransaction(any<TransactionModel>()),
        ).thenAnswer((_) async => fallbackTransactionIncome.copyWith(id: 254));
        when(() => repo.getAllTransactions()).thenAnswer((_) async => <TransactionModel>[]);

        return TransactionCubit(transactionRepo: repo);
      },
      act: (cubit) async {
        await cubit.addTransaction(
          transaction(amountCents: 250, date: DateTime(2026, 1, 2), type: TransactionType.expense, note: 'coffee'),
        );
      },
      expect: () => const <TransactionState>[TransactionLoaded(<TransactionModel>[])],
      verify: (_) {
        verify(() => repo.insertTransaction(any())).called(1);
        verify(() => repo.getAllTransactions()).called(1);
      },
    );

    blocTest<TransactionCubit, TransactionState>(
      'addTransaction emits Error then restores previous state when previous state is Loaded?',
      build: () {
        when(() => repo.insertTransaction(any())).thenThrow(Exception('failed'));
        return TransactionCubit(transactionRepo: repo);
      },
      seed: () => const TransactionLoaded(<TransactionModel>[]),
      act: (cubit) async {
        await cubit.addTransaction(fallbackTransactionIncome);
      },
      expect: () => [
        isA<TransactionError>().having((e) => e.errorMessage, 'errorMessage', contains('Failed to add:')),
        const TransactionLoaded(<TransactionModel>[]),
      ],
      verify: (_) {
        verify(() => repo.insertTransaction(any())).called(1);
        verifyNever(() => repo.getAllTransactions());
      },
    );

    blocTest<TransactionCubit, TransactionState>(
      'updateTransaction emits Loaded with refreshed list on success?',
      build: () {
        when(() => repo.updateTransaction(any())).thenAnswer((_) async {});
        when(() => repo.getAllTransactions()).thenAnswer((_) async => <TransactionModel>[]);

        return TransactionCubit(transactionRepo: repo);
      },
      act: (cubit) async {
        await cubit.updateTransaction(fallbackTransactionIncome.copyWith(note: 'updated'));
      },
      expect: () => const <TransactionState>[TransactionLoaded(<TransactionModel>[])],
      verify: (_) {
        verify(() => repo.updateTransaction(any())).called(1);
        verify(() => repo.getAllTransactions()).called(1);
      },
    );

    blocTest<TransactionCubit, TransactionState>(
      'updateTransaction emits Error then restores previous Loaded state on failure?',
      build: () {
        when(() => repo.updateTransaction(any())).thenThrow(Exception('failed'));
        return TransactionCubit(transactionRepo: repo);
      },
      seed: () => const TransactionLoaded(<TransactionModel>[]),
      act: (cubit) async {
        await cubit.updateTransaction(fallbackTransactionIncome);
      },
      expect: () => [
        isA<TransactionError>().having((e) => e.errorMessage, 'errorMessage', contains('Failed to add:')),
        const TransactionLoaded(<TransactionModel>[]),
      ],
      verify: (_) {
        verify(() => repo.updateTransaction(any())).called(1);
        verifyNever(() => repo.getAllTransactions());
      },
    );

    blocTest<TransactionCubit, TransactionState>(
      'removeTransaction emits Loaded with refreshed list on success?',
      build: () {
        when(() => repo.deleteTransactionById(any())).thenAnswer((_) async {});
        when(() => repo.getAllTransactions()).thenAnswer((_) async => <TransactionModel>[]);

        return TransactionCubit(transactionRepo: repo);
      },
      act: (cubit) => cubit.removeTransaction(123),
      expect: () => const <TransactionState>[TransactionLoaded(<TransactionModel>[])],
      verify: (_) {
        verify(() => repo.deleteTransactionById(123)).called(1);
        verify(() => repo.getAllTransactions()).called(1);
      },
    );

    blocTest<TransactionCubit, TransactionState>(
      'removeTransaction emits Error then restores previous Loaded state on failure?',
      build: () {
        when(() => repo.deleteTransactionById(any())).thenThrow(Exception('bad'));
        return TransactionCubit(transactionRepo: repo);
      },
      seed: () => const TransactionLoaded(<TransactionModel>[]),
      act: (cubit) => cubit.removeTransaction(123),
      expect: () => [
        isA<TransactionError>().having((e) => e.errorMessage, 'errorMessage', contains('Failed to add:')),
        const TransactionLoaded(<TransactionModel>[]),
      ],
      verify: (_) {
        verify(() => repo.deleteTransactionById(123)).called(1);
        verifyNever(() => repo.getAllTransactions());
      },
    );

    blocTest<TransactionCubit, TransactionState>(
      'fetchTransactionsByDateRange emits [Loading, Loaded] on success?',
      build: () {
        when(() => repo.fetchTransactionsByDateRange(any(), any())).thenAnswer((_) async => <TransactionModel>[]);

        return TransactionCubit(transactionRepo: repo);
      },
      act: (cubit) => cubit.fetchTransactionsByDateRange(DateTime(2026, 1, 1), DateTime(2026, 1, 31)),
      expect: () => const <TransactionState>[TransactionLoading(), TransactionLoaded(<TransactionModel>[])],
      verify: (_) {
        verify(() => repo.fetchTransactionsByDateRange(any(), any())).called(1);
      },
    );

    blocTest<TransactionCubit, TransactionState>(
      'fetchTransactionsByCategory emits [Loading, Loaded] on success?',
      build: () {
        final result = <TransactionModel>[];
        when(
          () => repo.fetchTransactionsByCategory(categoriesForType(TransactionType.income).first),
        ).thenAnswer((_) async => result);

        return TransactionCubit(transactionRepo: repo);
      },
      act: (cubit) => cubit.fetchTransactionsByCategory(categoriesForType(TransactionType.income).first),
      expect: () => [
        const TransactionLoading(),
        isA<TransactionLoaded>().having((s) => s.transactions, 'transactions', isEmpty),
      ],
      verify: (_) =>
          verify(() => repo.fetchTransactionsByCategory(categoriesForType(TransactionType.income).first)).called(1),
    );

    blocTest<TransactionCubit, TransactionState>(
      'fetchTransactionByType emits [Loading, Loaded] on success?',
      build: () {
        final result = <TransactionModel>[];
        when(() => repo.fetchTransactionsByType(TransactionType.expense)).thenAnswer((_) async => result);

        return TransactionCubit(transactionRepo: repo);
      },
      act: (cubit) => cubit.fetchTransactionByType(TransactionType.expense),
      expect: () => [
        const TransactionLoading(),
        isA<TransactionLoaded>().having((s) => s.transactions, 'transactions', isEmpty),
      ],
      verify: (_) => verify(() => repo.fetchTransactionsByType(TransactionType.expense)).called(1),
    );

    blocTest<TransactionCubit, TransactionState>(
      'fetchTransactionByType emits [Loading, Error] then restores previous Loaded state on failure?',
      build: () {
        when(() => repo.fetchTransactionsByType(TransactionType.expense)).thenThrow(Exception('bad'));
        return TransactionCubit(transactionRepo: repo);
      },
      seed: () => const TransactionLoaded(<TransactionModel>[]),
      act: (cubit) => cubit.fetchTransactionByType(TransactionType.expense),
      expect: () => [
        const TransactionLoading(),
        isA<TransactionError>().having((e) => e.errorMessage, 'errorMessage', contains('Failed to load:')),
        const TransactionLoaded(<TransactionModel>[]),
      ],
    );
  });

  group('TransactionLoaded computed getters', () {
    test('incomeCents / expenseCents / balanceCents are computed correctly?', () {
      final transactions = [
        transaction(amountCents: 1000, date: DateTime(2026, 1, 3), type: TransactionType.income, note: 'salary'),
        transaction(amountCents: 250, date: DateTime(2026, 1, 2), type: TransactionType.expense, note: 'coffee'),
        transaction(amountCents: 500, date: DateTime(2026, 1, 1), type: TransactionType.income, note: 'bonus'),
      ];

      final s = TransactionLoaded(transactions);
      expect(s.incomeCents, 1500);
      expect(s.expenseCents, 250);
      expect(s.balanceCents, 1250);
    });

    test('firstTransactionDate returns epoch when list is empty?', () {
      final s = const TransactionLoaded(<TransactionModel>[]);
      expect(s.firstTransactionDate, DateTime.fromMillisecondsSinceEpoch(0));
    });

    test('firstTransactionDate returns last transaction date (uses .last)?', () {
      final transactions = [
        transaction(amountCents: 100, date: DateTime(2026, 1, 1), type: TransactionType.expense),
        transaction(amountCents: 200, date: DateTime(2026, 1, 5), type: TransactionType.expense),
        transaction(amountCents: 300, date: DateTime(2026, 1, 3), type: TransactionType.income),
      ];

      final s = TransactionLoaded(transactions);

      // Your code uses transactions.last, not earliest date.
      expect(s.firstTransactionDate, DateTime(2026, 1, 3));
    });
  });
}
