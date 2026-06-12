import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:financo/core/errors/exceptions.dart';
import 'package:financo/features/chat/data/datasources/chat_datasources.dart';
import 'package:financo/features/chat/domain/entities/chat_image_attachment.dart';
import 'package:financo/features/chat/domain/entities/chat_message_entity.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../harness/factories/chat_message_factory.dart';
import '../../../../harness/mocks.dart';

void main() {
  group('ChatBackendDataSourceImpl', () {
    late MockFirebaseFunctions functions;
    late MockHttpsCallable chatCallable;
    late MockHttpsCallable transcribeCallable;
    late ChatBackendDataSourceImpl datasource;

    const userId = 'user-1';

    setUp(() {
      functions = MockFirebaseFunctions();
      chatCallable = MockHttpsCallable();
      transcribeCallable = MockHttpsCallable();
      when(() => functions.httpsCallable('chatSend'))
          .thenReturn(chatCallable);
      when(() => functions.httpsCallable('transcribeChatAudio'))
          .thenReturn(transcribeCallable);
      datasource = ChatBackendDataSourceImpl(functions: functions);
    });

    void stubChatResponse(Map<Object?, Object?> data) {
      final result = MockHttpsCallableResult<Map<Object?, Object?>>();
      when(() => result.data).thenReturn(data);
      when(
        () => chatCallable.call<Map<Object?, Object?>>(any<dynamic>()),
      ).thenAnswer((_) async => result);
    }

    Map<String, dynamic> capturedPayload() => verify(
      () => chatCallable.call<Map<Object?, Object?>>(captureAny<dynamic>()),
    ).captured.single as Map<String, dynamic>;

    group('sendMessage', () {
      test('maps the callable response into an assistant message', () async {
        stubChatResponse({
          'id': 'srv-1',
          'content': 'All set!',
          'metadata': {'actionType': 'transaction', 'amount': 50},
        });

        final message = await datasource.sendMessage(
          userId: userId,
          content: 'add expense',
          history: const [],
        );

        expect(message.id, 'srv-1');
        expect(message.userId, userId);
        expect(message.role, ChatRole.assistant);
        expect(message.content, 'All set!');
        expect(message.metadata, {'actionType': 'transaction', 'amount': 50});
      });

      test('tolerates a response without content or metadata', () async {
        stubChatResponse({'id': 'srv-2'});

        final message = await datasource.sendMessage(
          userId: userId,
          content: 'hi',
          history: const [],
        );

        expect(message.content, isEmpty);
        expect(message.metadata, isNull);
      });

      test('sends the history with user/assistant roles', () async {
        stubChatResponse({'id': 'srv-3', 'content': 'ok'});

        await datasource.sendMessage(
          userId: userId,
          content: 'next question',
          history: [
            ChatMessageFactory.entity(content: 'how much did I spend?'),
            ChatMessageFactory.assistant(content: r'You spent R$ 10.'),
          ],
        );

        final payload = capturedPayload();
        expect(payload['content'], 'next question');
        expect(payload['history'], [
          {'role': 'user', 'content': 'how much did I spend?'},
          {'role': 'assistant', 'content': r'You spent R$ 10.'},
        ]);
      });

      test('strips app-generated action results from the history', () async {
        stubChatResponse({'id': 'srv-4', 'content': 'ok'});

        await datasource.sendMessage(
          userId: userId,
          content: 'hi',
          history: [
            ChatMessageFactory.entity(content: 'add it'),
            // Tagged action result — must not reach the AI or it starts
            // mimicking success text without emitting action blocks.
            ChatMessageFactory.withMetadata(
              metadata: const {'kind': 'actionResult'},
              content: 'Transaction created successfully!',
            ),
            // Legacy persisted result (pre-tag) caught by the regex.
            ChatMessageFactory.assistant(
              id: 'legacy',
              content: 'Transaction "Uber" created successfully!',
            ),
          ],
        );

        final history = capturedPayload()['history'] as List<dynamic>;
        expect(history, hasLength(1));
        expect((history.single as Map)['content'], 'add it');
      });

      test('reconstructs the action block from saved metadata', () async {
        stubChatResponse({'id': 'srv-5', 'content': 'ok'});

        await datasource.sendMessage(
          userId: userId,
          content: 'confirm',
          history: [
            ChatMessageFactory.withMetadata(
              metadata: const {
                'actionType': 'transaction',
                'kind': 'actionProposal',
                'amount': 50,
              },
              content: 'Confirm the expense?',
            ),
          ],
        );

        final history = capturedPayload()['history'] as List<dynamic>;
        final content = (history.single as Map)['content'] as String;
        // The Cloud Function strips blocks before persisting; the wrapper
        // must rebuild them so the AI keeps seeing its own past format.
        expect(content, startsWith('Confirm the expense?'));
        expect(content, contains('[TRANSACTION_DATA]'));
        expect(content, contains('"amount":50'));
        expect(content, contains('[/TRANSACTION_DATA]'));
        expect(content, isNot(contains('actionType')));
      });

      test('attaches the image payload when present', () async {
        stubChatResponse({'id': 'srv-6', 'content': 'ok'});

        await datasource.sendMessage(
          userId: userId,
          content: 'receipt',
          history: const [],
          image: const ChatImageAttachment(
            base64Data: 'aGVsbG8=',
            mimeType: 'image/png',
          ),
        );

        expect(capturedPayload()['image'], {
          'data': 'aGVsbG8=',
          'mimeType': 'image/png',
        });
      });

      test('wraps FirebaseFunctionsException into AiException', () async {
        final exception = MockFirebaseFunctionsException();
        when(() => exception.code).thenReturn('internal');
        when(() => exception.message).thenReturn('model overloaded');
        when(
          () => chatCallable.call<Map<Object?, Object?>>(any<dynamic>()),
        ).thenThrow(exception);

        expect(
          () => datasource.sendMessage(
            userId: userId,
            content: 'hi',
            history: const [],
          ),
          throwsA(isA<AiException>()),
        );
      });
    });

    group('transcribeAudio', () {
      test('returns the trimmed transcript and sends the audio payload',
          () async {
        final result = MockHttpsCallableResult<Map<Object?, Object?>>();
        when(() => result.data).thenReturn({'transcript': '  hello world  '});
        when(
          () => transcribeCallable.call<Map<Object?, Object?>>(any<dynamic>()),
        ).thenAnswer((_) async => result);

        final transcript = await datasource.transcribeAudio(
          base64Data: 'YXVkaW8=',
          mimeType: 'audio/m4a',
        );

        expect(transcript, 'hello world');
        final payload = verify(
          () => transcribeCallable.call<Map<Object?, Object?>>(
            captureAny<dynamic>(),
          ),
        ).captured.single as Map<String, dynamic>;
        expect(payload['audio'], {
          'data': 'YXVkaW8=',
          'mimeType': 'audio/m4a',
        });
      });

      test('wraps FirebaseFunctionsException into AiException', () async {
        final exception = MockFirebaseFunctionsException();
        when(() => exception.code).thenReturn('invalid-argument');
        when(() => exception.message).thenReturn('bad audio');
        when(
          () => transcribeCallable.call<Map<Object?, Object?>>(any<dynamic>()),
        ).thenThrow(exception);

        expect(
          () => datasource.transcribeAudio(
            base64Data: 'x',
            mimeType: 'audio/m4a',
          ),
          throwsA(isA<AiException>()),
        );
      });
    });
  });

  group('ChatRemoteDataSourceImpl', () {
    late FakeFirebaseFirestore firestore;
    late ChatRemoteDataSourceImpl datasource;

    const userId = 'user-1';

    setUp(() {
      firestore = FakeFirebaseFirestore();
      datasource = ChatRemoteDataSourceImpl(firestore: firestore);
    });

    test('saveChatMessage persists under the message id', () async {
      final message = ChatMessageFactory.model(
        metadata: {'actionType': 'transaction'},
      );

      await datasource.saveChatMessage(message);

      final doc =
          await firestore.collection('chat_messages').doc('msg-1').get();
      expect(doc.exists, isTrue);
      expect(doc.data()!['content'], message.content);
      expect(doc.data()!['role'], 'user');
      expect(doc.data()!['metadata'], {'actionType': 'transaction'});
    });

    test("getChatHistory returns only the user's messages, oldest first",
        () async {
      await datasource.saveChatMessage(
        ChatMessageFactory.model(
          id: 'msg-newer',
          content: 'second',
          createdAt: DateTime(2026, 6, 2),
        ),
      );
      await datasource.saveChatMessage(
        ChatMessageFactory.model(
          id: 'msg-older',
          content: 'first',
          createdAt: DateTime(2026, 6),
        ),
      );
      await datasource.saveChatMessage(
        ChatMessageFactory.model(
          id: 'msg-foreign',
          userId: 'user-2',
          content: 'not mine',
        ),
      );

      final history = await datasource.getChatHistory(userId: userId);

      expect(history.map((m) => m.content).toList(), ['first', 'second']);
    });
  });
}
