import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/chat/domain/entities/chat_message_entity.dart';
import 'package:financo/features/chat/presentation/bloc/chat_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../harness/factories/chat_message_factory.dart';
import '../../../../harness/helpers.dart';
import '../../../../harness/mocks.dart';

/// Bloc-level tests focus on orchestration: history loading, message
/// dispatch, AI failure surfacing, action delegation, preflight rejection,
/// and audio transcription. Per-handler business logic (account creation,
/// category resolution, etc.) lives under
/// `test/features/chat/domain/action_handlers/` — keeping the bloc tests
/// fast and centred on flow rather than rule details.
void main() {
  late MockSendMessageUseCase mockSendMessage;
  late MockGetChatHistoryUseCase mockGetChatHistory;
  late MockSaveChatMessageUseCase mockSaveChatMessage;
  late MockTranscribeAudioUseCase mockTranscribeAudio;
  late MockAccountChatActionHandler mockAccountHandler;
  late MockCategoryChatActionHandler mockCategoryHandler;
  late MockTransactionChatActionHandler mockTransactionHandler;
  late MockTransferChatActionHandler mockTransferHandler;
  late MockBudgetChatActionHandler mockBudgetHandler;

  const userId = 'user-1';

  setUpAll(registerChatFallbackValues);

  setUp(() {
    mockSendMessage = MockSendMessageUseCase();
    mockGetChatHistory = MockGetChatHistoryUseCase();
    mockSaveChatMessage = MockSaveChatMessageUseCase();
    mockTranscribeAudio = MockTranscribeAudioUseCase();
    mockAccountHandler = MockAccountChatActionHandler();
    mockCategoryHandler = MockCategoryChatActionHandler();
    mockTransactionHandler = MockTransactionChatActionHandler();
    mockTransferHandler = MockTransferChatActionHandler();
    mockBudgetHandler = MockBudgetChatActionHandler();
    when(() => mockSaveChatMessage(any())).thenAnswer(
      (_) async => const Right<Failure, void>(null),
    );
  });

  ChatBloc buildBloc() => ChatBloc(
    sendMessage: mockSendMessage,
    getChatHistory: mockGetChatHistory,
    saveChatMessage: mockSaveChatMessage,
    transcribeAudio: mockTranscribeAudio,
    accountHandler: mockAccountHandler,
    categoryHandler: mockCategoryHandler,
    transactionHandler: mockTransactionHandler,
    transferHandler: mockTransferHandler,
    budgetHandler: mockBudgetHandler,
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
      expect: () => [const ChatLoading(), isA<ChatError>()],
    );
  });

  group('ChatMessageSent', () {
    blocTest<ChatBloc, ChatState>(
      'emits user bubble (typing) then AI response',
      build: buildBloc,
      setUp: () {
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
            .having((s) => s.messages.length, 'messages.length', 1),
        isA<ChatLoaded>()
            .having((s) => s.isTyping, 'isTyping', false)
            .having((s) => s.messages.length, 'messages.length', 2),
      ],
    );

    blocTest<ChatBloc, ChatState>(
      'emits error bubble on AI failure',
      build: buildBloc,
      setUp: () {
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
        isA<ChatLoaded>().having((s) => s.isTyping, 'isTyping', true),
        isA<ChatLoaded>().having(
          (s) => s.messages.last.role,
          'last role',
          ChatRole.assistant,
        ),
      ],
    );

    blocTest<ChatBloc, ChatState>(
      'appends rejection bubble when preflight returns error',
      build: buildBloc,
      setUp: () {
        when(
          () => mockSendMessage(
            userId: any(named: 'userId'),
            content: any(named: 'content'),
            history: any(named: 'history'),
          ),
        ).thenAnswer(
          (_) async => Right<Failure, ChatMessageEntity>(
            ChatMessageEntity(
              id: 'ai-1',
              userId: userId,
              role: ChatRole.assistant,
              content: 'Confirma o gasto?',
              metadata: const {
                'actionType': 'transaction',
                'amount': 50.0,
                'category': 'Mercado',
                'account': 'Nubank',
              },
              createdAt: DateTime(2026, 4, 18),
            ),
          ),
        );
        when(
          () => mockTransactionHandler.preflight(
            userId: any(named: 'userId'),
            meta: any(named: 'meta'),
            locale: any(named: 'locale'),
          ),
        ).thenAnswer((_) async => 'Categoria "Mercado" não existe.');
      },
      act: (bloc) => bloc.add(const ChatMessageSent('mercado 50')),
      expect: () => [
        isA<ChatLoaded>().having((s) => s.isTyping, 'isTyping', true),
        isA<ChatLoaded>()
            .having((s) => s.messages.length, 'messages.length', 3)
            .having(
              (s) => s.messages.last.metadata?['kind'],
              'rejection kind',
              'actionRejected',
            )
            .having(
              (s) => s.messages.last.metadata?['originActionId'],
              'originActionId',
              'ai-1',
            ),
      ],
    );

    blocTest<ChatBloc, ChatState>(
      'no rejection when preflight returns null',
      build: buildBloc,
      setUp: () {
        when(
          () => mockSendMessage(
            userId: any(named: 'userId'),
            content: any(named: 'content'),
            history: any(named: 'history'),
          ),
        ).thenAnswer(
          (_) async => Right<Failure, ChatMessageEntity>(
            ChatMessageEntity(
              id: 'ai-1',
              userId: userId,
              role: ChatRole.assistant,
              content: 'Confirma o gasto?',
              metadata: const {
                'actionType': 'transaction',
                'amount': 50.0,
                'category': 'Mercado',
                'account': 'Nubank',
              },
              createdAt: DateTime(2026, 4, 18),
            ),
          ),
        );
        when(
          () => mockTransactionHandler.preflight(
            userId: any(named: 'userId'),
            meta: any(named: 'meta'),
            locale: any(named: 'locale'),
          ),
        ).thenAnswer((_) async => null);
      },
      act: (bloc) => bloc.add(const ChatMessageSent('mercado 50')),
      expect: () => [
        isA<ChatLoaded>().having((s) => s.isTyping, 'isTyping', true),
        isA<ChatLoaded>()
            .having((s) => s.messages.length, 'messages.length', 2)
            .having(
              (s) => s.messages.last.metadata?['actionType'],
              'still a proposal',
              'transaction',
            ),
      ],
    );
  });

  group('ChatActionConfirmed', () {
    blocTest<ChatBloc, ChatState>(
      'transaction action sets shouldRefreshTransactions',
      build: buildBloc,
      setUp: () {
        when(
          () => mockTransactionHandler.handle(
            userId: any(named: 'userId'),
            meta: any(named: 'meta'),
            locale: any(named: 'locale'),
          ),
        ).thenAnswer((_) async => 'Transaction created!');
      },
      act: (bloc) => bloc.add(
        const ChatActionConfirmed(
          actionMessageId: 'msg-1',
          metadata: {'actionType': 'transaction'},
        ),
      ),
      expect: () => [
        isA<ChatLoaded>()
            .having(
              (s) => s.shouldRefreshTransactions,
              'shouldRefreshTransactions',
              true,
            )
            .having(
              (s) => s.messages.last.metadata?['kind'],
              'kind',
              'actionResult',
            )
            .having(
              (s) => s.messages.last.metadata?['originActionId'],
              'originActionId',
              'msg-1',
            ),
      ],
    );

    blocTest<ChatBloc, ChatState>(
      'budget action sets shouldRefreshBudgets',
      build: buildBloc,
      setUp: () {
        when(
          () => mockBudgetHandler.handle(
            userId: any(named: 'userId'),
            meta: any(named: 'meta'),
            locale: any(named: 'locale'),
          ),
        ).thenAnswer((_) async => 'Budget created');
      },
      act: (bloc) => bloc.add(
        const ChatActionConfirmed(
          actionMessageId: 'msg-1',
          metadata: {'actionType': 'budget'},
        ),
      ),
      expect: () => [
        isA<ChatLoaded>().having(
          (s) => s.shouldRefreshBudgets,
          'shouldRefreshBudgets',
          true,
        ),
      ],
    );

    blocTest<ChatBloc, ChatState>(
      'transfer action sets shouldRefreshTransactions',
      build: buildBloc,
      setUp: () {
        when(
          () => mockTransferHandler.handle(
            userId: any(named: 'userId'),
            meta: any(named: 'meta'),
            locale: any(named: 'locale'),
          ),
        ).thenAnswer((_) async => 'Transfer ok');
      },
      act: (bloc) => bloc.add(
        const ChatActionConfirmed(
          actionMessageId: 'msg-1',
          metadata: {'actionType': 'transfer'},
        ),
      ),
      expect: () => [
        isA<ChatLoaded>().having(
          (s) => s.shouldRefreshTransactions,
          'shouldRefreshTransactions',
          true,
        ),
      ],
    );

    blocTest<ChatBloc, ChatState>(
      'unknown actionType emits unknown action message',
      build: buildBloc,
      act: (bloc) => bloc.add(
        const ChatActionConfirmed(
          actionMessageId: 'msg-1',
          metadata: {'actionType': 'unknown'},
        ),
      ),
      expect: () => [
        isA<ChatLoaded>().having(
          (s) => s.messages.last.metadata?['kind'],
          'kind',
          'actionResult',
        ),
      ],
    );

    blocTest<ChatBloc, ChatState>(
      'save failure does not crash and state is still emitted',
      build: buildBloc,
      setUp: () {
        when(() => mockSaveChatMessage(any())).thenThrow(Exception('boom'));
      },
      act: (bloc) => bloc.add(
        const ChatActionConfirmed(
          actionMessageId: 'msg-1',
          metadata: {'actionType': 'unknown'},
        ),
      ),
      expect: () => [isA<ChatLoaded>()],
    );
  });

  group('ChatAudioTranscriptionRequested', () {
    blocTest<ChatBloc, ChatState>(
      'transcribe failure surfaces no message',
      build: buildBloc,
      setUp: () {
        when(
          () => mockTranscribeAudio(
            base64Data: any(named: 'base64Data'),
            mimeType: any(named: 'mimeType'),
          ),
        ).thenAnswer(
          (_) async => const Left<Failure, String>(AiFailure('asr down')),
        );
      },
      act: (bloc) => bloc.add(
        const ChatAudioTranscriptionRequested(
          base64Data: 'AAA',
          mimeType: 'audio/m4a',
        ),
      ),
      expect: () => [
        isA<ChatLoaded>().having(
          (s) => s.isTranscribing,
          'isTranscribing',
          true,
        ),
        isA<ChatLoaded>().having(
          (s) => s.isTranscribing,
          'isTranscribing',
          false,
        ),
      ],
    );

    blocTest<ChatBloc, ChatState>(
      'empty transcript drops back to idle without dispatching message',
      build: buildBloc,
      setUp: () {
        when(
          () => mockTranscribeAudio(
            base64Data: any(named: 'base64Data'),
            mimeType: any(named: 'mimeType'),
          ),
        ).thenAnswer((_) async => const Right<Failure, String>('   '));
      },
      act: (bloc) => bloc.add(
        const ChatAudioTranscriptionRequested(
          base64Data: 'AAA',
          mimeType: 'audio/m4a',
        ),
      ),
      verify: (_) => verifyNever(
        () => mockSendMessage(
          userId: any(named: 'userId'),
          content: any(named: 'content'),
          history: any(named: 'history'),
        ),
      ),
      expect: () => [
        isA<ChatLoaded>().having(
          (s) => s.isTranscribing,
          'isTranscribing',
          true,
        ),
        isA<ChatLoaded>().having(
          (s) => s.isTranscribing,
          'isTranscribing',
          false,
        ),
      ],
    );

    blocTest<ChatBloc, ChatState>(
      'non-empty transcript flows into ChatMessageSent path',
      build: buildBloc,
      setUp: () {
        when(
          () => mockTranscribeAudio(
            base64Data: any(named: 'base64Data'),
            mimeType: any(named: 'mimeType'),
          ),
        ).thenAnswer(
          (_) async => const Right<Failure, String>('gastei 30 reais'),
        );
        when(
          () => mockSendMessage(
            userId: any(named: 'userId'),
            content: any(named: 'content'),
            history: any(named: 'history'),
          ),
        ).thenAnswer(
          (_) async => Right<Failure, ChatMessageEntity>(
            ChatMessageFactory.assistant(content: 'ok'),
          ),
        );
      },
      act: (bloc) => bloc.add(
        const ChatAudioTranscriptionRequested(
          base64Data: 'AAA',
          mimeType: 'audio/m4a',
        ),
      ),
      verify: (_) => verify(
        () => mockSendMessage(
          userId: any(named: 'userId'),
          content: 'gastei 30 reais',
          history: any(named: 'history'),
        ),
      ).called(1),
    );
  });
}
