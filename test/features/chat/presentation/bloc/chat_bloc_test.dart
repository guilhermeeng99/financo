import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/accounts/domain/entities/account_entity.dart';
import 'package:financo/features/categories/domain/entities/category_entity.dart';
import 'package:financo/features/chat/domain/entities/chat_message_entity.dart';
import 'package:financo/features/chat/presentation/bloc/chat_bloc.dart';
import 'package:financo/features/transactions/domain/entities/transaction_entity.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../harness/factories/account_factory.dart';
import '../../../../harness/factories/chat_message_factory.dart';
import '../../../../harness/helpers.dart';
import '../../../../harness/mocks.dart';

void main() {
  late MockSendMessageUseCase mockSendMessage;
  late MockGetChatHistoryUseCase mockGetChatHistory;
  late MockSaveChatMessageUseCase mockSaveChatMessage;
  late MockCreateAccountUseCase mockCreateAccount;
  late MockGetAccountsUseCase mockGetAccounts;
  late MockDeleteAccountUseCase mockDeleteAccount;
  late MockCreateCategoryUseCase mockCreateCategory;
  late MockGetCategoriesUseCase mockGetCategories;
  late MockDeleteCategoryUseCase mockDeleteCategory;
  late MockCreateTransactionUseCase mockCreateTransaction;

  const userId = 'user-1';

  setUpAll(() {
    registerChatFallbackValues();
    registerAccountFallbackValues();
    registerCategoryFallbackValues();
    registerTransactionFallbackValues();
  });

  setUp(() {
    mockSendMessage = MockSendMessageUseCase();
    mockGetChatHistory = MockGetChatHistoryUseCase();
    mockSaveChatMessage = MockSaveChatMessageUseCase();
    mockCreateAccount = MockCreateAccountUseCase();
    mockGetAccounts = MockGetAccountsUseCase();
    mockDeleteAccount = MockDeleteAccountUseCase();
    mockCreateCategory = MockCreateCategoryUseCase();
    mockGetCategories = MockGetCategoriesUseCase();
    mockDeleteCategory = MockDeleteCategoryUseCase();
    mockCreateTransaction = MockCreateTransactionUseCase();
  });

  ChatBloc buildBloc() => ChatBloc(
    sendMessage: mockSendMessage,
    getChatHistory: mockGetChatHistory,
    saveChatMessage: mockSaveChatMessage,
    createAccount: mockCreateAccount,
    getAccounts: mockGetAccounts,
    deleteAccount: mockDeleteAccount,
    createCategory: mockCreateCategory,
    getCategories: mockGetCategories,
    deleteCategory: mockDeleteCategory,
    createTransaction: mockCreateTransaction,
    userId: userId,
  );

  test('initial state is ChatInitial', () {
    final bloc = buildBloc();
    expect(bloc.state, const ChatInitial());
    addTearDown(bloc.close);
  });

  group('ChatLoadRequested', () {
    final messages = ChatMessageFactory.history();

    blocTest<ChatBloc, ChatState>(
      'emits [Loading, Loaded] on success',
      build: buildBloc,
      setUp: () {
        when(
          () => mockGetChatHistory(userId: any(named: 'userId')),
        ).thenAnswer(
          (_) async => Right<Failure, List<ChatMessageEntity>>(messages),
        );
      },
      act: (bloc) => bloc.add(const ChatLoadRequested()),
      expect: () => [
        const ChatLoading(),
        isA<ChatLoaded>().having(
          (s) => s.messages.length,
          'messages.length',
          messages.length,
        ),
      ],
    );

    blocTest<ChatBloc, ChatState>(
      'emits [Loading, Error] on failure',
      build: buildBloc,
      setUp: () {
        when(
          () => mockGetChatHistory(userId: any(named: 'userId')),
        ).thenAnswer(
          (_) async => const Left<Failure, List<ChatMessageEntity>>(
            ServerFailure(),
          ),
        );
      },
      act: (bloc) => bloc.add(const ChatLoadRequested()),
      expect: () => [
        const ChatLoading(),
        isA<ChatError>(),
      ],
    );
  });

  group('ChatMessageSent', () {
    blocTest<ChatBloc, ChatState>(
      'emits Loaded with user message + AI response on success',
      build: buildBloc,
      setUp: () {
        when(
          () => mockSaveChatMessage(any()),
        ).thenAnswer(
          (_) async => const Right<Failure, void>(null),
        );
        when(
          () => mockSendMessage(
            userId: any(named: 'userId'),
            content: any(named: 'content'),
            history: any(named: 'history'),
          ),
        ).thenAnswer(
          (_) async => Right<Failure, ChatMessageEntity>(
            ChatMessageFactory.assistant(content: 'AI response'),
          ),
        );
      },
      act: (bloc) => bloc.add(const ChatMessageSent('Hello')),
      expect: () => [
        isA<ChatLoaded>()
            .having((s) => s.isTyping, 'isTyping', true)
            .having(
              (s) => s.messages.length,
              'messages.length',
              1,
            ),
        isA<ChatLoaded>()
            .having((s) => s.isTyping, 'isTyping', false)
            .having(
              (s) => s.messages.length,
              'messages.length',
              2,
            ),
      ],
    );

    blocTest<ChatBloc, ChatState>(
      'emits Loaded with error message on AI failure',
      build: buildBloc,
      setUp: () {
        when(
          () => mockSaveChatMessage(any()),
        ).thenAnswer(
          (_) async => const Right<Failure, void>(null),
        );
        when(
          () => mockSendMessage(
            userId: any(named: 'userId'),
            content: any(named: 'content'),
            history: any(named: 'history'),
          ),
        ).thenAnswer(
          (_) async => const Left<Failure, ChatMessageEntity>(
            AiFailure('Something went wrong'),
          ),
        );
      },
      act: (bloc) => bloc.add(const ChatMessageSent('Hello')),
      expect: () => [
        isA<ChatLoaded>().having(
          (s) => s.isTyping,
          'isTyping',
          true,
        ),
        isA<ChatLoaded>().having(
          (s) => s.messages.last.content,
          'error message',
          contains('could not process'),
        ),
      ],
    );

    blocTest<ChatBloc, ChatState>(
      'shows quota message when rate limited',
      build: buildBloc,
      setUp: () {
        when(
          () => mockSaveChatMessage(any()),
        ).thenAnswer(
          (_) async => const Right<Failure, void>(null),
        );
        when(
          () => mockSendMessage(
            userId: any(named: 'userId'),
            content: any(named: 'content'),
            history: any(named: 'history'),
          ),
        ).thenAnswer(
          (_) async => const Left<Failure, ChatMessageEntity>(
            AiFailure('Resource exhausted: quota exceeded'),
          ),
        );
      },
      act: (bloc) => bloc.add(const ChatMessageSent('Hello')),
      expect: () => [
        isA<ChatLoaded>(),
        isA<ChatLoaded>().having(
          (s) => s.messages.last.content,
          'quota message',
          contains('rate limits'),
        ),
      ],
    );
  });

  group('ChatActionConfirmed', () {
    group('account create', () {
      blocTest<ChatBloc, ChatState>(
        'emits Loaded with success message',
        build: buildBloc,
        setUp: () {
          when(
            () => mockCreateAccount(any()),
          ).thenAnswer(
            (_) async => Right<Failure, AccountEntity>(
              AccountFactory.checking(name: 'Nubank Gui'),
            ),
          );
          when(
            () => mockSaveChatMessage(any()),
          ).thenAnswer(
            (_) async => const Right<Failure, void>(null),
          );
        },
        act: (bloc) => bloc.add(
          const ChatActionConfirmed({
            'actionType': 'account',
            'action': 'create',
            'name': 'Nubank Gui',
            'type': 'checking',
            'bank': 'nubank',
            'balance': 1000,
          }),
        ),
        expect: () => [
          isA<ChatLoaded>().having(
            (s) => s.messages.last.content,
            'success',
            contains('created successfully'),
          ),
        ],
      );

      blocTest<ChatBloc, ChatState>(
        'creates credit card with all fields',
        build: buildBloc,
        setUp: () {
          when(
            () => mockGetAccounts(
              userId: any(named: 'userId'),
              forceRefresh: any(named: 'forceRefresh'),
            ),
          ).thenAnswer(
            (_) async => Right<Failure, List<AccountEntity>>(
              [AccountFactory.checking(name: 'Nubank Gui')],
            ),
          );
          when(
            () => mockCreateAccount(any()),
          ).thenAnswer(
            (_) async => Right<Failure, AccountEntity>(
              AccountFactory.creditCard(name: 'Nubank CC'),
            ),
          );
          when(
            () => mockSaveChatMessage(any()),
          ).thenAnswer(
            (_) async => const Right<Failure, void>(null),
          );
        },
        act: (bloc) => bloc.add(
          const ChatActionConfirmed({
            'actionType': 'account',
            'action': 'create',
            'name': 'Nubank CC',
            'type': 'creditCard',
            'bank': 'nubank',
            'balance': 0,
            'creditLimit': 5000.0,
            'closingDay': 5,
            'dueDay': 15,
            'linkedAccountName': 'Nubank Gui',
          }),
        ),
        verify: (_) {
          final captured = verify(
            () => mockCreateAccount(captureAny()),
          ).captured;
          final account = captured.first as AccountEntity;
          expect(account.type, AccountType.creditCard);
          expect(account.creditLimit, 5000.0);
          expect(account.closingDay, 5);
          expect(account.dueDay, 15);
          expect(account.linkedAccountId, 'acc-checking-1');
        },
      );
    });

    group('account delete', () {
      blocTest<ChatBloc, ChatState>(
        'deletes account found by name',
        build: buildBloc,
        setUp: () {
          when(
            () => mockGetAccounts(
              userId: any(named: 'userId'),
              forceRefresh: any(named: 'forceRefresh'),
            ),
          ).thenAnswer(
            (_) async => Right<Failure, List<AccountEntity>>(
              [AccountFactory.checking(name: 'Nubank Gui')],
            ),
          );
          when(
            () => mockDeleteAccount(any()),
          ).thenAnswer(
            (_) async => const Right<Failure, void>(null),
          );
          when(
            () => mockSaveChatMessage(any()),
          ).thenAnswer(
            (_) async => const Right<Failure, void>(null),
          );
        },
        act: (bloc) => bloc.add(
          const ChatActionConfirmed({
            'actionType': 'account',
            'action': 'delete',
            'name': 'Nubank Gui',
          }),
        ),
        expect: () => [
          isA<ChatLoaded>().having(
            (s) => s.messages.last.content,
            'success',
            contains('deleted successfully'),
          ),
        ],
      );

      blocTest<ChatBloc, ChatState>(
        'returns not found when account name does not match',
        build: buildBloc,
        setUp: () {
          when(
            () => mockGetAccounts(
              userId: any(named: 'userId'),
              forceRefresh: any(named: 'forceRefresh'),
            ),
          ).thenAnswer(
            (_) async => Right<Failure, List<AccountEntity>>(
              [AccountFactory.checking(name: 'Other')],
            ),
          );
          when(
            () => mockSaveChatMessage(any()),
          ).thenAnswer(
            (_) async => const Right<Failure, void>(null),
          );
        },
        act: (bloc) => bloc.add(
          const ChatActionConfirmed({
            'actionType': 'account',
            'action': 'delete',
            'name': 'Nonexistent',
          }),
        ),
        expect: () => [
          isA<ChatLoaded>().having(
            (s) => s.messages.last.content,
            'not found',
            contains('No account named'),
          ),
        ],
      );
    });

    group('category create', () {
      blocTest<ChatBloc, ChatState>(
        'emits Loaded with success message',
        build: buildBloc,
        setUp: () {
          when(
            () => mockGetCategories(
              userId: any(named: 'userId'),
              forceRefresh: any(named: 'forceRefresh'),
            ),
          ).thenAnswer(
            (_) async => const Right<Failure, List<CategoryEntity>>([]),
          );
          when(
            () => mockCreateCategory(any()),
          ).thenAnswer(
            (_) async => const Right<Failure, CategoryEntity>(
              CategoryEntity(
                id: 'cat-1',
                userId: userId,
                name: 'Groceries',
                icon: 58332,
                color: 4294198070,
                type: CategoryType.expense,
              ),
            ),
          );
          when(
            () => mockSaveChatMessage(any()),
          ).thenAnswer(
            (_) async => const Right<Failure, void>(null),
          );
        },
        act: (bloc) => bloc.add(
          const ChatActionConfirmed({
            'actionType': 'category',
            'action': 'create',
            'name': 'Groceries',
            'type': 'expense',
          }),
        ),
        expect: () => [
          isA<ChatLoaded>().having(
            (s) => s.messages.last.content,
            'success',
            contains('created successfully'),
          ),
        ],
      );
    });

    group('category delete', () {
      blocTest<ChatBloc, ChatState>(
        'deletes category found by name',
        build: buildBloc,
        setUp: () {
          when(
            () => mockGetCategories(
              userId: any(named: 'userId'),
              forceRefresh: any(named: 'forceRefresh'),
            ),
          ).thenAnswer(
            (_) async => const Right<Failure, List<CategoryEntity>>(
              [
                CategoryEntity(
                  id: 'cat-1',
                  name: 'Food',
                  icon: 58332,
                  color: 4280391411,
                  type: CategoryType.expense,
                ),
              ],
            ),
          );
          when(
            () => mockDeleteCategory(any()),
          ).thenAnswer(
            (_) async => const Right<Failure, void>(null),
          );
          when(
            () => mockSaveChatMessage(any()),
          ).thenAnswer(
            (_) async => const Right<Failure, void>(null),
          );
        },
        act: (bloc) => bloc.add(
          const ChatActionConfirmed({
            'actionType': 'category',
            'action': 'delete',
            'name': 'Food',
          }),
        ),
        expect: () => [
          isA<ChatLoaded>().having(
            (s) => s.messages.last.content,
            'success',
            contains('deleted successfully'),
          ),
        ],
      );

      blocTest<ChatBloc, ChatState>(
        'returns not found when category name does not match',
        build: buildBloc,
        setUp: () {
          when(
            () => mockGetCategories(
              userId: any(named: 'userId'),
              forceRefresh: any(named: 'forceRefresh'),
            ),
          ).thenAnswer(
            (_) async => const Right<Failure, List<CategoryEntity>>([]),
          );
          when(
            () => mockSaveChatMessage(any()),
          ).thenAnswer(
            (_) async => const Right<Failure, void>(null),
          );
        },
        act: (bloc) => bloc.add(
          const ChatActionConfirmed({
            'actionType': 'category',
            'action': 'delete',
            'name': 'Nonexistent',
          }),
        ),
        expect: () => [
          isA<ChatLoaded>().having(
            (s) => s.messages.last.content,
            'not found',
            contains('No category named'),
          ),
        ],
      );
    });

    group('transaction create', () {
      blocTest<ChatBloc, ChatState>(
        'emits Loaded with success and shouldRefreshTransactions',
        build: buildBloc,
        setUp: () {
          when(
            () => mockGetCategories(
              userId: any(named: 'userId'),
              forceRefresh: any(named: 'forceRefresh'),
            ),
          ).thenAnswer(
            (_) async => const Right<Failure, List<CategoryEntity>>(
              [
                CategoryEntity(
                  id: 'cat-1',
                  name: 'Food',
                  icon: 58332,
                  color: 4280391411,
                  type: CategoryType.expense,
                ),
              ],
            ),
          );
          when(
            () => mockGetAccounts(
              userId: any(named: 'userId'),
              forceRefresh: any(named: 'forceRefresh'),
            ),
          ).thenAnswer(
            (_) async => Right<Failure, List<AccountEntity>>(
              [AccountFactory.checking(name: 'Nubank Gui')],
            ),
          );
          when(
            () => mockCreateTransaction(any()),
          ).thenAnswer(
            (_) async => Right<Failure, TransactionEntity>(
              TransactionEntity(
                id: 'tx-1',
                userId: userId,
                accountId: 'acc-checking-1',
                categoryId: 'cat-1',
                type: TransactionType.expense,
                amount: 50,
                description: 'Lunch',
                date: DateTime(2024),
                createdAt: DateTime(2024),
                updatedAt: DateTime(2024),
              ),
            ),
          );
          when(
            () => mockSaveChatMessage(any()),
          ).thenAnswer(
            (_) async => const Right<Failure, void>(null),
          );
        },
        act: (bloc) => bloc.add(
          const ChatActionConfirmed({
            'actionType': 'transaction',
            'action': 'create',
            'type': 'expense',
            'amount': 50.0,
            'category': 'Food',
            'account': 'Nubank Gui',
            'description': 'Lunch',
            'date': '2024-01-01',
          }),
        ),
        expect: () => [
          isA<ChatLoaded>()
              .having(
                (s) => s.shouldRefreshTransactions,
                'shouldRefreshTransactions',
                true,
              )
              .having(
                (s) => s.messages.last.content,
                'success',
                contains('created successfully'),
              ),
        ],
      );

      blocTest<ChatBloc, ChatState>(
        'returns error when category not found',
        build: buildBloc,
        setUp: () {
          when(
            () => mockGetCategories(
              userId: any(named: 'userId'),
              forceRefresh: any(named: 'forceRefresh'),
            ),
          ).thenAnswer(
            (_) async => const Right<Failure, List<CategoryEntity>>([]),
          );
          when(
            () => mockSaveChatMessage(any()),
          ).thenAnswer(
            (_) async => const Right<Failure, void>(null),
          );
        },
        act: (bloc) => bloc.add(
          const ChatActionConfirmed({
            'actionType': 'transaction',
            'type': 'expense',
            'amount': 50.0,
            'category': 'Unknown',
            'description': 'Test',
          }),
        ),
        expect: () => [
          isA<ChatLoaded>().having(
            (s) => s.messages.last.content,
            'not found',
            contains('not found'),
          ),
        ],
      );

      blocTest<ChatBloc, ChatState>(
        'returns error when no accounts exist',
        build: buildBloc,
        setUp: () {
          when(
            () => mockGetCategories(
              userId: any(named: 'userId'),
              forceRefresh: any(named: 'forceRefresh'),
            ),
          ).thenAnswer(
            (_) async => const Right<Failure, List<CategoryEntity>>(
              [
                CategoryEntity(
                  id: 'cat-1',
                  name: 'Food',
                  icon: 58332,
                  color: 4280391411,
                  type: CategoryType.expense,
                ),
              ],
            ),
          );
          when(
            () => mockGetAccounts(
              userId: any(named: 'userId'),
              forceRefresh: any(named: 'forceRefresh'),
            ),
          ).thenAnswer(
            (_) async => const Right<Failure, List<AccountEntity>>([]),
          );
          when(
            () => mockSaveChatMessage(any()),
          ).thenAnswer(
            (_) async => const Right<Failure, void>(null),
          );
        },
        act: (bloc) => bloc.add(
          const ChatActionConfirmed({
            'actionType': 'transaction',
            'type': 'expense',
            'amount': 50.0,
            'category': 'Food',
            'description': 'Test',
          }),
        ),
        expect: () => [
          isA<ChatLoaded>().having(
            (s) => s.messages.last.content,
            'no accounts',
            contains('No accounts found'),
          ),
        ],
      );

      blocTest<ChatBloc, ChatState>(
        'returns error for invalid amount',
        build: buildBloc,
        setUp: () {
          when(
            () => mockSaveChatMessage(any()),
          ).thenAnswer(
            (_) async => const Right<Failure, void>(null),
          );
        },
        act: (bloc) => bloc.add(
          const ChatActionConfirmed({
            'actionType': 'transaction',
            'type': 'expense',
            'amount': 0,
            'category': 'Food',
          }),
        ),
        expect: () => [
          isA<ChatLoaded>().having(
            (s) => s.messages.last.content,
            'invalid amount',
            'Invalid amount.',
          ),
        ],
      );
    });

    blocTest<ChatBloc, ChatState>(
      'returns unknown action type for invalid actionType',
      build: buildBloc,
      setUp: () {
        when(
          () => mockSaveChatMessage(any()),
        ).thenAnswer(
          (_) async => const Right<Failure, void>(null),
        );
      },
      act: (bloc) => bloc.add(
        const ChatActionConfirmed({
          'actionType': 'invalid',
        }),
      ),
      expect: () => [
        isA<ChatLoaded>().having(
          (s) => s.messages.last.content,
          'unknown',
          'Unknown action type.',
        ),
      ],
    );

    blocTest<ChatBloc, ChatState>(
      'save failure is non-blocking — state still emitted',
      build: buildBloc,
      setUp: () {
        when(
          () => mockSaveChatMessage(any()),
        ).thenThrow(Exception('Save failed'));
      },
      act: (bloc) => bloc.add(
        const ChatActionConfirmed({
          'actionType': 'invalid',
        }),
      ),
      expect: () => [
        isA<ChatLoaded>().having(
          (s) => s.messages.last.content,
          'still emitted',
          'Unknown action type.',
        ),
      ],
    );

    group('account action failures', () {
      blocTest<ChatBloc, ChatState>(
        'returns error when createAccount fails',
        build: buildBloc,
        setUp: () {
          when(
            () => mockCreateAccount(any()),
          ).thenAnswer(
            (_) async =>
                const Left<Failure, AccountEntity>(ServerFailure('DB error')),
          );
          when(
            () => mockSaveChatMessage(any()),
          ).thenAnswer(
            (_) async => const Right<Failure, void>(null),
          );
        },
        act: (bloc) => bloc.add(
          const ChatActionConfirmed({
            'actionType': 'account',
            'action': 'create',
            'name': 'Test Account',
            'type': 'checking',
          }),
        ),
        expect: () => [
          isA<ChatLoaded>().having(
            (s) => s.messages.last.content,
            'create failed',
            contains('Failed to create account'),
          ),
        ],
      );

      blocTest<ChatBloc, ChatState>(
        'returns error when deleteAccount fails',
        build: buildBloc,
        setUp: () {
          when(
            () => mockGetAccounts(
              userId: any(named: 'userId'),
              forceRefresh: any(named: 'forceRefresh'),
            ),
          ).thenAnswer(
            (_) async => Right<Failure, List<AccountEntity>>(
              [AccountFactory.checking(name: 'Nubank')],
            ),
          );
          when(
            () => mockDeleteAccount(any()),
          ).thenAnswer(
            (_) async =>
                const Left<Failure, void>(ServerFailure('Delete error')),
          );
          when(
            () => mockSaveChatMessage(any()),
          ).thenAnswer(
            (_) async => const Right<Failure, void>(null),
          );
        },
        act: (bloc) => bloc.add(
          const ChatActionConfirmed({
            'actionType': 'account',
            'action': 'delete',
            'name': 'Nubank',
          }),
        ),
        expect: () => [
          isA<ChatLoaded>().having(
            (s) => s.messages.last.content,
            'delete failed',
            contains('Failed to delete account'),
          ),
        ],
      );

      blocTest<ChatBloc, ChatState>(
        'returns error when getAccounts fails on delete',
        build: buildBloc,
        setUp: () {
          when(
            () => mockGetAccounts(
              userId: any(named: 'userId'),
              forceRefresh: any(named: 'forceRefresh'),
            ),
          ).thenAnswer(
            (_) async => const Left<Failure, List<AccountEntity>>(
              ServerFailure('Network error'),
            ),
          );
          when(
            () => mockSaveChatMessage(any()),
          ).thenAnswer(
            (_) async => const Right<Failure, void>(null),
          );
        },
        act: (bloc) => bloc.add(
          const ChatActionConfirmed({
            'actionType': 'account',
            'action': 'delete',
            'name': 'Nubank',
          }),
        ),
        expect: () => [
          isA<ChatLoaded>().having(
            (s) => s.messages.last.content,
            'find failed',
            contains('Failed to find account'),
          ),
        ],
      );

      blocTest<ChatBloc, ChatState>(
        'returns unknown account action for unrecognized action',
        build: buildBloc,
        setUp: () {
          when(
            () => mockSaveChatMessage(any()),
          ).thenAnswer(
            (_) async => const Right<Failure, void>(null),
          );
        },
        act: (bloc) => bloc.add(
          const ChatActionConfirmed({
            'actionType': 'account',
            'action': 'update',
          }),
        ),
        expect: () => [
          isA<ChatLoaded>().having(
            (s) => s.messages.last.content,
            'unknown action',
            'Unknown account action.',
          ),
        ],
      );
    });

    group('category action failures', () {
      blocTest<ChatBloc, ChatState>(
        'returns error when createCategory fails',
        build: buildBloc,
        setUp: () {
          when(
            () => mockGetCategories(
              userId: any(named: 'userId'),
              forceRefresh: any(named: 'forceRefresh'),
            ),
          ).thenAnswer(
            (_) async => const Right<Failure, List<CategoryEntity>>([]),
          );
          when(
            () => mockCreateCategory(any()),
          ).thenAnswer(
            (_) async =>
                const Left<Failure, CategoryEntity>(ServerFailure('DB error')),
          );
          when(
            () => mockSaveChatMessage(any()),
          ).thenAnswer(
            (_) async => const Right<Failure, void>(null),
          );
        },
        act: (bloc) => bloc.add(
          const ChatActionConfirmed({
            'actionType': 'category',
            'action': 'create',
            'name': 'Entertainment',
            'type': 'expense',
          }),
        ),
        expect: () => [
          isA<ChatLoaded>().having(
            (s) => s.messages.last.content,
            'create failed',
            contains('Failed to create category'),
          ),
        ],
      );

      blocTest<ChatBloc, ChatState>(
        'returns error when getCategories fails on delete',
        build: buildBloc,
        setUp: () {
          when(
            () => mockGetCategories(
              userId: any(named: 'userId'),
              forceRefresh: any(named: 'forceRefresh'),
            ),
          ).thenAnswer(
            (_) async => const Left<Failure, List<CategoryEntity>>(
              ServerFailure('Network error'),
            ),
          );
          when(
            () => mockSaveChatMessage(any()),
          ).thenAnswer(
            (_) async => const Right<Failure, void>(null),
          );
        },
        act: (bloc) => bloc.add(
          const ChatActionConfirmed({
            'actionType': 'category',
            'action': 'delete',
            'name': 'Food',
          }),
        ),
        expect: () => [
          isA<ChatLoaded>().having(
            (s) => s.messages.last.content,
            'find failed',
            contains('Failed to find category'),
          ),
        ],
      );

      blocTest<ChatBloc, ChatState>(
        'returns error when deleteCategory use case fails',
        build: buildBloc,
        setUp: () {
          when(
            () => mockGetCategories(
              userId: any(named: 'userId'),
              forceRefresh: any(named: 'forceRefresh'),
            ),
          ).thenAnswer(
            (_) async => const Right<Failure, List<CategoryEntity>>([
              CategoryEntity(
                id: 'cat-1',
                name: 'Food',
                icon: 58332,
                color: 4280391411,
                type: CategoryType.expense,
              ),
            ]),
          );
          when(
            () => mockDeleteCategory(any()),
          ).thenAnswer(
            (_) async =>
                const Left<Failure, void>(ServerFailure('Has children')),
          );
          when(
            () => mockSaveChatMessage(any()),
          ).thenAnswer(
            (_) async => const Right<Failure, void>(null),
          );
        },
        act: (bloc) => bloc.add(
          const ChatActionConfirmed({
            'actionType': 'category',
            'action': 'delete',
            'name': 'Food',
          }),
        ),
        expect: () => [
          isA<ChatLoaded>().having(
            (s) => s.messages.last.content,
            'delete failed',
            contains('Failed to delete category'),
          ),
        ],
      );

      blocTest<ChatBloc, ChatState>(
        'returns unknown category action for unrecognized action',
        build: buildBloc,
        setUp: () {
          when(
            () => mockSaveChatMessage(any()),
          ).thenAnswer(
            (_) async => const Right<Failure, void>(null),
          );
        },
        act: (bloc) => bloc.add(
          const ChatActionConfirmed({
            'actionType': 'category',
            'action': 'update',
          }),
        ),
        expect: () => [
          isA<ChatLoaded>().having(
            (s) => s.messages.last.content,
            'unknown action',
            'Unknown category action.',
          ),
        ],
      );
    });

    group('transaction action edge cases', () {
      blocTest<ChatBloc, ChatState>(
        'falls back to first account when name does not match',
        build: buildBloc,
        setUp: () {
          when(
            () => mockGetCategories(
              userId: any(named: 'userId'),
              forceRefresh: any(named: 'forceRefresh'),
            ),
          ).thenAnswer(
            (_) async => const Right<Failure, List<CategoryEntity>>([
              CategoryEntity(
                id: 'cat-1',
                name: 'Food',
                icon: 58332,
                color: 4280391411,
                type: CategoryType.expense,
              ),
            ]),
          );
          when(
            () => mockGetAccounts(
              userId: any(named: 'userId'),
              forceRefresh: any(named: 'forceRefresh'),
            ),
          ).thenAnswer(
            (_) async => Right<Failure, List<AccountEntity>>(
              [AccountFactory.checking(id: 'acc-fallback', name: 'Nubank')],
            ),
          );
          when(
            () => mockCreateTransaction(any()),
          ).thenAnswer(
            (_) async => Right<Failure, TransactionEntity>(
              TransactionEntity(
                id: 'tx-1',
                userId: userId,
                accountId: 'acc-fallback',
                categoryId: 'cat-1',
                type: TransactionType.expense,
                amount: 50,
                description: 'Lunch',
                date: DateTime(2024),
                createdAt: DateTime(2024),
                updatedAt: DateTime(2024),
              ),
            ),
          );
          when(
            () => mockSaveChatMessage(any()),
          ).thenAnswer(
            (_) async => const Right<Failure, void>(null),
          );
        },
        act: (bloc) => bloc.add(
          const ChatActionConfirmed({
            'actionType': 'transaction',
            'type': 'expense',
            'amount': 50.0,
            'category': 'Food',
            'account': 'NonexistentAccount',
            'description': 'Lunch',
          }),
        ),
        verify: (_) {
          final captured = verify(
            () => mockCreateTransaction(captureAny()),
          ).captured;
          final tx = captured.first as TransactionEntity;
          expect(tx.accountId, 'acc-fallback');
        },
        expect: () => [
          isA<ChatLoaded>().having(
            (s) => s.messages.last.content,
            'success',
            contains('created successfully'),
          ),
        ],
      );

      blocTest<ChatBloc, ChatState>(
        'returns error when createTransaction fails',
        build: buildBloc,
        setUp: () {
          when(
            () => mockGetCategories(
              userId: any(named: 'userId'),
              forceRefresh: any(named: 'forceRefresh'),
            ),
          ).thenAnswer(
            (_) async => const Right<Failure, List<CategoryEntity>>([
              CategoryEntity(
                id: 'cat-1',
                name: 'Food',
                icon: 58332,
                color: 4280391411,
                type: CategoryType.expense,
              ),
            ]),
          );
          when(
            () => mockGetAccounts(
              userId: any(named: 'userId'),
              forceRefresh: any(named: 'forceRefresh'),
            ),
          ).thenAnswer(
            (_) async => Right<Failure, List<AccountEntity>>(
              [AccountFactory.checking()],
            ),
          );
          when(
            () => mockCreateTransaction(any()),
          ).thenAnswer(
            (_) async => const Left<Failure, TransactionEntity>(
              ServerFailure('DB error'),
            ),
          );
          when(
            () => mockSaveChatMessage(any()),
          ).thenAnswer(
            (_) async => const Right<Failure, void>(null),
          );
        },
        act: (bloc) => bloc.add(
          const ChatActionConfirmed({
            'actionType': 'transaction',
            'type': 'expense',
            'amount': 50.0,
            'category': 'Food',
            'description': 'Lunch',
          }),
        ),
        expect: () => [
          isA<ChatLoaded>().having(
            (s) => s.messages.last.content,
            'create failed',
            contains('Failed to create transaction'),
          ),
        ],
      );

      blocTest<ChatBloc, ChatState>(
        'returns error when getCategories fails for transaction',
        build: buildBloc,
        setUp: () {
          when(
            () => mockGetCategories(
              userId: any(named: 'userId'),
              forceRefresh: any(named: 'forceRefresh'),
            ),
          ).thenAnswer(
            (_) async => const Left<Failure, List<CategoryEntity>>(
              ServerFailure('Network error'),
            ),
          );
          when(
            () => mockSaveChatMessage(any()),
          ).thenAnswer(
            (_) async => const Right<Failure, void>(null),
          );
        },
        act: (bloc) => bloc.add(
          const ChatActionConfirmed({
            'actionType': 'transaction',
            'type': 'expense',
            'amount': 50.0,
            'category': 'Food',
            'description': 'Lunch',
          }),
        ),
        expect: () => [
          isA<ChatLoaded>().having(
            (s) => s.messages.last.content,
            'categories failed',
            'Failed to load categories.',
          ),
        ],
      );

      blocTest<ChatBloc, ChatState>(
        'returns error when getAccounts fails for transaction',
        build: buildBloc,
        setUp: () {
          when(
            () => mockGetCategories(
              userId: any(named: 'userId'),
              forceRefresh: any(named: 'forceRefresh'),
            ),
          ).thenAnswer(
            (_) async => const Right<Failure, List<CategoryEntity>>([
              CategoryEntity(
                id: 'cat-1',
                name: 'Food',
                icon: 58332,
                color: 4280391411,
                type: CategoryType.expense,
              ),
            ]),
          );
          when(
            () => mockGetAccounts(
              userId: any(named: 'userId'),
              forceRefresh: any(named: 'forceRefresh'),
            ),
          ).thenAnswer(
            (_) async => const Left<Failure, List<AccountEntity>>(
              ServerFailure('Network error'),
            ),
          );
          when(
            () => mockSaveChatMessage(any()),
          ).thenAnswer(
            (_) async => const Right<Failure, void>(null),
          );
        },
        act: (bloc) => bloc.add(
          const ChatActionConfirmed({
            'actionType': 'transaction',
            'type': 'expense',
            'amount': 50.0,
            'category': 'Food',
            'description': 'Lunch',
          }),
        ),
        expect: () => [
          isA<ChatLoaded>().having(
            (s) => s.messages.last.content,
            'accounts failed',
            'Failed to load accounts.',
          ),
        ],
      );

      blocTest<ChatBloc, ChatState>(
        'uses DateTime.now when date string is invalid',
        build: buildBloc,
        setUp: () {
          when(
            () => mockGetCategories(
              userId: any(named: 'userId'),
              forceRefresh: any(named: 'forceRefresh'),
            ),
          ).thenAnswer(
            (_) async => const Right<Failure, List<CategoryEntity>>([
              CategoryEntity(
                id: 'cat-1',
                name: 'Food',
                icon: 58332,
                color: 4280391411,
                type: CategoryType.expense,
              ),
            ]),
          );
          when(
            () => mockGetAccounts(
              userId: any(named: 'userId'),
              forceRefresh: any(named: 'forceRefresh'),
            ),
          ).thenAnswer(
            (_) async => Right<Failure, List<AccountEntity>>(
              [AccountFactory.checking()],
            ),
          );
          when(
            () => mockCreateTransaction(any()),
          ).thenAnswer(
            (_) async => Right<Failure, TransactionEntity>(
              TransactionEntity(
                id: 'tx-1',
                userId: userId,
                accountId: 'acc-checking-1',
                categoryId: 'cat-1',
                type: TransactionType.expense,
                amount: 50,
                description: 'Lunch',
                date: DateTime.now(),
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
              ),
            ),
          );
          when(
            () => mockSaveChatMessage(any()),
          ).thenAnswer(
            (_) async => const Right<Failure, void>(null),
          );
        },
        act: (bloc) => bloc.add(
          const ChatActionConfirmed({
            'actionType': 'transaction',
            'type': 'expense',
            'amount': 50.0,
            'category': 'Food',
            'description': 'Lunch',
            'date': 'not-a-date',
          }),
        ),
        expect: () => [
          isA<ChatLoaded>().having(
            (s) => s.messages.last.content,
            'success with fallback date',
            contains('created successfully'),
          ),
        ],
      );
    });
  });
}
