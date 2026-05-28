import 'package:dartz/dartz.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/accounts/domain/entities/account_entity.dart';
import 'package:financo/features/bills/domain/entities/bill_entity.dart';
import 'package:financo/features/categories/domain/entities/category_entity.dart';
import 'package:financo/features/chat/domain/action_handlers/bill_chat_action_handler.dart';
import 'package:financo/gen/i18n/strings.g.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../harness/factories/account_factory.dart';
import '../../../../harness/factories/bill_factory.dart';
import '../../../../harness/factories/category_factory.dart';
import '../../../../harness/factories/transaction_factory.dart';
import '../../../../harness/helpers.dart';
import '../../../../harness/mocks.dart';

void main() {
  late MockGetBillsUseCase mockGetBills;
  late MockCreateBillUseCase mockCreateBill;
  late MockUpdateBillUseCase mockUpdateBill;
  late MockDeleteBillUseCase mockDeleteBill;
  late MockPayBillUseCase mockPayBill;
  late MockGetAccountsUseCase mockGetAccounts;
  late MockGetCategoriesUseCase mockGetCategories;
  late BillChatActionHandler handler;
  late AppLocale locale;

  const userId = 'user-1';

  setUpAll(() async {
    registerBillFallbackValues();
    // Bill success messages format the due date via intl DateFormat, which
    // needs locale data initialized in the test environment.
    await initializeDateFormatting();
  });

  setUp(() {
    mockGetBills = MockGetBillsUseCase();
    mockCreateBill = MockCreateBillUseCase();
    mockUpdateBill = MockUpdateBillUseCase();
    mockDeleteBill = MockDeleteBillUseCase();
    mockPayBill = MockPayBillUseCase();
    mockGetAccounts = MockGetAccountsUseCase();
    mockGetCategories = MockGetCategoriesUseCase();
    handler = BillChatActionHandler(
      getBills: mockGetBills,
      createBill: mockCreateBill,
      updateBill: mockUpdateBill,
      deleteBill: mockDeleteBill,
      payBill: mockPayBill,
      getAccounts: mockGetAccounts,
      getCategories: mockGetCategories,
    );
    locale = AppLocale.en;
  });

  Either<Failure, List<AccountEntity>> accountsRight(
    List<AccountEntity> accounts,
  ) => Right<Failure, List<AccountEntity>>(accounts);

  Either<Failure, List<CategoryEntity>> categoriesRight(
    List<CategoryEntity> categories,
  ) => Right<Failure, List<CategoryEntity>>(categories);

  Either<Failure, List<BillEntity>> billsRight(List<BillEntity> bills) =>
      Right<Failure, List<BillEntity>>(bills);

  void stubGetBills(List<BillEntity> bills) {
    when(
      () => mockGetBills(
        userId: any(named: 'userId'),
        status: any(named: 'status'),
        forceRefresh: any(named: 'forceRefresh'),
      ),
    ).thenAnswer((_) async => billsRight(bills));
  }

  void stubGetAccounts(List<AccountEntity> accounts) {
    when(
      () => mockGetAccounts(
        userId: any(named: 'userId'),
        forceRefresh: any(named: 'forceRefresh'),
      ),
    ).thenAnswer((_) async => accountsRight(accounts));
  }

  void stubGetCategories(List<CategoryEntity> categories) {
    when(
      () => mockGetCategories(
        userId: any(named: 'userId'),
        forceRefresh: any(named: 'forceRefresh'),
      ),
    ).thenAnswer((_) async => categoriesRight(categories));
  }

  group('handle dispatch', () {
    test('unknown action returns unknownBillAction message', () async {
      final result = await handler.handle(
        userId: userId,
        meta: const {'action': 'somethingElse'},
        locale: locale,
      );
      expect(result, 'Unknown bill action.');
      verifyNever(() => mockCreateBill(any()));
      verifyNever(() => mockPayBill(
            billId: any(named: 'billId'),
            accountId: any(named: 'accountId'),
            categoryId: any(named: 'categoryId'),
          ));
    });

    test('missing action falls through to unknownBillAction', () async {
      final result = await handler.handle(
        userId: userId,
        meta: const {},
        locale: locale,
      );
      expect(result, 'Unknown bill action.');
    });
  });

  group('create', () {
    test('builds bill from meta and returns success message', () async {
      when(() => mockCreateBill(any())).thenAnswer(
        (_) async => Right<Failure, BillEntity>(
          BillFactory.pending(amount: 99.9),
        ),
      );

      final result = await handler.handle(
        userId: userId,
        meta: const {
          'action': 'create',
          'description': 'Internet',
          'amount': 99.9,
          'dueDate': '2026-06-10',
          'recurrence': 'monthly',
          'type': 'payable',
          'notes': 'fiber plan',
        },
        locale: locale,
      );

      final captured = verify(() => mockCreateBill(captureAny())).captured;
      final bill = captured.first as BillEntity;
      expect(bill.userId, userId);
      expect(bill.description, 'Internet');
      expect(bill.amount, 99.9);
      expect(bill.dueDate, DateTime(2026, 6, 10));
      expect(bill.recurrence, BillRecurrence.monthly);
      expect(bill.type, BillType.payable);
      expect(bill.status, BillStatus.pending);
      expect(bill.notes, 'fiber plan');
      expect(result, contains('Internet'));
    });

    test('resolves categoryId by case-insensitive name match', () async {
      stubGetCategories([CategoryFactory.expense(id: 'cat-food')]);
      when(() => mockCreateBill(any())).thenAnswer(
        (_) async => Right<Failure, BillEntity>(BillFactory.pending()),
      );

      await handler.handle(
        userId: userId,
        meta: const {
          'action': 'create',
          'description': 'Lunch tab',
          'amount': 50,
          'category': 'food',
        },
        locale: locale,
      );

      final captured = verify(() => mockCreateBill(captureAny())).captured;
      final bill = captured.first as BillEntity;
      expect(bill.categoryId, 'cat-food');
    });

    test('receivable type is honoured when meta type is receivable', () async {
      when(() => mockCreateBill(any())).thenAnswer(
        (_) async => Right<Failure, BillEntity>(BillFactory.receivable()),
      );

      await handler.handle(
        userId: userId,
        meta: const {
          'action': 'create',
          'description': 'Salary',
          'amount': 5000,
          'type': 'receivable',
        },
        locale: locale,
      );

      final captured = verify(() => mockCreateBill(captureAny())).captured;
      final bill = captured.first as BillEntity;
      expect(bill.type, BillType.receivable);
    });

    test('empty description returns billDescriptionRequired', () async {
      final result = await handler.handle(
        userId: userId,
        meta: const {'action': 'create', 'description': '  ', 'amount': 10},
        locale: locale,
      );
      expect(result, isNotEmpty);
      verifyNever(() => mockCreateBill(any()));
    });

    test('non-positive amount returns billAmountInvalid', () async {
      final result = await handler.handle(
        userId: userId,
        meta: const {'action': 'create', 'description': 'X', 'amount': 0},
        locale: locale,
      );
      expect(result, isNotEmpty);
      verifyNever(() => mockCreateBill(any()));
    });

    test('createBill failure surfaces the failure message', () async {
      when(() => mockCreateBill(any())).thenAnswer(
        (_) async => const Left<Failure, BillEntity>(ServerFailure('boom')),
      );
      final result = await handler.handle(
        userId: userId,
        meta: const {'action': 'create', 'description': 'X', 'amount': 12},
        locale: locale,
      );
      expect(result, contains('boom'));
    });
  });

  group('update', () {
    test('updates existing pending bill and returns success', () async {
      stubGetBills([BillFactory.pending(id: 'bill-9', description: 'Old')]);
      when(() => mockUpdateBill(any())).thenAnswer(
        (_) async => Right<Failure, BillEntity>(
          BillFactory.pending(id: 'bill-9', description: 'New'),
        ),
      );

      final result = await handler.handle(
        userId: userId,
        meta: const {
          'action': 'update',
          'billId': 'bill-9',
          'description': 'New',
          'amount': 200,
        },
        locale: locale,
      );

      final captured = verify(() => mockUpdateBill(captureAny())).captured;
      final bill = captured.first as BillEntity;
      expect(bill.id, 'bill-9');
      expect(bill.description, 'New');
      expect(bill.amount, 200);
      expect(result, contains('New'));
    });

    test('missing billId returns billIdRequired', () async {
      final result = await handler.handle(
        userId: userId,
        meta: const {'action': 'update'},
        locale: locale,
      );
      expect(result, 'Bill id required.');
      verifyNever(() => mockUpdateBill(any()));
    });

    test('unknown billId returns billNotFound', () async {
      stubGetBills([BillFactory.pending(id: 'other')]);
      final result = await handler.handle(
        userId: userId,
        meta: const {'action': 'update', 'billId': 'missing'},
        locale: locale,
      );
      expect(result, 'Bill not found.');
      verifyNever(() => mockUpdateBill(any()));
    });

    test('paid bill cannot be edited', () async {
      stubGetBills([BillFactory.paid()]);
      final result = await handler.handle(
        userId: userId,
        meta: const {'action': 'update', 'billId': 'bill-paid'},
        locale: locale,
      );
      expect(result, isNotEmpty);
      verifyNever(() => mockUpdateBill(any()));
    });

    test('updateBill failure surfaces the failure message', () async {
      stubGetBills([BillFactory.pending(id: 'bill-9')]);
      when(() => mockUpdateBill(any())).thenAnswer(
        (_) async => const Left<Failure, BillEntity>(ServerFailure('nope')),
      );
      final result = await handler.handle(
        userId: userId,
        meta: const {'action': 'update', 'billId': 'bill-9'},
        locale: locale,
      );
      expect(result, contains('nope'));
    });
  });

  group('markPaid', () {
    test(
      'resolves first checking account + bill category and pays bill',
      () async {
        stubGetBills([
          BillFactory.pending(id: 'bill-7', categoryId: 'cat-bill'),
        ]);
        stubGetAccounts([
          AccountFactory.creditCard(id: 'acc-cc'),
          AccountFactory.checking(id: 'acc-chk-1', name: 'Primary'),
          AccountFactory.checking(id: 'acc-chk-2', name: 'Secondary'),
        ]);
        when(
          () => mockPayBill(
            billId: any(named: 'billId'),
            accountId: any(named: 'accountId'),
            categoryId: any(named: 'categoryId'),
          ),
        ).thenAnswer(
          (_) async => Right<Failure, BillPaymentResult>(
            BillPaymentResult(
              paidBill: BillFactory.paid(description: 'Rent'),
              transaction: TransactionFactory.expense(),
            ),
          ),
        );

        final result = await handler.handle(
          userId: userId,
          meta: const {'action': 'markPaid', 'billId': 'bill-7'},
          locale: locale,
        );

        final captured = verify(
          () => mockPayBill(
            billId: captureAny(named: 'billId'),
            accountId: captureAny(named: 'accountId'),
            categoryId: captureAny(named: 'categoryId'),
          ),
        ).captured;
        expect(captured[0], 'bill-7');
        // First checking account in the list (credit card is skipped).
        expect(captured[1], 'acc-chk-1');
        // Bill already had a category — no category lookup needed.
        expect(captured[2], 'cat-bill');
        expect(result, contains('Rent'));
        verifyNever(
          () => mockGetCategories(
            userId: any(named: 'userId'),
            forceRefresh: any(named: 'forceRefresh'),
          ),
        );
      },
    );

    test(
      'resolves first expense category when bill has no category',
      () async {
        stubGetBills([
          BillFactory.pending(id: 'bill-8', categoryId: null),
        ]);
        stubGetAccounts([AccountFactory.checking(id: 'acc-chk-1')]);
        stubGetCategories([
          CategoryFactory.income(id: 'cat-inc'),
          CategoryFactory.expense(id: 'cat-exp-first'),
          CategoryFactory.expense(id: 'cat-exp-second'),
        ]);
        when(
          () => mockPayBill(
            billId: any(named: 'billId'),
            accountId: any(named: 'accountId'),
            categoryId: any(named: 'categoryId'),
          ),
        ).thenAnswer(
          (_) async => Right<Failure, BillPaymentResult>(
            BillPaymentResult(
              paidBill: BillFactory.paid(description: 'Water'),
              transaction: TransactionFactory.expense(),
            ),
          ),
        );

        await handler.handle(
          userId: userId,
          meta: const {'action': 'markPaid', 'billId': 'bill-8'},
          locale: locale,
        );

        final captured = verify(
          () => mockPayBill(
            billId: captureAny(named: 'billId'),
            accountId: captureAny(named: 'accountId'),
            categoryId: captureAny(named: 'categoryId'),
          ),
        ).captured;
        expect(captured[2], 'cat-exp-first');
      },
    );

    test(
      'resolves first income category for a receivable bill',
      () async {
        stubGetBills([
          BillFactory.receivable(id: 'bill-rec'),
        ]);
        stubGetAccounts([AccountFactory.checking(id: 'acc-chk-1')]);
        stubGetCategories([
          CategoryFactory.expense(id: 'cat-exp'),
          CategoryFactory.income(id: 'cat-inc-first'),
        ]);
        when(
          () => mockPayBill(
            billId: any(named: 'billId'),
            accountId: any(named: 'accountId'),
            categoryId: any(named: 'categoryId'),
          ),
        ).thenAnswer(
          (_) async => Right<Failure, BillPaymentResult>(
            BillPaymentResult(
              paidBill: BillFactory.paid(description: 'Salary'),
              transaction: TransactionFactory.income(),
            ),
          ),
        );

        await handler.handle(
          userId: userId,
          meta: const {'action': 'markPaid', 'billId': 'bill-rec'},
          locale: locale,
        );

        final captured = verify(
          () => mockPayBill(
            billId: captureAny(named: 'billId'),
            accountId: captureAny(named: 'accountId'),
            categoryId: captureAny(named: 'categoryId'),
          ),
        ).captured;
        expect(captured[2], 'cat-inc-first');
      },
    );

    test('includes next occurrence in message when present', () async {
      stubGetBills([
        BillFactory.pending(id: 'bill-m', categoryId: 'cat-bill'),
      ]);
      stubGetAccounts([AccountFactory.checking(id: 'acc-chk-1')]);
      when(
        () => mockPayBill(
          billId: any(named: 'billId'),
          accountId: any(named: 'accountId'),
          categoryId: any(named: 'categoryId'),
        ),
      ).thenAnswer(
        (_) async => Right<Failure, BillPaymentResult>(
          BillPaymentResult(
            paidBill: BillFactory.paid(description: 'Internet'),
            transaction: TransactionFactory.expense(),
            nextOccurrence: BillFactory.monthly(
              dueDate: DateTime(2026, 7, 30),
            ),
          ),
        ),
      );

      final result = await handler.handle(
        userId: userId,
        meta: const {'action': 'markPaid', 'billId': 'bill-m'},
        locale: locale,
      );
      expect(result, contains('Internet'));
      expect(result, contains('Next occurrence'));
    });

    test('missing billId returns billIdRequired', () async {
      final result = await handler.handle(
        userId: userId,
        meta: const {'action': 'markPaid'},
        locale: locale,
      );
      expect(result, 'Bill id required.');
    });

    test('unknown billId returns billNotFound', () async {
      stubGetBills([BillFactory.pending(id: 'other')]);
      final result = await handler.handle(
        userId: userId,
        meta: const {'action': 'markPaid', 'billId': 'missing'},
        locale: locale,
      );
      expect(result, 'Bill not found.');
    });

    test('already-paid bill returns billAlreadyPaid', () async {
      stubGetBills([BillFactory.paid()]);
      final result = await handler.handle(
        userId: userId,
        meta: const {'action': 'markPaid', 'billId': 'bill-paid'},
        locale: locale,
      );
      expect(result, 'Bill is already paid.');
      verifyNever(
        () => mockPayBill(
          billId: any(named: 'billId'),
          accountId: any(named: 'accountId'),
          categoryId: any(named: 'categoryId'),
        ),
      );
    });

    test('no checking account returns billNoCheckingAccount', () async {
      stubGetBills([BillFactory.pending(id: 'bill-7')]);
      stubGetAccounts([AccountFactory.creditCard(id: 'acc-cc')]);
      final result = await handler.handle(
        userId: userId,
        meta: const {'action': 'markPaid', 'billId': 'bill-7'},
        locale: locale,
      );
      expect(result, 'No checking account available to register the payment.');
      verifyNever(
        () => mockPayBill(
          billId: any(named: 'billId'),
          accountId: any(named: 'accountId'),
          categoryId: any(named: 'categoryId'),
        ),
      );
    });

    test('no expense category returns billNoExpenseCategory', () async {
      stubGetBills([BillFactory.pending(id: 'bill-8', categoryId: null)]);
      stubGetAccounts([AccountFactory.checking(id: 'acc-chk-1')]);
      stubGetCategories([CategoryFactory.income(id: 'cat-inc')]);
      final result = await handler.handle(
        userId: userId,
        meta: const {'action': 'markPaid', 'billId': 'bill-8'},
        locale: locale,
      );
      expect(result, 'No expense category available to register the payment.');
      verifyNever(
        () => mockPayBill(
          billId: any(named: 'billId'),
          accountId: any(named: 'accountId'),
          categoryId: any(named: 'categoryId'),
        ),
      );
    });

    test('no income category returns billNoIncomeCategory', () async {
      stubGetBills([
        BillFactory.receivable(id: 'bill-rec'),
      ]);
      stubGetAccounts([AccountFactory.checking(id: 'acc-chk-1')]);
      stubGetCategories([CategoryFactory.expense(id: 'cat-exp')]);
      final result = await handler.handle(
        userId: userId,
        meta: const {'action': 'markPaid', 'billId': 'bill-rec'},
        locale: locale,
      );
      expect(result, 'No income category available to register the payment.');
    });

    test('payBill failure surfaces the failure message', () async {
      stubGetBills([
        BillFactory.pending(id: 'bill-7', categoryId: 'cat-bill'),
      ]);
      stubGetAccounts([AccountFactory.checking(id: 'acc-chk-1')]);
      when(
        () => mockPayBill(
          billId: any(named: 'billId'),
          accountId: any(named: 'accountId'),
          categoryId: any(named: 'categoryId'),
        ),
      ).thenAnswer(
        (_) async =>
            const Left<Failure, BillPaymentResult>(ServerFailure('pay failed')),
      );

      final result = await handler.handle(
        userId: userId,
        meta: const {'action': 'markPaid', 'billId': 'bill-7'},
        locale: locale,
      );
      expect(result, contains('pay failed'));
    });
  });

  group('delete', () {
    test('deletes by billId and returns success', () async {
      when(() => mockDeleteBill(any())).thenAnswer(
        (_) async => const Right<Failure, void>(null),
      );
      final result = await handler.handle(
        userId: userId,
        meta: const {'action': 'delete', 'billId': 'bill-3'},
        locale: locale,
      );
      final captured = verify(() => mockDeleteBill(captureAny())).captured;
      expect(captured.first, 'bill-3');
      expect(result, 'Bill deleted.');
    });

    test('missing billId returns billIdRequired', () async {
      final result = await handler.handle(
        userId: userId,
        meta: const {'action': 'delete'},
        locale: locale,
      );
      expect(result, 'Bill id required.');
      verifyNever(() => mockDeleteBill(any()));
    });

    test('deleteBill failure surfaces the failure message', () async {
      when(() => mockDeleteBill(any())).thenAnswer(
        (_) async => const Left<Failure, void>(ServerFailure('del error')),
      );
      final result = await handler.handle(
        userId: userId,
        meta: const {'action': 'delete', 'billId': 'bill-3'},
        locale: locale,
      );
      expect(result, contains('del error'));
    });
  });
}
